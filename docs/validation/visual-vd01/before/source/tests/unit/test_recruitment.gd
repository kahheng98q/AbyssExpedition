extends RefCounted

class Controlled:
	extends RefCounted
	var values: Array = []
	var index: int = 0
	func draw(_rng) -> int:
		var value = values[index % values.size()]
		index += 1
		return value

func run(t) -> void:
	var p = ProfileData.fresh()
	p["tickets"] = 10
	var provider = Controlled.new()
	provider.values = [0, 1]
	var candidate = RecruitmentService.candidate(p, 10, "test-draw", provider)
	t.check(not candidate.is_empty(), "ten pull produces an atomic recruitment candidate")
	if candidate.is_empty(): return
	t.check(candidate.tickets == 0 and candidate.tokens == 8 and candidate.owned.size() == 5, "ten ordered pulls acquire two heroes and convert eight duplicates")
	t.check(p.tickets == 10 and p.owned.size() == 3, "candidate does not change committed input")
	t.check(candidate.history[0].results[0].hero == "brann" and candidate.history[0].results[1].hero == "nyra", "integer intervals zero Brann / one Nyra")
	for balance in [0, 1, 9, 10]:
		p.tickets = balance
		t.check(RecruitmentService.candidate(p, 10, "batch", provider).is_empty() == (balance < 10), "ten pull ticket boundary " + str(balance))
		t.check(RecruitmentService.candidate(p, 1, "single", provider).is_empty() == (balance < 1), "single pull ticket boundary " + str(balance))
	for owned in [[], ["brann"], ["nyra"], ["brann", "nyra"]]:
		for sequence in [[0], [1], [0, 1]]:
			p = ProfileData.fresh()
			p.tickets = 10
			for id in owned: p.owned[id] = OwnedHero.record(id)
			provider = Controlled.new()
			provider.values = sequence
			candidate = RecruitmentService.candidate(p, 10, "distribution", provider)
			var newly = 0
			var tentative = owned.duplicate()
			for result in candidate.history[0].results:
				var duplicate = tentative.has(result.hero)
				t.check(result.duplicate == duplicate and result.tokens == (1 if duplicate else 0), "ordered conversion against tentative ownership")
				if not duplicate:
					tentative.append(result.hero)
					newly += 1
			t.check(candidate.tokens == 10 - newly and candidate.owned.size() == 3 + tentative.size(), "reward distribution for each ownership/outcome combination")
	# Statistical verification of the real generator and pool mapping, fixed before sampling.
	var rng = DrawRng.restore(DrawRng.initial("20261015"))
	var brann = 0
	var samples = 200000
	var pool: GachaPoolDefinition = load("res://data/gacha/guild_pool.tres")
	for i in range(samples):
		if pool.hero_at(DrawRng.draw(rng)) == "brann": brann += 1
	var chi_square = 4.0 * pow(brann - samples / 2.0, 2) / samples
	print("DRAW STATISTICS: seed=20261015 n=%d Brann=%d Nyra=%d chi-square=%.6f (df=1, cutoff=10.828)" % [samples, brann, samples - brann, chi_square])
	t.check(chi_square < 10.828, "real draw distribution passes preselected 0.1% chi-square test")
	# Check independent ten-pull distribution through the actual candidate service.
	var stream = DrawRng.initial("20261016")
	var histogram = []
	histogram.resize(11)
	histogram.fill(0)
	var reward_totals_valid = true
	var batches = 8192
	for sample in range(batches):
		p = ProfileData.fresh()
		p.tickets = 10
		p.draw_rng = stream.duplicate(true)
		candidate = RecruitmentService.candidate(p, 10, "statistical-batch")
		stream.state = candidate.draw_rng.state
		var count = 0
		for result in candidate.history[0].results:
			if result.hero == "brann": count += 1
		histogram[count] += 1
		if candidate.tokens + candidate.owned.size() - 3 != 10: reward_totals_valid = false
	var binomial = [1, 10, 45, 120, 210, 252, 210, 120, 45, 10, 1]
	var batch_chi = 0.0
	for i in range(11):
		var expected = batches * binomial[i] / 1024.0
		batch_chi += pow(histogram[i] - expected, 2) / expected
	print("TEN-PULL STATISTICS: seed=20261016 batches=%d histogram=%s chi-square=%.6f (df=10, cutoff=29.588)" % [batches, histogram, batch_chi])
	t.check(batch_chi < 29.588, "ten independent pulls follow preselected binomial distribution test")
	t.check(reward_totals_valid, "all 8192 actual ten-pull candidates conserve new heroes plus duplicate rewards")
	for entry in pool.entries: t.check(entry.probability(pool.total_weight()) == 0.5, "displayed odds derived from actual integer weights")
	for tokens in [4, 5, 6]:
		p = ProfileData.fresh()
		p.tokens = tokens
		candidate = TokenExchangeService.candidate(p, "brann")
		t.check(candidate.is_empty() == (tokens < 5), "exchange balance boundary " + str(tokens))
		if not candidate.is_empty():
			t.check(candidate.tokens == tokens - 5 and candidate.owned.brann.level == 1 and TokenExchangeService.candidate(candidate, "brann").is_empty(), "exchange spends five once and rejects already-owned hero")
	t.check(TokenExchangeService.candidate(p, "sera").is_empty(), "Sera excluded from exchange")
	# Split generation/reopen must continue the exact same stream.
	var saved = DrawRng.initial("9223372036854775807")
	rng = DrawRng.restore(saved)
	for i in range(17): DrawRng.draw(rng)
	saved.state = str(rng.state)
	var restored = DrawRng.restore(JSON.parse_string(JSON.stringify(saved)))
	var equal = true
	for i in range(100):
		if DrawRng.draw(rng) != DrawRng.draw(restored): equal = false
	t.check(equal, "64-bit decimal state roundtrip preserves next draws")
	for bad in ["9223372036854775808", "1.5", "01", "", 123, "-9223372036854775809"]:
		t.check(not DrawRng.decimal(bad), "invalid or overflowing decimal state rejected " + str(bad))
