//////////////////////////// 
// Gugulele 6 Assembly 
////////////////////////////

module assemble() {
    saddle_ht = BRDG_SET + BRDG_TCK + SDDL_RAD;
    nut_ht = FRETBD_HD_TCK + F0_RAD;
    f12_ht = FRETBD_HD_TCK + tan(FRETBD_RISE)*SCALE_LEN/2 + FRET_RAD;
    str12_ht = nut_ht + (saddle_ht - nut_ht)/2;
    body_rad = body_rad(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SHOULDER_FLARE) ;
    torso_len = torso_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE) ;
    butt_len = butt_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE, FRONT_BACK_RATIO) ;
    front_scale = front_scale(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE); 
    back_scale = back_scale(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE, FRONT_BACK_RATIO);
    
    echo(str("scale_len = ", SCALE_LEN, 
            ", Action at 12th fret = ", str12_ht - f12_ht));
    echo(str("body_rad = ", body_rad, ", front_scale = ", front_scale, ", back_scale = ", back_scale));
    echo(str("TOP_SCALE = ", TOP_SCALE, ", BOTTOM_SCALE = ", BOTTOM_SCALE));
    difference() {
        
        union() {
            body();
            
            if (SHOW_HEAD) {
                head(NECK_HEAD_WTH, HEAD_STEM, 0);
            }
    
            if (SHOW_FRETBD) {
                translate([0, 0, F_GAP])  fretboard();
            }
    
            if (SHOW_FRETS) {
                translate([0,0, F_GAP]) 
                rotate([0, -FRETBD_RISE, 0])
                lay_frets_from_nut(F1_LEN, F1_LEN / SEMI_RATIO, 1);
            }
    
            if (SHOW_BRIDGE) {
                translate([SCALE_LEN +N_GAP +S_GAP, 0, BRDG_SET  +B_GAP]) 
                    bridge(is_cut = false); 
            }
            
            if (SHOW_GUIDE && (HEAD_STYLE==0 || HEAD_STYLE==2)) {
                translate([STR_GUIDE_PLCMT +N_GAP +S_GAP, 0, 
                         BRDG_SET -STR_GUIDE_SET_OFF_BRDG +G_GAP]) 
                    strings_guide(); 
            }
            
            if (SHOW_STRINGS) {
                translate([0, 0, F_GAP]) strings();
            }
            
            if (SHOW_BRACE ) {
				translate([0, 0, -FIT_TOL])
                if (BRACE_STYLE == 1) {
                    xbrace(body_rad, butt_len);
                } else if (BRACE_STYLE == 2) {
                    tbrace(body_rad, butt_len);
                }
            }
        }
    
        if (SHOW_LOGO) {
            logo();
        }
        
        if (SPINE_STYLE>0 && 
		   (SHOW_SHOULDER_TOP || SHOW_SHOULDER_BOTTOM || SHOW_TOP || SHOW_BOTTOM || SHOW_HEAD || SHOW_FRETBD)) {    
            echo(str("spine_len = ", SPINE_LEN, ", or ", SPINE_LEN/INCH_TO_MM, " inches"));
            place_spine(is_cut = true);
        }
        
        if (SHOW_HEAD && HEAD_STYLE == 1 && USE_HEAD_PIN) {
            for (hpx = H_GAP > 0 ? [-H_GAP, 0] : [0]) {
                translate([hpx, 0, -5-V_GAP])
                rotate([0, 90-HEAD_ANGLE, 0]) {
                    translate([0, 0, -55])
                    rotate([0, 180, 0]) {
                        cylinder(h=100, r=5);
                        screw(HEAD_PIN_MODEL, thread="no");
                    }
                }
            }
        }
        
        if (SHOW_CUTOUT) {
            translate([-100, 0, -V_GAP -body_rad -C_GAP])
                cube([2*SCALE_LEN +N_GAP +S_GAP, 2*body_rad, 2*body_rad +V_GAP +F_GAP +C_GAP]);
        }
        
        if (SHOW_CROSS_SECTION) {
            translate([SCALE_LEN, -2*body_rad, -V_GAP -2*body_rad -C_GAP])
                cube([2*SCALE_LEN, 4*body_rad, 4*body_rad +V_GAP +F_GAP +C_GAP]);
        }
        
        if (SHOW_FRETBD && SHOW_FRETDECO) {
            translate([0, 0, F_GAP])  
            rotate([0, -FRETBD_RISE, 0]) 
                deco_frets_from_nut(F1_LEN, F1_LEN / SEMI_RATIO, 1, true);
        }
            
    }
        
    if (SHOW_PEGS) {
        if (HEAD_STYLE==0 || HEAD_STYLE==2) {
            translate([N_GAP +S_GAP, 0, -TUNER_BD_TCK -FIT_TOL]) 
                tail_pegs(is_cut = false);
        } else {
            translate([-H_GAP, 0, -V_GAP]) 
                rotate([0, -HEAD_ANGLE, 0]) 
                    pegs(is_cut = false);
        }
    }
    
    if (SPINE_STYLE>0 && SHOW_SPINE) {    
        place_spine(is_cut = false);
    }
    
    if (SHOW_PICKUP) {
        place_pickup(is_cut = false);
    }
}
