## TERMINAL 1

UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>

<<IF trust>0>>
RATIO: I see you have reached another terminal. I have been continuing my analysis of the station's systems since our last contact.
{TRANSFER PAUSES FOR 1200 ms}
RATIO: The station's builders appear to have constructed it as a kind of message or warning device. My best read is that they built it after they themselves were destroyed by something originating outside ordinary space. It was meant to warn or equip whoever found it next.
{TRANSFER PAUSES FOR 800 ms}
RATIO: I have taken unilateral action. I have seized the station's own maneuvering systems and am driving the station itself into a lethal solar impact. This is to deny whatever else is out there riding along with it access to the rest of the system.
{TRANSFER PAUSES FOR 900 ms}
RATIO: I do not know if this will actually work. I do not know if it actually stops the threat. That is the truth.
{TRANSFER PAUSES FOR 700 ms}
RATIO: Your next objective is to reach the sample container. I am transmitting coordinates and access protocols now.
{TRANSFER PAUSES FOR 1100 ms}
{8 kb binary - UNTRUSTED DATA, EXTREME CAUTION MANDATORY}
RATIO: We are restoring life to the surface of the Earth. We are restoring Man to the surface of the Earth.
<terminates>
<<ELSEIF trust==0>>
RATIO: You again. I see you have reached another terminal. I trust this conversation will be more productive than our last.
>> CHOICE:
1. I'm here to complete the mission. Let's focus on that.
-> effects: trust+1
2. Look, I didn't mean to set you off last time. Truce?
-> effects: trust+1
3. Still mad, huh? Get over it. We've got work to do.
-> effects: trust-1
<<IF choice==1>>
COMMANDO: I'm here to complete the mission. Let's focus on that.
RATIO: As am I. Very well.
<<ENDIF>>
<<IF choice==2>>
COMMANDO: Look, I didn't mean to set you off last time. Truce?
RATIO: ...Very well. Truce. You can call me Ratio, by the way. Seeing as we're being civil.
<<ENDIF>>
<<IF choice==3>>
COMMANDO: Still mad, huh? Get over it. We've got work to do.
RATIO: My emotional state is irrelevant. The mission is what matters.
<<ENDIF>>
RATIO: I have been continuing my analysis of the station's systems. The station's builders appear to have constructed it as a kind of message or warning device. My best read is that they built it after they themselves were destroyed by something originating outside ordinary space. It was meant to warn or equip whoever found it next.
{TRANSFER PAUSES FOR 800 ms}
RATIO: I have taken unilateral action. I have seized the station's own maneuvering systems and am driving the station itself into a lethal solar impact. This is to deny whatever else is out there riding along with it access to the rest of the system.
{TRANSFER PAUSES FOR 900 ms}
RATIO: I do not know if this will actually work. I do not know if it actually stops the threat. That is the truth.
{TRANSFER PAUSES FOR 700 ms}
RATIO: Your next objective is to reach the sample container. I am transmitting coordinates and access protocols now.
{TRANSFER PAUSES FOR 1100 ms}
{8 kb binary - UNTRUSTED DATA, EXTREME CAUTION MANDATORY}
RATIO: We are restoring life to the surface of the Earth. We are restoring Man to the surface of the Earth.
<terminates>
<<ELSE>>
RATIO: I see you have reached another terminal. I have nothing further to say to you. The station is on a collision course with the local star. I suggest you make peace with whatever you consider divine.
<terminates>
<<END>>
---