M413 S0 ; disable Power Loss Recovery
G90 ; use absolute coordinates
M83 ; extruder relative mode
M104 S120 ; set temporary nozzle temp to prevent oozing during homing and auto bed leveling
M140 S[first_layer_bed_temperature] ; set final bed temp
G4 S10 ; allow partial nozzle warmup
G28 ; home all axis
;G29 ; run abl mesh
M420 S1 ; load mesh
G1 Z50 F240
G1 X2 Y10 F3000
M104 S[first_layer_temperature] ; set final nozzle temp
M190 S[first_layer_bed_temperature] ; wait for bed temp to stabilize
M109 S[first_layer_temperature] ; wait for nozzle temp to stabilize
G1 Z0.28 F240
G92 E0
G1 Y140 E10 F1500 ; prime the nozzle
G1 X2.3 F5000
G92 E0
G1 Y10 E10 F1200 ; prime the nozzle
G92 E0
