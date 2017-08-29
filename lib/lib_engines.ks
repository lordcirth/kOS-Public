parameter tagged. //Values:
	//"tagged": return tagged engines only
	//"untagged": untagged only
	//"all"
	//invalid args = all

LIST engines IN raweng.
set eng TO List().

if (tagged = "tagged") {
	for e in raweng {
		if (e:tag <> "") {
			eng:Add(e).
		}
	}
}
else if (tagged = "untagged") {
	for e in raweng {
		if (e:tag = "") {
			eng:Add(e).
		}
	}
}
else { set eng TO raweng. }

set jets TO List().
set rapiers TO List().
set nervs TO List().
set rockets TO List().

set jetMinThrust TO 70. //Point at which jets are considered done.


//TODO: Figure out how to exclude payload engines
for e in eng {
	if (e:name = "RAPIER") {rapiers:ADD(e).}.
	else if (e:name = "nuclearEngine") {nervs:ADD(e).}.

	//TODO detect jet/rocket generally?.
	else if (e:name = "turboFanEngine") {jets:ADD(e).}.
	//Matches many liquid rocket engines, not all
	else if ((e:name:contains("Liquid")) OR (e:name:contains("aerospike"))) {rockets:ADD(e).}.

	else {Print "Error: Unclassified engine " + e:name + " will be ignored".}.
}.

Function RapierSet {
//List of rapier engines, bool air
parameter air.
	for r in rapiers {
		if NOT (air = r:PrimaryMode) { r:togglemode(). }.
	}.
}.


Function EngineSet {
//Pass a list of engines, and a bool, on
parameter eList, on.
	if on {
		for e in eList {e:Activate.}.
	}.
	else {
		for e in eList {e:Shutdown.}.
	}.
}.


for r in rapiers {
	set r:autoswitch to false.
}.


Function EngineLimit {
//Pass a list of engines, and the new thrust limit
parameter eList, limit.

	for e in eList {set e:ThrustLimit to limit.}.

}.

// How much LF do we have, excluding that which matches Ox?
Function GetJetBudget {
	set lf to ship:liquidfuel.
	set ox to ship:oxidizer.
	set matched_lf to (ox/11 * 9).
	set extra_lf to lf - matched_lf.
	return extra_lf.

}.

set airbrakes TO List().

for p in ship:parts {
	if (p:name = "airbrake1") {airbrakes:ADD(p).}.

}.

Function AirbrakeSet {
//Pass a list of engines, and a bool, on
parameter bList, on.
	if on {
		for b in bList {b:getmodule("ModuleAeroSurface"):doaction("extend",true).}.
	}.
	else {
		for b in bList {b:getmodule("ModuleAeroSurface"):doaction("retract",true).}.
	}.
}.
