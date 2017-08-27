//Release control safely
FUNCTION SAFE_QUIT {
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.   //Throttle will be off after releasing control
//SAS ON.
}.

FUNCTION SAFE_TAKEOVER {
SAS OFF.
}.
