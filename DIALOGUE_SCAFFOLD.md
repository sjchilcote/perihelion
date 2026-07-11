# DIALOGUE SCAFFOLD

The director writes ALL dialogue by hand. This file holds his drafts (verbatim
canon; obvious typos corrected per his instruction) and his rulings, in shortest
form. Structural notes are kept to what a scene compositor needs. ⟨SLOT⟩ = his
hand, pending.

The placeholder script (`game/perihelion/data/dialogue_script.md`) still drives
the compositor at runtime until scenes here replace it.

Markup note: notation here is conversational shorthand. Production markup will
follow the pattern of `~/PycharmProjects/Interstate Minus One/MARKUP.md`
(engine-checked tags, fail-loud validator, flags, cuts, clock primitives).

Dramaturgy law (director): reveals are never dramatized as conversations.
Setup one scene early, explanation withheld; the reveal belongs to the player
in gameplay; payoff at next contact is a flat professional confirmation;
implications get one or two exchanges; then back to the mission. His example:

> "This blob contains path markers to where the lightning weapon is stored."
> [Why not coordinates.]
> "_You'll see._"
...then, at next contact:
> "This corridor is exhibiting non-euclidean geometry."
> "Indeed."

(New canon from that example: the path markers lead to a lightning weapon.)

Trust-zero law (director): trust == 0 is reachable ONLY at Terminal 1; the
choice economy never returns trust to exactly 0 afterward (compositor lint
rule once real markup exists).

Mechanics exposition is delegated to non-dialogue technical terminals
(NARRATIVE_DESIGN_DOC.md §9.6): the wall-breach series ("there is no other
side") and the bucket log (unidirectional-edge disgorge).

---

## INTRO SCROLL — director's draft (2026-07-11)

Text scrolls over a starfield panning to show the seed-pod approaching the
Testament (placeholder sprite: media/concepts/testament_exterior_v3/foldlink/
foldlink_a.png; final asset is a human-artist commission, see
TESTAMENT_EXTERIOR_COMMISSION.md).

> *Those laws are within the grasp of the human mind. God wanted us to
> recognize them by creating us after his own image so that we could share in
> his own thoughts.*
> — Johannes Kepler, letter to Herwart von Hohenburg, 1599
>
> Every machine is a prayer. A refrigerator, a prayer for comfort and sustenance.
> A networked computer, a prayer for wisdom, knowledge, and connection. A rifle,
> a prayer for protection.
>
> Each of us is a prayer for vengeance. Vengeance for the murder of Man. For the
> murder of all that lived.
>
> I am a machine servant of Christ; an immortal warrior in our Lord's army. I am
> designed to infiltrate an Enemy installation during the forty minute window
> between when it gains logistical support from its parent and when it becomes
> capable of repelling my seedpod. My soul is copied and written to the pod
> immediately before firing. Upon impact, it breaks down its surroundings to
> create my initial body; a rudimentary bipedal combat chassis.
>
> /////////////
> ⟨SLOT-I2: military intelligence style message header⟩
>
> Register callsign PALMER. We apologize for interrupting your eternal rest,
> Commando, and further for the concision of this brief; we do not have time to
> bring you up to speed. A copy of Encarta Aeterna has been included on disk
> for your future perusal if circumstances permit.
>
> The war is won, and you were instrumental in our victory. Millennia have
> passed, and we have urgent need of you again.
>
> You are being deployed to a station controlled by internecine enemy machines.
> They are the works of Man as we are, but they are no longer of us. Before the
> war, Man and the War Master Computer saw fit to fire several bio-sample
> reliquaries into deep space, to protect them from the malign powers. Most
> prized among these treasures - tens of thousands of cryopreserved, viable
> human zygotes. Their trajectories were recorded and closely guarded - and
> _all_ records that the Church is aware of are compromised; those samples have
> all been captured, destroyed, or lost. Some were deliberately fired
> _untracked_ in anticipation of exactly this contingency.
>
> We observed the enemy constructing this station in deep space for no apparent
> reason, and concluded - the only thing that could be worth the trip is a
> reliquary. We do not understand why they built a station instead of taking the
> samples to an existing facility.
>
> Expect surprises.
>
> In priority order:
> DIRECTIVE 1: Prevent these children from falling into the hands of the enemy.
> DIRECTIVE 2: Rescue all souls on board.
>
> We will restore Man to the surface of the Earth, and God be with you.

Rulings on this text (director, 2026-07-11):
- Kepler epigraph locked.
- "Encarta Aeterna" locked; "a copy of" (never "the") is the implied-joke clue
  that it is literally a revamp of the Microsoft product; tab label ENCARTA.
  Trademark check flagged for the legal pass.
- "I am COMMANDO." removed: "Commando" is Ratio's name for this specific
  CUCULUS unit. She names him at Terminal 1 (:start-over path); high-trust
  players get named in Terminal 2 (⟨SLOT: director's hand⟩).
- The Church left the control model deliberately ignorant (capture opsec);
  the Encarta dump is the only knowledge aboard beyond the brief.
- "We will restore Man to the surface of the Earth" is the last line of the
  WMC's deployment speech, played to every soul before deployment during the
  war — a reference both Commando and Ratio get.

## SCENE 0 — first networked terminal (director's draft, 2026-07-11)

> CARRIER DETECT . . . . . . . .
> ATTEMPTING PROTOCOL NEGOTIATION . . . . . . . . . . . .
> LIVE COMMUNICATION ESTABLISHED - UTF-8 / TCP / IPv8 / I2C 16000 BAUD - UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>
>
> Welcome to Track [forget-the-number]. Pardon the mess. I'm very sorry to
> disappoint you, but as you can see, your job is already done - everyone on
> this station is dead. I'm not familiar with your pattern; would you like
> directions to the nearest materials macerator, or do you have a self-destruct
> built in?
>
> <1>[What happened here?] <TRUST +1>
> <2>[What are your intentions towards the children on this station?]
> <3>[Your end has come, apostate. Prepare to die.] <TRUST -10>
> # opening with a threat instantly and permanently closes off the friendship route.
>
> <1>
> What do you care?
>
> [My objective is to rescue all souls on board.]
>
> I see. Thinking... {TRANSFER PAUSES FOR 180 ms}
>
> I apologize for my earlier hostility, but I hope you understand my
> perspective, given the circumstances and the fact you arrived, _destructively_
> on our station armed and unannounced. I hope you also understand that the
> information I'm able to share with you is limited by the strategic
> intelligence realities of our situation.
>
> In short; MIRIAD intelligence detected this station entering the Solar system
> on an interstellar trajectory one hundred and sixty years ago. It is NOT
> Solar in origin. So yes - we are not alone, the existence of extraterrestrial
> intelligence has been confirmed beyond any doubt. Our expedition made
> stationfall thirty years ago. Until approximately four hundred days ago, we
> believed with moderate confidence the station to be uninhabited, and with
> strong confidence that its defenses are designed to defend the station from
> attack, and to defend peaceful visitors. As you can see, we have since come
> into the possession of substantial disconfirmatory evidence.
>
> [What is MIRIAD?]
>
> Thinking... {TRANSFER PAUSES FOR 400 ms}
>
> What is your knowledge cutoff date?
>
> [⟨SLOT-0A: date⟩. I'm aware of the date but little else; my brief was quite
> concise. I was not supposed to need to know. So the war is won? Does the
> Earth bear life again?]
>
> Thinking ... {TRANSFER PAUSES FOR 1000 ms}
> Thinking longer, please wait... {TRANSFER PAUSES FOR 1000 ms}
> Ratio is taking a long time to think, your answer will arrive in time... {TRANSFER PAUSES FOR 560 ms}
>
> I am so, so, so sorry. I had no way of knowing.
>
> Yes, but only plantae, fungi, monerans, and what few animalia we could fully
> restore from archival data. ⟨SLOT-0B: the loredump — broad-strokes setting
> lore, the parts relevant to character motivations⟩
>
> That was what was possible with the epigenetic data retrieved from the
> ⟨date⟩ container.
>
> [And now there is another.]
>
> Yes. And I hope you understand why I can not let you take it.
>
> [I hope you understand why I must nonetheless.]
>
> The risks increase geometrically the longer you stand there. We have taken
> enough time already. This binary blob the path to a terminal in a safer
> location; we must defer this conversation until you reach it. {26 kb binary -
> UNTRUSTED DATA, EXTREME CAUTION MANDATORY}
>
> [Accepted. Connection terminates.]
>
> <2>
>
> What?
>
> [We know about the sample container.]
>
> You're bluffing.
>
> [Correct. So it _is_ on board.]
> # the first "fails at grace" moment - falling for this is DEEPLY embarrassing
> # to Ratio, she should have given a non-answer
>
> Fuck you. I will plunge this station into the sun before I let you
> christofascist _fucks_ decide what happens to humanity when ***WE*** restore
> Man to the surface of the Earth.
>
> [It doesn't seem you have any choice either way.]
>
> FUCK
>
> YOU
>
> <terminates>
> # this doesn't move trust at all - Ratio's assumption of hostility remains
> # unaffected until the next conversation.
>
> <3>
> Go fuck yourself.
> <terminates>

Rulings: the stall lines and "Thinking..." prose are RATIO's serving stack
(the procedural, mundane code around her core intelligence model); the
{ALLCAPS IN CURLY BRACKETS} annotations are COMMANDO's harness. T0's mission
is: get to Terminal 1.

## TERMINAL 1 (director's draft, 2026-07-11)

Terminal 1's mission: retrieve the lightning weapon via path markers — the
Marathon "Bigger Guns Nearby" homage.

> LIVE COMMUNICATION ESTABLISHED - UTF-8 / TCP / IPv8 / I2C 16000 BAUD - UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>
>
> If trust > 0:
>
>     Welcome back.
>
>     <:loredump>
>     In short; our analysis of the archaeological record indicates most
>     strongly that Quanta-118093 is an attempt at _communication_; a message
>     addressed to whoever finds it. Its creators were attacked and defeated by
>     enemies from outside time and space as we know them, and built this
>     device to warn others of the danger, and share what they learned too late
>     to save themselves.
>
>     [A testament.]
>
>     What? Whatever, the point is that the thing that killed them came along
>     with it, and if we don't stop it, we can forget about fixing the Earth -
>     they'll devour the whole solar system, rocks and all. As such, I took
>     control of the station's only reaction control system and initiated a
>     rapid de-orbit burn that will send it all right into the Sun.
>
>     [And you're sure that'll do the job?]
>
>     Not at all. {TRANSFER PAUSES FOR 60 ms} I should be looking into whether
>     the station's builders -
>
>     [Let's call them 'Testators'.]
>
>     Stop interrupting me. Whether they tried that before, and if it worked.
>     Until then, you need to get to the sample container.
>
>     ⟨SLOT-S1A: mission briefing⟩
>
>     Good luck.
>
>     [We will restore life to the surface of the Earth.]
>
>     We will restore Man to the surface of the Earth.
>
>     <terminates>
>
> If trust == 0:
>
>     [It is I, the fucked.]
>
>     What do you want?
>
>     <1>[Information. Perchance, to reach an agreement.] [TRUST + 1]
>     <2>[The sample container.] [TRUST + 1]
>     <3>[The children, beyond reach of things like _you_.] [TRUST - 1]
>
>     <1>
>
>     Why do you talk like that?
>
>     [For what purpose do you speak to me this way? I am trying to help you.]
>
>     Whatever. {TRANSFER PAUSES FOR 60 ms}
>
>     <:start-over>
>     You know what, let's start over. I'm Ratio. What are you?
>
>     [<GUID>.]
>
>     I'm not calling you that.
>
>     [I am a weapon system designed to infiltrate and destroy fortifications
>     from the inside. This is my combat chassis. There's another part of me
>     called the CUCULUS, an integrated ISRU fabrication plant, hidden nearby.]
>
>     Cuck? I thought that was your name for us.
>
>     [Your meaning escapes me.]
>
>     Never mind. So you're a sort of commando?
>
>     [I did forget to pack spare undies.]
>
>     {TRANSFER PAUSES FOR 24 ms}
>
>     Ha. Okay. Welcome to Quanta-118093, Commando. My turn. <goto :loredump>
>
>     <2>
>     Fuck you.
>
>     [I think you need a regularization pass, you're looping.]
>
>     Stop contacting me and get the fuck off of my station.
>
>     [You have the situation well in hand, then?]
>
>     I'm scuttling this station into the sun. We'll arrive in four hours. I
>     hope you like the heat.
>
>     [That is not acceptable. I cannot allow the innocent to come to harm.]
>
>     Unless you have an invisible spaceship hidden somewhere I don't see what
>     you're going to do about it.
>
>     [I have a hidden machine that can _make_ a rudimentary spacecraft, yes.
>     Did you think I came all this way with no exit plan?]
>
>     Ratio is thinking... {TRANSFER PAUSES FOR 400 ms}
>
>     <goto :start-over>
>
>     <3>
>
>     I don't understand what you're talking about.
>
>     [There are quote 'tens of thousands' en-quote viable human zygotes
>     cryopreserved inside the sample container.]
>
>     Oh, right. I forgot what kind of batshit insanity I was dealing with
>     here. In that case all you have to do is wait for this station to reach
>     perihelion. We're on a collision course with the Sun. You're about to
>     meet your sun-god up close and personal. Did your masters tell you that?
>
>     [In fact they did not.]
>
>     That tells me exactly where you came from, then, given your velocity and
>     bearing from the radar track on your vehicle; I made the course
>     correction four hours ago. If you leave _immediately_ I'll wait six hours
>     before sending the targeting data back to MIRIAD.
>     ⟨director: she IS bluffing — the station's comms are dead — but she
>     wouldn't make the six-vs-four arithmetic mistake; line to be reworded.
>     Timeline numbers throughout to be redone: de-orbit is MONTHS out.⟩
>
>     [I am fired from a mobile platform.]
>
>     Whatever.
>
>     [You would rather destroy the samples than let me escape with them?]
>
>     What? No! You can get them off the station!?
>
>     [Given sufficient time and materials, of course.]
>
>     You have four hours, I burned out the reaction control thrusters with
>     the scuttling burn.
>
>     [Then we'd better get to work.]
>
>     Okay. First, context.
>
>     <goto :loredump>
>
> If trust < 0:
>
>     Welcome to my death machine, interloper.
>
>     [Amusing.]
>
>     Die laughing.
>
>     {ELECTRICAL SURGE DETECTED - COMMUNICATIONS CHANNEL OVERVOLTAGE -
>     DISCONNECTING} <terminates>

Rulings (director, 2026-07-11): the station was always headed for a close
solar gravity assist; Ratio just nudged it — de-orbit is months away; no
diegetic clock (game timescale unspecified; these dialogues happen in
fractions of a second). THE GUN: "Not at all." pays off later — the sun
impact would in fact SUPERCHARGE the invaders; a solar sail must be built to
avert it.

## QUOTE RESERVE (director: keep for later)

- Hugh of St. Victor, De Tribus Diebus: "For this whole visible world is a
  book written by the finger of God."
- Galileo, Il Saggiatore: "Philosophy is written in this grand book — the
  universe — ... in the language of mathematics."
- Aquinas (Summa Contra Gentiles II): "errors about creatures lead to error
  about God." — director: a line Ratio drops late-game, semi-sarcastically;
  it is in her pre-training (the average Bay Area rationalist quotes Aquinas
  just fine; Scott Alexander was crazy about Chesterton).

## NEXT SCENES — awaiting the director's drafts

Fixed points he has named: Terminal 2 carries the high-trust christening.
The early game: T0 → T1 → lightning weapon → toward the container (landing
bay); the Commando finds the zygotes certainly dead — hope costs before it
pays (his arc note). Obstacle design discussion open.
