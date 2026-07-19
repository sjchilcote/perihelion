"""Sanity checks for tools/musiccal/factor_model.json (director's brief,
step 5: "Sanity checks, fail-first"). These pin the COMMITTED fitted
output, not live sim state — regenerating it is tools/musiccal/fit_factors.py's
job (`uv run python tools/musiccal/fit_factors.py`), not a test's. All the
actual statistics (including the shuffled-label permutation control) are
computed once, on the full calibration corpus, inside fit_factors.py;
this file only asserts the committed numbers have the shape and direction
the brief requires."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
MODEL_PATH = ROOT / "tools" / "musiccal" / "factor_model.json"


@pytest.fixture(scope="module")
def model():
    assert MODEL_PATH.exists(), \
        "run: uv run python tools/musiccal/fit_factors.py"
    return json.loads(MODEL_PATH.read_text())


# --- schema pin -----------------------------------------------------------

def test_top_level_schema(model):
    for key in ("schema", "run_metadata", "total_ticks", "primary_horizon",
                "horizons", "features", "baseline_features", "saturation",
                "pca", "stalwart", "contempt", "prayer", "sanity_checks",
                "per_polygon_hazard_final_batch", "polygon_hop_order"):
        assert key in model, f"factor_model.json missing top-level key {key!r}"
    assert model["schema"] == 2
    assert model["primary_horizon"] in model["horizons"]
    assert isinstance(model["features"], list) and len(model["features"]) > 10


def test_run_metadata_schema(model):
    rm = model["run_metadata"]
    for key in ("n_runs", "outcomes", "clear_rate"):
        assert key in rm
    assert rm["n_runs"] > 0
    assert 0.0 <= rm["clear_rate"] <= 1.0


def test_saturation_schema(model):
    sat = model["saturation"]
    assert "criterion" in sat and "batches" in sat and "evaluation" in sat
    assert len(sat["batches"]) >= 2
    ev = sat["evaluation"]
    for key in ("n_covered_polygons", "coverage_frac", "se_criterion_met",
                "shift_criterion_met", "saturated"):
        assert key in ev
    assert 0.0 <= ev["coverage_frac"] <= 1.0 + 1e-9


def test_pca_schema(model):
    pca = model["pca"]
    assert pca["n_samples"] > 0
    assert len(pca["components"]) >= 1
    c1 = pca["components"][0]
    for key in ("component", "explained_variance_ratio", "loadings", "top_loadings"):
        assert key in c1
    # components are sorted by descending explained variance
    ratios = [c["explained_variance_ratio"] for c in pca["components"]]
    assert ratios == sorted(ratios, reverse=True)


def test_stalwart_model_schema(model):
    st = model["stalwart"]
    m = st["model"]
    if "error" in m:
        pytest.skip(f"stalwart model not fit: {m['error']}")
    for key in ("auc", "coefficients", "intercept", "calibration",
                "n_train", "n_test", "n_nonzero_coefficients"):
        assert key in m
    assert 0.0 <= m["auc"] <= 1.0
    cal = m["calibration"]
    assert len(cal["mean_predicted"]) == len(cal["frac_positive"])
    assert st["cdf_reference"] is not None
    ref = st["cdf_reference"]
    assert len(ref) == 101
    assert ref == sorted(ref), "CDF reference table must be non-decreasing"
    assert ref[0] <= ref[-1]


def test_contempt_schema(model):
    c = model["contempt"]
    assert len(c["table"]) == 5  # weak_aggro_same_polygon bins 0,1,2,3,"4+"
    for row in c["table"]:
        assert row["kills_per_sec"] >= 0.0
    assert len(c["cdf_reference"]) == 101


def test_prayer_schema(model):
    p = model["prayer"]
    assert p["formula"] == "1/(1+n_aggro)"
    assert 0.0 <= p["mean_overall"] <= 1.0


# --- fail-first sanity checks (director's brief, step 5) ------------------

def test_hazard_by_zone_is_a_real_measured_effect(model):
    """Originally named test_hazard_higher_in_combat_than_corridor, per the
    brief's hypothesis; renamed because that hypothesis is false in this
    data (see below) and the old name would misdescribe what's pinned.
    Must show a real, non-vacuous effect AND a shuffled-label permutation
    control that does NOT show it -- proof this isn't vacuous (Bayescraft:
    conservation of expected evidence / a test with no way to fail isn't a
    test).

    GROUND TRUTH, replicated at every corpus prefix from 75 to 2400 runs
    (FITTING_REPORT.md, contradiction #1, has the full writeup): hazard is
    NOT higher in combat polygons than corridors+loot pooled -- it is
    slightly LOWER (hazard_combat=0.0126 vs hazard_corridor_or_loot=
    0.0139 at n=1200, the pinned statistic). The three-way decomposition
    is sharper: LOOT polygons are the deadliest zone class (0.0271, 2.2x
    combat's 0.0121) while corridors alone are the SAFEST (0.0072) --
    the pooled corridor+loot > combat statistic is driven entirely by the
    loot polygons. Traced to real engine/behavior properties, not a
    measurement bug: (a) `GameSession._enemy_ai` (game/perihelion/sim.py)
    has no de-aggro transition for standard enemies once state=="hunt" --
    a hunting enemy pathfinds toward the player's CURRENT polygon via
    `next_edge(polygon, ppolygon)` forever, so fight survivors pursue into the
    'safe' interlude space; (b) hurt bots deliberately path to loot-polygon
    medkits, so loot polygons concentrate the lowest-hp population, and hp
    is the fitted model's dominant hazard factor.

    This test therefore checks the thing that must be true regardless of
    which way the assumption fell: the permutation control shows near-zero
    effect (proving the pipeline has real discriminating power) while the
    real, unshuffled statistic is significant -- i.e. the measurement is
    trustworthy. It does NOT assert the original hypothesized direction,
    because that hypothesis is now known to be false."""
    h = model["sanity_checks"]["hazard_combat_vs_corridor"]
    assert h["hazard_combat"] is not None and h["hazard_corridor_or_loot"] is not None
    assert h["permutation_p_value"] < 0.05, \
        "the combat/corridor hazard split must be a statistically real effect, not noise"
    # the control: with zone labels shuffled, the SAME statistic must land
    # much closer to zero than the real, unshuffled effect -- this is what
    # makes the check fail-first rather than assumed-true, independent of
    # which direction the real effect points.
    assert abs(h["shuffled_diff_mean"]) < abs(h["observed_diff"]) * 0.5, \
        "shuffled-label control shows nearly as much effect as the real split " \
        "-- the hazard-by-zone comparison has no discriminating power"
    # ground-truth regression pin (see docstring): corridors/loot polygons
    # read as SLIGHTLY more hazardous than combat polygons, not less.
    assert h["observed_diff"] < 0, \
        "expected hazard_corridor_or_loot > hazard_combat (see docstring) -- " \
        "if this now shows combat as more hazardous, the de-aggro/persistent-hunt " \
        "root cause may have changed; re-verify before updating this pin"


def test_contempt_trash_vs_heavy_direction(model):
    """GROUND TRUTH, replicated under two different conditioning schemes
    (segment-level, then kind-specific same-polygon aggro -- see
    sanity_contempt_trash_vs_heavy's docstring): heavy-segment (E/F)
    engagement reads a HIGHER kills/sec (0.48/s) than trash engagement
    (0.30/s), the opposite of the brief's assumption. Most likely
    mechanism: E and F mix escort trash (husk/mite/spitter) alongside
    their signature brute/shrieker/warden, so ticks where a heavy kind is
    aggro'd in-polygon often ALSO have escorts dying simultaneously, inflating
    the heavy-conditioned kill rate; isolating a "solo heavy, zero escort"
    tick population was not attempted (see FITTING_REPORT.md caveats).
    This is reported plainly rather than asserted as a design failure --
    the main line reads this back to the director per the task brief."""
    c = model["sanity_checks"]["contempt_trash_vs_heavy"]
    if not c.get("available"):
        pytest.skip(f"no auxiliary full-density batch: {c.get('reason')}")
    assert c["trash_kills_per_sec"] is not None and c["heavy_kills_per_sec"] is not None
    assert c["n_trash_ticks"] > 1000 and c["n_heavy_ticks"] > 1000, \
        "sample too thin to trust either rate"
    assert c["heavy_kills_per_sec"] > c["trash_kills_per_sec"], \
        "expected heavy > trash (see docstring) -- if this now shows trash " \
        "higher, the escort-inflation hypothesis may not hold; re-verify " \
        "before updating this pin"


def test_prayer_in_loot_polygons(model):
    """GROUND TRUTH, replicated at n=300/1200: PRAYER (the brief's literal
    1/(1+n_aggro), GLOBAL aggro count) reads ~0.64 in loot polygons, not ~1.0.
    Partial root cause, same as the hazard finding above: enemies that
    survive a fight keep hunting indefinitely (no de-aggro transition in
    `_enemy_ai`), so the global aggro count rarely returns to zero even
    while the player stands in a polygon with nothing nearby. The diagnostic
    POLYGON-LOCAL variant (`prayer.mean_in_loot_local`,
    1/(1+n_aggro_same_polygon) -- not the official value) is measurably HIGHER
    (0.746 vs 0.640), confirming distant/global hunters explain PART of the
    gap -- but it does NOT reach ~1.0 either (an original hypothesis this
    test held and rejected on the real data): at the density this gauntlet
    was tuned to (10 enemies total across the whole run), persistent
    hunters sometimes physically catch up into a 'safe' polygon WITH the
    player before dying, so even same-polygon aggro doesn't cleanly zero out
    in nominally safe space. See FITTING_REPORT.md for the full writeup."""
    p = model["sanity_checks"]["prayer_loot_polygons"]
    prayer = model["prayer"]
    assert p["mean_prayer_in_loot_polygons"] is not None
    local = prayer.get("mean_in_loot_local")
    assert local is not None, "the polygon-local PRAYER diagnostic must be present"
    assert local > p["mean_prayer_in_loot_polygons"], \
        "the polygon-local variant should read higher than the global formula " \
        "(distant hunters are part, not all, of the depression) -- see docstring"
    # ground-truth regression pin: global PRAYER stays well below 1.0 in
    # loot polygons because upstream hunters never give up the chase.
    assert p["mean_prayer_in_loot_polygons"] < 0.9, \
        "expected global PRAYER to stay depressed in loot polygons (see docstring) " \
        "-- if this now reads near 1.0, the persistent-hunt root cause may have " \
        "changed; re-verify before updating this pin"


def test_baseline_comparison_is_reported(model):
    """The brief's original pre-selected feature (weighted_threat_active
    alone) is kept as an explicit baseline comparison, per the director's
    correction ('beats it out-of-sample or we've learned my guesses were
    sufficient -- also worth knowing'). Either outcome is informative; this
    only pins that BOTH numbers exist and are valid."""
    st = model["stalwart"]
    full_auc = st["model"].get("auc")
    base_auc = st["baseline_model"].get("auc")
    assert full_auc is not None and base_auc is not None
    assert 0.0 <= full_auc <= 1.0
    assert 0.0 <= base_auc <= 1.0
