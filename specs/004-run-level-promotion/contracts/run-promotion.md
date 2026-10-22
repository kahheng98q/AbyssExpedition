# Run promotion contract

`PromotionService.reason(run, hero_id, branch="")`: no mutation; active run, deployed living member, level>=15, unpromoted, branch belongs to base. `apply(run,id,branch)` returns bool; no profile access; records branch, rebuilds stats/passive/upgrades/contracts, preserves HP ratio and all health flags/counters/cooldown.

ChoiceCoordinator owns `promotion_id`, `promotion_hero`, `promotion_token`, deferred state. `present` refuses concurrent event/rescue/upgrade/promotion. At idle chooses eligible member then upgrades. `confirm_promotion(run,nonce,hero,branch)` rejects stale/duplicate/invalid; traces valid actions then hands off in stable order. `cancel_promotion` defers remaining promotions, releases only its own token, advances upgrade queue. `request_promotion` clears deferral and queues request behind any current choice. Exit cancels all choices without recording fake decisions.

Promotion page has optional live run + offer nonce; absent run means read-only gallery. Existing two-branch previews/stop/occlusion/focus behavior retained. Run submit uses coordinator and generation guards; Cancel leaves a visible HUD Promotion button when eligible. Main menu/roster gallery cannot commit. Debug page uses same live service in sandbox, existing action IDs preserved; materials aliases eligibility with honest label. Test-branch remains explicit debug bypass.

Late joins: new identity enters BASE with current shared RUN level and stacks; coordinator schedules eligibility next boundary. A previously promoted identity reuses its run branch and cannot get a second confirmation. Downed actors stay down and are excluded.
