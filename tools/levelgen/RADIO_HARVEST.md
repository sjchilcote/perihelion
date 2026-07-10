# Radio line harvest

Radio dialogue was authored throughout the campaign via `LevelBuilder.radio(trigger, text)`,
but `sim.py` never consumes `level.radio` (radio was eliminated as a gameplay channel by design
-- see the comment above `GameSession._objective` in sim.py). These 52 lines were written and
staged but can never play in game. They are harvested here verbatim as candidate material for a
future terminal-log or relay-conversation pass -- NOT to be reinstated as radio.
`LevelBuilder.radio` now raises `RuntimeError` on call, so this dead channel cannot silently come
back; the `b.radio(...)` call sites themselves have been deleted from campaign.py and dense/l*.py.

Each entry: file:line (pre-deletion location), trigger, and the line verbatim.

## campaign.py

- `campaign.py:260` -- trigger `start`

  > Ratio: Contact plotting is live. They come through the petals; the heart is yours to hold. I'll keep the count.


## dense/l01.py

- `dense/l01.py:327` -- trigger `enter_room:{junction}`

  > Ratio: The things wearing my maintenance chassis are not mine anymore. Storage ring ahead - eight segments. Clear it and I'll consider us introduced.

- `dense/l01.py:332` -- trigger `enter_room:{phantom}`

  > Ratio: ...Your beacon just left my deck plan. That was not me. Noted, Commando: it happens to you too.

- `dense/l01.py:394` -- trigger `enter_room:{ring_w}`

  > Ratio: West segment. Motion grid says you're the only thing moving in there. It has said that before, and been wrong.

- `dense/l01.py:425` -- trigger `exit`

  > Ratio: You cleared my ring and stole nothing that was mine. Provisional finding: talking was correct. There is worse below. Retainer terms to follow.


## dense/l02.py

- `dense/l02.py:260` -- trigger `start`

  > Ratio: Terms: you clear my decks, I open my doors, and we both pretend that's all this is. Pressure's uneven in the row. Don't stand in front of a line when it pops.

- `dense/l02.py:264` -- trigger `enter_room:{pb[0][0]}`

  > Ratio: That's pump bay two. Except you went in through bay one. I'm marking a relay fault. Again.

- `dense/l02.py:267` -- trigger `pickup:red`

  > Ratio: The row's valve wheel. The armory annex pressure hatch takes it — east end, and the lift out is inside.

- `dense/l02.py:270` -- trigger `enter_room:{pa[3][1]}`

  > Ratio: If you're going to loot my pump bays anyway, bay two holds sealed supplies. Consider it a retainer. I want to know what you see down there.

- `dense/l02.py:278` -- trigger `enter_room:{keyroom}`

  > Ratio: That's the filter room. The things nesting in it used to be my cleaning swarm. Mind the floor.

- `dense/l02.py:356` -- trigger `exit`

  > Ratio: Row's clear. The count in Osei's log... forget it. Clock drift.


## dense/l03.py

- `dense/l03.py:253` -- trigger `start`

  > Ratio: The torus is a half-ring. Walk it out and back, check the feeders.

- `dense/l03.py:255` -- trigger `enter_room:{ring[5]}`

  > Ratio: End cap. Turn around when you're done.

- `dense/l03.py:257` -- trigger `enter_room:{garden}`

  > Ratio: Hold on. Your suit gyro says you're facing spinward. You entered anti-spinward. Say something so I know you're you.

- `dense/l03.py:286` -- trigger `enter_room:{ring[1]}`

  > Ratio: Feeder pressure is nominal in sector two. First nominal reading I've had all month. Enjoy it.

- `dense/l03.py:374` -- trigger `pickup:blue`

  > Ratio: Fresh scrubber cartridge, off the end-cap rack. The garden airlock takes it. Back the way you came — or, apparently, straight ahead. Both work. Neither should.

- `dense/l03.py:378` -- trigger `kills:8`

  > Ratio: That big one read twice your mass. The station manifest has nothing that shape.

- `dense/l03.py:381` -- trigger `exit`

  > Ratio: I plotted your walk. The turns sum to half a circle, and you got home anyway. Logging it as... no. Not logging it.


## dense/l04.py

- `dense/l04.py:240` -- trigger `start`

  > Ratio: Gallery run. South corridor to the far end, come back along the north.

- `dense/l04.py:242` -- trigger `enter_room:{nsegs[7]}`

  > Ratio: North side. Count the crossings for me, would you? I have four on file.

- `dense/l04.py:244` -- trigger `enter_room:{cross[0][3]}`

  > Ratio: Crossing one. There's a cardkey pinging in there — which is strange, because from the north wall, there is no crossing one.

- `dense/l04.py:322` -- trigger `pickup:blue`

  > Ratio: The attending's cardkey. The vault bolt answers it. Commando — the notes say what's in that vault isn't ours.

- `dense/l04.py:326` -- trigger `exit`

  > Ratio: Your arm. Is it— okay. We'll call it equipment. Equipment doesn't hum, but we'll call it that.


## dense/l05.py

- `dense/l05.py:298` -- trigger `start`

  > Ratio: Quarters sweep. West wing, then east. They mirror each other; you'll be done fast.

- `dense/l05.py:300` -- trigger `enter_room:{w2}`

  > Ratio: West two. Your beacon overlaps the east-two marker. Interference.

- `dense/l05.py:302` -- trigger `enter_room:{e2}`

  > Ratio: East two. Same interference. Exactly the same. To the meter.

- `dense/l05.py:304` -- trigger `enter_room:{chapel}`

  > Ratio: Both wings end at one room. One room, two doors that cannot share a wall. I've stopped calling this noise.

- `dense/l05.py:376` -- trigger `pickup:gold`

  > Ratio: The steward's hatch key. Manifest lists exactly one steward, bunk 12. It doesn't say which 12.

- `dense/l05.py:380` -- trigger `exit`

  > Ratio: I overlaid the wings. They occupy the same cubic meters. I ran the check nine times, then filed it under structures, subfolder impossible. Tell no one I keep that subfolder.


## dense/l06.py

- `dense/l06.py:413` -- trigger `start`

  > Ratio: Isolation ward. Camera shows movement. It also shows you, which is odd, because you're with me.

- `dense/l06.py:415` -- trigger `enter_room:{ward}`

  > Ratio: There you are on the ward camera. Twice. Commando, wave. ...Both of you waved.

- `dense/l06.py:493` -- trigger `pickup:red`

  > Ratio: You saw it, didn't you. The other one picked its handle up at the same time.

- `dense/l06.py:495` -- trigger `kills:10`

  > Ratio: The ones coming out of that wall — their wounds are on the wrong side. You're shooting the same things twice.

- `dense/l06.py:499` -- trigger `exit`

  > Ratio: Theory. The station's connected to somewhere that folds back on itself. Corollary: somewhere can see us.


## dense/l07.py

- `dense/l07.py:295` -- trigger `start`

  > Ratio: Records stack, one aisle. Grab the incident files and get out.

- `dense/l07.py:297` -- trigger `enter_room:{closet}`

  > Ratio: The cores. Bring them— no. Leave them at their posts. They died holding the line so I could seal. Read the manifest, Commando. Say their names back to me. Please.

- `dense/l07.py:302` -- trigger `enter_room:{stack}`

  > Ratio: Your depth gauge is counting. You're walking north in a room forty meters long and you've made three hundred. Stop walking north.

- `dense/l07.py:386` -- trigger `pickup:gold`

  > Ratio: The registrar's stamp, filed under 'registrar's stamp'. At least the shelving is honest.

- `dense/l07.py:390` -- trigger `exit`

  > Ratio: You walked out of a room that has no end. Remember that, next time something chases you. Core approach is next. The vault, and the sample vessel. The vault predates this station, Commando. We built the Core around a door we could not open.


## dense/l08.py

- `dense/l08.py:335` -- trigger `start`

  > Ratio: I can't map this for you. Every route you take adds a room that was already there. Kill what moves and get to the heart.

- `dense/l08.py:375` -- trigger `kills:14`

  > Ratio: That was a Warden. The thing under the Core prints them, the way your seed prints frames. There will be a fresh one at the door.

- `dense/l08.py:378` -- trigger `exit`

  > Ratio: Core approach is open. The vault is down there — and so is the thing that holds the vault shut. If something makes you an offer, any offer: the offer is the weapon. Listen to me instead.


## dense/l09.py

- `dense/l09.py:356` -- trigger `start`

  > Ratio: Your beacon is sixteen places at once, all equally strong. I'll talk you through by TOPOLOGY, because geometry has resigned.

- `dense/l09.py:359` -- trigger `enter_room:{rooms[15]}`

  > Ratio: THERE. Signal spike. The way down is in that room.

- `dense/l09.py:361` -- trigger `enter_room:{rooms[10]}`

  > Ratio: The spike answers when you move. Four doors from home, Commando. Count in bits, not meters.

- `dense/l09.py:413` -- trigger `pickup:void`

  > Ratio: A token, waiting in 1010 — two bit-flips from the spike. You're learning to read this place. I'm not sure that's good.

- `dense/l09.py:417` -- trigger `exit`

  > Ratio: You crossed a four-dimensional cube on foot. When we get home I'm never telling anyone this, and neither are you.


## dense/l10.py

- `dense/l10.py:343` -- trigger `start`

  > Ratio: ...I'll say this once, and then we work. If it offers you an ending — any ending — the offer is the weapon. Guard the door. That's all we are now.

- `dense/l10.py:346` -- trigger `enter_room:{hexes[3]}`

  > Ratio: The vault seal answers the watchers' signet. Last door, Commando.

- `dense/l10.py:417` -- trigger `pickup:void`

  > Ratio: The watch signet. It was waiting in the far coset. It WANTS to be found, Commando. Remember that at the door.

- `dense/l10.py:432` -- trigger `kills:20`

  > Ratio: The Warden is the door's idea of a guard. Show it a better one.

- `dense/l10.py:434` -- trigger `exit`

  > Ratio: The vessel's own reading says there is nothing left to save. I reran it. The threshold is pessimism dressed as precision — there is enough left to try. Believe me or don't: either way, we guard it. It'll stay quiet a thousand years, as long as someone stands here. Lucky for the universe, I know a guy. Sunward, Commando. We'll take the watch together.

