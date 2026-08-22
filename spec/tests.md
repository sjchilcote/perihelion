# Test contracts

This specfile contains the program operation shown by the Python tests and the full repository check. The active set contains 642 named test functions in 77 Python test modules. A `Trace` list names each function, and the previous text states its tested operation and measured results.

A satisfactory test shows only the inputs, made examples, time limits, tolerances, and environment used by its module. It does not test all possible inputs. An error that code does not catch is a failure. A test for an error is satisfactory only when the specified error occurs.

## Python test execution

### Goal

Give the same results for equal program conditions, data files, platform boundaries, media output, and performance limits.

### Invariants

- Run a module from the repository directory with `uv run pytest -q game/tests/<module>.py`. Run the default Python selection with `uv run pytest -q game/tests`. The repository configuration uses 18 processes and does not run tests marked `slow`. Run all marks with `uv run pytest -q -m "" game/tests`.

- `Pytest` runs each parameter value as a different condition. `Hypothesis` makes the stated number and range of examples. A failure in one condition gives the test function a failure result.

- The tests must use a compatible `necore` extension and the libraries in the repository environment. Some tests also use external programs, output `assets`, fitted data, or an audio device. Those items must be available for these tests.

- Tests that change `SDL` configuration or `PERIHELION_INTERNAL_RES` make the change before they import program code. Use a different `pytest` process when a different initial value is part of the test condition.

- Temporary `pytest` paths are removed by `pytest`. The stream and economy helpers use `mkdtemp` and do not remove those directories from the system temporary directory.

- `Feature`-demo tests can replace files in `media/features`. `Mypy` tests can replace `out/mypy_frame_fixture`. `Mindmap` tests use `game/tests/__pbtcache__`, and music tests can make and remove `game/tests/__pbtcache__/stems.json`. Do not at the same time run tests that write to the same repository path.

### Verification

`Pytest` reports each collected condition. A zero process result means that each selected condition without `skip` had no failure. It gives no information about conditions with `skip` or conditions that were not selected.

The code has 9 calls to `pytest.skip` and 3 module-level `skipif` marks:

- 4 Audio `Bank` test functions can `skip` a parameter condition when no output WAV file is available.

- Two `Gauntlet` Calibration conditions `skip` when there is no fitted model or `full-density` `batch`.

- `Mypy` Frame Types `skips` when `mypy` is not available.

- 4 `Platform` Contracts mixer tests use the same `skip` helper when no audio device is available.

- Render Headless `skips` when the installed `necore` build cannot use Raster functions.

- `Feature` Demos has a module mark that `skips` its 4 parameter conditions unless `PERIHELION_FEATURE_DEMOS=1`.

- `Root Invariance` and `Render Textures` have module marks that `skip` their modules when the installed `necore` build cannot use Raster functions.

Decision open (see item `TEST-SKIP-POLICY` in `spec/open-questions.md`): which of these `skip` results can occur in the standard check, and which check must reject the others?

### Implementation

The modules make small sessions and levels, load program data, run deterministic simulation ticks, examine NumPy frames, or call external programs. Test helpers decrease duplicate configuration. Assertions examine returned values, written state, emitted events, pixels, media metadata, timing records, or specified errors.

Source code boundary tests examine imports and names only when the condition is about source structure.

### Caveats

- Disk-found level and Python-file sets change when files are added or removed.
- `Hypothesis` can replay kept regression examples in addition to its set examples.
- Time and media test results can change with the system, installed tools, and build profile stated by their module.
- The `Adversary`-return, hub-shell, and `scout` production tests calculate `levels/gauntlet4.json` from each test module's absolute path. Their level access does not change with the process start directory.

## `Adversary`, signal, and coordination operation

### Goal

Show that enemy groups see, send signals, attack, retreat, return, and hold the player through the portal graph. They must use only state from the specified interfaces.

### Invariants

- An attack is permitted only when its range, portal distance, line of view, body state, and faction conditions are correct.

- Signals decay and spread by their named conditions. A sealed connection stops transfer.

- Body removal, death, return, and `census` records stay different events.

- `Scout` bodies, garrisons, callers, and other `adversary` functions send data through the stated signal or channel interfaces.

- A `captor` does not write player HP. Damage while the player is held comes from the `captor` system.

### Verification

#### `Adversary` Arsenal — `game/tests/test_adversary_arsenal.py`

The module puts `vagrant` entities and targets in the same `polygon` or on opposite sides of portals. It shows `lob` and snare selection, range bands, aim in front of a target that changes position, and movement after a bounce. It also shows knockback, the end of the slow effect, entity data for a hit, and the source recorded for a kill. A `projectile` cannot damage its source or charge one body 2 times.

`Trace`:
`test_a_cross_portal_lob_is_aimed_and_connects`, `test_a_distant_cross_chamber_player_is_not_fired_on`, `test_the_knockback_pushes_away_across_a_portal`, `test_the_lob_is_heavy_slow_and_large_enough_to_be_the_push`, `test_the_lob_survives_the_wall_it_bounces_off`, `test_the_bands_do_not_overlap`, `test_inside_the_lob_band_the_snare_is_never_chosen`, `test_an_adversary_that_is_not_fleeing_never_fires`, `test_the_snare_is_chosen_at_middle_range_and_slows_the_player`, `test_the_snare_wears_off`, `test_an_expired_snare_does_not_lend_its_strength_to_the_next`, `test_the_same_chamber_case_still_works`, `test_the_thrown_object_shoves_a_testator_too`, `test_a_crossfire_kill_is_attributed_apart_from_a_player_kill`, `test_a_round_never_damages_the_body_that_loosed_it`, `test_one_throw_bills_a_body_once`, `test_the_snare_leads_a_moving_target`, `test_a_thrown_round_never_damages_its_own_thrower`, `test_one_thrown_round_damages_a_body_at_most_once`.

#### `Adversary` Return — `game/tests/test_adversary_return.py`

The module removes and returns bodies through live breaches. It shows the `recovery` interval, `jitter` and protection time for each body, and conditions that monitor or cause an exit. It also shows states during a breach crossing. The tests make sure that the system absorbs bodies with no route and keeps permanent kills, sound, and telemetry correct. A seal of the same breach removes returns that are not complete, while a seal of a different breach does not.

`Trace`:
`test_withdrawn_adversary_returns_through_a_live_breach`, `test_return_needs_a_live_breach`, `test_recovery_is_not_instant`, `test_a_kill_is_permanent`, `test_recovery_constant_is_a_real_delay`, `test_arrival_has_its_own_tell`, `test_a_returned_body_cannot_immediately_go_home_again`, `test_pacing_is_jittered_not_a_metronome`, `test_arrival_grace_is_sampled_per_body`, `test_a_sealed_breach_takes_its_returns_with_it`, `test_an_unrelated_seal_leaves_a_grace_alone`, `test_a_stranded_return_is_reabsorbed_where_it_stands`, `test_a_departure_never_pops_while_the_player_is_watching`, `test_a_forced_departure_outranks_the_camera`, `test_a_finished_body_crosses_where_the_membrane_is_thin`, `test_crossing_needs_stillness_not_just_arrival`, `test_a_watched_body_will_not_cross`, `test_the_crossing_has_its_own_voice`, `test_the_crossing_cue_is_a_real_asset`, `test_a_departure_is_legible_in_the_trace_alone`.

#### Alarm and Dread — `game/tests/test_alarm_and_dread.py`

The module samples `distress`, noise, `scent`, and risk at their boundary values. It shows that one signal condition can make an agent engage without a peer signal. A new trail can replace a beacon. Bodies near it decrease `dread`. A body with no peers moves in the direction opposite a weapon that it can see for a limited time.

Inactive bodies stay inactive. A view emits `distress` in the `polygon` where it occurred.

`Trace`:
`test_an_alarm_does_not_need_a_vote`, `test_gunfire_alone_is_enough_to_commit_an_agent`, `test_a_fresh_scent_beats_the_beacon_that_led_you_to_it`, `test_scent_lock_needs_a_trail_that_is_actually_fresh`, `test_numbers_override_dread`, `test_a_lone_body_flees_a_gun_it_can_see`, `test_the_flight_is_bounded_and_cannot_re_arm_itself`, `test_the_danger_mark_is_a_level_not_a_running_total`, `test_dormant_bodies_are_not_frightened_out_of_their_ambush`, `test_sighting_the_player_dumps_distress_where_it_happened`.

#### Coordination Telemetry — `game/tests/test_coord_telemetry.py`

The module runs a `prowl` in a field with no events and a hold log. It shows movement after a `prowl` event and checks that engage/end records do not show state changes that last one tick.

`Trace`:
`test_prowl_fires_and_moves_on_a_quiet_field`, `test_hold_ledger_reports_no_single_tick_flutter`.

#### Coordination — `game/tests/test_coordination.py`

The module checks the fraction of peers that engage and how frequently bodies engage in a `polygon` with a small number of bodies. It checks doorway priority, route selection, `stand-down` timing, and risk holds. It also checks attack-group body counts, weapon-fire cascades, and release from a `hunt` with no result in `polygons` that have one door. A source check rejects a second procedure that makes bodies active and `pursuit` that does not use senses.

`Trace`:
`test_quorum_fraction_exact_values`, `test_sparse_rooms_flip_at_least_twice_as_often`, `test_priority_budget_never_averages_into_the_doorframe`, `test_choose_route_fans`, `test_stand_down_rule_is_exact`, `test_danger_hold_rule`, `test_no_parallel_wake_or_omniscient_pursuit`, `test_raid_flag_demographics`, `test_stand_down_exits_hunt_at_300_quiet_ticks`, `test_danger_hold_at_a_deadly_doorway`, `test_gunfire_two_hops_away_starts_a_cascade`, `test_one_door_hunt_stands_down_instead_of_grinding`.

#### Coordination Boundaries — `game/tests/test_coordination_boundaries.py`

The module sets equality boundaries for the signal condition that uses no peer signal. It also sets them for `dread`, `scent` lock, the fraction of peers that engage, risk, `stand-down`, risk hold, and `settlement`. It checks specified pull values, acceleration allocation, separation vectors, and correct selection of the second route. The `settlement` function expands into 6 parameter conditions.

`Trace`:
`test_alarm_and_dread_boundaries`, `test_scent_lock_boundaries`, `test_hunt_attraction_exact_values`, `test_quorum_excitation_and_hazard_boundaries`, `test_acceleration_budget_uses_priority_magnitude_and_direction`, `test_separation_request_exact_vectors`, `test_stand_down_and_danger_hold_equalities`, `test_settlement_truth_table`, `test_route_choice_uses_only_a_valid_second_route_for_raid_members`.

#### Garrisons — `game/tests/test_garrisons.py`

The module shows `settlement` at the hold boundary, the requirement for a `warden`, and continued `settlement` after that `warden` goes. It also checks that `warden` records have no command fields. It tests signal distance and internal signal conditions and makes sure that view with no portal between the bodies makes them active.

`Trace`:
`test_settlement_lands_at_the_hold_boundary`, `test_no_warden_no_settlement_and_persistence_after_departure`, `test_warden_record_never_grows_command_fields`, `test_lone_holder_marks_reach_pair_holds_interior`, `test_settled_agents_ignore_the_field_quorum_but_wake_on_sight`.

#### Gate 56 blockers — `game/tests/test_gate56_blockers.py`

The module supplies sent flickers and callers. It then checks tag removal, continued `lurking`, and one of 2 results after send. The body returns to inactive state or continues its `hunt` after view. Counts for killed, missing, and removed bodies stay different.

`Trace`:
`test_dispatched_flicker_sheds_its_tag`, `test_dispatched_flicker_still_lurks_once_delivered`, `test_undispatched_flicker_is_untouched`, `test_delivered_caller_returns_to_rest`, `test_delivered_caller_that_sees_the_player_keeps_hunting`, `test_kill_and_withdrawal_are_different_entries`, `test_withdrawal_books_as_withdrawn_not_killed`.

#### `Scout` Authoring — `game/tests/test_scout_authoring.py`

The module loads the specified `scout` `census` and `home` polygons and makes sure that each `home` can contain a breach. It checks that `core` production does not include `scout` bodies. An inactive `scout` does not move or become active below the noise threshold. `Combat` near it or damage to it makes it active.

`Trace`:
`test_gauntlet4_authors_the_scout_census`, `test_every_scout_home_can_hold_a_breach`, `test_the_core_never_produces_scouts`, `test_dormant_scout_sleeps_until_the_fight_arrives`, `test_below_threshold_noise_does_not_wake`, `test_shooting_a_dormant_scout_wakes_it`.

#### `Scouts` — `game/tests/test_scouts.py`

The module shows one communication holder, transfer after holder death, one dry call, and class priority. It checks one active sender from 2 `lacuna` entities, constant position and transmit timing, and no movement. It also checks records that include the `polygon` and a stop caused by damage. The `scouts` module must obey its import boundary.

`Trace`:
`test_imprint_carries_nothing_for_the_marrow`, `test_one_lease_and_holder_death_handoff`, `test_dry_call_is_consumed_once_never_queued`, `test_scouts_module_boundary`, `test_weakest_class_calls_first`, `test_two_lacunae_only_one_ever_transmits`, `test_rooted_broadcast_timing_and_stillness`, `test_imprint_names_the_body_chamber`, `test_damage_interrupts_and_census_is_permanent`.

#### Shrieker Mark — `game/tests/test_shrieker_mark.py`

The module moves a `shrieker` through `sentinel`, warning, `approach`, mark, `rally`, and `stand-down` operation. It checks view and damage that the `shrieker` receives, `home` travel, and differences between weapon fire and calls. It also tests one sent mark, and removal and decay of a mark. Other checks test doorway trails, `glob` movement in view, send, and the end of the wait timer.

`Trace`:
`test_a_sentinel_screams_only_after_it_has_seen_the_intruder`, `test_sighting_starts_warning_and_first_hand_screams`, `test_rouse_leaves_other_shriekers_alone`, `test_marking_locks_and_fires_a_marker_that_brands`, `test_brand_decays_on_its_own`, `test_branded_crossing_lays_the_doorway_trail`, `test_the_glob_reads_on_a_standing_body`, `test_the_glob_trails_behind_a_moving_body`, `test_home_is_the_post_not_wherever_it_happened_to_see_him`, `test_warning_actually_travels_home_before_approaching`, `test_a_firefight_next_door_sends_it_looking_but_never_screaming`, `test_the_door_hears_gunfire_not_cries`, `test_a_crowd_alone_is_not_a_call`, `test_a_dispatched_caller_marches_delivers_and_only_then_posts`, `test_being_shot_is_first_hand_and_does_cry`, `test_approach_stands_down_when_its_patience_runs_out`.

#### Signals — `game/tests/test_signals.py`

The module checks 9 signal types and rejects a time lower than the previous time, unknown `polygons`, and neighborhoods deeper than one hop. Trail decays by 50 percent each 12 seconds, while risk decays by 50 percent each 180 seconds. Decay does not change with update `frequency`. Spread conditions are different for each signal. A disconnect occurs in the same tick. Other checks test doorway trails that transmit in one direction, one drain capacity for all signals, and emissions from live combat.

`Trace`:
`test_exactly_nine_kinds`, `test_time_backwards_and_unknown_chamber_raise`, `test_neighborhood_deeper_than_one_hop_raises`, `test_trail_half_life_is_12s`, `test_danger_half_life_is_180s`, `test_decay_is_update_frequency_invariant`, `test_distress_spreads_at_its_stated_rate`, `test_noise_spreads_fast_and_wide`, `test_danger_never_spreads`, `test_disconnect_stops_transfer_immediately`, `test_muster_attenuates_steeply_per_hop`, `test_one_hop_neighborhood_never_shows_two_hops`, `test_garrison_interior_needs_two_fronts`, `test_doorway_trail_is_directed_capped_and_fades`, `test_drain_capacity_is_shared_across_all_nine`, `test_sim_emissions_follow_the_fight`.

#### Signal Boundaries — `game/tests/test_signal_boundaries.py`

The module checks the initial tick, zero totals, and emission totals in the same tick. It checks the default neighborhood of one hop and a view at depth zero of only its polygon. A topology update must replace cached adjacency after the world disconnects its polygons.

`Trace`:
`test_initial_tick_and_total_are_observable`, `test_neighborhood_default_and_zero_depth`, `test_topology_refresh_replaces_adjacency`.

#### `Warden` Engulf — `game/tests/test_warden_engulf.py`

The module checks one `captor` for each `captive`, release in the same tick, two warning flashes, and a lunge at 2.5 times normal speed. It also checks that front contact holds the player and side contact does not. The tests check 75 hp of damage each second, damage while fire points in the opposite direction, and release after `captor` death. Source checks make sure that player fire code has no `warden` branch and that `warden` AI does not write player hp.

`Trace`:
`test_player_fire_code_has_no_warden_check`, `test_warden_ai_never_touches_player_hp`, `test_one_captor_per_captive_and_same_tick_release`, `test_charge_flashes_twice_then_lunges_at_2_5x`, `test_head_on_captures_and_costs_75_per_second`, `test_glancing_hit_does_not_capture`, `test_firing_away_still_wounds_the_captor_and_kill_releases`.

### Implementation

These tests build small portal graphs or load specified levels. They run a constant number of simulation ticks, examine enemy records and signal samples, and drain sound or telemetry events. They use deterministic seeds for tests of random timing or `placement`.

### Caveats

- The tests show selected enemy types, graph shapes, thresholds, and time windows. They do not show all pairs of enemy and level.
- Source code boundary checks show the examined import and name conditions, not all possible forms of access through a different unit.

## `Combat`, world systems, and economy

### Goal

Show that `combat` impulse values, damage, bodies, the hub, production, `salvage`, `fabricator` operations, thought progress, and `sentries` keep their stated state and total conditions.

### Invariants

- Damage and impulse use the weapon and body data. Damage paths do not write the simulation velocity.
- Death, `salvage` drops, `corpse` `recovery`, `fabricator` results, and written state keep the totals that their tests track.
- Hub agents, the `core` `organ`, `marrow` production, `cloisters`, and `sentries` stay standard world systems with specified boundaries.
- Deterministic tests use the same seed, level, inputs, and tick sequence for the two runs.

### Verification

#### Cloister — `game/tests/test_cloister.py`

The module collects a `core` and builds its isolated small polygon with two `guardian` bodies. It crosses the live connection in each direction, shows how those bodies attack enemies that follow, and transfers `cloister` state into the next level.

`Trace`:
`test_core_pickup_builds_pocket_with_guardians`, `test_link_enter_exit_and_rotation`, `test_guardians_kill_pursuers`, `test_cloister_carries_between_levels`.

#### `Combat` Canon — `game/tests/test_combat_canon.py`

The module checks each weapon that causes damage for positive impulse and searches damage paths for writes to velocity. It shows that the `warden` is a standard enemy with 168 hp and checks the calculation from impulse and mass. It shows a kill with 4 `rail` projectiles and a kill with 2 charged `tau` projectiles. It also checks a charged `tau` area limit near 20 units and `projectile` impulse data. Last, it compares enemy speed and turn limits with the player's.

`Trace`:
`test_every_damaging_weapon_pushes`, `test_no_velocity_writes_in_damage_paths`, `test_warden_is_a_normal_enemy`, `test_every_kind_heavier_and_turn_limited`, `test_impulse_mass_law_exact`, `test_four_rail_shots_kill_a_warden`, `test_two_full_charge_tau_kill_a_warden`, `test_full_tau_aoe_reaches_20u_not_60u`, `test_bullet_weapons_carry_their_impulse`, `test_every_kind_outruns_the_commando_by_its_ratio`, `test_everything_turns_worse_than_the_commando`.

#### Containment — `game/tests/test_containment.py`

The module moves an enemy not in its polygon and shows `recovery`. A normal-play run must finish with zero containment `recovery` events.

`Trace`:
`test_escaped_enemy_is_recovered`, `test_normal_play_never_triggers_recovery`.

#### Core Organ — `game/tests/test_core_organ.py`

The module checks the specified `organ` in each world, no master hp bar or `blackout` timer, and weapon-quantized part damage. It shows an increase in the send interval after the `collar` is removed and source repair after 10 seconds with no `combat`. It also tests hp increase from `caretaker` contact, damage that continues after `caretaker` death, `blackout` after 3 source deaths, and the next `reform`. A source check rejects `organ` animation by a caller.

`Trace`:
`test_every_world_embodies_the_exact_organ`, `test_no_blackout_timer_and_no_master_bar`, `test_part_hp_is_weapon_quantized`, `test_collar_deaths_stretch_dispatch_immediately`, `test_source_knits_only_after_ten_quiet_seconds`, `test_caretaker_contact_heals_and_its_death_makes_damage_stick`, `test_three_source_deaths_are_the_blackout_and_reform_follows`, `test_no_caller_can_animate_an_organ`.

#### Corpse Economy — `game/tests/test_corpse_economy.py`

`Hypothesis` makes held component and `station`-kit totals. The module shows equal totals for a normal death, `protected revival`, and an operation that drops and gets the items again.

`Trace`:
`test_drop_conserves_totals_normal_case`, `test_drop_conserves_totals_protected_revival`, `test_drop_then_retrieve_round_trips_exactly`.

#### Economy and Thought — `game/tests/test_economy.py`

The module checks `salvage` drops, `wallet` pickup, more than one `corpse` frame, full `recovery`, `fabricator` costs, and results for rejected `fabricator` requests. It also tests `station` `placement`, `shop` interaction, cold `restore`, and the condition with no `chassis` at start. It checks `mindmap` data, `prereq` and frontier conditions, field progress, an end that occurs only in the `pod`, and `combat` effects. More checks test kept `protected revival` value, deterministic kept progress, `recall` end and stop, and the `protected revival` protection window.

`Trace`:
`test_kill_drops_salvage_worth_score`, `test_components_pickup_adds_to_wallet`, `test_death_drops_corpse_and_zeroes_carried_salvage`, `test_multiple_corpses_accumulate`, `test_corpse_retrieval_returns_contents_exactly`, `test_no_chassis_prints_at_the_starting_pod`, `test_fabricator_prices_and_purchases`, `test_fabricator_refuses_when_broke`, `test_place_station_consumes_kit_and_anchors_here`, `test_interact_at_station_opens_shop`, `test_cold_restore_preserves_corpses_and_does_not_refund`, `test_mindmap_data_integrity`, `test_set_focus_prereqs_and_refusals`, `test_thinking_accrues_in_field_and_unlock_waits_for_pod`.
`test_dead_frames_do_not_think`, `test_reveal_unlock_admits_neighbors`, `test_mindmap_effects_wire_into_combat`, `test_protected_revival_banks_salvage`, `test_mind_rides_state_snapshots`, `test_thinking_survives_death_and_reprint`, `test_thinking_survives_cold_restore`, `test_thinking_state_roundtrips_player_state`, `test_thinking_is_deterministic`, `test_recall_channel_completes_at_the_seed`, `test_recall_severed_by_damage`, `test_recall_refuses_without_beacon`, `test_protected_revival_grants_a_grace_window`, `test_no_grace_window_without_the_rite`.

#### Gate 53 blockers — `game/tests/test_gate53_blockers.py`

The module shows that a separation request with no effect gives control only when the group does not move apart. It records a `grip` as the source of a `grip` kill and checks that telemetry samples stay after `hitstop` and death.

`Trace`:
`test_a_keep_apart_demand_that_keeps_nothing_apart_yields`, `test_the_yield_does_not_fire_while_a_crowd_is_spreading`, `test_the_grip_records_itself_as_the_killer`, `test_the_instrument_samples_survive_a_hitstop`, `test_the_instrument_samples_survive_death`.

#### Grip across a doorway — `game/tests/test_grip_across_a_doorway.py`

The module holds the player across a portal and shows that fire at zero range and charged `tau` damage the `captor` in its `polygon`. If there is no coordinate route, the `captor` releases the player. Coordinate transfer returns no value and does not make a transform when there is no route.

`Trace`:
`test_point_blank_fire_into_a_cross_chamber_captor_lands`, `test_the_charged_tau_discharges_into_a_cross_chamber_captor`, `test_a_captor_with_no_route_is_released_rather_than_pulled_nowhere`, `test_the_carry_declines_rather_than_guessing`.

#### Portable hole and `tau` — `game/tests/test_hole_tau.py`

The module puts two hole marks, checks the new `corridor` and its traversal, and checks its width against `brute`, `mite`, and `projectile` dimensions. It also tests primary `tau` `ricochet`, charge use, charged fire, and player damage from `overcharge`.

`Trace`:
`test_portable_hole_links_two_walls`, `test_hole_corridor_excludes_brutes_admits_mites`, `test_tau_primary_ricochets_and_charged_shot_fires`, `test_tau_overcharge_bites`.

#### Hub Residents — `game/tests/test_hub_residents.py`

The module compares the `census` of agents that live in the hub with the `placement` table approved by the user. It shows a lighter mix than the group sent from the hub. It checks each output world and checks specified `polygon` `placement` and standard agent records. It does not include these hub agents in the world-side snapshot and checks the output hub light metadata.

`Trace`:
`test_resident_composition_is_the_ratified_table`, `test_the_hub_reads_lighter_than_what_it_sends`, `test_every_world_houses_the_residents`, `test_residents_live_in_their_authored_chambers`, `test_residents_are_ordinary_agents_not_organs`, `test_residents_stay_out_of_the_worldside_snapshot`, `test_hub_lights_itself_at_build`.

#### `Marrow` — `game/tests/test_marrow.py`

The module checks the `marrow` import boundary and that a breach contains no `reserve` or state from a related breach. It shows `reserve` fill and decrease, `debt` `recovery`, waits for the selected unit, and a limit on cost differences. It also shows a body go through an opening at scale one, close causes, and that a closed breach can become active again. Other checks show a protection interval during `exhaustion` and a first call from the `shelf`.

`Trace`:
`test_marrow_module_is_blind`, `test_breach_stores_no_reserve_and_no_siblings`, `test_regen_rates_full_empty_and_debt`, `test_the_stall_waits_for_the_selected_unit`, `test_cost_fair_scheduler_bounds_the_skew`, `test_physical_entry_through_a_scale_1_gate`, `test_closure_no_route_then_idle_rearm_then_exhaustion`, `test_first_call_leads_with_the_shelf_later_calls_do_not`.

#### `Marrow` Shelf — `game/tests/test_marrow_shelf.py`

The module checks the 20-body attack cycle approved by the user and the production sequence used again for each cycle. It also checks that each new `guardian` decreases `reserve` and obeys its `cadence`. The tests stop new `guardian` bodies during a `pour` or `exhaustion`. They check `court` `placement` and one body that knows the send target for each 10 sends. More checks make sure that the first record contains the send target, the `shelf` has fast output, and production continues.

`Trace`:
`test_strike_cycle_is_the_ratified_mix`, `test_production_rotation_walks_the_cycle`, `test_replacements_cost_reserve_and_respect_the_cadence`, `test_no_replacement_during_a_pour_or_while_exhausted`, `test_sim_posts_the_replacement_body_in_a_court`, `test_only_every_tenth_dispatched_body_knows_the_site`, `test_first_body_of_a_pour_always_knows`, `test_the_shelf_bursts_and_production_sustains`.

#### `Sentry` Turret — `game/tests/test_sentry_turret.py`

The module shows target damage in range and line of view, no target more than the maximum range or behind terrain, and no player damage. It also shows target selection around occlusion, deterministic firing, and `sentry` defense in two `gauntlet` `pursuit` conditions.

`Trace`:
`test_sentry_damages_enemy_in_range_and_los`, `test_sentry_ignores_enemy_out_of_range`, `test_sentry_never_damages_player`, `test_sentry_blocked_by_terrain_between_it_and_target`, `test_sentry_kills_same_target_once_terrain_is_removed`, `test_sentry_prefers_farther_visible_target_over_nearer_occluded_one`, `test_sentry_is_deterministic`, `test_gauntlet_loot_polygon_kills_what_follows_the_player_in`, `test_gauntlet_pursued_into_loot_polygon_dies_to_sentry`.

### Implementation

These modules use small deterministic sessions, specified hub and `gauntlet` data, `fabricator` and interaction calls, constant tick loops, state snapshots, and event drains. Property tests make economy totals and compare them after the complete operation.

### Caveats

- Defect: `test_first_body_of_a_pour_always_knows` contains a condition equivalent to `dispatch_target is present or true`. It thus gives a satisfactory result for each body without a check for the `dispatch_target` field. Other event checks show that the first record has `dispatch_target` data. Decision open (see item `MARROW-DISPATCH-TARGET` in `spec/open-questions.md`): must the first body also have a send target?
- Numeric `combat` and `cadence` results apply to the active weapon, enemy, and schedule data.

## Engine boundaries, coordinates, perception, and telemetry

### Goal

Show that the engine and Python layers keep coordinate spaces, portal transforms, perception limits, telemetry sequence, and system boundaries.

### Invariants

- Each position, direction, offset, transform, and view names its coordinate space. Operations reject incompatible spaces.
- Perception follows the portal graph and returns reports, not simulation objects that callers can write.
- Telemetry accepts only writes during play, keeps sequence and tick sequence, and uses the same event `schema` in the `app` and `harness`.
- The renderer does not connect to telemetry, simulation stays free of pygame and file `I/O`, and audio is not a telemetry source.

### Verification

#### Architecture Boundaries — `game/tests/test_architecture_boundaries.py`

The module examines imports. It limits telemetry to the standard library and rejects a renderer connection to telemetry. It keeps simulation free of pygame and file `I/O`. It also limits senses and signals to the standard library and engine and rejects an audio `dependency` on telemetry.

`Trace`:
`test_telemetry_imports_stdlib_only`, `test_renderer_cannot_subscribe_to_telemetry`, `test_sim_stays_pygame_and_io_free`, `test_senses_import_only_stdlib_and_engine`, `test_signals_import_only_stdlib_and_engine`, `test_audio_is_not_a_trace_source`.

#### Camera Phase Lock — `game/tests/test_camera_phase_lock.py`

The module records camera and smoothed camera transforms during standard ticks and portal transfers. It checks that the linear part is identity, integer translation at transfer, and no step larger than 0.5 pixel. It also checks correct origin correction and that transforms agree across spans. World-aligned frames must agree at 97 percent or more of the same positions.

`Trace`:
`test_phase_lock_non_transfer_ticks`, `test_phase_lock_transfer_ticks_follow_step_is_integer`, `test_drift_bound_over_long_wander`, `test_transfer_rebase_is_exact`, `test_no_half_pixel_step_at_transfer`, `test_phase_lock_transitive_across_spans`, `test_world_aligned_frames_across_crossing`.

#### Coordinate Spaces — `game/tests/test_coordinate_spaces.py`

The module subtracts, moves, transforms, `spawns`, views, and reconciles values in one coordinate space and across coordinate spaces. Operations with incompatible coordinate spaces make `FrameMismatch`, `TypeError`, or no route. Correct positions and directions use complete portal transforms and keep direction length. The module also checks camera conversion between `polygon` and screen space and record-only reconciliation.

`Trace`:
`test_two_bodies_in_different_chambers_refuse_to_be_subtracted`, `test_two_bodies_in_the_same_chamber_subtract_freely`, `test_a_sighting_arrives_in_the_observers_own_space`, `test_a_place_crossing_a_rotating_doorway_moves_by_the_whole_matrix`, `test_a_direction_crossing_a_rotating_doorway_turns_and_keeps_its_length`, `test_a_transform_refuses_a_value_from_the_wrong_space`, `test_track_velocity_and_facing_ride_the_sightings_own_route`, `test_python_cannot_conjure_a_place_without_naming_its_space`, `test_an_offset_is_free_because_a_decision_is_not_a_claim`, `test_writes_refuse_an_offset_from_another_chamber`, `test_spawning_takes_a_place_so_polygon_and_position_cannot_disagree`, `test_develop_answers_none_for_the_screen_because_no_doorway_reaches_it`, `test_a_screen_point_and_a_chamber_point_meet_through_the_camera`, `test_reconciliation_uses_records_and_never_the_world`.

#### Frame Timing — `game/tests/test_frame_timing.py`

The module puts named phase durations into a window with constant duration. It checks one record when the window closes and none before it closes. It keeps phase-local work and maximum frame duration different from the mean, and does not include idle time in work. It also tests simulation `debt`, errors for unknown phases and windows with length zero, and the encoded `frame_timing` event.

`Trace`:
`test_a_window_publishes_exactly_one_record`, `test_nothing_is_published_before_the_window_closes`, `test_a_phase_that_burns_time_is_the_phase_that_reports_it`, `test_worst_is_the_worst_frame_not_the_mean`, `test_voluntary_idle_is_not_counted_as_work`, `test_sim_ticks_expose_a_loop_falling_behind_the_clock`, `test_an_unknown_phase_is_refused_at_the_mark`, `test_it_serializes_onto_the_session_bus_like_every_other_record`, `test_a_window_of_zero_is_refused`.

#### `Mypy` Frame Types — `game/tests/test_mypy_frame_types.py`

The module writes a fixture for `mypy` and calls `mypy`. The fixture must accept correct `place` and `difference` operations and report that they cannot be used together.

`Trace`:
`test_mypy_settles_the_place_versus_difference_split`.

#### Necore Smoke — `game/tests/test_necore_smoke.py`

The module tests transfer, `visibility`, `ray` queries, matrix composition, inverse matrices, and engine error types. It checks kept speed after a polygon change and correct instance records. It also checks a ray hit through a portal and direction use with no translation. A polygon with 0, 1, or 2 vertices or an unknown entity makes `ValueError`.

`Trace`:
`test_transfer_preserves_speed_and_changes_polygon`, `test_visible_set_returns_sane_instances`, `test_raycast_crosses_portal_and_hits_far_wall`, `test_mat_helpers_roundtrip`, `test_errors_are_value_errors`.

#### Perception graph search — `game/tests/test_perception_searches_the_graph.py`

The module searches for entities in a faction through portals. It checks faction selection, range and hop limits, and occlusion along the line of view. It keeps a live held target and releases one after death. An empty neighborhood makes no result. Other `population` or group records do not change the result or its cost.

`Trace`:
`test_it_returns_the_nearest_of_the_faction`, `test_it_never_returns_another_faction`, `test_range_excludes_a_body_the_graph_can_reach`, `test_the_hop_cap_bounds_how_deep_it_looks`, `test_a_body_behind_another_body_is_not_the_nearest_sighted_one`, `test_a_held_target_is_kept_over_a_closer_one`, `test_a_dead_held_target_does_not_blind_the_search`, `test_an_empty_neighbourhood_answers_nothing`, `test_the_cost_does_not_follow_the_worlds_population`, `test_the_crowd_does_not_change_the_answer_either`.

#### Seamless engine runs — `game/tests/test_seamless.py`

The module runs `corridor`, `loop`, `doorway-wobble`, and `mirror-approach` `scenarios` through the engine. Each `scenario` must finish without the discontinuity specified for it, and transfers must not make a brightness seam.

`Trace`:
`test_seamless_corridor_walk`, `test_seamless_infinite_loop_walk`, `test_seamless_doorway_wobble`, `test_seamless_mirror_approach`, `test_no_brightness_seam_across_transfers`.

#### Senses — `game/tests/test_senses.py`

The module checks read-only tracks without object references, the agreed tag names, and a frame limit of one hop. It tests targeted view deeper than the frame that is not more than the view cap. It also tests occlusion not in the view angle and at a closed door. It checks tag search with the nearest result first, different route images with the shortest first, and `combat` through the senses interface.

`Trace`:
`test_a_track_is_a_read_only_report_carrying_no_object_references`, `test_tags_are_one_agreed_vocabulary`, `test_frame_deeper_than_one_hop_raises`, `test_one_hop_visible_enemy_appears_two_hop_absent_from_frame`, `test_off_axis_body_one_hop_away_is_not_seen`, `test_targeted_sight_runs_deeper_than_the_frame`, `test_sight_respects_the_vision_cap`, `test_sealed_door_reads_as_wall_until_unlocked`, `test_find_searches_by_tag_and_answers_nearest_first`, `test_every_route_enumerates_distinct_images_shortest_first`, `test_engagement_flows_through_the_senses`.

#### Telemetry — `game/tests/test_telemetry.py`

The module rejects missing event fields and all query surfaces on the `bus`. Sequence numbers always increase, and ticks do not decrease. It shows specified event counts in a 120-tick `scenario`, equal `app` and `harness` `schemas`, and one `JSON` record on each line in sequence.

`Trace`:
`test_events_reject_missing_fields`, `test_bus_has_no_query_surface`, `test_seq_strictly_increases_and_tick_never_decreases`, `test_120_tick_vector_exact_counts`, `test_app_and_harness_schemas_identical`, `test_writer_output_parses_and_orders`.

### Implementation

The tests make specified coordinate spaces and portal transforms. They use engine calls for `visibility` and rays, examine Python import graphs, give timing samples, and drain telemetry records. The `mypy` test calls an external static checker against an output fixture.

### Caveats

- The `mypy` test can `skip` with the same `skip` `policy` when `mypy` is not available.
- Import checks examine the source forms used by their inspection helpers. They do not find imports made at runtime.

## Levels, editor, hub geometry, and streaming

### Goal

Show that source and output levels are correct, have all necessary routes, have correct indexes, and are safe to write. They load terrain and streamed chunks without incorrect state changes.

### Invariants

- Level polygons have correct winding and convex geometry. Connections use correct polygon and edge indexes.
- The player can get a key before its gate, and program key metadata stays the same after load and write.
- Editor changes form complete undo steps and do not write incorrect data.
- Each streamed chunk keeps its polygon offset, entry state, and walk mask.

### Verification

#### Level Editor — `game/tests/test_editor.py`

The module loads `l01`, moves and removes polygons, updates the indices of connections and source objects, and checks complete undo. It makes a polygon, connection, key metadata, terminal, and entity. It then writes and reloads a level that the program can run. It rejects incorrect entities and polygons with 0, 1, or 2 vertices.

Removal of a vertex removes its connections. The module rejects incorrect convexity, winding, missing endpoints, and edges used 2 times. It accepts a `self-mirror` edge and keeps the last correct model after a malformed load.

`Trace`:
`test_load_l01`, `test_move_polygon_moves_verts_and_entities`, `test_move_polygon_is_a_single_undo_step`, `test_delete_polygon_reindexes_everything`, `test_delete_polygon_clears_player_when_its_polygon_is_deleted`, `test_delete_polygon_reindexes_terminals_and_radio_triggers`, `test_add_polygon_connect_save_loads_and_runs`, `test_key_metadata_survives_editor_round_trip`, `test_undo_restores_exact_prior_dict`, `test_convexity_violation_blocks_save`, `test_wrong_winding_blocks_save`, `test_missing_player_or_exit_blocks_save`, `test_double_used_edge_blocks_save`, `test_self_mirror_connect_is_not_a_double_use_conflict`, `test_add_entity_rejects_unspawnable_type`, `test_delete_entity_and_terminal`, `test_delete_vertex_drops_bound_connections_not_others`, `test_delete_vertex_refuses_below_triangle`, `test_load_malformed_file_does_not_crash_or_clobber_state`.

#### `Gauntlet` Level — `game/tests/test_gauntlet_level.py`

The module loads the output `gauntlet` and its metadata. It checks a route through all areas not in the isolated hub and checks that there are no keys or gates. Segments `A` through `F` have enemy lists that are not empty. Enemies occur only in `combat` regions.

7 `loot` polygons each contain health or `ammo` and one `sentry`. 14 long, safe `corridors` put the player and exit polygons at opposite ends.

`Trace`:
`test_structure_loads_and_is_traversable`, `test_gauntlet_has_no_keys_or_gates`, `test_six_segments_present_with_enemy_rosters`, `test_enemies_only_in_combat_zones`, `test_loot_polygons_carry_health_and_ammo`, `test_loot_polygons_each_have_one_sentry`, `test_corridors_are_long_and_safe`, `test_player_and_exit_at_opposite_ends`.

#### Hub Shells — `game/tests/test_hub_shells.py`

The module examines each output `polygon` shell. It checks convex shapes with no duplicates or rectangles, edge length that can hold each doorway, all portal routes, and source depths of 10 or 11 crossings. It checks that no new `polygon` with one door is made and all source systems stay contained. Breach width equals the specified width, and the depth gradient is complete. It also tests `corruption` that only increases, the type change at depth 6, lighting `crossfade`, different `marrow` `props`, and `otherworld` `props` that change with depth. No prop generator makes a closed loop.

`Trace`:
`test_every_chamber_is_a_one_off_convex_shell`, `test_no_chamber_is_a_rectangle`, `test_every_doorway_has_a_palate_long_enough_to_seat_it`, `test_the_portal_graph_survives_the_reshape`, `test_the_sources_stay_ten_or_eleven_crossings_deep`, `test_no_new_one_door_chambers`, `test_every_landed_system_still_stands_inside_its_chamber`, `test_the_breach_seams_are_exactly_breach_width`, `test_the_gradient_reaches_every_chamber`, `test_corruption_rises_monotonically_with_depth`, `test_the_kind_switches_at_depth_six_and_not_before`, `test_the_lighting_model_arrives_on_a_crossfade`, `test_the_marrow_has_its_own_prop_vocabulary`, `test_the_otherworld_generator_reads_its_descent`, `test_no_prop_generator_emits_a_closed_ring`.

#### Hub Topology — `game/tests/test_hub_topology.py`

The module checks scale-one connection of equal 96-unit edges. It rejects edges that are not equal before it makes the portal and again at the scale check in the lower layer. Edge identifiers stay stable after code divides an edge. Each world contains one isolated 24-`polygon` hub and deep source cells that are apart. The module also checks the specified transept loop and trunk distances. About 50 percent of the floor area is in the first 3 bands, and signal fields increase with the hub.

`Trace`:
`test_connect_equal_glues_96_to_96_at_scale_1`, `test_mismatched_lengths_refused_before_any_portal_exists`, `test_even_without_the_length_check_the_scale_assert_kills_it`, `test_edge_handles_survive_later_splits`, `test_every_world_builds_one_unreachable_hub`, `test_source_cells_are_deep_and_separate`, `test_transept_loop_and_trunk`, `test_half_the_floor_area_sits_in_the_first_three_bands`, `test_signal_fields_grew_with_the_hub`.

#### Topology Contracts — `game/tests/test_topology_contracts.py`

The module checks stable, different edge identifiers and index changes after code divides an edge. `Carve` and connect operations call the callback only after the operation ends with a satisfactory result. Connection of equal edges returns its connection. An incorrect calculated scale disconnects the source edge. Different edge lengths make no connection and report the 2 lengths.

`Trace`:
`test_adopt_assigns_stable_distinct_handles`, `test_split_updates_only_later_handles_in_the_same_polygon`, `test_carve_forwards_arguments_and_notifies_only_on_success`, `test_connect_returns_endpoints_and_notifies`, `test_bad_derived_scale_disconnects_the_source_edge`, `test_length_error_names_both_lengths_without_connecting`.

#### Level Winding — `game/tests/test_level_winding.py`

`Hypothesis` puts a polygon with incorrect winding at different indices. A correctly wound polygon loads. Each polygon with incorrect winding raises a `ValueError` that names the bad polygon.

`Trace`:
`test_well_wound_polygon_loads_cleanly`, `test_reversed_winding_polygon_is_rejected_loudly`, `test_reversed_winding_is_caught_in_any_polygon_position`.

#### Product Levels — `game/tests/test_levels.py`

The module checks the 10-entry campaign manifest, output level structure, structural references, and access to keys before gates. It also tests key metadata through write and load and text in the simulation world. More checks test operations that divide doorway edges and solid walls when no connection is requested.

`Trace`:
`test_campaign_exists_and_generator_runs`, `test_level_structure`, `test_keys_reachable_before_their_doors`, `test_key_meta_round_trips_through_save_and_load`, `test_every_shipped_key_has_diegetic_metadata`, `test_doorway_splitter_makes_doorways`, `test_no_connect_keeps_walls_solid`.

#### `Marathon` Map Read — `game/tests/test_marathon_mapread.py`

The module loads the recorded `WAD` fixture for a space with 5 dimensions. It shows the specified level, polygon, line, point, and player start counts. It also shows clockwise convex polygons, line and polygon references in the 2 directions, and positive doorway-scale portal widths.

`Trace`:
`test_known_level_facts`, `test_polygons_are_convex_clockwise`, `test_lines_and_polygons_cross_reference`, `test_portal_widths_are_door_scale`.

#### Stream — `game/tests/test_stream.py`

The module starts a stream of 2 chunks. It checks load when necessary at the `spine`, and local `conversation` data and keys for each chunk. It checks the exit that becomes enabled after the second chunk. It also checks the last completed state and respawn at the active chunk entry with initial hp and kept world bodies.

`Trace`:
`test_stream_lazy_load_arrival_and_completion`, `test_stream_respawn_at_chunk_entry`.

#### Walk-mask Terrain — `game/tests/test_walk_mask_terrain.py`

The module compares the repository `PNG` `decoder` with a Pillow reference and rejects an incorrect header or dimension mismatch. A missing mask or empty level id stays fully `walkable` without disk access. The module installs the mask as polygon-local terrain, blocks player and `projectile` movement, and loads a different mask for an added chunk.

`Trace`:
`test_decoder_matches_pil_reference`, `test_decoder_rejects_bad_signature`, `test_absence_of_mask_file_means_fully_walkable`, `test_level_with_no_level_id_never_touches_disk`, `test_walk_mask_installs_matching_polygon_local_rect`, `test_walk_mask_blocks_player_movement`, `test_walk_mask_blocks_projectiles`, `test_walk_mask_size_mismatch_fails_loudly`, `test_append_chunk_loads_its_own_walk_mask`.

#### Walk-mask Clearance Gate — `game/tests/test_walkmask_clearance_gate.py`

The module checks a clearance margin equal to one player radius or more. A channel with small width has point `connectivity` but does not have clearance. A wide channel has `connectivity` and clearance. `Erosion` decreases without an increase, is the identity at zero radius, and keeps a mask with only `false` values.

`Trace`:
`test_clearance_radius_is_at_least_one_player_radius_margin`, `test_narrow_channel_passes_plain_connectivity_but_fails_clearance`, `test_wide_channel_passes_both_gates`, `test_erode_walkable_shrinks_and_never_grows`, `test_erode_walkable_zero_radius_is_identity`, `test_erode_walkable_all_false_stays_false`.

### Implementation

The editor tests change `JSON`-compatible dictionaries in memory and use temporary output paths. Level tests load program `JSON`, made dictionaries, one `WAD` fixture, and `PNG` masks. Hub tests make the code-made hub and examine geometry, topology, `props`, lighting metadata, and signal fields.

### Caveats

- Program file checks test the files found at test time. A new file changes the results set.
- The `WAD` reader results applies to the included fixture and its recorded counts.

## Narrative scenes and `mindmap`

### Goal

Show that `conversation` data, objective text, `pod` interaction, thought `layout`, selection, and `reveal` animation show the specified information and keep progress.

### Invariants

- Specified empty `conversation` spaces stay empty. Correct `synthetic` `conversation` data moves through each line.
- Objective prompts use specified key metadata when it is available and a constant fallback if not.
- `Mindmap` `layout` is deterministic for the same graph and seed. It keeps nodes in their depth bands and local labels in their `placement` limits.
- A `reveal` applies its unlock at the start, controls its camera until the end, and returns all temporary audio `ducking` to its previous value.

### Verification

#### Conversation Scene — `game/tests/test_convscene.py`

The module checks that each empty space has no `conversation` and rejects an empty or unknown speaker. It moves through `synthetic` `conversation` data with more than one line until the scene closes and applies its `trust` callback.

`Trace`:
`test_every_gap_is_silent_until_the_directors_scripts`, `test_scene_rejects_empty_or_unknown_speaker`, `test_scene_plays_synthetic_lines_to_completion`.

#### `Mindmap` `Layout` — `game/tests/test_mindmap_layout.py`

The module checks output and program graphs for `canvas` bounds, deterministic `layout`, local labels that do not overlap, node-disc clearance, and node adjacency. It checks `visibility` at different scales and region nodes that stay together. It also checks a decrease in crossing count, depth bands, radial position differences, and live trajectories that stay in bounds. More checks test recorded inactive states for active fixtures, deterministic live relaxation, and the specified camera end position. They also test the camera view at a large target scale.

`Hypothesis` reads graph dimensions and example counts from `PERIHELION_PBT_*` environment values. Defaults keep the standard run small.

`Trace`:
`test_geometry_within_bounds`, `test_layout_deterministic`, `test_local_labels_never_overlap`, `test_local_labels_clear_of_node_discs`, `test_local_labels_adjacent_to_their_node`, `test_local_labels_lod_law`, `test_local_labels_deterministic`, `test_local_zoom_reference_and_scaling`, `test_region_cohesion`, `test_crossings_relaxed_never_worse_than_seed`, `test_crossings_bounded_for_sparse_graphs`, `test_crossings_batch_substantial_reduction`, `test_real_mindmap_local_labels_every_camera`, `test_real_mindmap_within_bounds`, `test_real_mindmap_deterministic`, `test_real_mindmap_region_cohesion`, `test_real_mindmap_trajectory_reaches_final_frame`, `test_real_mindmap_crossings`.
`test_relax_respects_depth_annulus`, `test_real_mindmap_relax_respects_annulus`, `test_rest_never_rides_band_boundary`, `test_live_sleep_never_rides_band_boundary`, `test_real_mindmap_radial_variance_within_bands`, `test_live_rest_respects_annulus_at_sleep`, `test_live_trajectory_never_leaves_annulus`, `test_live_rest_open_reaches_exact_bitwise_rest`, `test_live_rest_from_seed_reaches_exact_bitwise_rest`, `test_live_relax_deterministic`, `test_camera_glide_exact_arrival_and_static_after`, `test_camera_glide_zero_duration_snaps`, `test_camera_glide_deterministic`, `test_target_scale_fixture_shape`, `test_target_scale_bands_hold`, `test_target_scale_local_framing`, `test_target_scale_local_labels`, `test_target_scale_live_physics_leashed`.

#### Objective Text — `game/tests/test_objective.py`

The module checks that one prompt is shown while the player stays against a locked exit or doorway. It also tests that the prompt can be shown again after the player is no longer against it. Other checks test `warden`-holder text and gate text from metadata or fallback data. More checks test pickup text from metadata or fallback data and the `tau-cannon` pickup message. `Radio` data raises an error, and no `radio-strip` surface stays.

`Trace`:
`test_exit_locked_shows_seal_prompt_once_while_standing`, `test_exit_locked_prompt_rearms_after_walking_away`, `test_exit_gated_by_warden_names_the_holder`, `test_exit_locked_prompt_uses_key_metadata`, `test_key_pickup_with_metadata_names_the_object`, `test_key_pickup_without_metadata_falls_back_to_seal`, `test_locked_door_bump_shows_gate_prompt_once`, `test_locked_door_bump_without_metadata_falls_back`, `test_weapon_pickup_emits_acquired_prompt`, `test_radio_authoring_raises`, `test_no_radio_strip_surface_exists`.

#### Pod Scene — `game/tests/test_podscene.py`

The module checks first entry at the `fabricator`, hp gain, `purchase` operations, image fallback, and fog-of-war `visibility`. It tests unlock at the start of a `reveal`, a sequence of `reveal` operations, and `skip` after the specified time. It checks audio `ducking` and return to the previous value for a `corrupted` `reveal`. It also checks `focus` selection and movement on edges. More checks test that `Escape` closes the view, camera glide, containment of a selected node in its band, and label and region-header fit. The `reveal` controls continuous camera movement.

`Trace`:
`test_pod_opens_on_fabricator_and_heals`, `test_fabricator_buys_through_the_pod`, `test_hero_panel_prefers_art_else_vector_glyph`, `test_fog_of_war_shows_unlocked_plus_frontier_only`, `test_reveal_commits_unlock_at_start_and_admits_neighbors`, `test_reveal_skippable_only_after_first_beat`, `test_reveal_queue_chains`, `test_corrupted_reveal_dips_ambience_and_restores`, `test_enter_sets_focus_and_nav_walks_edges`, `test_escape_seals_the_pod`, `test_selecting_a_node_glides_the_camera_toward_it`, `test_node_never_leaves_its_band_while_selected`, `test_label_renders_fit_canonical_boxes`, `test_region_headers_render_at_reserved_width`, `test_camera_owned_by_reveal_while_it_plays`, `test_reveal_pulls_camera_continuously_from_selection`.

### Implementation

The tests use small `app` and scene stubs, program `mindmap` data, output graphs, and deterministic `layout` state. They also use NumPy framebuffers, typed `UI` events, and sound call records. Camera and `reveal` tests run the same tick functions as the program scene.

### Caveats

- The target-scale `mindmap` checks measure camera-view and label ratios for their output fixture, not each possible large graph.
- Empty `conversation` data is the active specified state. These tests will change when `director`-specified scripts are added.

## Audio, rendering, `UI` platform, and recorded media

### Goal

Show that audio `assets`, music that adapts, headless render, lighting, `UI` drawing, and video recording obey their contracts. The contracts test screen images, audible output, file format, and platform operation.

### Invariants

- Program render and `UI` paths use the NumPy framebuffer and one renderer backend. They do not import pygame.
- Lighting and `visibility` stay continuous across a portal to each test's pixel tolerance.
- Audio voice limits, `asset` format, music decisions, and tap records follow the active audio contracts.
- A recording contains each accepted frame and all accepted audio or sidecar data in a media file that can be read.

### Verification

#### Audio `Bank` — `game/tests/test_audio_bank.py`

The module builds the sound manifest and checks each output path. An `asset` file that can be read must contain frames in 44,100 Hz, mono, signed 16-bit WAV data. Its `RMS` must be more than the silence limit, no sample can clip, and its duration must be at most 2 times the specified range. The manifest names have no duplicates. It contains 30 or more sounds and all 6 `revival` and economy additions. It maps each addition to its file.

`Trace`:
`test_wav_file_exists`, `test_wav_loads_and_is_44100_mono_16bit`, `test_wav_non_silent`, `test_wav_no_clipping`, `test_wav_duration_within_2x_of_spec_range`, `test_manifest_covers_expected_sound_count`, `test_manifest_covers_new_revival_economy_sounds`, `test_new_revival_economy_sound_resolves_to_its_own_wav`.

#### Crossing Tint — `game/tests/test_crossing_is_visible.py`

The module renders a portal crossing and an `arrival`. In the 2 conditions, the transition tint must change framebuffer pixels.

`Trace`:
`test_the_crossing_tint_reaches_the_screen`, `test_the_arrival_tint_still_reaches_the_screen`.

#### `Feature` Demos — `game/tests/test_feature_demos.py`

When `PERIHELION_FEATURE_DEMOS=1`, the module uses parameters to record the named `adversary-return`, `lob`, snare, and `shrieker-mark` `scenarios`. Each process must have a satisfactory result and make an `MP4` larger than 50,000 bytes. A local parser must find 2 or more known outer `MP4` boxes from `ftyp`, `moov`, and `mdat`. The test does not examine media tracks.

`Trace`:
`test_feature_demo_captures`.

#### Flicker Campaign `Placement` — `game/tests/test_flicker_campaign_placement.py`

The module loads program campaign levels. It checks that the region of each `corrupted` `testator` contains no flickers and that each `adversary` level contains between 3 and 30. Each flicker is 20 units or more from each other entity, with no more than 2 for each polygon. The audit log agrees with program `placement` and contains text that gives the cause.

`Trace`:
`test_no_flickers_in_corrupted_testator_territory`, `test_adversary_levels_carry_flicker_seasoning`, `test_flickers_never_stacked_on_another_entity`, `test_at_most_two_flickers_per_polygon`, `test_placement_audit_log_matches_shipped_levels`.

#### Flicker `Harness` — `game/tests/test_flicker_harness.py`

The module runs the flicker `feature` `harness` and checks that a different adjacent `prop` makes no blink event.

`Trace`:
`test_neighbor_decor_never_blinks`.

#### Flicker Lurker — `game/tests/test_flicker_lurker.py`

The module samples light with and without sources. It runs a `lurking` flicker below a work light that moves and checks `ambush` radius boundaries. It checks a `trace` that changes between dim values during `lurk` and a solid `trace` after `commit`. Two runs with the same seed must make the same deterministic state.

`Trace`:
`test_light_level_at_lit_point_vs_shadow_point`, `test_light_level_at_zero_with_no_lights`, `test_lurk_holds_low_light_position_under_moving_worklight`, `test_ambush_does_not_trigger_outside_radius`, `test_ambush_triggers_within_radius`, `test_trace_intensity_dim_while_lurking_solid_while_committed`, `test_flicker_ai_is_deterministic_given_seed_and_inputs`.

#### Floater Render — `game/tests/test_floater_render.py`

The module empties all other effect pools, renders one floater, and checks more than 100 bright pixels. This shows that the floater path uses no other pool.

`Trace`:
`test_floater_renders_with_all_other_pools_empty`.

#### Grip Attribution Render — `game/tests/test_grip_attribution.py`

The module renders a `warden` during its `grind` and a player hit. It checks rim changes that occur more than once and are easy to see during the `grip`. It also checks a bright rim flash on the attributed hit.

`Trace`:
`test_gripping_warden_rim_blinks_legibly_while_it_grinds`, `test_gripping_warden_rim_flashes_bright_on_the_players_hit`.

#### Grip `Visibility` — `game/tests/test_grip_is_visible.py`

The module measures `warden` body and rim colors and a rendered `grip`. It keeps the specified low body RGB values and keeps the `grip` signal out of the vignette color group. The rim must be bright, and its first RGB channel must not be the largest. All RGB values in the empty frame must be zero. The test compares the rim before a `grip` with the rim during a `grip` and makes sure that their difference is sufficient.

`Trace`:
`test_the_warden_body_is_dark_on_purpose_and_stays_that_way`, `test_the_grip_signal_is_not_painted_in_the_vignettes_colour`, `test_the_grip_signal_survives_a_black_background`, `test_the_grip_signal_is_distinguishable_from_the_resting_rim`, `test_the_warden_rim_is_what_makes_it_legible_at_all`.

#### Light Occlusion Demo — `game/tests/test_light_occlusion_demo.py`

The module loads the demo level and checks that connections made automatically equal the connections in the level data. The ratio of a lit projectile to the same projectile with no light must be 10 or more.

`Trace`:
`test_no_spurious_autoconnects`, `test_shot_contrast`.

#### Lighting Invariants — `game/tests/test_lighting_invariants.py`

Property and `scenario` tests check a zero light value across disconnected polygons and falloff that only decreases along a clear ray. They compare cached and new light instances and check portal-seam continuity in samples and pixels. They also check that a radius edge has no incorrect pixels and that cross-portal muzzle light has no seam.

`Trace`:
`test_occlusion_zero_contribution_across_disconnected_polygons`, `test_falloff_monotonic_along_unobstructed_ray`, `test_cache_matches_fresh_computation`, `test_seam_freeness_across_a_portal`, `test_pixel_composite_seam_freeness_across_corridor_portals`, `test_no_ghost_pixel_at_light_radius_edge`, `test_muzzle_flash_lights_across_the_portal_without_a_seam`.

#### Music System — `game/tests/test_music_system.py`

The module checks `prayer`, `contempt`, and `stalwart` control values for empty, light, heavy, adjacent, `hurt`, and `lurking` inputs. It checks the `prayer` floor and a threat response that does not decrease. It also checks native float inputs, use at bar boundaries, and a strong hit only during `ambush`. It rejects the previous `sting` and riser path that starts from events. It checks riser timing before a transition to the maximum.

The module also tests music stop at death, deterministic tap logs, a boss release of one bar, `combat`-form selection, and read-only `bank` metadata. More checks make sure that the end of each program `bank` bar is the start of the next bar. They test validation errors, live start, errors for a session with missing declarations, and errors for an unknown enemy.

The tests also check active `prayer` stems, stem chunks that contain audio, and the `war-chant` lane at maximum `stalwart`.

`Trace`:
`test_empty_polygon_is_full_prayer`, `test_weak_swarm_is_contempt_not_stalwart`, `test_heavies_raise_stalwart`, `test_adjacent_warden_is_nearly_copolygon`, `test_stalwart_monotone_in_threat`, `test_hurt_does_not_amplify_stalwart`, `test_blends_are_native`, `test_prayer_floor_never_breaks`, `test_lurking_flicker_is_tension_not_aggro`, `test_engine_inputs_complete`, `test_application_only_at_bar_boundaries`, `test_slam_is_ambush_only`, `test_no_reactive_stings_or_risers`, `test_riser_leads_the_peak_jump`.
`test_death_halts_music`, `test_deterministic_tap_log`, `test_boss_release_is_one_bar_comedown`, `test_combat_keeps_form_out_of_calm_sections`, `test_bank_meta_is_read_only`, `test_all_shipped_banks_valid_and_tiled`, `test_bank_meta_missing_fields_raise`, `test_live_start_contract`, `test_unknown_enemy_kind_crashes`, `test_underdeclared_session_crashes`, `test_shipped_prayer_never_silent_for_multiple_bars`, `test_no_stem_chunk_is_obviously_dead`, `test_war_chant_at_peak_stalwart`.

#### `Platform` Contracts — `game/tests/test_platform_contracts.py`

The module draws `plated` `UI` text in a live simulation scene and caps active sound effects at 24 voices. It stops and uses the voice with the lowest volume again only for a request with higher volume. It restarts queued sounds on an idle or stopped channel, drops duplicate `keydown` events, and keeps mouse-button `cursor` position.

`Trace`:
`test_plated_ui_text_draws_on_a_live_game_scene`, `test_sfx_pool_is_capped_at_twenty_four_voices`, `test_full_pool_steals_quietest_for_a_louder_sound`, `test_queue_on_idle_channel_starts_playing`, `test_queue_after_stop_all_restarts`, `test_auto_repeat_keydowns_are_dropped`, `test_button_events_carry_cursor_position`.

#### Recorder Shutter — `game/tests/test_recorder_shutter.py`

The module adds `synthetic` frames with and without movement. It keeps all positions used by the object. One frame with no movement stays the same, and the blend divides brightness equally across movement positions. It also checks a full frame result, rejects an empty blend, and prevents integer overflow at the tested `cadence`.

`Trace`:
`test_a_moving_dot_survives_at_every_position_it_occupied`, `test_a_still_scene_is_unchanged_by_the_blend`, `test_brightness_is_shared_across_the_positions_it_visited`, `test_a_full_frame_is_a_full_frame`, `test_blending_nothing_is_refused_rather_than_dividing_by_zero`, `test_the_accumulator_cannot_overflow_at_realistic_cadences`.

#### Render Headless — `game/tests/test_render_headless.py`

With `SDL` in `dummy` mode and Raster functions, the module runs and renders a headless scene. It checks the frame count, changes in image data, a bright frame, average draw time below the module limit, and a temporary `PNG`.

`Trace`:
`test_render_headless_smoke`.

#### Render Layers — `game/tests/test_render_layers.py`

The module puts bodies, `stations`, decals, and view boundaries at portal seams and around corners. It checks complete seam `visibility`, corner occlusion, zoom-scaled edge occlusion, some `visibility` at the view boundary, and no `station` leakage around corners.

`Trace`:
`test_a_body_on_a_room_seam_is_not_cut`, `test_a_body_past_the_corner_is_not_drawn`, `test_edge_of_sight_occlusion_scales_with_zoom`, `test_a_body_at_the_edge_of_sight_is_partly_occluded`, `test_a_station_on_a_seam_is_not_cut_from_either_side`, `test_a_decal_on_a_seam_is_not_cut_from_either_side`, `test_a_station_around_the_corner_is_not_visible`.

#### Render without pygame — `game/tests/test_render_pygame_free.py`

The module examines the render, HUD, and text modules for pygame imports and a second backend. It makes the renderer and shows a `uint8` NumPy frame with internal width, internal height, and 3 channels. Source checks must have 16-pixel `UI` text.

`Trace`:
`test_render_path_module_imports_no_pygame`, `test_exactly_one_renderer_backend`, `test_draw_returns_numpy_frame`, `test_hud_text_is_16px`.

#### Render Textures — `game/tests/test_render_textures.py`

The module compares the texture-dimension helper with polygon bounds and shows a textured floor different from the flat fallback. It checks RGB-zero output at zero `ambient`, followed by nonzero world pixels below a light.

`Trace`:
`test_texture_size_helper_matches_polygon_bbox`, `test_textured_floor_differs_from_untextured_fallback`, `test_zero_ambient_black_then_light_falloff_on_world_pixels`.

#### Root Invariance — `game/tests/test_root_invariance.py`

The module renders the same world from different `visibility` roots. For pixels in each result, textured, flat, and frames with `darkness` can have a difference of at most 3 channel levels. Doorway side walls must be shown before the crossing while the apex clamp applies, and they must stay continuous across the transfer.

`Trace`:
`test_textured_floor_is_root_frame_invariant`, `test_flat_floor_is_root_frame_invariant`, `test_jamb_walls_visible_before_crossing_within_apex_clamp_margin`, `test_jamb_wall_reveal_is_continuous_across_the_actual_crossing`, `test_darkness_enabled_multipolygon_is_root_frame_invariant`.

#### Terrain Light Shadows — `game/tests/test_terrain_light_shadows.py`

The module puts terrain between a light and sample points. Calculated light values and last pixels must show no light behind the blocker and light at its side. The module checks no shadow without terrain, root-invariant shadow polygons through a portal, and enemies in view in shadow. The tested scene has a light calculation time below 25 ms.

`Trace`:
`test_shadow_behind_terrain_dark_beside_lit`, `test_shadow_behind_terrain_pixel_composite`, `test_no_shadow_without_terrain_regression`, `test_terrain_shadow_root_invariance_across_portal`, `test_enemy_visible_in_terrain_shadow`, `test_lights_pass_stays_within_budget`.

#### `UI` without pygame — `game/tests/test_ui_pygame_free.py`

The module rejects pygame imports at each scope. It draws heading, pause, `conversation`, and the two `pod` views into NumPy frames. It accepts only typed `UI` events, not pygame-shaped events. It checks specified framebuffer pixels for rectangle, line, circle, polygon, and text primitives.

`Trace`:
`test_no_pygame_import_at_any_scope`, `test_title_scene_draws_on_numpy_fb`, `test_pause_scene_draws_on_numpy_fb`, `test_conversation_scene_draws_on_numpy_fb`, `test_pod_scene_both_pages_draw_on_numpy_fb`, `test_scenes_consume_uievent_and_duck_typed_pygame_events`, `test_fb2d_primitives_write_expected_pixels`.

#### Video Recorder — `game/tests/test_video_recorder.py`

The module calls the recorder and probes the result. It checks each supplied frame, a point in the middle that a player can move playback to, and 44,100 Hz stereo audio when supplied. It also checks correct video without audio and replay data. Sidecars must have names, and a caller can replace them. Sidecars must be empty when none are supplied.

The module rejects malformed audio, dimensions not divisible by 2, and unknown profiles. It checks equal pixels with full chroma plus telemetry and high quality encoding profiles.

`Trace`:
`test_every_submitted_frame_reaches_the_file`, `test_the_clip_is_seekable_partway_through`, `test_audio_arrives_as_a_real_track`, `test_a_recording_with_no_audio_is_still_valid`, `test_the_replay_rides_inside_the_file`, `test_sidecars_are_named_and_replaceable`, `test_a_file_with_no_sidecar_reads_as_empty`, `test_bad_audio_is_refused_rather_than_mangled`, `test_odd_dimensions_are_refused`, `test_unknown_profile_is_refused`, `test_the_video_is_full_chroma`, `test_both_profiles_encode`.

### Implementation

The tests examine output WAV files and call audio and music objects with recorded taps. They render `synthetic` and program scenes into NumPy frames, sample selected pixels, and compare `visibility` roots. They use `ffprobe` and the set `encoder` for media inspection. `UI` tests send repository `UIEvent` values. Timing tests use their module limits and the active build.

### Caveats

- Audio `Bank`, `Feature` Demos, `Platform` Contracts, Render Headless, Render Textures, and `Root Invariance` have `skip` paths listed in the same execution unit.
- `Feature` demos write repository media only when their environment flag turns on the test.
- Pixel and timing limits apply to the tested resolution, scene, `platform`, and build. They do not set a limit for each level.

## Automated play, calibration, and replay results

### Goal

Show that deterministic bots, recorded inputs, replay files, calibration reports, and performance harnesses make stable results for inspection.

### Invariants

- Equal seed, level, bot, and input values make equal deterministic results.
- A replay records the level and input state necessary to make the same tested last simulation state.
- Calibration files contain their stated `schemas` and measured directions.
- A visual record with a failure must not turn a correct simulation run into a failure.

### Verification

#### `Gauntlet` Calibration — `game/tests/test_gauntlet_calibration.py`

The module loads the calibration report and checks the outer, run, saturation, `PCA`, `stalwart`, `contempt`, `prayer`, and reference-comparison `schemas`. When fitted and `full-density` data are available, the fitted probability test shows that `combat` risk is lower than risk in a `corridor` or `loot` area. It also shows a higher kill rate for heavy enemies than small enemies and higher local `prayer` than the mean in a `loot` polygon.

`Trace`:
`test_top_level_schema`, `test_run_metadata_schema`, `test_saturation_schema`, `test_pca_schema`, `test_stalwart_model_schema`, `test_contempt_schema`, `test_prayer_schema`, `test_hazard_by_zone_is_a_real_measured_effect`, `test_contempt_trash_vs_heavy_direction`, `test_prayer_in_loot_polygons`, `test_baseline_comparison_is_reported`.

#### Person Bot — `game/tests/test_human_bot.py`

The module compares an aggro bot with no response wait to a person model with a response wait. It checks perception `latency` through portals, sampled release, mouse speed and acceleration limits, overshoot, and position change with no input movement. It also checks faster responses to `anticipated` enemies and equal results with the same seed. Different seeds must give different results. Other checks test temporary damage `flinch`, movement out of side attacks, doorway pauses, and `aim` `sweep`.

More checks test enemies in view before they are in the same polygon. The bot must not continue through a doorway after it sees an enemy. It must not start a `ritual` while a threat is `perceived`. The perception record contains no `NPC` internal data, calculates active state from movement, and gives each `warden` one recoil at first view.

`Trace`:
`test_aggro_bot_fires_on_the_same_tick_the_enemy_becomes_copolygon`, `test_human_bot_never_fires_before_perception_latency_elapses`, `test_perception_model_releases_entity_only_after_sampled_latency`, `test_perception_model_widens_to_visible_ids_not_just_polygon_local`, `test_mouse_model_never_teleports_velocity_and_accel_are_bounded`, `test_mouse_model_overshoots_on_large_flicks`, `test_mouse_model_settles_near_target_and_drifts_at_rest`, `test_anticipated_reactions_are_faster_than_surprise_reactions`, `test_two_identical_human_bot_runs_are_bit_identical`, `test_different_seeds_produce_different_human_bot_runs`, `test_aim_deviates_after_taking_damage_then_recovers`, `test_flank_escape_commits_through_the_weaker_side`, `test_flanked_choke_is_survived_and_escape_engages`, `test_human_bot_pauses_at_the_threshold_of_an_unexplored_polygon`, `test_human_bot_heading_wobbles_but_aggro_bot_does_not`, `test_human_bot_sweeps_aim_at_the_threshold`, `test_husk_is_viewport_visible_through_the_portal_before_copolygon`, `test_human_bot_does_not_run_past_an_enemy_seen_through_a_doorway`, `test_rituals_never_fire_while_any_threat_is_perceived`, `test_perception_returns_no_npc_internals`, `test_perception_activity_inferred_from_movement`, `test_first_sight_recoil_fires_once_per_warden`.

#### Testkit — `game/tests/test_testkit.py`

The module compares 2 aggro runs and 2 `explorer` runs. It records and replays an input run, then writes and loads a compressed replay. It runs aggro, `pacifist`, `camper`, and `explorer` results and checks a smoke level. An image output failure must not cause a run failure. It also runs the fast and full performance budget selection modes and checks the output radial hub world.

`Trace`:
`test_two_identical_aggro_runs_are_bit_identical`, `test_explorer_bot_run_is_deterministic`, `test_replay_record_play_roundtrip_identical_final_state`, `test_replay_save_load_gzip_roundtrip`, `test_aggro_bot_completes_smoke_level`, `test_pacifist_bot_survives_empty_level_and_reaches_exit`, `test_pacifist_bot_does_not_complete_level_with_mandatory_combat`, `test_camper_and_explorer_bots_run_without_crashing`, `test_assert_playable_smoke_level_has_no_issues`, `test_capture_is_best_effort_and_never_fails_the_run`, `test_perf_budgets_fast_subset`, `test_perf_budgets_full_suite`, `test_radial_hub_world_is_well_formed`.

### Implementation

The bot modules run constant tick sessions with recorded seeds and inputs. Replay tests write the level dictionary, seed, input frames, and metadata. Calibration tests read fitted `JSON` reports. Performance selection modes call the repository performance `harness` with their named subset or full set mode.

### Caveats

- `Gauntlet` Calibration has two `skip` calls listed in the same execution unit. Without the fitted artifacts, the `schema` check can return zero while the two measured effect conditions `skip`.
- Deterministic equality is scoped to the same build, platform operation, seed, level, and input sequence used by the test.

## Full repository check — `check.sh`

### Goal

Check the Rust engine, build the Python extension again, and run the default Python test selection against that build.

### Invariants

- The script uses `set -euo pipefail` and changes to its directory.
- A stage with a failure stops the script, and the next stages do not run.
- The Python tests run only after the release extension build is satisfactory.

### Verification

Change to a directory different from the repository directory. Run `check.sh` by its absolute path. A zero result and the last `check.sh: all green` line mean that these stages all returned zero:

1. `cargo test -p necore` in `engine`.
2. `uv run maturin develop --release -m engine/necore-py/Cargo.toml -q`.
3. `uv run pytest -q`.

The same open `skip` decision applies to the `pytest` stage. Repository configuration does not run the one test marked `slow`. A zero script result does not show that a test with `skip` or a test not selected was satisfactory.

### Implementation

The `Maturin` stage installs or replaces `necore` in the Python environment selected by `uv`. The `pytest` stage uses that installed extension and the repository `pytest` configuration.

### Caveats

- The check must have `Bash`, `Cargo`, Rust, `uv`, `Maturin`, Python, the repository libraries, and extension build tools.
- The extension installation changes the selected repository environment.
