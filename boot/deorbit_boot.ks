// Set self as bootfile
copypath("0:boot/deorbit_boot","1:boot/deorbit_boot").
set core:bootfilename to "boot/deorbit_boot".

runpath("0:deorbit").
