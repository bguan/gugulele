//////////////////////////////////////////
// test script to render individual parts
//////////////////////////////////////////
include <G6.scad>

SKIP_ASSEMBLY = true;
TOP_RND_RAD = .4;
BOT_RND_RAD = .4;
TUNER_STYLE = 3;

//minkowski() {
//    difference() {
//        translate([-50, 0, -50])
//            cube([100, 100, 100]);
//        peg();
//    }
//    sphere(r=BOT_RND_RAD);
//}
MODEL = 3;
HIRES = 36;
DEFRES = 24;
LORES = 12;
back_cover(99.5, .75, 1.6, .9, true);
