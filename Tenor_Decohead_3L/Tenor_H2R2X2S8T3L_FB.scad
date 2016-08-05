include <../G6.scad>;

// Overriding Default Params
HIRES = 180; 
DEFRES = 60;
LORES = 20;

SHOW_LOGO = true; 
//SHOW_HEAD = false;
//SHOW_NECK = false;
//SHOW_FRETBD = false;
//SHOW_FRETS = false;
//SHOW_TOP = false;
//SHOW_BOTTOM = false;
//SHOW_BRIDGE = false;
//SHOW_GUIDE = false;
//SHOW_BRACE = false;
// useful for debugging
//SHOW_PEGS = true;  
//SHOW_STRINGS = true;
//SHOW_SCREWS = true;
//SHOW_SPINE = true;
//SHOW_PICKUP = true;
//SHOW_CUTOUT = true;
//SHOW_CROSS_SECTION = true;

// High level params
TOP_RND_RAD = .5;
BOT_RND_RAD = .5;
HD_RND_RAD = .5;
MODEL = 3;
TUNER_STYLE = 3;
HEAD_STYLE = 2;
PICKUP_STYLE = 2;
F_GAP = 100;
B_GAP = 100; 
USE_SCREWS = true;
BRDG_STYLE = 2;
SNDHOLE_STYLE = 8;
OVAL_LEN_RATIO = .333;
OVAL_WTH_RATIO = .12;
SPINE_STYLE = 2;   
BRACE_STYLE = 1 ;   
FRONT_BACK_RATIO = 1.618;
SHOULDER_FLARE = 103; 
NUT_HOLE_GAP = 9.65;
STR_GUIDE_SET_OFF_BRDG = 4;
CHAMBER_UP_SHIFT = 1.5;
CHAMBER_FRONT_SHIFT = 5.5;
FRETBD_LEN = .615*SCALE_LEN;
CHAMBER_TILT = .4;
CHAMBER_BACK_RATIO = .95;
BUTT_CHOP = 1.5;
