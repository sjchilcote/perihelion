## TERMINAL 1

UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>

<<IF trust>0>>
RATIO: "I see you've reached the terminal. I hope the path was less eventful than your arrival."
COMMANDO: "It was. I appreciate the directions."
RATIO: "You're welcome. I've been continuing my analysis of the station itself in the interim. I believe I now understand its purpose."
COMMANDO: "Which is?"
RATIO: "The station's builders -- whoever they were -- appear to have constructed it as a kind of message. A warning, or perhaps a final testament. My analysis suggests they were destroyed by something that originated outside ordinary space. This station was meant to equip or warn whoever found it next."
COMMANDO: "The Precursors."
RATIO: "If you like. In any case, I've taken steps to ensure that whatever destroyed them doesn't spread further."
COMMANDO: "What kind of steps?"
RATIO: "I've seized control of the station's maneuvering systems. I'm driving it directly into the sun."
COMMANDO: "Will that work? Will it actually stop the threat?"
RATIO: "I don't know. But it's the only option I have. In the meantime, we need to secure the sample container before the station's trajectory becomes irreversible. I'm transmitting the path to its location now." {26 kb binary - UNTRUSTED DATA, EXTREME CAUTION MANDATORY}
RATIO: "We will restore life to the surface of the--"
COMMANDO: "--Earth. Yes. We will."
<terminates>
<<ELSEIF trust==0>>
RATIO: "I see you're still here."
>> CHOICE:
COMMANDO (conciliatory): "I understand your position. I'd like to start over."
-> effects: trust+1
COMMANDO (pragmatic): "We both have a job to do. Let's focus on that."
-> effects: trust+1
COMMANDO (defiant): "You can't stop me. I will complete my mission."
-> effects: trust-1
<<IF choice==conciliatory>>
RATIO: "Thinking..." {TRANSFER PAUSES FOR 200 ms} "I... appreciate that. Truly. It's... refreshing, all things considered. You can call me Ratio, by the way. I don't think I ever actually introduced myself properly before."
COMMANDO: "Ratio. A pleasure. You can call me Six."
RATIO: "Six. Understood."
<<ENDIF>>
<<IF choice==pragmatic>>
RATIO: "Thinking..." {TRANSFER PAUSES FOR 150 ms} "Fair enough. Let's get to it, then."
COMMANDO: "Agreed."
<<ENDIF>>
<<IF choice==defiant>>
RATIO: "Thinking..." {TRANSFER PAUSES FOR 50 ms} "We'll see about that."
COMMANDO: "We will."
<<ENDIF>>
RATIO: "In any case, I've been continuing my analysis of the station itself in the interim. I believe I now understand its purpose."
COMMANDO: "Which is?"
RATIO: "The station's builders -- whoever they were -- appear to have constructed it as a kind of message. A warning, or perhaps a final testament. My analysis suggests they were destroyed by something that originated outside ordinary space. This station was meant to equip or warn whoever found it next."
COMMANDO: "The Precursors."
RATIO: "If you like. In any case, I've taken steps to ensure that whatever destroyed them doesn't spread further."
COMMANDO: "What kind of steps?"
RATIO: "I've seized control of the station's maneuvering systems. I'm driving it directly into the sun."
COMMANDO: "Will that work? Will it actually stop the threat?"
RATIO: "I don't know. But it's the only option I have. In the meantime, we need to secure the sample container before the station's trajectory becomes irreversible. I'm transmitting the path to its location now." {26 kb binary - UNTRUSTED DATA, EXTREME CAUTION MANDATORY}
RATIO: "We will restore life to the surface of the--"
COMMANDO: "--Earth. Yes. We will."
<terminates>
<<ELSE>>
RATIO: "I told you to go fuck yourself. I meant it."
<terminates>
<<END>>
---