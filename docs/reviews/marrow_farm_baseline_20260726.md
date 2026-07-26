# Marrow acceptance baseline — 16 ordinary seeds, 2026-07-26 pre-dawn

`tools/playtest/marrow_farm.py --seeds 16 --ticks 24000` on shipping
gauntlet4 (authored scouts, HumanBot hard, no harness help). Raw:
`out/marrow_farm.json`, log `out/marrow_farm_run.log`.

## The loop is universal
- **16/16 seeds fire the full loop unaided.** First breach mean t3310
  (55s), min t2737, max t4099 — the opening leg belongs to the player,
  then the marrow answers, every time.
- 64 breaches opened across the bank; seeds ran 3–8 breaches each
  (seal → new call → re-open episodes work; seed 2 ran eight).
- Knower fraction 13.3% — the ~10% rule plus min-one-per-pour,
  exactly as constructed.
- Shelf replacements fire only in post-seal quiet (0 in seeds that die
  during their first siege, 6–11 in seeds that outlive one).

## The open difficulty question, now with numbers
- **Mean death t14783 (246s); 2/16 alive at the 400s cap.** The bot
  has no anti-scout or anti-breach policy — it never hunts a rooted
  broadcaster and fights pours where they find it. Scouts killed:
  mean 3.1 of 7 (attrition real, extermination never happens).
- 58 dry calls vs 64 opens. Two distinct causes blend here: "no free
  apse seam" (all three committed — healthy scarcity) and "no wall
  holds a 96u seam" (the measured U15 geometry-migration need). The
  farm should split these next revision.
- This is the NEW baseline; the pre-marrow bot numbers (mean 80–131s)
  came from a different loadout/tuning era and are not comparable.
  Tuning direction if the director wants it easier/harder lives in
  authored scout count/placement and the beacon knob — never in
  enemy HP/damage inflation (ratified).
