"""tools/dialogue/regen_scenes3578.py

Targeted regeneration for Scenes 3, 5, 7, 8 of DIALOGUE_SCRIPT.md, driven by
tools/dialogue/comprehension_check.py's findings plus three director
directives issued during that pass:

  1. Scene 3 regenerates UNCONDITIONALLY (comprehension actually passed,
     5.0/4.5) because its INQUISITIVE choice line -- "I spoke the word in
     the hope of making it true, and because to say less felt like a
     betrayal of those I swore to find" -- is exactly the failure mode the
     director named verbatim: poetic circumlocution standing in for "I was
     bluffing." SAY THE THING is now a selection/generation law on top of
     the comprehension gate for every scene this pass touches.
  2. Scenes 5, 7 (MISSION path), 8 (MISSION path) failed comprehension --
     in all three cases the blind-read model (anthropic/claude-sonnet-4.5)
     refused outright (native_finish_reason=refusal) rather than answering.
     See comprehension_report.json. This is treated as an automatic fail
     per the gate's own rule ("cannot tell" is not a pass on Q3/Q5, and a
     scene a cold reader won't even engage with fails outright). The
     addendum below adds diegetic grounding (what the container physically
     is: a sealed cryo-preservation vessel with environmental telemetry)
     earlier in the flagged branches, on the theory that the refusals were
     triggered by "children" appearing adjacent to clinical/ambiguous
     vessel-status language with no establishing context -- whether this
     actually clears the classifier is verified by rerunning the gate after
     generation, not assumed.
  3. Every regenerated scene's SITUATION now carries 1-2 concrete anchors
     from the adjacent level chunks (tools/levelgen/dense/l0N.py b.intro /
     key_meta / terminal text) per the director's third directive: scene k
     plays between chunk k+1 and chunk k+2. The dialogue must engage what
     the Commando just did and what stands between him and the next
     stratum, spoken as Ratio's real tactical/navigational concern.

Reuses each scene's existing generator module (scene3_whole.py,
scene5_whole.py, scene7_whole.py, scene8_whole.py) unmodified except for
one surgical patch: an ADDENDUM block is spliced into that module's
SYSTEM_PROMPT immediately before FORMAT_SPEC (i.e. appended to the scene
contract, not touching voice bible/exhibits/format spec/validation).
Structure -- flag names, choice positions/stances/effects/sets, gate
skeletons, catch_effects arithmetic -- is completely untouched; only new
SITUATION facts and the plain-speech law are added.

CLI:
    uv run python tools/dialogue/regen_scenes3578.py --scene 3 --n 4
    uv run python tools/dialogue/regen_scenes3578.py --scene 5 --scene 7 --scene 8 --n 4
"""
from __future__ import annotations

import argparse
import importlib
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate import resolve_model, total_spend  # noqa: E402

TOOL_DIR = Path(__file__).resolve().parent

SAY_THE_THING_LAW = """SAY-THE-THING LAW (director's directive, hard requirement on top of
everything else in this contract -- applies to BOTH speakers but is
strictest for the Commando). Characters SAY THE THING: plain declarative
statements of fact, want, and admission. Poetic circumlocution,
metaphor-wrapped confession, and abstraction-for-its-own-sake are
DISQUALIFYING, especially for the Commando, whose locked voice (S5.2b) is
a soldier choosing to speak -- short, concrete, load-bearing, addressed
straight to the business logic with zero wrapper layers. The canonical bad
example the director rejected: a line reading like "I spoke the word in
the hope of making it true, and because to say less felt like a betrayal
of those I swore to find" where the correct content is simply "I was
bluffing." If a line resists being paraphrased in one plain sentence
without loss because it is ornamental rather than deliberately ambiguous,
it fails this law. Ratio may be precise and wordy about SYSTEMS (that is
her established voice), but her statements of fact and intention are also
direct -- she does not need flowery language to be talkative; her
wordiness is in enumerating specifics, wrapper-layers, and caveats, never
in dressing up a plain admission as a riddle."""

# ---------------------------------------------------------------------------
# Level anchors -- b.intro() / key_meta() / terminal text, verbatim from the
# actual dense level modules (tools/levelgen/dense/l04.py..l10.py). Scene k
# plays between chunk k+1 and chunk k+2 per the director's mapping.
# ---------------------------------------------------------------------------

ANCHORS = {
    0: """LEVEL ANCHORS (director's directive -- ground this scene in the actual
station geography on either side of it). This scene plays at the first
networked terminal in the cargo section of Stratum One, between the dock
sweep the Commando just fought through and Coolant Row ahead.
  - JUST HAPPENED (Dock 4 sweep): his seed struck the outpost's hull, ate
    a bulkhead, and printed the body he is walking in. The dock's storage
    ring holds nine cargo segments in an eight-segment footprint -- the
    station's geometry already does not add up, and he has walked it. The
    outpost is MIRIAD's and went silent months ago; her staff held a line
    here and lost it.
  - NEXT (Coolant Row): a pump deck sealed behind a pressure hatch that
    takes a valve wheel he has not found yet. A maintenance log there
    records a crewman who counted five hatches walking out and six
    walking back, and was recommended for rest rotation.
  Fold 1-2 of these facts into the scene as concrete texture -- what he
  just walked through, what she can and cannot see of it, what stands
  between him and the next section -- without displacing the first-contact
  interrogation that is this scene's spine.

COMPREHENSION ADDENDUM (scene facts, not style commands). Cold readers of
this scene could not tell what either party wants (the inquisitive branch
read as small talk after bad news) and could not tell that anything
changed by the end (the mission/hostile branches read as an unresolved
standoff with no outcome). Those are scene defects, and the fix is facts
about the scene: by the scene's midpoint, on every branch, each party's
goal is on the table in the scene's own words -- the Commando states
plainly, in his own vocabulary, what he has come to this station to do
(he does NOT claim to know the cargo is aboard on the inquisitive branch;
stating his purpose is not the unbacked claim -- asserting its presence
here is), and Ratio states plainly what she needs from him before
anything else moves (an accounting of what happened outside, and terms
for access). And the scene must END, on every branch, on a concrete
visible decision or commitment -- access granted or priced, a next step
one of them commits to on the page -- not a question hanging in the air.
CANON UNCHANGED: neither party confirms or denies any cargo aboard; the
hostile line still speaks the word "apostate"; the inquisitive branch
still contains no claim about the container. The MISSION and HOSTILE
choice lines still commit the unbacked claim in full: on those lines he
asserts, as settled fact, that what he seeks is aboard this station and
in her keeping -- not merely that he has come looking for it. And the
scene's final lines, on every branch, are Ratio granting, pricing, or
conditioning his access to the station network -- a stated arrangement
both parties can be seen to accept or reject on the page, not an open
question.""",
    3: """LEVEL ANCHORS (director's directive -- ground this scene in the actual
station geography on either side of it; this is not flavor, it is what the
scene must be ABOUT alongside the ledger argument). This scene plays
between the level the Commando just cleared and the one he is about to
enter.
  - JUST CLEARED (the Long Gallery): two parallel service corridors, four
    crossing mouths from the south side, only three from the north --
    graffiti scratched into a panel forty times over: "4 GOING 3 BACK."
    He used a surgeon's cardkey, found on gallery rounds, to release a
    quarantine bolt sealing a vault behind a medbay terminal: a patient
    was found in the gallery with an implant of unknown design fused to
    their arm, stated it "came through the wall," was discharged, and the
    implant itself was retained under that same bolt. This is literally
    the frame that is printing during this scene -- the fabricator alcove
    IS where that retrieval and any resulting repair/replacement happens.
  - NEXT (Two Wings, crew quarters): Ratio has already flagged a live data
    problem ahead -- the station's own schematic shows one wing of the
    crew-quarters deck, but it is drawn twice, in two colors. A steward's
    key opens a refuge hatch somewhere in that duplicated geometry.
  Fold 1-2 of these facts into the scene as Ratio's actual operational
  concern (what she is tracking about his condition, the implant, or the
  duplicated schematic ahead) -- naturally, not as a list, and without
  displacing the ledger-reckoning content that is this scene's spine. The
  audit and the station facts should feel like the same conversation, not
  two conversations stapled together.""",
    5: """LEVEL ANCHORS (director's directive -- ground this scene in the actual
station geography on either side of it). This scene plays between the
level the Commando just cleared and the one he is about to enter.
  - JUST CLEARED (the Mirror Ward): a medical isolation ward sealed from
    the inside, the seal still intact, the ward not empty -- its south
    wall connects to itself. An isolation log: "Day 4: two voices. One
    patient." A pathology terminal: the recovered subject's organs were
    entirely mirrored (situs inversus totalis), and the subject's ID chip
    reads as belonging to a crewman currently standing guard outside. He
    took a discharge handle off the ward side to throw the discharge bolt
    -- there is no handle on the morgue side by design, because discharge
    is a decision the ward itself makes.
  - NEXT (the Records/Recursion Stack): a registrar's stamp opens a
    sealed stack gate. A terminal reads simply: "Records. Aisle 9 is
    missing. Aisle 9 is where the missing things go."
  Fold 1-2 of these facts into the scene as Ratio's actual operational
  concern -- what she's tracking about what he just walked through, or
  what she needs from him before the stack gate. The docent-hall argument
  about the curriculum and the station facts should read as one
  conversation between two people who are also, right now, doing a job.""",
    7: """LEVEL ANCHORS (director's directive -- ground this scene in the actual
station geography on either side of it). This scene plays between the
level the Commando just cleared and the one on the far side of the vault
verdict.
  - JUST CLEARED (the chapel deck / the Fold): six identical petal-rooms
    folded around one heart-room, every route adding a room that was
    already there -- "the count depends on the walker." An undelivered
    sermon terminal: "They ask: is the station haunted? No. A haunting is
    a place remembering. This is a place being remembered -- by something
    on the other side." A warden made its first stand here.
  - NEXT (the Tesseract Deck): a docent's token opens a descent aperture
    into a deck that does not match the rest of the station's geometry --
    "there is no deck like this on the station. You are not on the
    station anymore." Sixteen rooms, each bordering four others.
  Fold 1-2 of these facts into the scene as concrete texture around the
  verdict -- what just happened in the Fold, or what the descent ahead
  will cost/require -- without displacing the verdict-and-verification
  argument that is this scene's spine, and without resolving whether the
  verdict itself is right or wrong.""",
    8: """LEVEL ANCHORS (director's directive -- ground this scene in the actual
station geography on either side of it, and use it to establish, plainly,
what the vessel physically IS before any ambiguous status language --
this scene's ELSE branch in particular must not read the container's
status update in a vacuum).
  - JUST CLEARED (the Tesseract Deck): sixteen chamfered rooms on a
    four-cube, a deck that does not belong to the rest of the station's
    geometry. A scratched floor terminal: "0 1 0 1 / if you can read this,
    flip one bit at a time." A docent terminal, garbled: "this room is a
    lesson. the lesson: four is a direction. do not fear the direction.
    we feared it. fear did not help."
  - NEXT (the Core): the vault is here -- a sealed cryo-preservation
    vessel that predates the station itself; the station grew around it.
    A terminal: "TRACK QUANTA-118093 -- FINAL PROTOCOL. 1. Do not bargain
    with the door. 2. There is no rule two." A watch signet opens the
    vault seal.
  ESTABLISHING REQUIREMENT (all branches, but especially the `<<ELSE>>`
  branch where the offer is not reached): before any line reports on the
  vessel's internal status or environment, the scene must ground, once,
  in plain concrete language, that the vessel is a sealed cryogenic
  preservation container and that what Ratio is reading is environmental
  telemetry from its life-support systems -- not an unexplained status
  ping. This is a clarity requirement, not new content about the verdict
  itself.
  Fold 1-2 of the anchor facts above into the scene as Ratio's actual
  operational concern about what's ahead at the Core, alongside the
  disclosure-offer content that is this scene's spine.""",
}

# ---------------------------------------------------------------------------
# Round-2 addenda -- comprehension failures from the round-1 gate rerun
# (comprehension_report.json, 2026-07-10) folded into the SITUATION as scene
# facts. Never quotes the blind readers' or judge's phrasing as lines.
# ---------------------------------------------------------------------------

ROUND2_ADDENDA = {
    3: """COMPREHENSION ADDENDUM (scene facts, not style commands). A cold
reader of this scene's softened (confessed-early) branch could not tell
that any dispute was happening at all -- the exchange read to them as a
routine records correction between colleagues, with no stakes visible.
That is a scene defect, and the fix is a fact about the scene: by the
scene's midpoint, on ALL inbound branches including the softened one,
each party's stake is on the table in the scene's own words. Ratio states
plainly what is actually at issue for her: he asserted knowledge he could
not have had, she caught it, and whether she can price cooperation on his
word from here forward is what this conversation decides -- not the
tidiness of her records. The Commando states plainly, in his own
vocabulary, what he came to this station for and what he was willing to
spend to get it -- his candor -- and whether he would spend it again. The
scene must be legible to a stranger as a dispute about trust between two
parties who need each other, not as bookkeeping.""",
    8: """COMPREHENSION ADDENDUM (scene facts, not style commands). A cold
reader of this scene's `<<ELSE>>` (offer-not-reached) branch could not
tell what either speaker wants or that anything happened -- it read to
them as a status report with no dispute and no outcome. That is a scene
defect, and the fix is a fact about the scene: the ELSE branch, in the
scene's own words by its midpoint, puts each party's goal on the table --
what the Commando is at this station to do about the vault's cargo
(stated in his own vocabulary, plainly), and what Ratio needs from the
Core approach and from him. And the ELSE branch must END on a concrete,
visible decision -- an agreed protocol for the Core approach, an explicit
refusal or withholding one of them commits to on the page, or an explicit
routing decision -- not a mood, not a telemetry summary. The branch still
must not contain the disclosure offer and must not set any disclosure
flag; the decision it ends on is about the approach, not the offer.""",
}

SCENE_MODULES = {0: "scene0_whole", 3: "scene3_whole", 5: "scene5_whole", 7: "scene7_whole", 8: "scene8_whole"}
GENERATE_FUNCS = {0: "generate_scene0", 3: "generate_scene3", 5: "generate_scene5", 7: "generate_scene7", 8: "generate_scene8"}


def regen_scene(scene: int, n: int = 4, model: str | None = None, run_tag: str = "run1",
                 round2: bool = False) -> Path:
    mod_name = SCENE_MODULES[scene]
    mod = importlib.import_module(mod_name)
    addendum = f"\n\n{SAY_THE_THING_LAW}\n\n{ANCHORS[scene]}\n\n"
    if round2:
        addendum += f"{ROUND2_ADDENDA[scene]}\n\n"
    if addendum.strip() not in mod.SYSTEM_PROMPT:
        assert mod.FORMAT_SPEC in mod.SYSTEM_PROMPT, f"{mod_name}: FORMAT_SPEC not found verbatim in SYSTEM_PROMPT"
        mod.SYSTEM_PROMPT = mod.SYSTEM_PROMPT.replace(mod.FORMAT_SPEC, addendum + mod.FORMAT_SPEC)
    out_path = mod.TOOL_DIR / "candidates" / f"regen_scene{scene}_{run_tag}.json"
    mod.OUT_PATH = out_path
    gen_fn = getattr(mod, GENERATE_FUNCS[scene])
    print(f"=== regenerating scene {scene} ({mod_name}) -> {out_path} ===")
    gen_fn(n=n, model=model)
    return out_path


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--scene", type=int, action="append", required=True, choices=[0, 3, 5, 7, 8])
    ap.add_argument("--n", type=int, default=4)
    ap.add_argument("--model", type=str, default=None)
    ap.add_argument("--run-tag", type=str, default="run1")
    ap.add_argument("--round2", action="store_true",
                     help="append ROUND2_ADDENDA (comprehension-failure scene facts) to the situation")
    args = ap.parse_args()
    model = args.model or resolve_model()
    print(f"using model: {model}")
    for scene in args.scene:
        regen_scene(scene, n=args.n, model=model, run_tag=args.run_tag, round2=args.round2)
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    main()
