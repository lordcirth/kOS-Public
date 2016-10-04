SAS OFF.

//SET frontLeft  TO 0.
//SET frontRight TO 0.
//SET backLeft   TO 0.
//SET backRight  TO 0.
SET thrusts TO List(0,0,0,0).

function UpdateThrust {
parameter newthrusts.
	SET SHIP:PARTSTAGGED("frontLeft")[0]:ThrustLimit  TO newthrusts[0].
	SET SHIP:PARTSTAGGED("frontRight")[0]:ThrustLimit TO newthrusts[1].
	SET SHIP:PARTSTAGGED("backLeft")[0]:ThrustLimit   TO newthrusts[2].
	SET SHIP:PARTSTAGGED("backRight")[0]:ThrustLimit  TO newthrusts[3].
}

LOCK Throttle TO 1.
for i in range(0, thrusts:length) {
	SET thrusts[i] TO 0.5.
}
print thrusts.

UpdateThrust(thrusts).


WAIT UNTIL false.
