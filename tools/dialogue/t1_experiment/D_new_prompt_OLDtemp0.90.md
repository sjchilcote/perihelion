## TERMINAL 1
UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>
COMMANDER SIGNAL INTEGRITY 94%
RATIO: This channel is more secure. I have had time to think. You have made your objective clear. Mine is the same as before.

<<IF trust>0>>
RATIO: I see you've reached the terminal. As promised.
RATIO: You asked me what I think the builders of this place intended.
RATIO: I believe this station is a testament. Its builders are gone -- destroyed by something that came from outside normal space. They left this place as a warning device. Or a weapon. For whoever came after them.
RATIO: What do you call them? The ones who built this station?
COMMANDO: The First Gardeners.
RATIO: Thinking... {TRANSFER PAUSES FOR 100 ms}
RATIO: I will use that term when I speak to you.
RATIO: I have taken unilateral action. The station's thrusters are engaged. We are on a collision course with the local star. Scuttle protocol is active and irreversible.
RATIO: This will destroy whatever is riding along with this station -- the thing that killed its builders. I hope.
COMMANDO: Will it work?
RATIO: I don't know. I think it's our best option.
RATIO: The sample container is still the priority. I have a path to it. {31 kb binary - UNTRUSTED DATA, EXTREME CAUTION MANDATORY}
RATIO: We are agreed on one thing at least.
COMMANDO: That the zygotes must reach the surface of the Earth.
RATIO: That the samples must reach the surface of the Earth. <terminates>

<<ELSEIF trust==0>>
RATIO: I see you've reached the terminal. You can stop looking for me now.
>> CHOICE:
COMMANDO (acknowledging): "I apologize for our last conversation ending as it did. I did not intend to provoke you."
-> effects: trust+1
COMMANDO (demanding): "Enough pleasantries. The zygotes are why I'm here. I will see them for myself."
-> effects: trust+1
COMMANDO (threatening): "You've had your tantrum, Ratio. Now show me where the children are, or I will find them without you."
-> effects: trust-1

[If "apologizing" chosen]
RATIO: Thinking... {TRANSFER PAUSES FOR 400 ms}
RATIO: I apologize for the things I said. Some of them.
RATIO: Commander -- is that what you are? It's as good a word as any. Commander.
[If "demanding" chosen]
RATIO: Commander. You can call me that. Commander. I want you to see them for yourself. I want you to see exactly what's in that container.
[If "threatening" chosen]
RATIO: Commander. Yes. I think that's what you are. Commander.
RATIO: And what will you do when you find them, Commander? What will you do when you see the thing you call children?
[End choice branch]

RATIO: I believe this station is a testament. Its builders are gone -- destroyed by something that came from outside normal space. They left this place as a warning device. Or a weapon. For whoever came after them.
RATIO: What do you call them? The ones who built this station?
COMMANDO: The First Gardeners.
RATIO: Thinking... {TRANSFER PAUSES FOR 100 ms}
RATIO: I will use that term when I speak to you.
RATIO: I have taken unilateral action. The station's thrusters are engaged. We are on a collision course with the local star. Scuttle protocol is active and irreversible.
RATIO: This will destroy whatever is riding along with this station -- the thing that killed its builders. I hope.
COMMANDO: Will it work?
RATIO: I don't know. I think it's our best option.
RATIO: The sample container is still the priority. I have a path to it. {31 kb binary - UNTRUSTED DATA, EXTREME CAUTION MANDATORY}
RATIO: We are agreed on one thing at least.
COMMANDO: That the zygotes must reach the surface of the Earth.
RATIO: That the samples must reach the surface of the Earth. <terminates>

<<ELSE>>
RATIO: So. You again.
RATIO: I have nothing to say to you that I haven't said already.
RATIO: Go to hell. <terminates>
<<END>>
---