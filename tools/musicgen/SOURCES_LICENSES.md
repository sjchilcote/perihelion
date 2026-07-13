# Sources & licenses log (tools/musicgen)

Running log of downloaded/consulted assets and their source + license status for
the music-generation pipeline.

## 2026-07-13 — Catholic chant/mode research (text/note-data only, no audio)

Round-2 music direction requires melodic material drawn strictly from Catholic
liturgical tradition (Gregorian chant modes + specific chant melodies), separated
from Protestant hymnody. Research and captured note data written to
`tools/musicgen/CATHOLIC_SOURCES.md`. **No audio files were downloaded** for this
work — only mode definitions and short GABC-notation incipits (note-letter
sequences) transcribed by hand from public chant databases into that markdown file.

- Public-domain status: the eight church modes are medieval music-theory
  definitions (not copyrightable); the four captured chant melodies (Dies Irae,
  Victimae Paschali Laudes, Salve Regina, Veni Creator Spiritus) are medieval/early
  compositions whose melodic content is public domain. Only the *note sequence* was
  extracted as documented musicological fact from a modern (1961 Solesmes)
  engraving — the engraving/page image itself was not reproduced or stored.
- URLs consulted (see CATHOLIC_SOURCES.md for full citation list per item):
  - https://gregobase.selapa.net/chant.php?id=1198 (Dies irae, GABC incipit)
  - https://gregobase.selapa.net/chant.php?id=1086 (Victimae paschali laudes, GABC incipit)
  - https://gregobase.selapa.net/chant.php?id=2715 (Salve Regina, GABC incipit)
  - https://gregobase.selapa.net/chant.php?id=2923 (Veni Creator Spiritus, GABC incipit)
  - https://en.wikipedia.org/wiki/Church_modes
  - https://en.wikipedia.org/wiki/Dies_irae
  - https://en.wikipedia.org/wiki/Tom%C3%A1s_Luis_de_Victoria
  - https://en.wikipedia.org/wiki/Giovanni_Pierluigi_da_Palestrina
  - https://en.wikipedia.org/wiki/Genevan_Psalter
  - https://www.vatican.va/archive/hist_councils/ii_vatican_council/documents/vat-ii_instr_19670305_musicam-sacram_en.html (Musicam Sacram, 1967 — "Gregorian chant... pride of place")
  - https://grokipedia.com/page/Lutheran_chorale
  - https://grokipedia.com/page/Victimae_paschali_laudes

## 2026-07-13 — Marathon 1 (1994) MIDI soundtrack analysis (reference only, NOT PD)

Director approved borrowing licks from the Marathon 1 General MIDI soundtrack
(Alexander Seropian, Bungie, 1994; Marathon 2/Infinity had no music). The 16
original QuickTime-export MIDI files were downloaded to a scratch directory
(Dropbox folder linked from https://aaronfreed.github.io/soundtracks.html,
"Marathon 1 MIDI files" section), channel-split, and lead-line note sequences
extracted into `tools/musicgen/MARATHON_SOURCES.md`.

- **License status: copyrighted, not public domain.** The Marathon Trilogy is
  freeware (https://trilogyrelease.bungie.org/) and the Marathon 2 engine is GPL
  (Aleph One), but the music compositions remain Bungie/Seropian copyright.
- **No Bungie-derived files are committed to this repo** — the MIDIs stayed in
  scratch; only short analyzed note fragments (lick-length, for transformed
  homage use) are recorded in MARATHON_SOURCES.md.
- URLs consulted:
  - https://aaronfreed.github.io/soundtracks.html (MIDI exports + track history)
  - https://marathon.bungie.org/story/music.html (composer, format, track names)
  - https://marathongame.fandom.com/wiki/Marathon_Soundtrack
  - https://trilogyrelease.bungie.org/ (freeware status)
  - https://github.com/Aleph-One-Marathon/alephone (GPL covers engine, not music)

## 2026-07-13 — CC0 GM soundfonts for real organ/choir/bell/guitar samples

Round-2 order #2 ("real instruments... a guitar/chug that sounds like a GUITAR,
organ/choir/bells that sound REAL"). VST hosting (dawdreamer) was tried and ruled
out: no dawdreamer wheel matches this box's Python (3.13, dawdreamer's newest wheel
tops out at cp311), and `sudo` requires a password we don't have, so pacman-installed
Surge XT/sfizz was also a dead end. Fell back to the director's own explicitly
endorsed alternative: fluidsynth (already installed) + soundfonts, using ONLY CC0
1.0 licensed banks so provenance is unambiguous.

- **Source repo (aggregator only, not the rights holder)**:
  https://github.com/bratpeki/soundfonts — its README licence table marks
  `ChaosBank.sf2`, `Jnsgm2.sf2`, `Masterpiece.sf2`, `Unison.SF2` as **CC0 1.0**,
  originating from rKhive.com's soundfont collection
  (https://rkhive.com/banks.html, license page https://rkhive.com/legal.html).
  `Jnsgm2.sf2` additionally lists Jordi Navarro Subirana ("JNS-GM v2.0",
  https://www.polyphone-soundfonts.com/documents/27-instrument-sets/55-jns-gm-2)
  as an alternate source, same CC0 status per that repo's table.
- **Not committed to git** (would blow the <5MB audio-asset commit budget — each
  bank is 12-33MB). `tools/musicgen/fetch_soundfonts.sh` re-downloads all four CC0
  banks into `~/.cache/perihelion_musicgen/sf2` (override with `SF2_DIR`); that
  script IS committed (it's text, not audio).
  `tools/musicgen/real_sources.py` reads from that cache dir at render time.
- **Used for**: Church Organ, Choir Aahs, Tubular Bells, Distortion/Overdrive
  Guitar GM patches (all real sampled instruments baked into the soundfont, not
  synthesized) — real source material for `gordon_chain.py`'s processing.
- **Fallback soundfont** `GeneralUser GS` (S. Christian Collins,
  https://schristiancollins.com/generaluser.php, license text at
  https://raw.githubusercontent.com/mrbumpy409/GeneralUser-GS/main/documentation/LICENSE.txt)
  was also downloaded during evaluation but is **NOT used** in the committed
  pipeline: its license explicitly states some contained samples have
  "questionable origin" / uncertain provenance, which fails the director's
  "CC0/PD sources only, provenance logged" bar for the Catholic-tradition organ/
  choir/bell voices specifically. Kept only as a local scratch comparison, not
  wired into `real_sources.py`'s `BANK_ORDER`.
