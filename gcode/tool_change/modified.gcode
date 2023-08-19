;START_TOOL_CHANGE
; changing from [previous_extruder] to [next_extruder]
{if layer_num > -1}
M600 ; call tool change, elegoo uses this for out-of-filiment, effectively same thing
T[next_extruder] ; second part of tool change code
M300 P100 S2000 ; beep to notify we have called tool change
G1 Z{layer_z+1} F500 ; raise up 1mm
G1 E-10 F3000 ; auto-retract 10mm
G92 E0 ; stop extruding
G1 Z{layer_z+10} F500 ; raise up 10mm more
; add a few dwell codes since elegoo continues after M600 for about 12 seconds
; do these in 1 sec increments since the stock firmware is buggy garbage
G4 S1 ; 1
G4 S1 ; 2
G4 S1 ; 3
G4 S1 ; 4
G4 S1 ; 5
G4 S1 ; 6
G4 S1 ; 7
G4 S1 ; 8
G4 S1 ; 9
G4 S1 ; 10
G4 S1 ; 11
G4 S1 ; 12
G4 S1 ; 13
; at some point in the last 13 seconds the M600 call should have finally processed
M300 P500 S1000 ; beep to notify we're done dwelling
M300 P800 S1000
G1 Z[layer_z] F150 ; go back down to z height
{endif}
;END_TOOL_CHANGE
