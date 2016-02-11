# kOS-Public
Various useful libraries and scripts for Kerbal Operating System.  Copy scripts to your KSP/Ships/Script folder to use with kOS.  Note that kOS does not look for scripts in subfolders, so move libraries out of lib folder .

If using ssto.ks or deorbit.ks, keep in mind that the scripts and their dependencies use over 10k memory in kOS.  Use the radial kOS chip, or turn the memories to max on the others.

**To use the automatic ascent:**
* Install a kOS processor, preferably the tiny radial one, in the craft.
* Set it's boot script to boot.ascension.ks, or copy and modify it for another craft.
* Launch.  It should now fly to orbit automatically.
* The script should work for any plane that uses purely rapier engines to ascend.


**To use the automatic descent & landing:**
* COPY deorbit.ks FROM 0.
* RUN deorbit.ks.
* Sit back and wait.
* The landing script assumes that your plane is agile and relatively robust.
* If your plane does not have airbrakes, increase BurnLong for a shallower trajectory.
* It has not been tested with large craft.  Test results are welcome!
* Dynamic pressure peaks at around 28 kPa.
