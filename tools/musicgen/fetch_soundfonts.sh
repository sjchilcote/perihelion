#!/usr/bin/env bash
# Re-downloads the CC0 GM soundfonts round 2's real-instrument pipeline uses
# for organ / choir / bell / distortion-guitar source material. Not stored
# in git (see SOURCES_LICENSES.md: commit budget is <5MB, these are 12-33MB
# each) -- this script is the reproducible fetch step.
#
# Usage: SF2_DIR=/path/to/cache ./fetch_soundfonts.sh
set -euo pipefail
DEST="${SF2_DIR:-$HOME/.cache/perihelion_musicgen/sf2}"
mkdir -p "$DEST"
cd "$DEST"

# Source repo: https://github.com/bratpeki/soundfonts (aggregator, MIT repo
# license for the README/scripts; each soundfont keeps its own upstream
# license, all four below are CC0 1.0 per that repo's table, originating
# from rKhive.com's CC0-licensed bank collection: https://rkhive.com/legal.html
declare -A FILES=(
  [ChaosBank.sf2]="SF2/GM/ChaosBank.sf2"
  [Jnsgm2.sf2]="SF2/GM/Jnsgm2.sf2"
  [Masterpiece.sf2]="SF2/GM/Masterpiece.sf2"
  [Unison.sf2]="SF2/GM/Unison.SF2"
)
for name in "${!FILES[@]}"; do
  if [ -f "$name" ]; then
    echo "already have $name"
    continue
  fi
  url="https://raw.githubusercontent.com/bratpeki/soundfonts/main/${FILES[$name]}"
  echo "fetching $name <- $url"
  curl -sL -o "$name" "$url"
done
echo "soundfonts ready in $DEST"
