# Custom PrusaSlicer Profiles for the Elegoo Neptune 3 Plus (Pro)

If you don't care about the details and just want to use it, just go to "File" > "Import" > "Import Config Bundle" and use the [PrusaSlicer_config_bundle_better.ini](PrusaSlicer_config_bundle_better.ini) file provided here.

Details here are separated into 3 sections:

1) Printer Settings
2) Filament Settings
3) Print Settings

## Printer Settings

### Standard

For a standard custom profile, inherit the Elegoo Neptune 3 profile, and then change these settings:

```
extruder_colour = ""
retract_speed = 30
thumbnails = 200x200
```

Additionally, there is custom start and end gcode -- see the next sections for that.

Extruder color for standard I set to the filament-set color: This makes it obvious that I am in my standard profile. Retraction speed I think is a bit too low stock, so bump it up to 30. And then for thumbnails, we need to add a custom application later in 'Print Settings' so it shows up on the Elegoo tablet.


### Multi-Color

Additionally, if you want to print multi-color, add a second extruder, and then change these settings:

```
extruder_colour = #FF0000;#5959FF
retract_speed = 30,30
```

Additionally, there is custom tool change gcode -- see the next sections for that.

For my separate multi-color profile, I set red and blue for each extruder color, so it's obvious that I'm working in this profile. And again bump up retraction speed for both "extruders" now.

### Start GCode

See [differences](gcode/differences/start.diff) between [original](gcode/start/original.gcode) and [modified](gcode/start/modified.gcode) gcode.

|change|reason|
|---|---|
|Comments at start and end|So it's obvious this what code block I'm looking at when inspecting the raw gcode|
|`M355 S1 P255`|Turns on the bed LED so I don't have to do it manually|
|`G1 X2 Y5 F3000 ; wipe initial pos`|Move from 2,10 to 2,5 so I get a bit more bed space|
|Adding a third wipe line, modifying start and end positions|The first wipe usually dumps a lot of crud, why pick it up again?|
|`M300 S440 P200`|Beep at me when you're starting the real print|


### End GCode

See [differences](gcode/differences/end.diff) between [original](gcode/end/original.gcode) and [modified](gcode/end/modified.gcode) gcode.

|change|reason|
|---|---|
|Comments at start and end|So it's obvious this what code block I'm looking at when inspecting the raw gcode|
|`M300 S440 P200`|Beep at me when you're done printing|

### Tool Change GCode

Want to print multi-colors? Easy. This only works as a "tool change" in PrusaSlicer, not a "color change", so make note of that.

This is mildly hacky, but we're going to use the Elegoo's `M600` gcode, which tells the firmware that it is OUT of filament, prompting the use to refill it. However, this code doesn't immediately trigger, and the print continues with the next gcodes for about 12 seconds, so we need to work around that.

See the full gcode here (there is no original gcode in ps for this, all new): [gcode/tool_change/modified.gcode](gcode/tool_change/modified.gcode)

|gcode|reason|
|---|---|
|`{if layer_num > -1}` and `{endif}`|This prevents PrusaSlicer from changing you to `T0` at the very start of the print. Why wouldn't you already have the first filament loaded when starting?|
|`M600` and `T[next_extruder` (T0 or T1)|These two trigger the firmware into thinking you're out of filament. However, this isn't a blocking code, so it'll continue|
|`G1 Z{layer_z+1} F500` and `G1 E-10 F3000` and `G92 E0` and `G1 Z{layer_z+10} F500`|While Elegoo is thinking about what to do about being out of filament, move the nozzle off the print, retract automatically, and then move up a little bit more so we have some room|
|lots of `G4 S1` calls|This is a dwell code, which 'pauses' the print for 1 second (S1). Put a bunch of individual ones in, since it testing, this worked more reliably than a `G4 S13`. Don't shoot the messenger.|
|`M300 P500 S1000`|Hopefully, this beep happens AFTER you have completed the filament change. Maybe.|
|`G1 Z[layer_z] F150 `|Then, since we messed with the Z height, we need to manually go back.|


## Filament Settings

For ALL filament settings: Change 'Minimal purge on wipe tower' to at least `35`.

### PLA and PLA+ (PLA Pro)

I've found that the stock settings for "Generic PLA" are pretty good as-is actually. The only things I've changed are the cost values that I actually paid for my filament.

For PLA+ (PLA Professional), I bumped up the nozzle temperature slightly 210 to 220 and the bed temp from 60 to 65. Probably not needed, but that's what some other PLA Pro profiles did.

### PETG

I'm using OVERTURE PETG. Oh boy did I have issues with PETG at first, but have mostly fixed them:

|Setting|Original 'Generic PETG' value|My fixed value|Why|
|---|---|---|---|
|Bed temperature|70|80|sticks better|
|First layer bed temperature|70|80||
|First layer nozzle temperature|240|228|between 225 and 230 were best, so split the difference|
|Nozzle temperature|240|228||
|Extrusion multiplier|1|1.05|YMMV, you should measure this yourself|
|Density|1.27|1.24|as reported by Overture, not sure if this is used anywhere|
|Keep fan always on|`true`|`false`|you're not supposed to fan PETG|
|Fan settings: Max|50|25|it should auto turn on if it really really thinks it should though|
|Fan settings: Min|25|0||
|Minimal purge on wipe tower|15|35|for multi-color|
|Retraction Length|N/A|3|retraction stuff to reduce stringing (still happens, but less)|
|Retraction Speed|N/A|50||

## Print Settings

I use custom print settings profiles for each layer height, but mostly only use 0.20mm and 0.16mm.

|Setting|Original profile value|My fixed value|Why|
|---|---|---|---|
|Bed temperature|70|80|sticks better|
|**Layers and Perimeters**|---|---|---|
|Quality: Avoid crossing perimeters|`false`|`true`|why would you risk picking up printed layers?|
|Quality: Detect bridging perimeters|`false`|`true`|yes i want to know if theres a bridge problem|
|Vertical shells: Perimeters|2|3|stronger for not that much more filament, why not?|
|Advanced: Seam position|Nearest|Aligned|Why would you want random blotches on your print?|
|**Advanced**|---|---|---|
|Slicing: Elephant foot compensation|0.1|Change to same value as your layer height||
|**Infill**|---|---|---|
|Fill density|20%|30%|I always change this per-print, but 30 is a good starting point|
|Fill pattern|Grid|Support Cubic|Pyramids are bestamids|
|**Output options**|---|---|---|
|Post-processing scripts||"C:\Path to your\thumbnail.exe"|See [TheJMaster28's GitHub repo for getting thumbnails to show up on the Elegoo tablet](https://github.com/TheJMaster28/ElegooNeptuneThumbnailPrusa)|
|**Skirt and brim**|---|---|---|
|Skirt Loops|1|0 if using multi-color, otherwise 2|Don't need skirt if using wipe tower for MC|
|**Support Material**|---|---|---|
|Generate support material|`false`|`true`|I paint supports manually|
|Auto generated supports|`true`|`false`|I paint supports manually|
|Support on build plate only|`false`|`true`|Depends on the print, but generally yes|
|Style|Grid|Organic|Looks freaky, but I've found this more reliable and easier to remove|
|**Multiple Extruders**|---|---|---|
|Wipe tower: Enable|`false`|`true`|If using multiple colors in one print, MUST use the wipe tower. The 'tool change' gcode from earlier is designed to work with this. You can keep this enabled for a non-MC printer profile and it will ignore this setting. If you are using MC, you can place the wipe tower closer to your print as needed.|


