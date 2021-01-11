# Gugulele (G6)
OpenSCAD scripts to generate parametric 3D models of gourd shaped ukuleles suitable for 3D printing.  Check out some of the generated models here:

 * https://www.thingiverse.com/thing:1868201
 * http://www.thingiverse.com/thing:1007035
 * http://www.thingiverse.com/thing:1057746
 * http://p3d.in/kLuhJ/xray+spin

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

If you use G6 to generate and print a ukulele successfully please give credit to G6 and shoot me an email! brian dot guan at gmail dot com.


## Random Thoughts
The hardest part for me is to deal with the lack of spline in OpenSCAD.  I have to subtract scaled arc from rectangle and revolve it to get to a funnel shape for the shoulder, and similarly scaled different quadrants of sphere to get an ellipsoid.  Also due to "functional" nature of OpenSCAD, I have to contort the fret calculation by using some crazy recursive function.  Filleting also is a challenge as I have to accomplish that with Minkowski sum of small sphere
and the main parts with sharp edges.

The most painful part is that OpenSCAD is painfully slow when rendering at high resolution, as it is single threaded and not utilizing GPU unlike professional 3D CAD tools.  I have ported this to OnShape Feature Script. See the [Gugulele public document] (https://cad.onshape.com/documents/5d1958b45f2484ebebb64adf/w/d0b2164f9e843f6c6ce251e7/e/505e487213bab5c385cd9bb5) there.
