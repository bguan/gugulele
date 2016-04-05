///////////////////////////////////////////
// Gugulele 6 Params
///////////////////////////////////////////

FIT_TOL = .2;
FUSE_SHIFT = 0.01; // shift to avoid Manifold when fusing objects
STR_HOLE_RAD = 1;
INCH_TO_MM = 25.4;
SND_AIR_SPEED = 343; // meter per seconds
TOP_RND_RAD = 0; // rounding of top layer of tailend of body
BOT_RND_RAD = 0; // rounding of bottom layer of tailend of body
HD_RND_RAD = 0; // rounding of head 

// rendering controls
HIRES = 12;
DEFRES = 12;
LORES = 12;
SHOW_HEAD = true;
SHOW_FRETBD = true;
SHOW_NECK = true;
SHOW_TOP = true;
SHOW_BOTTOM = true;
SHOW_BRIDGE = true;
SHOW_FRETS = true;
SHOW_FRETDECO = true;
SHOW_GUIDE = true;
SHOW_BRACE = true;
SHOW_LOGO = false; 
SHOW_MODEL_CODE = false;

// useful for debugging
SHOW_PEGS = false;  
SHOW_STRINGS = false;
SHOW_SPINE = false;
SHOW_SCREWS = false;
SHOW_PICKUP = false;
SHOW_CUTOUT = false;
SHOW_CROSS_SECTION = false;
SKIP_ASSEMBLY = false;

// High level params: Model specific configs - expect frequent change
MODEL = 0;
HEAD_STYLE = 0; // 0 headless  1 headed  2 deco-headless
TUNER_STYLE = 0; // 0 hole 1 friction 2 sealed geared 3 banjo planetary 4 gotoh UPT  
SPINE_STYLE = 0;  // 0 none 1 neck only 2 whole body 3 angle thru body
SNDHOLE_STYLE = 0; // 0.none 1.side 2.f-hole 3.side+F 4.top 5.side+top 6.oval 7.side+oval
PICKUP_STYLE = 0;  // 0 none  1 end pin  2 side
BRDG_STYLE = 0;  // 0 embed in body, 1 platform
BRACE_STYLE = 0; // 0 none, 1 X, 2 +
USE_SCREWS = false;  // when any GAP > 0, cut holes + threads for screws
USE_HEAD_PIN = false; // for headed model to support  
FORCE_TAIL_CAVITY = false; // some tuner allow tail plcmt without cavity
FORCE_FRETBD_SCREWS = false; // allow fretbd screws just for decoration
B_GAP = 0;  // bridge gap to body
F_GAP = 0;  // fretboard gap, between neck and board
V_GAP = 0;  // vertical gap between top and bottom half of uke
N_GAP = 0;  // neck gap to body
G_GAP = 0;  // body gap to string_guide
H_GAP = 0;  // head gap to string_guide
C_GAP = 0;  // cover on the back

// Model driven params
NUM_STRS = [4, 4, 4, 4, 4, 6][MODEL];
SCALE_LEN = [270, 330, 380, 430, 480, 650][MODEL];
NUT_HOLE_GAP = [8.75, 9, 9.25, 9.5, 9.75, 8.5][MODEL];

// Functions to expose calculation of various guord parameters
function neck_tl_wth(nlen, nwth, nslope) = nwth +2*nlen*nslope;
function shoulder_rtop(nlen, nwth, nslope) = nwth/2 + (nlen*nslope);
function shoulder_atop(nslope) = atan(nslope);
function shoulder_abot(nslope, flare) = (shoulder_atop(nslope) + flare)/2;
function shoulder_curve_R(nlen, nwth, nslope, flare) = 
            shoulder_rtop(nlen, nwth, nslope) /
            (2*cos(shoulder_abot(nslope, flare)) -cos(shoulder_atop(nslope)));
function shoulder_rbot(nlen, nwth, nslope, flare) = 
                    fnl_bottom_radius(
                            shoulder_curve_R(nlen, nwth, nslope, flare), 
                            shoulder_rtop(nlen, nwth, nslope), 
                            shoulder_atop(nslope), 
                            shoulder_abot(nslope, flare));
function body_rad(nlen, nwth, nslope, flare) = 
            shoulder_rbot(nlen, nwth, nslope, flare)/cos(shoulder_abot(nslope, flare));
function shoulder_len_pre(nlen, nwth, nslope, flare) = 
            fnl_height(shoulder_curve_R(nlen, nwth, nslope, flare), 
                        shoulder_atop(nslope), shoulder_abot(nslope, flare));
function torso_len_pre(nlen, nwth, nslope, flare) = 
            sqrt(pow(body_rad(nlen, nwth, nslope, flare),2) 
            -pow(shoulder_rbot(nlen, nwth, nslope, flare),2));
function front_scale(nlen, nwth, nslope, mlen, flare) = 
            (mlen - nlen)/(shoulder_len_pre(nlen, nwth, nslope, flare) 
            +torso_len_pre(nlen, nwth, nslope, flare));
function back_scale(nlen, nwth, nslope, mlen, flare, back_ratio) = 
            front_scale(nlen, nwth, nslope, mlen, flare)/back_ratio;
function shoulder_len(nlen, nwth, nslope, mlen, flare) = 
            shoulder_len_pre(nlen, nwth, nslope, flare) *
            front_scale(nlen, nwth, nslope, mlen, flare);
function torso_len(nlen, nwth, nslope, mlen, flare) = 
            torso_len_pre(nlen, nwth, nslope, flare)*
            front_scale(nlen, nwth, nslope, mlen, flare);    
function butt_len(nlen, nwth, nslope, mlen, flare, back_ratio) = 
            body_rad(nlen, nwth, nslope, flare)*
            back_scale(nlen, nwth, nslope, mlen, flare, back_ratio);          
function gourd_len(nlen, nwth, nslope, mlen, flare, back_ratio) = 
            nlen +shoulder_len(nlen, nwth, nslope, mlen, flare) +
            torso_len(nlen, nwth, nslope, mlen, flare) +
            butt_len(nlen, nwth, nslope, mlen, flare, back_ratio);

// Scales and ratios
NECK_SLOPE = 1/48;
TOP_SCALE = 1/9; 
HEAD_TOP_SCALE = 1/5;
BOTTOM_SCALE = [1/2, 2/3, 2/3, 2/3, 2/3, 2/3][MODEL]; 
FRONT_BACK_RATIO = [2, 1.5, 1.5, 1.5, 1.5, 1.5][MODEL]; 
HEAD_FRONT_BACK_RATIO = [0, 1.5, 2][HEAD_STYLE];
BRDG_INDENT = [NUM_STRS/8 + .2, 0][BRDG_STYLE];
CHAMBER_BODY_RATIO = [.9, .92, .94, .96, .97, .92][MODEL]; 
CHAMBER_TOP_SCALE = .75*TOP_SCALE; 
CHAMBER_BOTTOM_SCALE = 1*BOTTOM_SCALE;
CHAMBER_UP_SHIFT = 1.5; 
CHAMBER_FRONT_SHIFT = [10, 4, 4.5, 5, 6, 7][MODEL]; //[10, 4, 5, 6.5, 7.5, 10][MODEL]; 
CHAMBER_TILT = .5; 
CHAMBER_BACK_RATIO = HEAD_STYLE == 1 ? .9 : 
        !FORCE_TAIL_CAVITY && TUNER_STYLE == 3 ? [.83, .84, .85, .86, .87, .88][MODEL] :
        !FORCE_TAIL_CAVITY && TUNER_STYLE == 4 ? [.90, .91, .92, .93, .94, .95][MODEL]:
        [.7, .76, .82, .88, .9, .95][MODEL]; 
SOUND_PORT_SCALE = V_GAP > 0 ? [.5, 1.5, .25*BOTTOM_SCALE] : 
                    [.6, 1.5, .25*BOTTOM_SCALE];
TOP_HOLE_RATIO = [.1961, .1721, .1596, .1459, .1526, .1815][MODEL]; // of body_rad
OVAL_WTH_RATIO = [.0565, .0645, .0675, .062, .0645, .065][MODEL]; // of body_rad

// angle of flare out at shoulder, between 45 - 180, affects girth 
SHOULDER_FLARE = [98, 99.5, 101, 102.5, 103, 103.5][MODEL]; 

// Body specs
BUTT_CHOP = HEAD_STYLE == 1 ?[15, 16, 17, 18, 19, 20][MODEL] :0;
BODY_TCK = 6; 

// Endpin/pickup specs
ENDPIN_RAD = 5; // for strap pin or 1/4" pick up jack 
ENDPIN_DEP = 4;
ENDPIN_DIP = HEAD_STYLE == 1 ? 55 : // angle pointing downward
            PICKUP_STYLE == 2 ? 20:
            FORCE_TAIL_CAVITY || TUNER_STYLE < 3 ? [10, 10, 15, 15, 14, 6][MODEL] : 
            TUNER_STYLE == 3 ? 59 : 50; 
ENDPIN_PLCMT = HEAD_STYLE == 1 ? .425 : 
            FORCE_TAIL_CAVITY || TUNER_STYLE < 3 ?
                [.5, .5, .45, .4, .35, .3][MODEL] :
            TUNER_STYLE == 3 ? 
                [1.2, .8, .75, .695, .55, .45][MODEL] : 
                [1.1, .75, .65, .6, .5, .4][MODEL];
PICKUP_STEM_LEN = 35;

// Bridge specs
BRDG_TCK = [5, 5.5, 6, 6.5, 7, 9][MODEL];
SDDL_RAD = 1;
BRDG_WTH = SCALE_LEN/30; //SCALE_LEN/25;
BRDG_CARVE_SCALE = [.475, .425, .375, .325, .275, .225][MODEL];
BRDG_BOTTOM = BRDG_TCK - (HEAD_STYLE==1 ? 
                            (BRDG_WTH -SDDL_RAD)*BRDG_CARVE_SCALE : 
                            2*((BRDG_WTH/2)-SDDL_RAD)*BRDG_CARVE_SCALE);
BRDG_LEN = 1.05*NUM_STRS*NUT_HOLE_GAP +2*SCALE_LEN*NECK_SLOPE +BRDG_BOTTOM;
BRDG_PINHOLE_RAD = 2.55;


// head specs
HEAD_ANGLE = 15;
HEAD_FLARE = [0, 100, MODEL < 5 ? 60 : 66][HEAD_STYLE]; // angle head flare
HEAD_SIDE_CUT_ANGLE = 10;
HEAD_STEM = [11, .01, .01][HEAD_STYLE];
// to transform gourd shaped head by scaling shoulder, torso, butt, tail
HEAD_MIDLEN = HEAD_STEM + 
                [0, 5+ 2*MODEL +NUM_STRS*10, 
                 [13,14,15,16,17,20][MODEL] ][HEAD_STYLE]; 

// neck specs
NECK_LEN = .5*SCALE_LEN;  
NECK_HEAD_WTH = NUM_STRS * NUT_HOLE_GAP;
NECK_JOINT_LEN = .1*NECK_LEN; 
NECK_JOINT_WTH1 = .8 *NUM_STRS *NUT_HOLE_GAP;
NECK_JOINT_WTH2 = V_GAP +F_GAP > 0 ? NECK_JOINT_WTH1*1.1 : NECK_JOINT_WTH1;
NECK_JOINT_TCK = [6, 7, 8.5, 9.5, 10.5, 12][MODEL];

// Derived params
BODY_RAD = body_rad(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SHOULDER_FLARE);
BODY_FRONT_SCALE= front_scale(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE); 
BODY_BACK_SCALE = back_scale(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE, FRONT_BACK_RATIO);

// Tuner and String Guide specs
TUNER_HOLE_RAD = [5, 2.5, 5, 5, 5][TUNER_STYLE] + BOT_RND_RAD; 
TUNER_TOP_RAD = [7.5, 5.5, 8.5, 7.5, 7.5][TUNER_STYLE] + TOP_RND_RAD; 
TUNER_BOT_RAD = [5, 11, 10, 8.5, 7.5][TUNER_STYLE] + BOT_RND_RAD; 
TUNER_BOT_LEN = [23, 9, 8, 23, 14][TUNER_STYLE]; 
TUNER_BTN_RAD = [11, 11, 11, 11, 9.5][TUNER_STYLE] + BOT_RND_RAD; 
TUNER_GAP = max(25, max(TUNER_TOP_RAD, TUNER_BOT_RAD, TUNER_BTN_RAD)*2.1); 
TUNER_UPLIFT = V_GAP == 0 && TOP_RND_RAD != BOT_RND_RAD ? 0 : 1;
TUNER_BD_TCK = [10, 10, 10, 13, 10][TUNER_STYLE]; 
HEAD_TUNER_WIDEN = 0;
STR_GUIDE_ROD_RAD = 2.25;

ANCHORPIN_RAD =  BOT_RND_RAD > .75 ? 0 : [0, 0, 1, .7, .2][TUNER_STYLE]; 
ANCHORPIN_OFFSET = [0, 0, 11, 6.8, 7][TUNER_STYLE]; 
ANCHORPIN_DEP = [0, 0, 8, 3.5, 3][TUNER_STYLE];
STR_HOLE_FROM_COUNTER = [15, 15, 22.5, 23, 17.5][TUNER_STYLE];
ANCHORPIN_ANGLE = [45, 45, 60][HEAD_STYLE]; //45;
PEGS_SHIFT = -HEAD_STEM + [-27,-28,-29,-30,-31,-30][MODEL]; // pegs plcmt
PEGS_DIVIDE = MODEL < 5 ? .4 : .6; // gap ratio btw L/R rows

// Fretboard specs
FRETBD_LEN = .66*SCALE_LEN; //[.66, .66, .66, .695, .695, .695][MODEL]*SCALE_LEN;
FRETBD_HD_TCK = NUM_STRS;
FRETBD_RISE = 1.25; // degree
FRET_RAD = 1.3; 
FRETBD_EXTN = [7,8,9,10,11,12][MODEL];
FRET_INSET = 0.2;
FRETBD_TOUNGE_WTH = .75*NECK_HEAD_WTH;
FRETBD_TOUNGE_LEN = FRETBD_LEN -NECK_LEN;

MIN_FRET_WTH = 4.5;
SEMI_RATIO = pow(2, 1/12); // ratio of each semitone to next is 2^(1/12)
function accum_mult_n(x, n) = n<=0 ? 0: x + accum_mult_n(x/SEMI_RATIO,n-1);
FSCALE_SUM = accum_mult_n(1, 12); 
F1_LEN = 0.5*SCALE_LEN/FSCALE_SUM;  // half of scale length is 1 octave

BRACE_WTH = 1;

// LOGO
MODEL_CODE = str(MODEL, HEAD_STYLE, "-", 
                (N_GAP>0?"N":""), 
                (V_GAP>0?"V":""), 
                (F_GAP>0?"F":""), 
                (H_GAP>0?"H":""), 
                (B_GAP>0?"B":""), 
                (G_GAP>0?"G":""), 
                (C_GAP>0?"C":""), "-", 
                SPINE_STYLE, TUNER_STYLE, SNDHOLE_STYLE, 
                BRDG_STYLE, PICKUP_STYLE, BRACE_STYLE);
LOGO_TXT = ["mind2form.com", "© 2016", SHOW_MODEL_CODE ? MODEL_CODE : "" ];
LOGO_FONT = "Tahoma";
LOGO_SIZE = 7;

// BACK COVER
BACK_COVER_RATIO = [.5, .5, .5, .5, .5, .5][MODEL];
BACK_COVER_SHIFT = [5, 5, 5, 5, 3, 2][MODEL];
BACK_COVER_PLCMT = [30, 40, 50, 56, 60, 81.5][MODEL]; 
BACK_COVER_ANGLE = [2.5, 2.5, 2.5, 2.5, 1.5, .5][MODEL];

// SCREWS
GEN_SCREW_MDL = "M1.6x12"; 
GEN_SCREW_HEAD_RAD = 1.6;
GEN_SCREW_HEAD_TCK = 2;
BODY_SCREW_MDL = "M1.6x8";
GUIDE_SCREW_MDL = BODY_SCREW_MDL;
BRDG_SCREW_MDL = BODY_SCREW_MDL; 
BACK_SCREW_MDL = "M1.6x3"; 
NECK_SCREW_MDL = !USE_SCREWS && FORCE_FRETBD_SCREWS ? "M1.6x3" :
                MODEL < 5 ? GEN_SCREW_MDL : "M2x20";
NECK_SHORT_SCREW_MDL = MODEL < 5 ? "M1.6x3" : "M2x5";
HEAD_SCREW_MDL = GEN_SCREW_MDL;
BODY_SCREW_HEAD_RAD = GEN_SCREW_HEAD_RAD;
GUIDE_SCREW_HEAD_RAD = BODY_SCREW_HEAD_RAD;
BRDG_SCREW_HEAD_RAD = BODY_SCREW_HEAD_RAD;
BACK_SCREW_HEAD_RAD = BODY_SCREW_HEAD_RAD;
NECK_SCREW_HEAD_RAD = MODEL < 5 ? GEN_SCREW_HEAD_RAD : 2; 
NECK_SCREW_HEAD_TCK = MODEL < 5 ? GEN_SCREW_HEAD_TCK : 2; 
HEAD_SCREW_HEAD_RAD = GEN_SCREW_HEAD_RAD;
HEAD_SCREW_HEAD_TCK = GEN_SCREW_HEAD_RAD;
SCREW_THREAD = "no";
HEAD_SCREW_PREDEP = 5;
HEAD_PIN_MODEL = "M6x60";
HEAD_SCREW_PLCMT = (MODEL < 5 ? 3 : 4)*HEAD_SCREW_HEAD_RAD;

TUNER_CAVITY_CUT = (MODEL < 5 ? 3 : 5)*max(TUNER_TOP_RAD, TUNER_BOT_RAD, .5*TUNER_GAP);

// Spine dimensions
SPINE_RAD = 0.125 *INCH_TO_MM;
SPINE_HT = 0.325 *INCH_TO_MM;
SPINE_WTH = 0.125 *INCH_TO_MM;
SPINE_GAP = 0; //2*NUT_HOLE_GAP;
SPINE_DIP = 0; //[2, 1.7, 1.5, 1.4, 1.3, 1.0][MODEL]; // only for spine_style 3
// control fan out angle when there are 2 spines
SPINE_FAN = [0, 0, 0, [1, .8, .7, .6, .5, .1][MODEL]][SPINE_STYLE]; 
RECT_SPINE = V_GAP+F_GAP > 0;
SPINE_TENTED = (SPINE_STYLE == 3);
SPINE_BEVELED = (SPINE_STYLE == 3);

SPINE_RAISE = SPINE_STYLE == 0 ? 0 : RECT_SPINE ? -SPINE_HT/2-FIT_TOL : -2*SPINE_RAD;
SPINE_PRE_LEN = [0, 1, HEAD_STYLE == 0 ?-15 : -50, 10][SPINE_STYLE];
SPINE_LEN = 
    SPINE_STYLE == 0 ? 0 :
    SPINE_STYLE == 1 ? FRETBD_LEN -SPINE_PRE_LEN:
    SPINE_STYLE == 2 ? 
        gourd_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE,FRONT_BACK_RATIO)
        -SPINE_PRE_LEN
		-(HEAD_STYLE==1 ? BUTT_CHOP +3 : TUNER_CAVITY_CUT -[9,9,6,3,10,40][MODEL]):
    gourd_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE,FRONT_BACK_RATIO)
        -(HEAD_STYLE==1 ? BUTT_CHOP + (!SPINE_TENTED? SPINE_PRE_LEN: 0): 
          N_GAP +V_GAP <= 0 ? 0 :TUNER_STYLE == 3 ? 1.8*TUNER_BTN_RAD: 1.65*TUNER_BTN_RAD);

// dist from zero plane to slice off top & bottom of head 
HEAD_POKED = len(search(SPINE_STYLE, [1,2])) > 0 && 
            (V_GAP+F_GAP+H_GAP+N_GAP == 0 || H_GAP>0 && USE_SCREWS);
HEAD_SLICE = [[1, 1.2, 1.4, .81, 1.4][TUNER_STYLE],
              [-3, -4.25, -4.5, -4.75, -5, -8][MODEL]]; 
HEADLESS_STRING_ANGLE = [ 
    (MODEL == 5 ? 49 : 44), 0, 
    [30, 29, 28, 27, 26, 29][MODEL] +(HEAD_POKED ?1 :0) 
    -(F_GAP+V_GAP+H_GAP+N_GAP>0 ? 0: 9)
   ][HEAD_STYLE]; 
F0_RAD = 1.75;
HEADLESS_TOP_GROOVE_RAD = [1.5*F0_RAD, 0, .666*HEAD_MIDLEN][HEAD_STYLE];
HEADLESS_FRONT_GROOVE_RAD = [ 
    (HEAD_POKED ? SPINE_RAD+1 : 2.5*STR_HOLE_RAD),
    0,
    (HEAD_POKED ? SPINE_RAD +3 :.22*NUM_STRS*NUT_HOLE_GAP) ][HEAD_STYLE];
HEADLESS_FRONT_GROOVE_PLCMT = [ 
    (HEAD_POKED ? -1.5: -1.6)*HEAD_MIDLEN, 0, 
    -.3*HEAD_MIDLEN];    

BUTT_LEN = butt_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE, FRONT_BACK_RATIO);
TUNER_CAVITY_WTH = .8*NUM_STRS *TUNER_GAP;
TUNER_CAVITY_DOME_SCALE = (BUTT_LEN - [27, 27, 27, 27, 25, 35][MODEL])/BUTT_LEN;
CAVITY_DOME_SIDE_STRETCH = 1.1;
CAVITY_DOME_VERT_STRETCH = 2;
BODY_LEN = SCALE_LEN + BUTT_LEN - (HEAD_STYLE == 1? BUTT_CHOP : 0);

BRDG_SET = body_rad(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SHOULDER_FLARE)
            *TOP_SCALE -BRDG_INDENT;

TUNER_CAVITY_DEP = HEAD_STYLE == 1 ? 0 :
    butt_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE,
             FRONT_BACK_RATIO) -TUNER_CAVITY_CUT;

TUNER_FANOUT_RAD = butt_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, 
                    SHOULDER_FLARE, FRONT_BACK_RATIO) 
					-.4*TUNER_GAP -2*max(TOP_RND_RAD, BOT_RND_RAD);
STR_GUIDE_PLCMT = SCALE_LEN + max(TUNER_CAVITY_DEP, .5*TUNER_FANOUT_RAD);
STR_GUIDE_SET_OFF_BRDG = [1, 1.5, 2.25, 3, 3.5, 4.5][MODEL];

echo(str(
    "TUNER_FANOUT_RAD = ", TUNER_FANOUT_RAD, 
    ", TUNER_CAVITY_DEP = ", TUNER_CAVITY_DEP, 
    ", TUNER_CAVITY_DOME_SCALE = ", TUNER_CAVITY_DOME_SCALE));
    
