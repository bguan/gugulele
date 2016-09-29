///////////////////////// 
// Gugulele 6 Cuts
//////////////////////////

module back_cover(body_rad, bot_scale, front_scale, back_scale, is_cut=false) {
    brad = BACK_COVER_RATIO * body_rad + (is_cut ? FIT_TOL : 0);
    irad = brad -3*BACK_SCREW_HEAD_RAD + (is_cut ? FIT_TOL : 0);
    //tck = is_cut ? 1.4 : bot_scale*brad;
    //itck = is_cut ? .75*bot_scale*brad : 1.4;
    tck = is_cut ? 1.5: bot_scale*brad;
    itck = is_cut ? 1.5*bot_scale*brad : 1;
    rndrad = BOT_RND_RAD; //.65;
    orad = BOT_RND_RAD; //.65;
    side_scale = BACK_COVER_SIDE_SCALE;
    
    rotate([0, BACK_COVER_ANGLE, 0])
    translate([0, 0, -BACK_COVER_PLCMT]) {
        difference() {
            union() {
                scale([1, side_scale, 1]) {

                    // inner oval
                    translate([0, 0, -FUSE_SHIFT]) {
                        difference() {
                            scale([front_scale, 1, 1]) {
                                if (is_cut) {
                                    cylinder(r=irad, h=itck, $fn=HIRES);
                                } else {
                                    minkowski() {
                                        cylinder(r=irad-rndrad, h=itck-.9*rndrad, $fn=HIRES);
                                        if (rndrad > 0) sphere(r=1.1*rndrad, $fn=LORES);
                                    }
                                }
                                funnel(rndrad, irad);
                            }
                            translate([0, -2*brad, -2*brad]) cube([4*brad, 4*brad, 4*brad]);
                        }
                        
                        scale([CHAMBER_BACK_RATIO*back_scale, 1, 1]) {
                            if (is_cut) {
                                cylinder(r=irad, h=itck, $fn=HIRES);
                            } else {
                                minkowski() {
                                    cylinder(r=irad-rndrad, h=itck-.9*rndrad, $fn=HIRES);
                                    if (rndrad > 0) sphere(r=1.1*rndrad, $fn=LORES);
                                }
                            }
                            funnel(rndrad, irad);
                        }
                    }
                    
                    // outer oval
                    translate([0, 0, 2*FUSE_SHIFT -tck]) {
                        difference() {
                            scale([front_scale, 1, 1]) {
                                minkowski() {
                                    cylinder(r=brad -rndrad, h=tck-rndrad, $fn=HIRES);
                                    if (rndrad > 0) sphere(r=rndrad, $fn=LORES);
                                }
                                if (is_cut) {
                                    translate([0, 0, FUSE_SHIFT-orad]) 
                                        funnel(orad, .999*brad);
                                    translate([0, 0, 2*FUSE_SHIFT-brad-orad]) 
                                        cylinder(r=2*brad, h=brad, $fn=HIRES);
                                } 
                            }
                            translate([0, -2*brad, -2*brad]) cube([4*brad, 4*brad, 4*brad]);
                        }
                        scale([CHAMBER_BACK_RATIO*back_scale, 1, 1]) {
                            minkowski() {
                                cylinder(r=brad -rndrad, h=tck-rndrad, $fn=HIRES);
                                if (rndrad > 0) sphere(r=rndrad, $fn=LORES);
                            }
                            if (is_cut) {
                                translate([0, 0, FUSE_SHIFT-orad]) 
                                    funnel(orad, .999*brad);
                                translate([0, 0, 2*FUSE_SHIFT-brad-orad]) 
                                    cylinder(r=2*brad, h=brad, $fn=HIRES);
                            } 
                        }
                    }
                }
            }
            
            if (!is_cut && USE_SCREWS) {
                for(fb =[1, -1]) {
					for(lr = fb > 0 ? [-.5, .5] : [-1, 1]) {
						translate([fb*(-(fb >0 ?front_scale :CHAMBER_BACK_RATIO*back_scale)*brad +4*BACK_SCREW_HEAD_RAD), 
								lr*4*ENDPIN_RAD, -2])
						rotate([180, 0, 0])
						union() {
							cylinder(r=BACK_SCREW_HEAD_RAD, h=10);
							screw(BACK_SCREW_MDL, thread=SCREW_THREAD);
						}
					}
                }
                
                for(lr =[-1, 1]) {
                    translate([-.1*BODY_RAD, 
                        lr*(side_scale*brad -1.5*BACK_SCREW_HEAD_RAD), 
                        -2])
                    rotate([180, 0, 0])
                    union() {
                        cylinder(r=BACK_SCREW_HEAD_RAD, h=10);
                        screw(BACK_SCREW_MDL, thread=SCREW_THREAD);
                    }
                }
            }
        }
        
        if (is_cut && USE_SCREWS) {
            for(fb =[1, -1]) {
				for(lr = fb > 0 ? [-.5, .5] : [-1, 1]) {
					translate([fb*(-(fb >0 ?front_scale :CHAMBER_BACK_RATIO*back_scale)*brad +4*BACK_SCREW_HEAD_RAD), 
							lr*4*ENDPIN_RAD, -2])
					rotate([180, 0, 0])
					union() {
						cylinder(r=BACK_SCREW_HEAD_RAD, h=10);
						screw(BACK_SCREW_MDL, thread=SCREW_THREAD);
					}
				}
            }
            
            for(lr =[-1, 1]) {
                translate([-.1*BODY_RAD, 
                    lr*(side_scale*brad -1.5*BACK_SCREW_HEAD_RAD), 
                    -2])
                rotate([180, 0, 0])
                union() {
                    cylinder(r=BACK_SCREW_HEAD_RAD, h=10);
                    screw(BACK_SCREW_MDL, thread=SCREW_THREAD);
                }
            }
        }
    }
}

                
module oval_holes(body_rad, front_scale, xlen, ylen) {
    for (lr = (SNDHOLE_STYLE >= 8 ? [-1] :[-1, 1])) {
        translate([0, lr*body_rad*OVAL_WIDEN_RATIO, 0])
        rotate([0, 0, lr*OVAL_ANGLE])
        scale([xlen/ylen, 1, 1])
        cylinder(r =ylen, h = body_rad);
    }
}

module peg_anchor(anchor_dx = 0, anchor_dy = 0, is_cut = true) {
    cut_adj = is_cut ? FIT_TOL : 0;    

	// anchor pins
	if (ANCHORPIN_RAD > 0) {
		translate([anchor_dx, anchor_dy, -2*TUNER_BD_TCK]) 
			cylinder(h=TUNER_BD_TCK+ANCHORPIN_DEP+cut_adj, 
				r=ANCHORPIN_RAD +cut_adj);
	}
}
    
module peg(anchor_dx = 0, anchor_dy = 0, is_cut = true) {
    top_rnd_rad = HEAD_STYLE == 1 ? 2*HD_RND_RAD : TOP_RND_RAD +BOT_RND_RAD >0 ? 2*TOP_RND_RAD : 0;
    bot_rnd_rad = HEAD_STYLE == 1 ? 2*HD_RND_RAD : TOP_RND_RAD +BOT_RND_RAD >0 ? 2*BOT_RND_RAD : 0;
    cut_adj = is_cut ? FIT_TOL : 0;    
	peg_res = 2*DEFRES;
    
    difference() {
        union() {
            // top counter hole
            minkowski() {
				translate([0, 0, top_rnd_rad -FIT_TOL])
            		cylinder(h=2*TUNER_BD_TCK, 
							r=TUNER_TOP_RAD +(top_rnd_rad > 0 ? 0 :cut_adj),
							$fn=peg_res);
				if (top_rnd_rad > 0) sphere(r=top_rnd_rad, $fn=LORES);
			}
            
            // main shaft
            translate([0,0,-TUNER_BD_TCK -FIT_TOL]) 
            cylinder(h=TUNER_BD_TCK +2*FIT_TOL, 
					r=TUNER_HOLE_RAD +cut_adj +max(top_rnd_rad, bot_rnd_rad), 
					$fn=peg_res);
            
            if (HEAD_STYLE == 1 || len(search(TUNER_STYLE, [0, 1])) > 0 || FORCE_TAIL_CAVITY) {
                // bottom counter hole
                translate([0,0,-TUNER_BD_TCK -TUNER_BOT_LEN +2*FUSE_SHIFT]) 
                    cylinder(h=TUNER_BOT_LEN, r=TUNER_BOT_RAD +cut_adj, $fn=peg_res);
                
                // turning button
                translate([0,0,-3*TUNER_BD_TCK -TUNER_BOT_LEN +3*FUSE_SHIFT]) 
                    cylinder(h=2*TUNER_BD_TCK, r=TUNER_BTN_RAD, $fn=peg_res);
            } else {
				hull() {
					// bottom counter hole
					minkowski() {
						translate([0,0,-TUNER_BD_TCK -TUNER_BOT_LEN +2*FUSE_SHIFT])
							cylinder(r2=TUNER_BOT_RAD -bot_rnd_rad,
									r1=TUNER_BTN_RAD -bot_rnd_rad,
									h=TUNER_BOT_LEN -bot_rnd_rad, $fn=peg_res);
						if (bot_rnd_rad > 0) sphere(r=bot_rnd_rad, $fn=LORES);
					}
					// turning button
					translate([0,0,-4*TUNER_BD_TCK -TUNER_BOT_LEN +5*FUSE_SHIFT]) 
						cylinder(h=3*TUNER_BD_TCK, 
							r=TUNER_BTN_RAD,
							$fn=peg_res);
				}
            }
        }
        if (!is_cut) {
            // string hole
            translate([2*TUNER_BD_TCK, 0, STR_HOLE_FROM_COUNTER-TUNER_BD_TCK]) 
            rotate([0, -90, 0]) 
                cylinder(h=4*TUNER_BD_TCK, r=2*STR_HOLE_RAD);
        }
    }
}
    
module pegs(is_cut = true) {
    peg_angle = HEAD_SIDE_CUT_ANGLE;
    pegswth = NUT_HOLE_GAP*(NUM_STRS-1);
    cut_adj = is_cut ? FIT_TOL : 0;
    drop = (HEAD_SLICE[0] -HEAD_SLICE[1]) +
			(-PEGS_SHIFT+HEAD_STEM)*sin(HEAD_ANGLE);
    dx = cos(peg_angle)*TUNER_GAP;
    dy = .5*sin(peg_angle)*TUNER_GAP;
    xshift = ceil(NUM_STRS/2)*dx;
    zshift = (HEAD_SLICE[0] - HEAD_SLICE[1]);
    translate([PEGS_SHIFT, 0, zshift +TUNER_UPLIFT])
    for (i = [0 : ceil(NUM_STRS/2) -1]) {
        anchor_dx = ANCHORPIN_OFFSET*cos(ANCHORPIN_ANGLE);
        anchor_dy = ANCHORPIN_OFFSET*sin(ANCHORPIN_ANGLE);
		peg_Y = i==0 && NUM_STRS%2>0 ? 0 : i*dy +i*HEAD_TUNER_WIDEN +PEGS_DIVIDE*TUNER_GAP; 
		peg_X = (i==0 && NUM_STRS%2>0 ?.3: i)*dx; 
        translate([peg_X -xshift , peg_Y, -drop]) 
            peg(anchor_dx, -anchor_dy, is_cut);
        
        if (is_cut && peg_Y != 0) { // only render half the real pegs
            translate([peg_X -xshift, -peg_Y, -drop]) 
                peg(anchor_dx, anchor_dy, is_cut);
        }
    }
}

module front_chamber(layer, chamber_front_scale, chamber_rad) {
    scale([chamber_front_scale, 1, 
        (layer == 0 ? CHAMBER_TOP_SCALE : CHAMBER_BOTTOM_SCALE)] ) 
    if (layer == 0) {
        mirror([1, 0, 0]) quartersphere(chamber_rad, res=HIRES/2);
    } else {
        mirror([0, 0, 1]) mirror([1, 0, 0]) quartersphere(chamber_rad, res=HIRES/2);
    }
}

module back_chamber(layer, chamber_back_scale, chamber_rad) {
    scale([chamber_back_scale, 1, 
        (layer == 0 ? CHAMBER_TOP_SCALE : CHAMBER_BOTTOM_SCALE)] ) 
    if (layer == 0) {
        quartersphere(chamber_rad, res=HIRES/2);
    } else {
        mirror([0, 0, 1]) quartersphere(chamber_rad, res=HIRES/2);
    }
}



module sound_port(rad) {
    translate([0, -1.6*rad, 0])
    scale(SOUND_PORT_SCALE) 
    rotate([-90, 0, -12]) 
    cylinder(r1 = rad, r2 = .1*rad, h=1.5*rad);
}

module string_holes(deg, gap, str_hole_rad = STR_HOLE_RAD) {
	str_res = DEFRES/2;
    rotate(deg,[0,1,0]) {
        for (i = [0:NUM_STRS-1]) {
            translate([0,(-(NUM_STRS/2 - 0.5) +i)*gap,0]) {
                cylinder(h=4*gap, r=str_hole_rad, $fn=str_res);
            }
        }
    }
}

module thru_holes() {
    thru_hole_plcmt = BRDG_WTH -5 -.5*MODEL; 
    thru_hole_gap = (SCALE_LEN + thru_hole_plcmt)*NECK_SLOPE*2/
        NUM_STRS +NUT_HOLE_GAP;
        
    // thru holes
    translate([thru_hole_plcmt, 0, -BRDG_TCK]) 
    scale([3,1,1])
    string_holes(0, thru_hole_gap, .5);
    
    translate([thru_hole_plcmt +1.5, 0, -BRDG_TCK]) 
        string_holes(0, thru_hole_gap, BRDG_PINHOLE_RAD);
}


module chamber(chamber_front_scale, chamber_back_scale, chamber_rad) {
    hull() {
        translate([0, 0, -FIT_TOL]) 
            front_chamber(0, chamber_front_scale, chamber_rad);
        translate([0, 0, -V_GAP+FIT_TOL]) 
            front_chamber(1, chamber_front_scale, chamber_rad);
        translate([0, 0, -FIT_TOL]) 
            back_chamber(0, chamber_back_scale, chamber_rad);
        translate([0, 0, -V_GAP+FIT_TOL]) 
            back_chamber(1, chamber_back_scale, chamber_rad);
    }       
}

module fhole(shoulder_len, torso_len, body_rad, hook_wth, hook_len) {
    translate( [NECK_LEN +N_GAP +S_GAP +shoulder_len +[.8, .6, .8][BRACE_STYLE]*torso_len, 
                -body_rad *.55, -BODY_TCK])  
    rotate([0, 0, [-3, -15, -8][BRACE_STYLE]]) 
        scurve(hook_wth, hook_len, 5*BODY_TCK);
}


module tail_pegs(is_cut = true) {
    back_scale = BODY_BACK_SCALE;
    // use geometry to factor distorted distance between tuners
    gap = sqrt(2*pow(back_scale,2)*pow(TUNER_GAP,2)/(pow(back_scale,2)+1)); 
    tuner_fanout = -180*gap/(PI*TUNER_FANOUT_RAD); 
    mid_i = NUM_STRS/2 -0.5;
    center_len = SCALE_LEN; 
    for (i = [0:NUM_STRS/2 - (NUM_STRS+1)%2]) { 
        fanout = tuner_fanout * (i - mid_i);
        translate([ center_len +TUNER_FANOUT_RAD*cos(fanout),  
                    TUNER_FANOUT_RAD*sin(fanout)/back_scale, 
                    TUNER_BD_TCK +TUNER_UPLIFT]) 
            peg(is_cut);
        
		// skip when rending pegs instead of cutting peg holes, so only half set of pegs shows
        if (is_cut) {
            translate([ center_len +TUNER_FANOUT_RAD*cos(fanout),  
                        -TUNER_FANOUT_RAD*sin(fanout)/back_scale, 
                        TUNER_BD_TCK +TUNER_UPLIFT]) 
                peg(is_cut);
        }
    }
}


module tail_peg_anchors(is_cut = true) {
    back_scale = BODY_BACK_SCALE;
    // use geometry to factor distorted distance between tuners
    gap = sqrt(2*pow(back_scale,2)*pow(TUNER_GAP,2)/(pow(back_scale,2)+1)); 
    tuner_fanout = -180*gap/(PI*TUNER_FANOUT_RAD); 
    mid_i = NUM_STRS/2 -0.5;
    center_len = SCALE_LEN; 
    for (i = [0:NUM_STRS/2 - (NUM_STRS+1)%2]) { 
        fanout = tuner_fanout * (i - mid_i);
        anchor_dx = -ANCHORPIN_OFFSET*cos(ANCHORPIN_ANGLE + (i-1)*tuner_fanout);
        anchor_dy = ANCHORPIN_OFFSET*sin(ANCHORPIN_ANGLE + (i-1)*tuner_fanout);
        translate([ center_len +TUNER_FANOUT_RAD*cos(fanout),  
                    TUNER_FANOUT_RAD*sin(fanout)/back_scale, 
                    TUNER_BD_TCK +TUNER_UPLIFT]) 
            peg_anchor(anchor_dx, -anchor_dy, is_cut);
        
        if (is_cut) {
            translate([ center_len +TUNER_FANOUT_RAD*cos(fanout),  
                        -TUNER_FANOUT_RAD*sin(fanout)/back_scale, 
                        TUNER_BD_TCK +TUNER_UPLIFT]) 
                peg_anchor(anchor_dx, anchor_dy, is_cut);
        }
    }
}

module tail_tuner_cavity() {  
    rndrad = 4*BOT_RND_RAD;
	butt_len = butt_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, 
							SHOULDER_FLARE, FRONT_BACK_RATIO);
	clen = butt_len -TUNER_CAVITY_DEP; // 90 arbitarty side of cutting cube  
	back_scale = BODY_BACK_SCALE;
	body_rad = BODY_RAD;
	wth_stretch = 2;
	w2 = wth_stretch*TUNER_CAVITY_WTH;
	rcut = w2-TUNER_CAVITY_WTH;
    if (FORCE_TAIL_CAVITY || len(search(TUNER_STYLE, [2,3,4])) == 0)         
    minkowski() {
        union() {
            difference() {
                translate( [SCALE_LEN +TUNER_CAVITY_DEP, 0, 
                            -2*clen -TUNER_BD_TCK -rndrad +2*TUNER_UPLIFT +FIT_TOL])
                    trapezoid(TUNER_CAVITY_WTH, w2, clen*2, clen*2, clen);
                
                translate( [SCALE_LEN , 0, -.5*TUNER_BD_TCK -rndrad]) 
                scale([TUNER_CAVITY_DOME_SCALE, 
                        TUNER_CAVITY_DOME_SCALE *CAVITY_DOME_SIDE_STRETCH, 
                        TUNER_CAVITY_DOME_SCALE *CAVITY_DOME_VERT_STRETCH]) 
                    butt(1, back_scale, body_rad*1.1, TOP_SCALE, BOTTOM_SCALE); 
            }    
        }
        
        sphere(r=rndrad, $fn=LORES);
    }
}

module logo() {  
    bot_rad = BODY_RAD*BOTTOM_SCALE;
    shoulder_len = shoulder_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE); 
    torso_len = torso_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE);
    
    difference() {
        for(l = [0:len(LOGO_TXT)-1]) {
            translate([SCALE_LEN - 2*LOGO_SIZE +N_GAP +S_GAP +l *LOGO_SIZE *1.5, 
                0, -bot_rad -V_GAP -C_GAP])
            mirror([0,1,0]) 
            rotate([0, 0, 90]) 
            linear_extrude(height = bot_rad) {
               text(text = LOGO_TXT[l], font = LOGO_FONT, size = LOGO_SIZE, 
                    halign = "center", spacing = 1.0);
            }
        }
        
        translate([N_GAP +S_GAP, 0, .5 -V_GAP -C_GAP]) {
            gourd([1], NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE, 
                FRONT_BACK_RATIO, TOP_SCALE, BOTTOM_SCALE);
        }
    }
}

// spine_wth <=0 means round spine, so radius = spine_ht/2
module round_spine(spine_len, spine_rad) {
    rotate([0, 90, 0]) cylinder(h=spine_len, r=spine_rad);
}

module rect_spine(spine_len, spine_ht, spine_wth, tented = false, beveled = true) {
    if (!tented) {
        translate([0, -spine_wth/2, -spine_ht/2])
            cube([spine_len, spine_wth, spine_ht]);
    } else {
        hull() {
            difference() {
                union() {
                    translate([-SPINE_PRE_LEN, 0, spine_ht/2])
                    rotate([180, 0, 0]) 
                        trapezoid(0, spine_wth, spine_ht/(beveled ? 2 : 1), spine_ht, SPINE_PRE_LEN);
                    translate([0, -spine_wth/2, -spine_ht/2])
                        cube([spine_len, spine_wth, spine_ht]);
                }
                translate([-SPINE_PRE_LEN -99, -50, -50]) cube([100, 100, 100]);
            }
            translate([1-SPINE_PRE_LEN, 0, beveled ? 0 : -spine_ht/2])
                cylinder(h=spine_ht/(beveled ? 2 : 1), r=.25);
            if (beveled) {
                translate([1-SPINE_PRE_LEN, 0, 0])
                sphere(r=.25, $fn=LORES);
            }
        }
    }
}

module place_spine(is_cut = false) {        
    cut_adj = (is_cut ? FIT_TOL :0);
    dist = (H_GAP + V_GAP + F_GAP + N_GAP +S_GAP > 0 ? SPINE_GAP/2 : 0);
    for (lr = dist > 0 ? [ 1, -1 ] : [0] ) {
        if (!RECT_SPINE) {
            translate([SPINE_PRE_LEN -H_GAP, lr*dist, SPINE_RAISE])
            round_spine(SPINE_LEN + H_GAP+N_GAP +S_GAP +2*cut_adj, 
                SPINE_RAD +2*cut_adj);
        } else {
            if (F_GAP > 0) {
                translate([SPINE_PRE_LEN -H_GAP, lr*dist, SPINE_RAISE +F_GAP]) 
                rotate([0, SPINE_STYLE ==3 ? SPINE_DIP :0, lr*SPINE_FAN]) 
                rect_spine(SPINE_LEN + N_GAP +S_GAP+H_GAP +2*cut_adj, 
                        SPINE_HT +2*cut_adj, 
                        SPINE_WTH +2*cut_adj,
                        tented=SPINE_TENTED);
            }
            
            if (is_cut && N_GAP +S_GAP > 0) {
                translate([SPINE_PRE_LEN -H_GAP, lr*dist, SPINE_RAISE +FUSE_SHIFT -V_GAP]) 
                rotate([0, SPINE_STYLE ==3 ? SPINE_DIP :0, lr*SPINE_FAN]) 
                rect_spine(NECK_LEN +H_GAP+N_GAP +S_GAP +cut_adj, 
                        SPINE_HT +2*cut_adj, 
                        SPINE_WTH +2*cut_adj,
                        tented=SPINE_TENTED);
                
                translate([SPINE_PRE_LEN -H_GAP +N_GAP +S_GAP, lr*dist, SPINE_RAISE +FUSE_SHIFT -V_GAP]) 
                rotate([0, SPINE_STYLE ==3 ? SPINE_DIP :0, lr*SPINE_FAN]) 
                rect_spine(SPINE_LEN +H_GAP+cut_adj, 
                        SPINE_HT +2*cut_adj, 
                        SPINE_WTH +2*cut_adj,
                        tented=SPINE_TENTED);
            } else {
                translate([SPINE_PRE_LEN -H_GAP, lr*dist, SPINE_RAISE +FUSE_SHIFT -V_GAP]) 
                rotate([0, SPINE_STYLE ==3 ? SPINE_DIP :0, lr*SPINE_FAN]) 
                rect_spine(SPINE_LEN + N_GAP +S_GAP+H_GAP +cut_adj, 
                        SPINE_HT +2*cut_adj, 
                        SPINE_WTH +2*cut_adj,
                        tented=SPINE_TENTED);
            }
            
            if (is_cut && SPINE_STYLE == 3) {
                // cut groove above actual spine in neck
                difference() {
                    translate([SPINE_PRE_LEN -H_GAP +N_GAP +S_GAP, lr*dist, SPINE_RAISE +2*SPINE_HT-V_GAP]) 
                    rotate([0, SPINE_DIP, lr*SPINE_FAN]) 
                    rect_spine(.8*SPINE_LEN +cut_adj +H_GAP +N_GAP +S_GAP, 
                            4*SPINE_HT+2*cut_adj, 
                            SPINE_WTH +2*cut_adj,
                            tented=SPINE_TENTED, beveled=false);
                    translate([0, -500, 1]) cube([1000, 1000, 1000]);
                    //translate([SPINE_PRE_LEN-1000, -500, -500]) cube([1000, 1000, 1000]);
                }
            }
        }
    }
}

module pickup(is_cut = true, rndrad=1, rimdep=.75) {
    cut_adj = is_cut? FIT_TOL : 0;
    butt_len = butt_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE, FRONT_BACK_RATIO) ;
    plen = PICKUP_STEM_LEN;
	pickup_res = 2*DEFRES;
    
    rotate([0, 90 +ENDPIN_ROLL, 0]) {
        translate([0, 0, -plen -rndrad])
        minkowski() {
            cylinder(r=2*ENDPIN_RAD+cut_adj, h=plen, $fn=pickup_res);
            sphere(r=rndrad, $fn=LORES);
        }
        
        translate([0, 0, -rndrad -FUSE_SHIFT])
        cylinder(r=ENDPIN_RAD+cut_adj, h=ENDPIN_DEP+3*(rndrad+FUSE_SHIFT), $fn=pickup_res);
        
        translate([0, 0, ENDPIN_DEP +rndrad -rimdep])
            minkowski() {
                cylinder(r=2*ENDPIN_RAD+cut_adj, h=plen, $fn=pickup_res);
                sphere(r=rndrad, $fn=LORES);
            }
	}
}

module place_pickup(is_cut = true) {    
    rndrad = 1.5*BOT_RND_RAD;
    rimdep = 1.5*BOT_RND_RAD;

    if (PICKUP_STYLE == 2) {
		roll = ENDPIN_ROLL +5;

		dx = (BUTT_LEN*cos(ENDPIN_DIP))*(1-ENDPIN_PUSHIN_RATIO);
		dy = (BODY_RAD*sin(ENDPIN_DIP))*(1-ENDPIN_PUSHIN_RATIO);
		dz = 4*ENDPIN_RAD;

        translate([SCALE_LEN+dx+N_GAP +S_GAP, dy, -dz -V_GAP])
        rotate([0, 0, ENDPIN_DIP])  
        rotate([0, roll, 0])  
        pickup(is_cut = true, rndrad, rimdep);
    } else if (PICKUP_STYLE == 1) {
        bot_rad = (HEAD_STYLE == 1 ? 1 : 
					TUNER_STYLE < 2 || FORCE_TAIL_CAVITY ? TUNER_CAVITY_DOME_SCALE :
					1-ENDPIN_PUSHIN_RATIO) *BUTT_LEN;
		dx = bot_rad*cos(ENDPIN_DIP);
		dz = (1-ENDPIN_PUSHIN_RATIO)*BODY_RAD*sin(ENDPIN_DIP)*BOTTOM_SCALE;

		translate([SCALE_LEN+dx+N_GAP +S_GAP, 0, -dz -V_GAP])
		rotate([0, ENDPIN_DIP, 0])
		translate([rndrad, 0, 0])
        rotate([0, ENDPIN_ROLL, 0])  
        pickup(is_cut = true, rndrad, rimdep);
    }
}
