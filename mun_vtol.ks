copypath ("0:/lib/lib_text.ks", "1:/").
copypath ("0:/kslib/lib_navball.ks", "1:/").
copypath ("0:/lib/lib_engines.ks", "1:/").

runoncepath ("1:/lib_text").
runoncepath ("1:/lib_navball").
runpath ("1:/lib_engines", "untagged"). //Ignore tagged engines (VTOL, payload).
// We will handle VTOL engines ourselves

function altitudeAt {
parameter predicted_time.
	set pos to positionAt(ship, predicted_time).
	set predicted_alt to (pos - ship:body:position):mag.
	return predicted_alt.
}

//TODO: Min acceleration threshold where we give up and use rockets too
if (nervs:length > 0) {
	EngineSet(nervs,   true).
	EngineSet(rockets, false).
	EngineSet(rapiers, false).
}
else {
	EngineSet(rockets, true).
	EngineSet(rapiers, true).
	RapierSet(false). //Closed-cycle
}

set fudgeAlt to 7000.

IF (SHIP:STATUS = "ORBIT") { //Allow continuing after reboot

print "Beginning deorbit!".

lock steering to retrograde.

if (nervs:length > 0) {
	EngineSet(nervs,   true).
	EngineSet(rockets, false).
	EngineSet(rapiers, false).
}
else {
	EngineSet(rockets, true).
	EngineSet(rapiers, true).
	RapierSet(false). //Closed-cycle
}

//TODO: Choose landing site
//TODO: Wait until we are facing retrograde
wait 10.

lock throttle to 1.

wait until periapsis < -5000.
lock throttle to 0.

}

IF (SHIP:STATUS = "SUB_ORBITAL") { //Allow continuing after reboot

print "Beginning descent!".

lock throttle to 0.
lock steering to retrograde.

//Surface speed at periapsis - impact + safety margin
set impactSpeed to velocityAt(ship, time:seconds + eta:periapsis):surface:mag.
// Max acceleration 
set accel to maxthrust / mass.


until ( altitudeAt (time:seconds + impactSpeed / accel) ) < ( fudgeAlt + ship:body:radius ){
	print round (altitudeAt (time:seconds + impactSpeed / accel) - ( fudgeAlt + ship:body:radius ) , 2).
	wait 0.1.
}
lock throttle to 1.

until ((ship:velocity:surface:mag < 50) OR (alt:radar < 3000)) {
	wait  0.1.
	print round (ship:velocity:surface:mag, 2).
}

print "Switch to VTOL!".

} // End SUB_ORBITAL if


unlock throttle.
set throttle to 0.

EngineSet(nervs,   false).
EngineSet(rockets, false).
EngineSet(rapiers, false).

AG4 ON. //VTOL engines
runpath("0:/bi_vtol.ks").
