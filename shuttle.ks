//Made to launch the Guppy v3 shuttle, but should work for most rockets?

set target_alt to 80000.

set pitch to 90.
lock steering to heading(90,pitch).

lock throttle to 1.
stage.

wait until (altitude > 1000) or (ship:verticalspeed > 300).
set pitch to 85.

lock pitch to 90 * (1 - (apoapsis / target_alt )).

wait until apoapsis > target_alt - 10000.
lock throttle to 0.

// TODO: circularize

lock pilotmainthrottle to 0.
