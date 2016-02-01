//Library for dealing with Rapier engines
//All function calls should operate on all Rapiers on the craft.

//Get handles for Rapier engines

SET engines TO SHIP:PARTSNAMED("RAPIER"). //Get list

//Get list of MultiModeEngine modules
SET modules TO List().  //Declare an empty list
FOR e IN engines {
	modules:ADD(e:GETMODULE("MultiModeEngine")).
}.

SET gimbals TO List().  //Declare an empty list
FOR e IN engines {
	gimbals:ADD(e:GETMODULE("ModuleGimbal")).
}.

//===========================================
//Setup complete.  Begin declaring functions.
//===========================================

FUNCTION SetRapiersOn {
	FOR e IN modules {
		e:DOACTION("Activate Engine",true).
	}.
}
FUNCTION SetRapiersOff {
	FOR e IN modules {
		e:DOACTION("Shutdown Engine",true).
	}.
}.

FUNCTION SetRapiersMode { 
parameter mode.		//Pass "AirBreathing" or "ClosedCycle"
	FOR m IN modules {
		IF NOT (mode = m:GETFIELD("mode") ) {
			m:DOEVENT("toggle mode").
		}.
	}.
}.

FUNCTION SetRapiersGimbal {
parameter new.		//Pass "On" or "Off", since True/False is unclear here
	FOR g IN gimbals {
		IF new = "On" {
			//False is Gimbal On ingame
			g:SETFIELD("gimbal",false).
		}. ELSE IF new = "Off" {
			g:SETFIELD("gimbal",true).
		}. ELSE { 
			Print "SetRapiersGimbal: invalid argument!".
			Print "    Pass 'On' or 'Off' ".
		}.
	}.
}.


FUNCTION GimbalOn {
	gimbal:SETFIELD("gimbal",false).  //Disables gimbal, strangely.
}.
FUNCTION GimbalOff {
	gimbal:SETFIELD("gimbal",true).  //Disables gimbal, strangely.
}.
