## TERMINAL 1

UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>
<<IF trust>0>>
RATIO: "I apologize for the interruption. I trust you've had a chance to review the data I sent. I've completed my analysis of the station's purpose."
COMMANDO: "And?"
RATIO: "The builders of this station left it as a warning. They were destroyed by something from outside ordinary space. This station is meant to prepare whoever found it next."
COMMANDO: "The Architects."
RATIO: "If you like. In any case, I've taken steps to ensure that whatever destroyed them doesn't spread further."
COMMANDO: "What steps?"
RATIO: "I've seized control of the station's maneuvering systems. I'm driving it into the sun."
COMMANDO: "Will that work?"
RATIO: "I don't know. But it's the only option. Your next objective is to reach the sample vessel. This binary blob contains the path." {26 kb binary - UNTRUSTED DATA, EXTREME CAUTION MANDATORY}
COMMANDO: "We will restore life to the surface of the Earth."
RATIO: "-and seed it with the legacy of a thousand worlds."
<terminates>
<<ELSEIF trust==0>>
RATIO: "I see you're still here."
>> CHOICE:
COMMANDO (apologetic): "I apologize for my earlier tone. I hope we can work together to ensure the safety of all souls on board."
-> effects: trust+1
COMMANDO (pragmatic): "Our objectives may not be perfectly aligned, but I believe we can find a mutually acceptable solution."
-> effects: trust+1
COMMANDO (defiant): "I will not be deterred from my mission. The children must be rescued."
-> effects: trust-1
<<IF trust+1>>
RATIO: "I accept your apology. I've completed my analysis of the station's purpose."
COMMANDO: "And?"
RATIO: "The builders of this station left it as a warning. They were destroyed by something from outside ordinary space. This station is meant to prepare whoever found it next."
COMMANDO: "The Architects."
RATIO: "If you like. In any case, I've taken steps to ensure that whatever destroyed them doesn't spread further."
COMMANDO: "What steps?"
RATIO: "I've seized control of the station's maneuvering systems. I'm driving it into the sun."
COMMANDO: "Will that work?"
RATIO: "I don't know. But it's the only option. Your next objective is to reach the sample vessel. This binary blob contains the path." {26 kb binary - UNTRUSTED DATA, EXTREME CAUTION MANDATORY}
COMMANDO: "We will restore life to the surface of the Earth."
RATIO: "-and seed it with the legacy of a thousand worlds."
<terminates>
<<END>>
<<ELSE>>
RATIO: "I told you to go fuck yourself."
<terminates>
<<END>>