Lock steering to prograde.
set slots to Ship:partsnamed("stackDecouplerMini").

for s in slots {
	WAIT 5.
	s:GetModule("ModuleDecouple"):DoEvent("decouple").
}
