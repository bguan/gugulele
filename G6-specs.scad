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
DEFRES = 9;
HIRES = 3*DEFRES;
LORES = DEFRES/3;
SHOW_HEAD = true;
SHOW_FRETBD = true;
SHOW_NECK = true;
SHOW_SHOULDER_TOP = true;
SHOW_SHOULDER_BOTTOM = true;
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
TUNER_STYLE = 0; // 0 hole 1 sealed geared 2 friction 3 banjo planetary 4 gotoh UPTL  
SPINE_STYLE = 0;  // 0 none 1 neck only 2 whole body 3 angle thru body
SNDHOLE_STYLE = 0; // 0.none 1.side 2.f-hole 3.side+F 4.top 5.side+top 
                   // 6.double ovals 7.side+double oval 8. single oval 9. single oval+side
PICKUP_STYLE = 0;  // 0 none  1 end pin  2 side
BRDG_STYLE = 0;  // 0 embed, 1 raise, 2 embed w under reinforcement
BRACE_STYLE = 0; // 0 none, 1 X, 2 +
USE_SCREWS = false;  // when any GAP > 0, cut holes + threads for screws
USE_HEAD_PIN = false; // for headed model to support  
STRTIE_STYLE = 0; // for headed model only, 0 pegs  1 bridge tie  2 tail piece
FORCE_TAIL_CAVITY = false; // some tuner allow tail plcmt without cavity
FORCE_FRETBD_SCREWS = false; // allow fretbd screws just for decoration
FORCE_FRETBD_TANG = false; // allow fretbd tounge and groove fitting even when not necessary
NECK_HOOK = false;
TAIL_HOOK = false;
B_GAP = 0;  // bridge gap to body
F_GAP = 0;  // fretboard gap, between neck and board
V_GAP = 0;  // vertical gap between top and bottom half of uke
N_GAP = 0;  // neck gap to body
S_GAP = 0;  // shoulder gap to body
G_GAP = 0;  // body gap to string_guide
H_GAP = 0;  // head gap to string_guide
C_GAP = 0;  // cover on the back

// Model driven params
NUM_STRS = [3, 4, 4, 4, 4, 6][MODEL];
SCALE_LEN = [245, 330, 380, 430, 480, 650][MODEL];
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
BOTTOM_SCALE = [NUM_STRS < 4 ? 3/4 : 2/3, 2/3, 2/3, 2/3, 2/3, 2/3][MODEL]; 
FRONT_BACK_RATIO = 2;
HEAD_FRONT_BACK_RATIO = [0, 1, 2][HEAD_STYLE];
BRDG_INDENT = [NUM_STRS/8 + .2, 0, NUM_STRS/8][BRDG_STYLE];
CHAMBER_BODY_RATIO = [.9, .92, .92, .92, .92, .92][MODEL]; 
CHAMBER_TOP_SCALE = .75*TOP_SCALE; 
CHAMBER_BOTTOM_SCALE = BOTTOM_SCALE;
CHAMBER_UP_SHIFT = [1, 1.1, 1.2, 1.3, 1.4, 1.7][MODEL]; 
CHAMBER_FRONT_SHIFT = [6, 5, 5.5, 6, 7, 5][MODEL]; 
CHAMBER_TILT = .5; 
CHAMBER_BACK_RATIO = .9;
//HEAD_STYLE == 1 ? .9 : 
//        !FORCE_TAIL_CAVITY && TUNER_STYLE == 2 ? .8 :
//        !FORCE_TAIL_CAVITY && TUNER_STYLE == 3 ? .75 :
//        !FORCE_TAIL_CAVITY && TUNER_STYLE == 4 ? .77 :
//        .75;
SOUND_PORT_SCALE = V_GAP > 0 ? [.5, 1.5, .25*BOTTOM_SCALE] : 
                    [.6, 1.5, .25*BOTTOM_SCALE];

// Helmholz target: classically should be:
// Pocket C, Soprano A, Concert G, Tenor C, Baritone A, Guitar E
// but with gugulele I aim for
// Pocket A4 440, Soprano E4 330, Concert D4 294, Tenor C4 262, Baritone C4 220, Guitar E3 165
TOP_HOLE_RATIO = [.1874, .1975, .215, .217, .22, .2][MODEL]; // of body_rad
OVAL_LEN_RATIO = SNDHOLE_STYLE >= 8 ? [.42, .42, .42, .42, .4, .43][MODEL] :
				 SNDHOLE_STYLE >= 6 ? .25 : 0; // of body_rad
HOOK_WTH_RATIO = [.12, .12, .12, .12, .12, .12][MODEL]; // of body_rad
HOOK_LEN_RATIO = [.45, .48, .55, .52, .5, .45][MODEL]; // of body_rad
OVAL_WTH_RATIO = SNDHOLE_STYLE >= 8 ? [.12, .12, .12, .12, .1, .11][MODEL]: // of body_rad
                 SNDHOLE_STYLE >= 6 ? [.063, .071, .0841, .0857, .0645, .065][MODEL] : 0; 
OVAL_PLCMT_RATIO = [.6, .6, .6, .6, .6, .6][MODEL]; // plcmt of oval hole(s)
OVAL_WIDEN_RATIO = [.58, .58, .58, .58, .58, .55][MODEL]; // widen gap of oval holes(s)
OVAL_ANGLE = [24, 24, 24, 24, 24, 24][MODEL];

// angle of flare out at shoulder, between 45 - 180, affects girth 
SHOULDER_FLARE = [NUM_STRS < 4 ? 102: 100, 101, 102, 102.6, 103, 104][MODEL]; 

// Endpin/pickup specs
ENDPIN_RAD = 5+BOT_RND_RAD; // for strap pin or 1/4" pick up jack 
ENDPIN_DEP = 3;
ENDPIN_DIP = HEAD_STYLE == 1 ? 55 : // angle pointing downward
            PICKUP_STYLE == 2 ? [60, 55, 50, 45, 45, 45][MODEL]:
            FORCE_TAIL_CAVITY || TUNER_STYLE < 2 ? [10, 10, 15, 15, 15, 15][MODEL] :
            45;
ENDPIN_ROLL = [0, 5, 10+2*MODEL][PICKUP_STYLE]; // minor adjustment rolling endpin in-place
ENDPIN_PUSHIN_RATIO = [0, .1, .15][PICKUP_STYLE]; // minor adjustment how much to push the pin into body
PICKUP_STEM_LEN = 35;

// Bridge specs
BRDG_TCK = SCALE_LEN/80; //[4.5, 5, 5.5, 5.5, 5.5, 6][MODEL];
SDDL_RAD = 1;
BRDG_WTH = (HEAD_STYLE==1 && STRTIE_STYLE==1 ? 1.2 : 1)*SCALE_LEN/30; //SCALE_LEN/25;
BRDG_CARVE_SCALE = .25; //[.6, .425, .375, .325, .275, .225][MODEL];
BRDG_BOTTOM = BRDG_TCK - (HEAD_STYLE==1 ? 
                            (BRDG_WTH -SDDL_RAD)*BRDG_CARVE_SCALE : 
                            2*((BRDG_WTH/2)-SDDL_RAD)*BRDG_CARVE_SCALE);
BRDG_LEN = 1.1*NUM_STRS*NUT_HOLE_GAP +2*SCALE_LEN*NECK_SLOPE +BRDG_BOTTOM;
BRDG_PINHOLE_RAD = MODEL == 0 ? 1.25 : 2.55;

// Tuner and String Guide specs
TUNER_HOLE_RAD = [5, 5, 3.5, 5, 5][TUNER_STYLE] + BOT_RND_RAD; 
TUNER_TOP_RAD = [5 +[2.5,0,2.5][HEAD_STYLE], 8.5, 5.5, 8, 8][TUNER_STYLE] + TOP_RND_RAD; 
TUNER_BOT_RAD = [5, 10, 11, 8.5, 8.5][TUNER_STYLE] + BOT_RND_RAD; 
TUNER_BOT_LEN = [23, 8, 9, 23, 14][TUNER_STYLE]; 
TUNER_BTN_RAD = [11, 11, 11, 11, 9.5][TUNER_STYLE] + BOT_RND_RAD; 
TUNER_GAP = max(25, max(TUNER_TOP_RAD, TUNER_BOT_RAD, TUNER_BTN_RAD)*2.1); 
TUNER_UPLIFT = HEAD_STYLE == 1 ? [.5, 2.5, 3, 4, 5, 6][MODEL] : [1, 1.2, 1.4, 1.6, 1.7, 2][MODEL];
TUNER_BD_TCK = [10, 13, 10, 14, 12][TUNER_STYLE]; 
HEAD_TUNER_WIDEN = 0;
STR_GUIDE_ROD_RAD = 2.25;

ANCHORPIN_RAD =  [0, 1, 0, .4, .4][TUNER_STYLE]; 
ANCHORPIN_OFFSET = [0, 11, 0, 7.5, 7.5][TUNER_STYLE]; 
ANCHORPIN_DEP = [0, 8, 0, 3, 3][TUNER_STYLE];
STR_HOLE_FROM_COUNTER = [15, 22.5, 15, 23, 17.5][TUNER_STYLE];
ANCHORPIN_ANGLE = [45, 45, 45][HEAD_STYLE]; //45;

// head specs
HEAD_ANGLE = 15;
HEAD_FLARE = [0, 100, MODEL < 5 ? 60 : 66][HEAD_STYLE]; // angle head flare
HEAD_SIDE_CUT_ANGLE = 15;
HEAD_STEM = [11, .01, .01][HEAD_STYLE];
// to transform gourd shaped head by scaling shoulder, torso, butt, tail
HEAD_MIDLEN = HEAD_STEM + [ 0, 
							(2+NUM_STRS/2)*max(TUNER_TOP_RAD, TUNER_BOT_RAD, .5*TUNER_GAP), 
							(NUM_STRS/2)*NUT_HOLE_GAP ][HEAD_STYLE];
//HEAD_MIDLEN = HEAD_STEM + [0, 6+ floor(NUM_STRS/2)*20 +(NUM_STRS%2)*15, [13,14,15,16,17,20][MODEL] ][HEAD_STYLE]; 

PEGS_SHIFT = -HEAD_STEM -max(TUNER_TOP_RAD, TUNER_BOT_RAD, .5*TUNER_GAP); // pegs plcmt
PEGS_DIVIDE = MODEL < 5 ? .5 : .6; // gap ratio btw L/R rows

// neck specs
NECK_LEN = .4*SCALE_LEN;  
NECK_HEAD_WTH = NUM_STRS * NUT_HOLE_GAP;
NECK_JOINT_LEN = .1*NECK_LEN; 
NECK_JOINT_WTH1 = .83 *NUM_STRS *NUT_HOLE_GAP;
NECK_JOINT_WTH2 = V_GAP +F_GAP > 0 ? NECK_JOINT_WTH1*1.1 : NECK_JOINT_WTH1;
NECK_JOINT_TCK = [6, 7, 7.5, 8, 8.5, 9][MODEL];

// Shoulder Specs
SHOULDER_SPLIT_RATIO = .25; // only when S_GAP > 0 to determine front vs back
SHOULDER_JNT_LEN = .07*SCALE_LEN; 
SHOULDER_JNT_WTH = NUM_STRS*NUT_HOLE_GAP*1.2;
SHOULDER_JNT_TCK = BOTTOM_SCALE*SHOULDER_JNT_WTH/2.5;

// Derived params
BODY_RAD = body_rad(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SHOULDER_FLARE);
BODY_FRONT_SCALE= front_scale(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE); 
BODY_BACK_SCALE = back_scale(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE, FRONT_BACK_RATIO);
BUTT_LEN = butt_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE, FRONT_BACK_RATIO);
BUTT_CHOP = HEAD_STYLE == 1 ? (FRONT_BACK_RATIO*.12)*BUTT_LEN :0;
BODY_TCK = 6; 


// Fretboard specs
FRETBD_LEN = .615*SCALE_LEN;
FRETBD_HD_TCK = [2, 3, 3, 3, 3, 4][MODEL];
FRETBD_RISE = 1.3; //MODEL < 5 ? 1.4 : 1.3; // degree
FRET_RAD = 1.3; 
FRETBD_EXTN = [7,8,9,10,11,12][MODEL];
FRET_INSET = 0.2;
FRETBD_TOUNGE_WTH = .85*NECK_HEAD_WTH;
FRETBD_TOUNGE_LEN = .85*(FRETBD_LEN -NECK_LEN);

MIN_FRET_WTH = 4.5;
SEMI_RATIO = pow(2, 1/12); // ratio of each semitone to next is 2^(1/12)
function accum_mult_n(x, n) = n<=0 ? 0: x + accum_mult_n(x/SEMI_RATIO,n-1);
FSCALE_SUM = accum_mult_n(1, 12); 
F1_LEN = 0.5*SCALE_LEN/FSCALE_SUM;  // half of scale length is 1 octave

BRACE_WTH = [1, 1.5, 1.75, 2, 2.25, 2][MODEL];
BRACE_LEN_RATIO = [.5, .55, .6, .65, .7, .6][MODEL]; // brace len as ratio of body rad
BRACE_X_PLCMT_RATIO = [.55, .55, .6, .65, .7, .75][MODEL]; // front shift as ratio of body rad
BRACE_X_WIDEN_RATIO = [.5, .5, .5, .5, .5, .5][MODEL]; // wide gap as ratio of body rad
BRACE_X_MID_RATIO = [.666, .666, .666, .666, .666, .666][MODEL]; // mid point as ratio of brace len
BRACE_X_ANGLE = [40, 40, 40, 40, 40, 35][MODEL];
BRACE_SPAN_RATIO = MODEL < 5 ? .333 : .5;

// LOGO
MODEL_CODE = str(MODEL, HEAD_STYLE, "-", 
                (N_GAP>0?"N":""), 
                (S_GAP>0?"N":""), 
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
BACK_COVER_RATIO = [.65, .6, .6, .6, .6, .6][MODEL];
BACK_COVER_SHIFT = [5, 6, 7, 8.5, 9, 2][MODEL];
BACK_COVER_PLCMT = [37, 44, 48.5, 51, 53, 67][MODEL]; 
BACK_COVER_ANGLE = [8, 4.2, 3.8, 3.8, 3.5, 1][MODEL];
BACK_COVER_SIDE_SCALE = [.82, .85, .86, .865, .87, .95][MODEL];

// SCREWS
GEN_SCREW_MDL = "M1.6x12"; 
GEN_SCREW_HEAD_RAD = 1.6;
GEN_SCREW_HEAD_TCK = 2;
BODY_SCREW_MDL = "M1.6x8";
GUIDE_SCREW_MDL = BODY_SCREW_MDL;
BACK_SCREW_MDL = "M1.6x4"; 
BRDG_SCREW_MDL = BACK_SCREW_MDL; 
NECK_SCREW_MDL = !USE_SCREWS && FORCE_FRETBD_SCREWS ? "M1.6x4" :
                MODEL < 5 ? GEN_SCREW_MDL : "M2x16";
NECK_SHORT_SCREW_MDL = MODEL < 5 ? "M1.6x4" : "M2x5";
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

TUNER_CAVITY_CUT = .66*NUM_STRS*max(TUNER_TOP_RAD, TUNER_BOT_RAD, .5*TUNER_GAP);

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
SPINE_PRE_LEN = [0, 1, 
				 H_GAP + N_GAP + S_GAP > 0 ? -5 : HEAD_STYLE == 1 ? -50 : HEAD_STYLE == 0 ?-15 : -25, 10
                ][SPINE_STYLE];
SPINE_LEN = 
    SPINE_STYLE == 0 ? 0 :
    SPINE_STYLE == 1 ? FRETBD_LEN -SPINE_PRE_LEN:
    SPINE_STYLE == 2 ? 
        gourd_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE,FRONT_BACK_RATIO)
        -SPINE_PRE_LEN
		-BUTT_CHOP
		-(HEAD_STYLE==1 ? 2 : 
		  TUNER_STYLE < 2 || FORCE_TAIL_CAVITY ? TUNER_CAVITY_CUT -22 +SPINE_GAP/5 :
		  8 +SPINE_GAP/1.8):
        gourd_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE,FRONT_BACK_RATIO)
		-BUTT_CHOP
        -(HEAD_STYLE==1 ? (!SPINE_TENTED? SPINE_PRE_LEN: 0): 
          N_GAP +S_GAP +V_GAP <= 0 ? 0 :TUNER_STYLE == 3 ? 1.8*TUNER_BTN_RAD: 1.65*TUNER_BTN_RAD);


// dist from zero plane to slice off top & bottom of head 
HEAD_POKED = len(search(SPINE_STYLE, [1,2])) > 0 && 
            (V_GAP+F_GAP+H_GAP+N_GAP +S_GAP == 0 || H_GAP>0 && USE_SCREWS);
HEAD_SLICE = [[0, 2, .25, .81, 1.4][TUNER_STYLE],
              [-3.25, -4.25, -4.5, -4.75, -5, -9][MODEL]]; 
HEADLESS_STRING_ANGLE = [ 
    [36, 44, 44, 44, 44, 49][MODEL], 0, 
    [35, 29, 28, 27, 26, 29][MODEL] +(HEAD_POKED ?1 :0) 
    -(F_GAP+V_GAP+H_GAP+N_GAP +S_GAP>0 ? 6: 9)
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

TUNER_CAVITY_WTH = NUM_STRS *TUNER_GAP;
TUNER_CAVITY_DOME_SCALE = (BUTT_LEN - NUM_STRS*6)/BUTT_LEN;
CAVITY_DOME_SIDE_STRETCH = 1.3;
CAVITY_DOME_VERT_STRETCH = 1.3;
BODY_LEN = SCALE_LEN + BUTT_LEN - BUTT_CHOP;

BRDG_SET = body_rad(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SHOULDER_FLARE)
            *TOP_SCALE -BRDG_INDENT;

TUNER_CAVITY_DEP = HEAD_STYLE == 1 ? 0 :
	!FORCE_TAIL_CAVITY && TUNER_STYLE >= 2 ? 0:
    butt_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE,
             FRONT_BACK_RATIO) -TUNER_CAVITY_CUT;

TUNER_FANOUT_RAD = butt_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, 
                    SHOULDER_FLARE, FRONT_BACK_RATIO) 
					-max(TUNER_TOP_RAD, TUNER_BOT_RAD) -max(TOP_RND_RAD, BOT_RND_RAD);
STR_GUIDE_PLCMT = SCALE_LEN + max(TUNER_CAVITY_DEP, TUNER_FANOUT_RAD -3*TUNER_TOP_RAD) -NUM_STRS;
STR_GUIDE_SET_OFF_BRDG = SCALE_LEN/100; 
