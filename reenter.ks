// Deorbit and parachute
SAS off.
//set SASmode to "Retrograde".
lock steering to retrograde.
wait 10.

lock throttle to 1.
wait until ship:periapsis < 30000.
lock throttle to 0.
wait 0.1. // For throttle to turn off first
stage. // Expose heatshield

wait until ship:altitude < 10000.
stage. // Pop chute

