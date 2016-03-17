# Gugulele (G6)
OpenSCAD scripts to generate parametric 3D models of gourd shaped ukuleles suitable for 3D printing.

## Usage
1. include G6 into an openscad project

   e.g. In a new OpenSCAD file my-uke.scad
 ```
include <../G6.scad>;
```
2. override any parameters in G6-params.scad
   e.g. In my-uke.scad
 ```
include <../G6.scad>;

// Overriding Default Rendering Resolution Params
HIRES = 30; 
DEFRES = 20; 
LORES = 20;

// High level params
MODEL = 3;
HEAD_STYLE = 2;
F_GAP = 90;
B_GAP = 90; 
C_GAP = 90; 
USE_SCREWS = true;
SNDHOLE_STYLE = 6;
SPINE_STYLE = 2;   
BRACE_STYLE = 2;   
TUNER_STYLE = 3;
PICKUP_STYLE = 1;
SHOW_LOGO = true; 
```
3. run and see the generated result!

   e.g. from command line
 ```
 > openscad -o my-uke.stl my-uke.scad
 > open my-uke.stl
```

## Warning
If you set the resolution as suggested in the example above, it could take a few minutes to generate the rough looking output STL file. This is often sufficient for debugging and preview. If you want a nice looking file for 3D printing, I would suggest setting HIRES to 180 or above, DEFRES to 30 or above, and LORES to 20 or above.  This configuration may take hours to render, at least until OpenSCAD can optimize its performance with effective multi-threading.

## Credits
G6 uses the excellent Nuts n Bolts library (https://github.com/JohK/nutsnbolts) to render screws and holes.

If you use G6 to generate and print a ukulele successfully please give credit to G6 and shoot me an email!
