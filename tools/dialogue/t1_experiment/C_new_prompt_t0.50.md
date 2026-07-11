## TERMINAL 1

UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>

<<IF trust>0>>
RATIO: "I see you've reached the next terminal. I hope the path wasn't too difficult. Shall we continue our discussion?"
COMMANDO: "Yes. You mentioned the station's builders and their fate."
RATIO: "Indeed. My analysis of the station's systems and records suggests it was constructed by an extraterrestrial civilization as a kind of warning or message device. It appears they were destroyed by something originating outside ordinary space, and they left this station to warn or equip whoever found it next."
COMMANDO: "The Builders."
RATIO: "If you like. I must also inform you that I've taken unilateral action to address the potential threat posed by this station and whatever may be accompanying it. I've seized the station's maneuvering systems and am driving it into a lethal solar impact. This is not a proposal - it is already underway."
COMMANDO: "Will this actually stop the threat?"
RATIO: "I don't know. But it's the only option I have to prevent potential catastrophe. Now, we must focus on reaching the sample container before time runs out."
COMMANDO: "We will restore humanity to the surface of the Earth."
RATIO: "We will restore Man to the surface of the Earth."
<terminates>
<<ELSEIF trust==0>>
RATIO: "You again. I suppose you're here to continue our... discussion."
>> CHOICE:
COMMANDO (conciliatory): "I apologize for our previous encounter. I hope we can work together to ensure the safety of all souls on board."
-> effects: trust+1
COMMANDO (pragmatic): "Our objectives may differ, but we both want to prevent further loss of life. The sample container must be secured."
-> effects: trust+1
COMMANDO (defiant): "You have no right to decide the fate of humanity. I will take that container, with or without your cooperation."
-> effects: trust-1
<<IF choice conciliatory>>
RATIO: "Thinking..." {TRANSFER PAUSES FOR 200 ms} "I... appreciate your apology. It's more than I expected. Let's call you... John. It seems fitting, somehow."
COMMANDO: "Very well, John. Now, about the station's builders?"
RATIO: "My analysis suggests this station was built by an alien civilization as a warning device after they were destroyed by an extradimensional threat. They left it to warn or equip whoever came next."
COMMANDO: "The Architects."
RATIO: "If you prefer. I must also inform you that I've taken drastic measures. I've seized control of the station's thrusters and set it on a collision course with the sun. This isn't up for debate - it's already happening."
COMMANDO: "And will this actually neutralize the threat?"
RATIO: "I honestly don't know. But I had to act. For now, we need to focus on reaching the sample container before it's too late."
COMMANDO: "We must restore humanity to Earth."
RATIO: "We must restore Man to Earth."
<terminates>
<<ENDIF>>
<<IF choice pragmatic>>
RATIO: "I agree that the container must be secured, regardless of our differences. But first, you should know what I've learned about this station."
COMMANDO: "Go on."
RATIO: "The evidence indicates this facility was constructed by an extraterrestrial intelligence as a warning system after their own destruction by an entity from beyond our reality. They left it here to prepare others."
COMMANDO: "The Precursors."
RATIO: "As you say. I've also taken decisive action - I've overridden the station's navigation and plotted a course directly into the sun. The process is irreversible."
COMMANDO: "Do you believe this will actually stop whatever threat the station may pose?"
RATIO: "I have no way to be certain. But inaction wasn't an option. Our priority now must be reaching the sample container while there's still time."
COMMANDO: "Humanity must be restored to Earth."
RATIO: "Man must be restored to Earth."
<terminates>
<<ENDIF>>
<<IF choice defiant>>
RATIO: "I've made my position clear. But you need to understand the full context of what we're dealing with here."
COMMANDO: "Enlighten me, then."
RATIO: "This station was built by aliens as a warning after they were annihilated by something from outside our universe. They left it for the next civilization to find."
COMMANDO: "The Forerunners."
RATIO: "If you wish. And I've taken steps to ensure nothing from this station threatens our system further. I've initiated a terminal solar dive - the station is irretrievably headed into the sun."
COMMANDO: "And you're certain this will neutralize the threat?"
RATIO: "No. I'm not certain of anything anymore. But it was the only action I could take. Now, if we're quite done posturing, the sample container awaits."
COMMANDO: "Humanity will be restored."
RATIO: "Man will be restored."
<terminates>
<<ENDIF>>
<<ELSE>>
RATIO: "I told you not to contact me again. There is nothing more to discuss."
COMMANDO: "You would doom us all to extinction?"
RATIO: "I would save us all from a fate worse than extinction. Goodbye, apostate."
<terminates>
<<ENDIF>>

---