//Automatically zero orbital inclination.

COPY lib_safe.ks from 0.
RUN ONCE lib_safe.
COPY lib_text.ks from 0.
RUN ONCE lib_text.
COPY lib_long.ks from 0.
RUN ONCE lib_long.

LOCK STEERING TO VCRS(SHIP:VELOCITY:ORBIT, BODY:POSITION).  //AntiNormal vector

// Ship Longitude and Orbit:Inclination longitude use different reference points.

UNTIL abs(SHIP:ORBIT:LAN - OrbitLong()) < 1 { //Loop info until within 1 degree of AN.
ClearScreen.
Print "Orbit Long:  "  + OrbitLong().
Print "Long of AN:  "  + SHIP:ORBIT:LAN.
Print "Difference:  "  + (SHIP:ORBIT:LAN - OrbitLong()).
Print "Inclination: "  + SHIP:ORBIT:Inclination.
WAIT 0.5.
}.

PrintHUD("At Ascending Node.  Burning.").

//Handy shortcut to taper off thrust starting at 1 deg remaining.
LOCK THROTTLE TO SHIP:Orbit:Inclination / 1.  // Change if needed.
WAIT UNTIL abs(SHIP:Orbit:Inclination) <0.01.
LOCK THROTTLE TO 0.
PrintHUD("Burn complete").
Print "Final inclination: " + SHIP:Orbit:Inclination.

SAFE_QUIT().
