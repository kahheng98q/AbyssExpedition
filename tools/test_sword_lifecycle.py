"""Non-empty cross-version lifecycle coverage and comparison guards."""
import copy
import unittest
import sword_identity_compare as contract


class LifecycleTests(unittest.TestCase):
    def setUp(self):
        self.record = {
            'fixture': {'start_tick': 7190, 'end_tick': 7550, 'xp_pickup': 100, 'termination': 'queued_lethal_damage'},
            'metadata': {'seed': 101},
            'states': [{'tick': t, 'phase': 'active', 'level': 2} for t in range(7190, 7551)],
            'final': {'tick': 7550, 'phase': 'results', 'level': 2},
            'trace': {'start': {'catalog': 'same'}, 'offers': [{'id': 1, 'options': ['might']}], 'decisions': [{'offer': 1, 'upgrade': 'might'}],
                      'events': [{'offer': {'id': 1, 'tick': 7200, 'kind': 'forbidden_altar'}}, {'id': 1, 'tick': 7200, 'choice': 'decline'}]},
            'initial_profile': {'owned': {'aren': {'total_xp': 1400}}},
            'profile_after': {'owned': {'aren': {'total_xp': 1440}}, 'receipt': {'result': {'kind': 'settlement'}}},
            'summary': {'outcome': 'defeat', 'ticks': 7550, 'seed': 101},
            'save': {'before_revision': 2, 'revision': 3, 'settlement_count': 1, 'state': 'ready'},
        }
        self.record['save']['round_trip_payload'] = copy.deepcopy(self.record['profile_after'])

    def validate(self, record):
        # The old comparison accepted empty lifecycle coverage: behavioral red.
        getattr(contract, 'validate_lifecycle', lambda record: None)(record)

    def test_complete_path(self):
        self.validate(self.record)

    def test_missing_required_behaviors(self):
        for key in ('offers', 'decisions', 'events'):
            with self.subTest(key=key):
                bad = copy.deepcopy(self.record); bad['trace'][key] = []
                with self.assertRaises(AssertionError): self.validate(bad)

    def test_missing_event_choice(self):
        bad = copy.deepcopy(self.record); bad['trace']['events'].pop()
        with self.assertRaises(AssertionError): self.validate(bad)

    def test_early_end(self):
        bad = copy.deepcopy(self.record); bad['final']['tick'] = 7200
        with self.assertRaises(AssertionError): self.validate(bad)

    def test_unsettled_run(self):
        bad = copy.deepcopy(self.record); bad['final']['phase'] = 'active'
        with self.assertRaises(AssertionError): self.validate(bad)

    def test_missing_or_duplicate_settlement(self):
        for count in (0, 2):
            bad = copy.deepcopy(self.record); bad['save']['settlement_count'] = count
            with self.assertRaises(AssertionError): self.validate(bad)

    def test_save_revision_and_roundtrip(self):
        for key, value in (('revision', 2), ('state', 'save-blocked'), ('round_trip_payload', {})):
            bad = copy.deepcopy(self.record); bad['save'][key] = value
            with self.assertRaises(AssertionError): self.validate(bad)

    def test_rewards_not_applied(self):
        bad = copy.deepcopy(self.record); bad['profile_after']['owned']['aren']['total_xp'] = 1400
        bad['save']['round_trip_payload'] = copy.deepcopy(bad['profile_after'])
        with self.assertRaises(AssertionError): self.validate(bad)

    def test_invalid_choice(self):
        bad = copy.deepcopy(self.record); bad['trace']['decisions'][0]['upgrade'] = 'unoffered'
        with self.assertRaises(AssertionError): self.validate(bad)

    def test_result_and_unknown_fields_are_compared(self):
        for field in ('summary', 'save', 'profile_after', 'fixture', 'unknown'):
            bad = copy.deepcopy(self.record); bad[field] = 'changed'
            self.assertTrue(contract.differences(contract.project(copy.deepcopy(self.record), {}), contract.project(bad, {})))

    def test_skipped_active_ticks(self):
        bad = copy.deepcopy(self.record); bad['states'][10]['tick'] += 30
        with self.assertRaises(AssertionError): self.validate(bad)

    def test_invalid_event_choice(self):
        bad = copy.deepcopy(self.record); bad['trace']['events'][1]['choice'] = 'unoffered'
        with self.assertRaises(AssertionError): self.validate(bad)


if __name__ == '__main__':
    unittest.main()
