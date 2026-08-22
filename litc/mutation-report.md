# Focused mutation report

Date: 2026-08-03

## Scope and command

The run mutated `game/perihelion/coordination.py`, `game/perihelion/signals.py`, and `game/perihelion/topology.py`. These modules own adversary coordination arithmetic, the nine signal fields, and mutable portal topology. Mutmut 3.5.0 ran the 37 directly relevant tests from the `game` directory. The clean tests passed before mutation, and Mutmut's forced-failure check failed as required.

Mutmut generated 364 mutants. The first run killed 258, left 96 survivors, and found ten mutants with no associated test. Three focused boundary modules were added in response. The final run killed 333 mutants and left 31 survivors. Every mutant had an associated test. No mutant timed out or crashed the runner.

## Adjudication

Three of the final survivors are equivalent within the supported behavior:

- Changing `commit_hazard` from `f <= 0.0` to `f < 0.0` has the same result at zero when the threshold is positive. Spawn thresholds are always positive.
- Replacing the initial empty `SignalField._adj` list with `None` has no effect because `on_topology_changed` replaces that value before the constructor returns.
- Changing the no-op topology callback from `lambda: None` to `lambda: 0` has no effect because no caller uses its return value.

The other 28 survivors change observable behavior and remain real test gaps.

The initial 106 findings and their disposition group as follows:

| Unit | Findings | Assessment |
|---|---:|---|
| Coordination decisions | 76 | New exact vectors killed 54. Twenty-one remain real gaps, and one zero-boundary mutant is equivalent. |
| Signal fields | 7 | New constructor, total, neighborhood, and refresh checks killed three. Three remain real gaps, and one constructor mutant is equivalent. |
| Portal topology | 23 | New handle, split, carve, callback, cleanup, return-link, and diagnostic checks killed 18. Four remain real gaps, and one callback mutant is equivalent. |

The new tests killed the high-impact survivors that subtracted doorway attraction, accepted settlement without a warden, changed signal totals, omitted portal cleanup arguments, or returned an invalid link. Remaining real survivors include default-argument changes, same-priority acceleration ordering, arithmetic at the `1e-9` cutoff, additional separation vectors, route edge zero, error-message detail, carve interaction with existing handles, and exact tolerance equality.

## Gate result

This focused mutation run is complete and every survivor is adjudicated. It produced 23 passing regression cases and raised the mutation kill rate from 70.9% to 91.5%. Twenty-eight real gaps remain in the focused scope, so the mutation evidence supports the spec caveats but does not justify a claim of exhaustive behavioral coverage.
