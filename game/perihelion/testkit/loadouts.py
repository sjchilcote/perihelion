"""Canonical player loadouts for calibration/playtest runs.

FULL_LOADOUT is THE calibration loadout (director 2026-07-16: "give the
player all weapons so he has an actual chance", HP 100, no resist) --
tune_pass_rate, run_farm and the app's --loadout flag must all draw
from here so a recorded run reproduces a farmed run bit-for-bit.
"""

FULL_LOADOUT = dict(
    weapons=["knife", "pistol", "smg", "shotgun", "rail", "lightning",
             "tau", "hole", "scrap", "gland"],
    ammo={"9mm": 400, "shell": 80, "cell": 120, "components": 60},
    max_hp=100, hp=100, dmg_taken_mul=1.0,
)
