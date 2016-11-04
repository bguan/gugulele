//////////////////////// 
// Gugulele 6 Body Parts 
//////////////////////////

// neck by layer, 0 is top, 1 is bottom
module neck(layer, front_scale, nlen, nwth, nslope, top_scale, bot_scale) {
    neck_tl_wth = nwth +2*nlen*nslope;
    prelen = FIT_TOL + nlen/front_scale;
    ntw = neck_tl_wth + FIT_TOL*2*nslope;
    planes = [-neck_tl_wth-1, 0];
    scales = [top_scale, bot_scale];
	scale([front_scale, 1, scales[layer] ]) difference() {
		translate([prelen, 0, 0]) rotate([0, -90, 0])
			cylinder(r2=nwth/2, r1=ntw/2, h=prelen, $fn=HIRES);
		translate([-1, -ntw/2 -1, planes[layer]]) 
			cube([prelen+2, ntw+2, ntw+1]);
	}        
}

// shoulder by layer, 0 is top, 1 is bottom
module shoulder(layer, front_scale, shoulder_len, torso_len, shoulder_curve_R, 
                shoulder_rtop, shoulder_rbot, shoulder_atop, shoulder_abot, 
                top_scale, bot_scale) {
    prelen = shoulder_len/front_scale;
    tlen = torso_len/front_scale;
    planes = [-2*shoulder_rbot-1, 0];
    scales = [top_scale, bot_scale];
    scale([front_scale, 1, scales[layer] ]) 
    difference() {
        translate([prelen, 0, 0]) 
        rotate([0, -90, 0]) 
        funnel(shoulder_curve_R, shoulder_rtop, shoulder_atop, shoulder_abot);
        
        translate([-1, -shoulder_rbot -1, planes[layer]]) 
        cube([prelen+2, 2*shoulder_rbot+2, 2*shoulder_rbot+1]);
    }
}

module torso(layer, front_scale, torso_len, body_rad, 
            top_scale, bot_scale) {
    tlen = torso_len/front_scale;
    planes = [-body_rad-1, 0];
    scales = [top_scale, bot_scale];
    scale([front_scale, 1, scales[layer] ]) difference() {
        translate([tlen, 0, 0]) 
            sphere(r=body_rad, $fn=HIRES);
        translate([-1, -body_rad -1, planes[layer]]) 
            cube([2*body_rad+2, 2*body_rad+2, body_rad+1]);
        translate([-2*body_rad, -body_rad -1, -body_rad-1]) 
            cube([2*body_rad, 2*body_rad+2, 2*body_rad+2]);
        translate([tlen, -body_rad -1, -body_rad-1]) 
            cube([2*body_rad+1, 2*body_rad+2, 2*body_rad+2]);
    }
}

module butt(layer, back_scale, body_rad, top_scale, bot_scale) {
    scale([back_scale, 1, (layer == 0 ? top_scale : bot_scale)] ) 
    rotate([(layer == 0 ? 0 : 180), 0, 0 ])
        quartersphere(body_rad, res=HIRES);
}


            
// The Main Gourd Shape that could be used as neck+body and head
module gourd(layers, nlen, nwth, nslope, mlen, flare, back_ratio, top_scale, bot_scale) {
                
    shoulder_rtop = shoulder_rtop(nlen, nwth, nslope);
    shoulder_atop = shoulder_atop(nslope);
    shoulder_abot = shoulder_abot(nslope, flare);
    shoulder_curve_R = shoulder_curve_R(nlen, nwth, nslope, flare); 
    shoulder_rbot = shoulder_rbot(nlen, nwth, nslope, flare); 

    body_rad = body_rad(nlen, nwth, nslope, flare); 
    front_scale = front_scale(nlen, nwth, nslope, mlen, flare); 
    back_scale = back_scale(nlen, nwth, nslope, mlen, flare, back_ratio);
    shoulder_len = shoulder_len(nlen, nwth, nslope, mlen, flare); 
    torso_len = torso_len(nlen, nwth, nslope, mlen, flare);
    butt_len = butt_len(nlen, nwth, nslope, mlen, flare, back_ratio);

    for (i=layers) {
        translate([0, 0, i == 0 ? -FUSE_SHIFT : 0]) 
            neck(i, front_scale, nlen, nwth, nslope, top_scale, bot_scale);
    
        translate([nlen -FUSE_SHIFT, 0, (i==0 ? -FUSE_SHIFT : 0)])
            shoulder(i, front_scale, shoulder_len, torso_len, 
                shoulder_curve_R, shoulder_rtop, shoulder_rbot,
                shoulder_atop, shoulder_abot, 
                top_scale, bot_scale);
        
        translate([nlen + shoulder_len -2*FUSE_SHIFT, 0, (i==0 ? -FUSE_SHIFT : 0) ] )
            torso(i, front_scale, torso_len, body_rad, 
                top_scale, bot_scale); 
    
        translate([nlen + shoulder_len + torso_len -3*FUSE_SHIFT, 0, (i==0 ? -FUSE_SHIFT : 0) ])
            butt(i, back_scale, body_rad, top_scale, bot_scale); 
    }
}

                
module dovetail(is_cut=false) {
    cut_adj = is_cut ? FIT_TOL : 0;
    trapezoid(NECK_JOINT_WTH2 +2*cut_adj, NECK_JOINT_WTH1 +2*cut_adj, 
              NECK_JOINT_TCK +2*cut_adj, NECK_JOINT_TCK +2*cut_adj, 
              NECK_JOINT_LEN +2*cut_adj);

	translate([0, 0, (is_cut ? FUSE_SHIFT: 0)])
	scale([1, 1, .25])
	difference() {
		rotate([0, 90, 0])
		cylinder(r2=NECK_JOINT_WTH1/2 +cut_adj, r1=NECK_JOINT_WTH2/2 +cut_adj, h=NECK_JOINT_LEN +2*cut_adj);

		translate([0, -200, 0]) cube([400, 400, 400]);
	}
}

module shoulder_joint(is_cut=false) {
    cut_adj = is_cut ? 2*FIT_TOL : 0;
	difference() {
		hull() 
		for(ud = [0, -1]) {
			for(lr = [-1, 1]) {
				translate([(SHOULDER_JNT_LEN+cut_adj)/2, 
							lr*(SHOULDER_JNT_WTH+cut_adj)/2, 
							ud*(SHOULDER_JNT_TCK+cut_adj)-(V_GAP > 0 ? 0 : SHOULDER_JNT_TCK/3)]) 
					rotate([0, 0, 90])
					round_rod(SHOULDER_JNT_LEN+cut_adj, 1);
			}
		}

		if (V_GAP > 0) {
			translate([-500, -500, 0])
			cube([1000, 1000, 1000]);
		}
	}
}

module body() {

    shoulder_rtop = shoulder_rtop(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE);
    shoulder_atop = shoulder_atop(NECK_SLOPE);
    shoulder_abot = shoulder_abot(NECK_SLOPE, SHOULDER_FLARE);
    shoulder_curve_R = shoulder_curve_R(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SHOULDER_FLARE); 
    shoulder_rbot = shoulder_rbot(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SHOULDER_FLARE); 

    body_rad = BODY_RAD;
    shoulder_len = shoulder_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE); 
    torso_len = torso_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE);
    front_scale = BODY_FRONT_SCALE;
    back_scale = BODY_BACK_SCALE;
    
    chamber_rad = body_rad - BODY_TCK;
    chamber_front_scale = CHAMBER_BODY_RATIO*front_scale;
    chamber_back_scale = CHAMBER_BODY_RATIO*back_scale*CHAMBER_BACK_RATIO;
    
    top_front_vol = PI*(chamber_front_scale*chamber_rad)*(CHAMBER_TOP_SCALE*chamber_rad)*chamber_rad/3;
    top_back_vol = PI*(chamber_back_scale*chamber_rad)*(CHAMBER_TOP_SCALE*chamber_rad)*chamber_rad/3;
    bot_front_vol = PI*(chamber_front_scale*chamber_rad)*(CHAMBER_BOTTOM_SCALE*chamber_rad)*chamber_rad/3;
    bot_back_vol = PI*(chamber_back_scale*chamber_rad)*(CHAMBER_BOTTOM_SCALE*chamber_rad)*chamber_rad/3;
    chamber_vol = top_front_vol +top_back_vol +bot_front_vol +bot_back_vol;
    echo(str("Chamber volume = ",chamber_vol, "(mm^3)"));
    
    // subtract spine & brace?
    chmb_len = chamber_rad*(chamber_front_scale + chamber_back_scale);
    echo(str("chamber len = ", chmb_len, "mm"));
    spine_vol_chmb = (SPINE_STYLE >=2 ? SPINE_HT*SPINE_WTH*chmb_len*(SPINE_GAP > 0 ? 2 : 1) : 0);
    echo(str("spine_vol_chmb = ", spine_vol_chmb, "mm^3"));
    brace_vol_chmb = [0, 2*chmb_len*BRACE_LEN_RATIO*BRACE_WTH, 
						chmb_len*BRACE_LEN_RATIO*body_rad*BRACE_SPAN_RATIO][BRACE_STYLE]; 
    echo(str("brace_vol_chmb = ", brace_vol_chmb, "mm^3"));
    adj_chmb_vol = chamber_vol -spine_vol_chmb -brace_vol_chmb; 
    echo(str("adjusted chamber volume = ", adj_chmb_vol, "mm^3"));
    
    hook_wth = HOOK_WTH_RATIO*body_rad;
    hook_len = HOOK_LEN_RATIO*torso_len;
    fholes_area = 2 *2 *hook_area(hook_wth, hook_len);
    
    top_hole_area = PI*pow(TOP_HOLE_RATIO*body_rad, 2);
    
    oval_len = OVAL_LEN_RATIO*body_rad; //1.4*front_scale*.12*body_rad;
    oval_wth = OVAL_WTH_RATIO*body_rad;
    sgl_o = PI * oval_len * oval_wth;
    dbl_o = 2*sgl_o;
    
    harea = ([0, fholes_area, top_hole_area, dbl_o, sgl_o][(SNDHOLE_STYLE -SNDHOLE_STYLE%2)/2])/
            pow(1000, 2);
    hvol = adj_chmb_vol/pow(1000,3);
    
    /* from
       http://www.acousticmasters.com/AcousticMasters_GuitarBody2.htm
       https://newt.phys.unsw.edu.au/jw/Helmholtz.html
    */

    max_tck = body_rad*TOP_SCALE -chamber_rad*CHAMBER_TOP_SCALE 
                -CHAMBER_UP_SHIFT +CHAMBER_FRONT_SHIFT*tan(CHAMBER_TILT) ;
    sndbd_tck = max_tck;
    echo(str("sndbd_tck (mm): ", sndbd_tck));

    tube_len = sndbd_tck + 1.7*(oval_len+oval_wth)/2;

    helmholz_freq = (SND_AIR_SPEED * sqrt(harea/(hvol * .001*tube_len)))/(2 *PI);
    echo(str("helmholz_freq = ", helmholz_freq, "hz"));
    echo(str("adjusted helmholz_freq = ", .98*helmholz_freq, "hz"));

    body_len = BODY_LEN;
    echo(str("Body Length = ", body_len, "mm"));
    
    screws_xy = [
                 [NECK_LEN +N_GAP +.1*shoulder_len, body_rad*.205],
                 [NECK_LEN +N_GAP +.5*shoulder_len, body_rad*.27], 
                 [NECK_LEN +N_GAP +.9*shoulder_len, body_rad*.5], 
                 [NECK_LEN +N_GAP +shoulder_len +torso_len*.34, body_rad*.82 ],
                 [NECK_LEN +N_GAP +shoulder_len +torso_len, body_rad*.965],
                 [body_len +N_GAP -10, body_rad*.55],
                 [body_len +N_GAP -3, body_rad*.15] 
                ];
    
    difference() {
        union() {
            if (SHOW_NECK) {
				translate([0, 0, -V_GAP])
                    neck(1, front_scale, NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE,
                        TOP_SCALE, BOTTOM_SCALE);
            }
            
            if (SHOW_SHOULDER_TOP) {
				translate([NECK_LEN +N_GAP -FUSE_SHIFT, 0, -FUSE_SHIFT]) {
					fs_len = (1-SHOULDER_SPLIT_RATIO)*shoulder_len; 
					bs_len = SHOULDER_SPLIT_RATIO*shoulder_len; 
					for (sx = (S_GAP == 0 ? [0] : V_GAP > 0 ? [S_GAP] : [0, S_GAP])) {
						translate([sx, 0, 0]) {
							difference() {
								shoulder(0, front_scale, shoulder_len, torso_len,
									shoulder_curve_R, shoulder_rtop, shoulder_rbot,
									shoulder_atop, shoulder_abot,
									TOP_SCALE, BOTTOM_SCALE);
								if (S_GAP > 0 && V_GAP == 0) {
									translate([(sx > 0 ? -bs_len : fs_len), -500, -FUSE_SHIFT])
										cube([shoulder_len, 1000, 1000]);
								}
							}
						}
					}
				}
			}

			if (SHOW_TOP) {
				translate([NECK_LEN +N_GAP +S_GAP + shoulder_len -2*FUSE_SHIFT, 0, -FUSE_SHIFT])
					torso(0, front_scale, torso_len, body_rad, TOP_SCALE, BOTTOM_SCALE);

				intersection() {
					// intersect with top butt piece to make sure the joint is seamless
					if (TOP_RND_RAD > 0) {
						translate([NECK_LEN +N_GAP +S_GAP + shoulder_len + torso_len -3*FUSE_SHIFT, 0, -FUSE_SHIFT])
								butt(0, back_scale*1.1, body_rad, TOP_SCALE, BOTTOM_SCALE); 
					}
					
					minkowski() {
						difference() {
							translate([NECK_LEN +N_GAP +S_GAP + shoulder_len + torso_len -3*FUSE_SHIFT, 0, -FUSE_SHIFT])
								butt(0, back_scale, body_rad -TOP_RND_RAD, TOP_SCALE, BOTTOM_SCALE); 

							if (HEAD_STYLE != 1) { 
								translate([N_GAP +S_GAP, 0, TUNER_UPLIFT -TUNER_BD_TCK -2*FIT_TOL])
									tail_pegs(is_cut = true);
							}
         
							// Flat butt cut
							if (BUTT_CHOP > 0) {
								translate([body_len +N_GAP +S_GAP, -200, -200]) 
								cube([400,400,400]);
							}
						}
						if (TOP_RND_RAD > 0) {
							sphere(r=TOP_RND_RAD, $fn=LORES);
						}
					}
				}
			}

            if (SHOW_SHOULDER_BOTTOM) {
				fs_len = (1-SHOULDER_SPLIT_RATIO)*shoulder_len; 
				bs_len = SHOULDER_SPLIT_RATIO*shoulder_len; 
				tck = NECK_JOINT_TCK*2;
				translate([NECK_LEN +N_GAP -FUSE_SHIFT, 0, -V_GAP]) {
					for (sx = (S_GAP == 0 ? [0] : [0, S_GAP])) {
						translate([sx, 0, 0]) {
							difference() {
								shoulder(1, front_scale, shoulder_len, torso_len,
									shoulder_curve_R, shoulder_rtop, shoulder_rbot,
									shoulder_atop, shoulder_abot,
									TOP_SCALE, BOTTOM_SCALE);

								if (S_GAP > 0) {
									if (sx == 0) {
										translate([fs_len, -500, -500])
										cube([1000, 1000, 1000]);
									} else {
										translate([fs_len -1000, -500, -500])
										cube([1000, 1000, 1000]);

										translate([fs_len-FIT_TOL, 0, 0])
										shoulder_joint(is_cut=true);
									}
								}
							}
						}
					}

					if (S_GAP > 0) {
						translate([fs_len -FUSE_SHIFT, 0, 0])
							shoulder_joint(is_cut=false);
					}
				}
			}

            if (SHOW_BOTTOM) {
					
				translate([NECK_LEN +N_GAP +S_GAP + shoulder_len -2*FUSE_SHIFT, 0, -V_GAP])
					torso(1, front_scale, torso_len, body_rad, TOP_SCALE, BOTTOM_SCALE);

				difference() {
					minkowski() {
						difference() {
							translate([NECK_LEN +N_GAP +S_GAP + shoulder_len + torso_len -3*FUSE_SHIFT, 0, -V_GAP])
								butt(1, back_scale, body_rad -BOT_RND_RAD, TOP_SCALE, BOTTOM_SCALE); 

							if (HEAD_STYLE != 1) union(){ 
								if (TUNER_STYLE < 2 || FORCE_TAIL_CAVITY) {
									translate([N_GAP +S_GAP, 0, -V_GAP])
										tail_tuner_cavity(4*BOT_RND_RAD);
								}
								translate([N_GAP +S_GAP, 0, TUNER_UPLIFT -TUNER_BD_TCK +FIT_TOL -V_GAP])
									tail_pegs(is_cut = true);
							}
         
							// Flat butt cut
							if (BUTT_CHOP > 0) {
								translate([body_len +N_GAP +S_GAP, -200, -200]) 
								cube([400,400,400]);
							}

							if (PICKUP_STYLE > 0) {
								place_pickup(is_cut=true);
							}
						}
						if (BOT_RND_RAD > 0) {
							scale([1, 1, BOTTOM_SCALE])
							sphere(r=BOT_RND_RAD, $fn=LORES);
						}
					}

					// shave away extra top material from rounding edges in bottom half
					if (BOT_RND_RAD > 0) {
						translate([N_GAP +S_GAP, -500, -V_GAP])
						cube([1000, 1000, 100]);
					}

					if (HEAD_STYLE != 1)
					    translate([N_GAP +S_GAP, 0, TUNER_UPLIFT -TUNER_BD_TCK +FIT_TOL -V_GAP])
						tail_peg_anchors(is_cut = true);
				}
			}
            
            if (SHOW_BOTTOM && C_GAP > 0) {
                
                translate([0, 0, -C_GAP]) {
                    intersection() { 
                        difference() {
                            union() {
                                translate([NECK_LEN +N_GAP +S_GAP + shoulder_len -2*FUSE_SHIFT, 0, -V_GAP] )
                                torso(1, front_scale, torso_len, body_rad, TOP_SCALE, BOTTOM_SCALE); 
                            
                                translate([NECK_LEN +N_GAP +S_GAP + shoulder_len + torso_len -3*FUSE_SHIFT, 0, -V_GAP])
                                butt(1, back_scale, body_rad, TOP_SCALE, BOTTOM_SCALE); 
                            }
                            
                            // chamber cut
                            translate([NECK_LEN +N_GAP +S_GAP +shoulder_len +torso_len -CHAMBER_FRONT_SHIFT, 
                                        0, CHAMBER_UP_SHIFT]) 
                            rotate([0, -CHAMBER_TILT, 0])
                            chamber(chamber_front_scale, chamber_back_scale, chamber_rad);
                        }
                        
						difference() {
							translate([NECK_LEN +N_GAP +S_GAP +shoulder_len +torso_len -BACK_COVER_SHIFT, 0, -V_GAP])
								back_cover(body_rad, BOTTOM_SCALE, front_scale, back_scale, is_cut=false);
							place_pickup(is_cut=true);
						}
                    }
                }
            }
            
            if (SHOW_SHOULDER_BOTTOM && N_GAP > 0) {
                // dovetail joint
                translate([NECK_LEN +N_GAP -NECK_JOINT_LEN +FUSE_SHIFT, 0, 
                    -NECK_JOINT_TCK -V_GAP])
                    dovetail(is_cut=false);
            }
            
            if (SHOW_TOP && BRDG_STYLE == 1) {
				// bridge seat 
				translate([SCALE_LEN +N_GAP +S_GAP + (HEAD_STYLE ==1 && STRTIE_STYLE !=2 ? -1+BRDG_WTH/2 : 0), 
						0, BRDG_SET -.25*BRDG_TCK]) 
					cube([BRDG_WTH+2, BRDG_LEN+2, .5*BRDG_TCK], center = true);
            }

            if (USE_SCREWS && SHOW_SCREWS && V_GAP > 0) {
                sz = -V_GAP/2;
                for(sxy = screws_xy)  {
                    if (HEAD_STYLE==1 || sxy[0] < (.9*body_len +N_GAP +S_GAP)) {
                        for (lr = [1, -1]) {
                            translate([sxy[0] +S_GAP, lr*sxy[1], sz]) 
                            screw(BODY_SCREW_MDL, thread="no"); 
                        }  
                    }
                }
            }

			if (S_GAP > 0 && SHOW_SCREWS) {
				//screw shoulders together
				for (lr = [-1, 1]) {
					translate([NECK_LEN +N_GAP +(1-SHOULDER_SPLIT_RATIO)*shoulder_len + SHOULDER_JNT_LEN/2, 
								lr*(-6+SHOULDER_JNT_WTH/2), V_GAP == 0 ? 50 : -V_GAP/2]) {
						screw(SHOULDER_SCREW_MDL, thread=SCREW_THREAD);
					}
				}
			}
        }
        
        if (SHOW_SHOULDER_TOP || SHOW_SHOULDER_BOTTOM || SHOW_TOP || SHOW_BOTTOM) {
            // chamber cut
			translate([NECK_LEN +N_GAP +S_GAP +shoulder_len +torso_len -CHAMBER_FRONT_SHIFT, 
							0, CHAMBER_UP_SHIFT]) 
				rotate([0, -CHAMBER_TILT, 0])
				chamber(chamber_front_scale, chamber_back_scale, chamber_rad);
        }

		if (S_GAP > 0 && USE_SCREWS) {
			//screw shoulders together
			for (fb = [0, 1]) 
			for (lr = [-1, 1])
				translate([NECK_LEN +N_GAP +fb*S_GAP + (1-SHOULDER_SPLIT_RATIO)*shoulder_len + SHOULDER_JNT_LEN/2, 
							lr*(-4+SHOULDER_JNT_WTH/2), (V_GAP > 0 ? -V_GAP-4 : -2)]) {
					cylinder(r=SHOULDER_SCREW_HEAD_RAD +FIT_TOL, h=40);
					screw(SHOULDER_SCREW_MDL, thread=SCREW_THREAD);
				}
		}
        
        // shoulder fretboard joint cut
        if ((SHOW_SHOULDER_TOP || SHOW_TOP) && F_GAP+N_GAP+S_GAP > 0) {
			for (sx = (S_GAP > 0 ? [0, S_GAP]: [0])) {
				if (V_GAP > 0 || FORCE_FRETBD_TANG) {
					translate([NECK_LEN +N_GAP +sx -FUSE_SHIFT, 
								-FRETBD_TOUNGE_WTH/2 -FIT_TOL, 
								(V_GAP > 0 ? -FIT_TOL: sx > 0 ? -FIT_TOL : 0)]) 
						cube([FRETBD_TOUNGE_LEN +FIT_TOL, 
							  FRETBD_TOUNGE_WTH +2*FIT_TOL, body_rad]);
				} else {
					translate([N_GAP+sx, 0, 0]) fretboard(is_cut = true);
				}
			}
        }
        
        // sound port cut
        if (SHOW_BOTTOM && len(search(SNDHOLE_STYLE, [1, 3, 5, 7])) > 0) {
            //echo(str("Sound port area (m^2): ", sport_area));
            translate( [NECK_LEN +N_GAP +S_GAP +shoulder_len +(V_GAP >0 ?.7 :.5)*torso_len, 
                       0, -.2*body_rad*BOTTOM_SCALE -V_GAP]) 
            sound_port(.75*body_rad);
        } 
        
        // f-hole cut
        if (SHOW_TOP && len(search(SNDHOLE_STYLE, [2, 3])) > 0) {  
            echo(str("F holes total area (m^2): ", fholes_area));
            fhole(shoulder_len, torso_len, body_rad, hook_wth, hook_len);
            mirror([0,1,0]) fhole(shoulder_len, torso_len, body_rad, hook_wth, hook_len);       
        }
        
        // Top-hole cut
        if (SHOW_TOP && len(search(SNDHOLE_STYLE, [4, 5])) > 0) {  
            echo(str("Top hole area (m^2): ", top_hole_area));
            translate( [NECK_LEN +N_GAP +S_GAP +shoulder_len +.15*torso_len, 0, 0]) 
            cylinder(r = TOP_HOLE_RATIO *body_rad, h = body_rad);       
        }
        
        // top oval hole cut
        if (SHOW_TOP && len(search(SNDHOLE_STYLE, [6, 7, 8, 9])) > 0) {  
            echo(str("Oval holes total area (m^2): ", harea));
            translate( [NECK_LEN +N_GAP +S_GAP +shoulder_len +(1-OVAL_PLCMT_RATIO)*body_rad, 0, -FUSE_SHIFT])
            oval_holes(body_rad, front_scale, oval_len, oval_wth);
        }
        
        // screw top and bottom of body together
        if (USE_SCREWS && V_GAP > 0) { 
		  for(sadj = (S_GAP > 0 ? [0, S_GAP] : [0])) {
            for(cxy = screws_xy)  {
			  if (sadj == S_GAP || cxy[0] < NECK_LEN + N_GAP + shoulder_len) {
                if (HEAD_STYLE==1 || cxy[0] < (.9*body_len +N_GAP)) {
                    for (cz = [1, 1-V_GAP]) {
                        if ((SHOW_TOP && cz > 0) || (SHOW_BOTTOM && cz <0))
                        for (lr = [1, -1]) {
                            translate([cxy[0] +sadj, lr*cxy[1], cz]) {
                                if (cz >= 0) 
                                    cylinder(r=BODY_SCREW_HEAD_RAD, h=body_rad);
                                screw(BODY_SCREW_MDL, thread="no"); 
                            }
                        }  
                    }
                }
			  }
            }    
		  }
        }
        
        // screw fretboard to neck
        if ((SHOW_NECK || SHOW_SHOULDER_TOP || SHOW_SHOULDER_BOTTOM ||  SHOW_TOP) && 
			USE_SCREWS && V_GAP + F_GAP + N_GAP +S_GAP > 0) {
			for(dz = (V_GAP > 0 ? [0, -V_GAP] :[0])) {
				translate([0, 0, dz]) {    
					for(dx = (N_GAP > 0 && S_GAP > 0 ? [0, N_GAP, N_GAP+S_GAP]:
							  N_GAP > 0 ? [0, N_GAP] :
							  S_GAP > 0 ? [0, S_GAP] : [0])) {
						rotate([0, -FRETBD_RISE, 0]) 
						translate([dx, 0, 0]) 
						deco_frets_from_nut(F1_LEN, F1_LEN / SEMI_RATIO, 1, true, 
							from=(dx == 0 ? 0 : dx == N_GAP || dx == S_GAP ? 12 : 17),
							to=(dx + N_GAP + S_GAP == 0 ? 24 : dx == 0 ? 20 : 24));
					}
				}   
			}
		}
        
        // screw head to neck 
        if ((SHOW_NECK || SHOW_HEAD) && USE_SCREWS && H_GAP > 0) {    
            for(lr = SPINE_STYLE > 0 && SPINE_GAP > 0 ? [0] : [1, -1]) {
				translate([-HEAD_SCREW_PREDEP, 
						lr*NUT_HOLE_GAP,
						-HEAD_SCREW_PLCMT -V_GAP]) 
				rotate([0, -90, 0]) {
					cylinder(r=HEAD_SCREW_HEAD_RAD +FIT_TOL, h=40);
					screw(HEAD_SCREW_MDL, thread=SCREW_THREAD);
				}
            }
        }
        
        if (SHOW_NECK && N_GAP > 0) {
            translate([NECK_LEN -NECK_JOINT_LEN, 0, 
                -NECK_JOINT_TCK -V_GAP -FIT_TOL ])
                dovetail(is_cut=true);
        }
            
        if (SHOW_TOP && B_GAP > 0) {
            translate([SCALE_LEN +N_GAP +S_GAP, 0, BRDG_SET]) 
                bridge(is_cut = true);
        }
        
        if (SHOW_TOP && (HEAD_STYLE==0 || HEAD_STYLE==2) && G_GAP > 0) {
            translate([STR_GUIDE_PLCMT +N_GAP +S_GAP, 0, 
                        BRDG_SET -STR_GUIDE_SET_OFF_BRDG +.5]) 
                strings_guide(is_cut = true); 
        }
        
        if (SHOW_TOP && HEAD_STYLE==1) {
			if (STRTIE_STYLE == 0) {
				translate([SCALE_LEN +N_GAP +S_GAP, 0, BRDG_SET]) 
				thru_holes();
			} else if (STRTIE_STYLE == 2) {
                strtie_entry = .1*BUTT_LEN;
				groove_rad = BODY_RAD*TOP_SCALE*.5;
				strtie_angle = (V_GAP > 0 ? 130 : 145);

    			tail_hole_gap = BODY_LEN*NECK_SLOPE*2/NUM_STRS +NUT_HOLE_GAP;
	
				translate([BODY_LEN - strtie_entry, 0, BRDG_SET]) 
				string_holes(strtie_angle, tail_hole_gap, .5);

				translate([BODY_LEN+(.05*BUTT_LEN), 0, groove_rad - (V_GAP > 0 ? .25 : .75)*strtie_entry]) 
					round_rod(1.1*(NUM_STRS-1)*tail_hole_gap, groove_rad);

			}
        }
            
        if (SHOW_BOTTOM && C_GAP > 0) {
            translate([NECK_LEN +N_GAP +S_GAP +shoulder_len +torso_len -BACK_COVER_SHIFT, 0, -V_GAP])
                back_cover(body_rad, BOTTOM_SCALE, front_scale, back_scale, is_cut=true);
        }
    }   
            
    if (USE_SCREWS && SHOW_SCREWS && V_GAP + F_GAP > 0) 
        translate([0, 0, .5*F_GAP -.5*V_GAP])   
        rotate([0, -FRETBD_RISE, 0]) 
            deco_frets_from_nut(F1_LEN, F1_LEN / SEMI_RATIO, 1, true);
    
	// under soundboard reinforcement for bridge
	if (SHOW_TOP && BRDG_STYLE == 2) {
		difference() {
			translate([SCALE_LEN +N_GAP +S_GAP, 0, BRDG_SET -.25*BRDG_TCK]) 
			scale([BRDG_WTH*3, 1, .6666666*BRDG_TCK])
			round_rod(BRDG_LEN, .3);

			// slice top half off
			translate([SCALE_LEN +N_GAP +S_GAP, 0, BRDG_SET]) 
			cube([BRDG_WTH*1.5, BRDG_LEN*1.5, .25*BRDG_TCK], center = true);

			// bridge foot print incl. screw holes
            translate([SCALE_LEN +N_GAP +S_GAP, 0, BRDG_SET]) 
                bridge(is_cut = true);
		}
	}
}


module head(wth, stem, nslope) {
    clen = 200; // arbitray side of cube to use as cut
    glen = gourd_len(stem, wth, nslope, HEAD_MIDLEN, HEAD_FLARE, HEAD_FRONT_BACK_RATIO);
    head_len = [ stem, glen, glen ][HEAD_STYLE];
    echo(str("Head Length = ", head_len));
    
    if (USE_SCREWS && SHOW_SCREWS && H_GAP > 0) {
        for(ud = [1, -1]) {
            translate([-.5*H_GAP, ud*NUT_HOLE_GAP, -HEAD_SCREW_PLCMT -V_GAP]) 
            rotate([0, -90, 0]) {
                screw(HEAD_SCREW_MDL, thread=SCREW_THREAD);
            }
        }
    }
    
    difference() {
        stem_wth = wth -2*stem*nslope;
        
        // Solid head parts
        if (HEAD_STYLE==0) {  // minimal headless
            // head stem bottom is extension of neck
            translate([FUSE_SHIFT -H_GAP, 0, -V_GAP]) 
            scale([1, 1, BOTTOM_SCALE]) 
            difference() {
                translate([0, 0, FUSE_SHIFT]) rotate([0, -90, 0])
                    cylinder(r2=stem_wth/2, r1=wth/2, h=stem, $fn=HIRES);
                translate([-clen, -clen/2, 0]) 
                    cube([clen, clen, clen]);
            }
            
            // head stem top is extension of fretboard if head is one with neck
            translate([-stem -H_GAP, 0, 
                    H_GAP > 0 ? -V_GAP -FUSE_SHIFT : F_GAP]) {
                trapezoid(stem_wth, wth, 
                        FRETBD_HD_TCK+.5*F0_RAD, FRETBD_HD_TCK+.5*F0_RAD, stem);
            }
        } else if (HEAD_STYLE==1) { // Headed w tuners
			minkowski() {
				difference() {
					translate([FUSE_SHIFT -H_GAP, 0, -V_GAP]) 
					rotate([ 0, 0, 180]) 
					gourd([0, 1], stem, wth -2*HD_RND_RAD, nslope, HEAD_MIDLEN, HEAD_FLARE, 
						HEAD_FRONT_BACK_RATIO, HEAD_TOP_SCALE, BOTTOM_SCALE);

					// slice top and bottom off at an angle
					for (tbd = [ HEAD_SLICE[0], -clen +HEAD_SLICE[1] ]) {
						translate([(tbd < 0 ? clen*tan(HEAD_ANGLE) :-stem ) -H_GAP +3, 
								0, tbd-V_GAP])
						rotate([0, -HEAD_ANGLE, 0]) 
						translate([-clen, -clen/2, 0]) 
							cube([clen,clen,clen]);
					}
					
					// slice left and right off at an angle
					for (i = [ 1, -1 ]) {
						translate([-clen/2  -H_GAP, 
								   i*(clen/2 +.5*NUT_HOLE_GAP*NUM_STRS), 
									-V_GAP])
						rotate([0, 0, i*HEAD_SIDE_CUT_ANGLE]) 
						translate([-clen/2, -clen/2, -clen/2]) 
							cube([clen,clen,clen]);
					}

					translate([-H_GAP, 0, -V_GAP]) 
					rotate([0, -HEAD_ANGLE, 0]) 
						pegs();
				}

				if (HD_RND_RAD > 0) 
					scale([1, 1, BOTTOM_SCALE])
						sphere(r=HD_RND_RAD, $fn=LORES);
			}
        } else { // decorative head
			minkowski() {
				difference() {
					translate([FUSE_SHIFT -H_GAP, 0, -V_GAP]) 
					rotate([ 0, 0, 180]) 
					gourd([0, 1], stem, wth -2*HD_RND_RAD, nslope, HEAD_MIDLEN, HEAD_FLARE, 
						HEAD_FRONT_BACK_RATIO, HEAD_TOP_SCALE, BOTTOM_SCALE);
					
					// cut groove at the top of headless stem
					translate([ -.5*HEADLESS_TOP_GROOVE_RAD -H_GAP, clen/2,
								HEADLESS_TOP_GROOVE_RAD -V_GAP +1]) 
					scale(1, 1, 2)
					rotate([90, 0, 0])
						cylinder(r=HEADLESS_TOP_GROOVE_RAD, h=clen, $fn=HIRES);
					
					// cut groove at front of headless stem
					translate([HEADLESS_FRONT_GROOVE_PLCMT[0] -H_GAP, 
								clen/2, 
								HEADLESS_FRONT_GROOVE_PLCMT[2] -V_GAP]) 
					scale([.7, 1, HEAD_POKED ? 1 : .7 ])
					rotate([90, 0, 0])
						cylinder(r=HEADLESS_FRONT_GROOVE_RAD, h=clen, $fn=HIRES);
            
				}
				if (HD_RND_RAD > 0) 
					scale([1, 1, BOTTOM_SCALE])
						sphere(r=HD_RND_RAD, $fn=LORES);
			}
        }
        
        // Subtract parts from head
        if (HEAD_STYLE == 0 ) {
            // cut string holes thru headless stem
            translate([-2*STR_HOLE_RAD -H_GAP, 0, FRETBD_HD_TCK +F0_RAD -V_GAP]) 
                string_holes(-90 -HEADLESS_STRING_ANGLE, NUT_HOLE_GAP);
            
            if (F_GAP > 0) {
                translate([-2*STR_HOLE_RAD -H_GAP, 0, FRETBD_HD_TCK +F0_RAD +
                    (H_GAP > 0 ? -V_GAP : F_GAP)]) 
                    string_holes(-90 -HEADLESS_STRING_ANGLE, NUT_HOLE_GAP);
            }
            
            // cut groove at the top of headless stem
            translate([-2*F0_RAD -H_GAP, clen/2, 
                        FRETBD_HD_TCK + F0_RAD +
                        (H_GAP > 0 ? -V_GAP : F_GAP)]) 
            rotate([90, 0, 0])
                cylinder(r=HEADLESS_TOP_GROOVE_RAD, h=clen, $fn=HIRES);
            
            translate([ -1.5*F0_RAD -H_GAP, -clen/2, 
                    FRETBD_HD_TCK +.5*F0_RAD -.5*HEADLESS_TOP_GROOVE_RAD +
                    (H_GAP > 0 ? -V_GAP -FUSE_SHIFT : F_GAP)])
                cube([HEADLESS_TOP_GROOVE_RAD, clen, F0_RAD]);
            
            // cut groove at the front of headless stem
            translate([-stem -H_GAP, clen/2, -2  -V_GAP -1]) 
            scale([.5, 1, 1])
            rotate([90, 0, 0])
                cylinder(r=HEADLESS_FRONT_GROOVE_RAD, h=clen, $fn=HIRES);
            
        } 
        
        if (HEAD_STYLE == 1 ) { 
			// cut to level any sharp angle at fretboard joint
			translate([-0.8*clen -H_GAP, -clen/2, FRETBD_HD_TCK]) 
				cube([clen,clen,clen]);
        }
            
        if (HEAD_STYLE == 2) {
            // cut string holes thru headless stem
            translate([-2*STR_HOLE_RAD -H_GAP, 0, FRETBD_HD_TCK +F0_RAD -V_GAP]) 
                string_holes(-90 -HEADLESS_STRING_ANGLE, NUT_HOLE_GAP);
            
            // level joining end to fretboard to avoid sharp edges
            translate([-.5*HEADLESS_TOP_GROOVE_RAD -H_GAP, -clen/2, -V_GAP+1+HD_RND_RAD]) 
            cube([clen,clen,clen]);
        }
        
        // cut to fit fretboard
        if (F_GAP +V_GAP +H_GAP > 0) {
            translate([-H_GAP, 0, -V_GAP]) fretboard(is_cut = true);
        }

        if (SHOW_NECK && USE_SCREWS && H_GAP > 0) {    
            for(lr = SPINE_STYLE > 0 && SPINE_GAP > 0 ? [0] : [1, -1]) {
				translate([-HEAD_SCREW_PREDEP -H_GAP, 
						lr*NUT_HOLE_GAP,
						-HEAD_SCREW_PLCMT -V_GAP]) 
				rotate([0, -90, 0]) {
					cylinder(r=HEAD_SCREW_HEAD_RAD +FIT_TOL, h=40);
					screw(HEAD_SCREW_MDL, thread=SCREW_THREAD);
				}
			}
            // level joining end to fretboard to avoid sharp edges
            translate([-.5*HEADLESS_TOP_GROOVE_RAD -H_GAP, 
                    -clen/2, FRETBD_HD_TCK-0.5]) 
                cube([clen,clen,clen]);
		}
    }
}

module fretboard(is_cut = false) {
    cut_adj = (is_cut ? FIT_TOL :0);
    
    shoulder_len = shoulder_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE); 
    torso_len = torso_len(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE);
    fretbd_hd_tck = FRETBD_HD_TCK;
    fretbd_hd_wth = NUT_HOLE_GAP*NUM_STRS;
    fretbd_neck_tck = fretbd_hd_tck + NECK_LEN*tan(FRETBD_RISE);
    fretbd_tl_tck = fretbd_hd_tck + FRETBD_LEN*tan(FRETBD_RISE);
    fretbd_tl_wth = fretbd_hd_wth +2*FRETBD_LEN*NECK_SLOPE;
    fretbd_extn_wth = fretbd_tl_wth +2*FRETBD_EXTN*NECK_SLOPE;
    fretbd_extn_tck = fretbd_tl_tck + FRETBD_EXTN*tan(FRETBD_RISE);
    f0_rad = F0_RAD +cut_adj;
    f0_len = 4*fretbd_hd_wth;
	front_scale = BODY_FRONT_SCALE;

    shoulder_rtop = shoulder_rtop(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE);
    shoulder_atop = shoulder_atop(NECK_SLOPE);
    shoulder_abot = shoulder_abot(NECK_SLOPE, SHOULDER_FLARE);
    shoulder_curve_R = shoulder_curve_R(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SHOULDER_FLARE); 
    shoulder_rbot = shoulder_rbot(NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SHOULDER_FLARE); 

    difference() {
        union() {
            trapezoid(fretbd_hd_wth+2*cut_adj, fretbd_tl_wth+2*cut_adj, 
                fretbd_hd_tck, fretbd_tl_tck, FRETBD_LEN);
            
            // Zeroth fret
            translate([0, 0, fretbd_hd_tck]) 
                scale([1, 1/4, 1]) round_rod(f0_len, f0_rad);
            
            translate([0, 0, fretbd_hd_tck])  {     
                difference() {
                    scale([1, 1/4, FRETBD_HD_TCK/f0_rad]) 
                        round_rod(f0_len, f0_rad);
                    translate([-2*f0_rad, -4*fretbd_hd_wth, 0]) 
                        cube([4*f0_rad, 8*fretbd_hd_wth, 2*FRETBD_HD_TCK]);
                }
            }
            
            // rolling extension to end of fretbd
            translate([FRETBD_LEN-FUSE_SHIFT, 0, 0]) {
                difference() {
                    // the main trapezoid of the extension
                    trapezoid(fretbd_tl_wth+2*cut_adj, fretbd_extn_wth+2*cut_adj, 
                            fretbd_tl_tck, fretbd_extn_tck, FRETBD_EXTN+cut_adj);
                    
                    if (!is_cut) {
                        // cut a notch where the roll off will happen
                        translate([FRETBD_EXTN/2, -fretbd_extn_wth/2, 
                                fretbd_extn_tck-FRETBD_EXTN/2]) 
                        cube([FRETBD_EXTN/2, fretbd_extn_wth, FRETBD_EXTN/2]);	
                    }
                }

                if (!is_cut) {
                    intersection() {
                        trapezoid(fretbd_tl_wth+2*cut_adj, 
                            fretbd_extn_wth+2*cut_adj, 
                            fretbd_tl_tck, fretbd_extn_tck, FRETBD_EXTN);
                        
                        translate([FRETBD_EXTN/2 -FUSE_SHIFT, fretbd_extn_wth/2, 
                                    fretbd_extn_tck-FRETBD_EXTN/2-FUSE_SHIFT]) 
                        rotate([90,0,0])
                        difference() {
                            cylinder(r=FRETBD_EXTN/2, h=fretbd_extn_wth);
                            translate([-FRETBD_EXTN, -FRETBD_EXTN/2, 0]) 
                                cube([FRETBD_EXTN, FRETBD_EXTN, fretbd_extn_wth]);
                            translate([-FRETBD_EXTN/2, -FRETBD_EXTN, 0]) 
                                cube([FRETBD_EXTN, FRETBD_EXTN, fretbd_extn_wth]);
                        }
                    }
                }
            }
        }
        
        // string slots on Zeroth fret
        if (!is_cut) {
            translate([-2*f0_rad, 0, fretbd_hd_tck +f0_rad +.25*STR_HOLE_RAD]) 
                string_holes(90, NUT_HOLE_GAP);
        }
        
        if (!is_cut && (V_GAP > 0 || FORCE_FRETBD_TANG) && F_GAP > 0) {
            // use shoulder top to cut fretboard!
            translate([NECK_LEN -FUSE_SHIFT -FIT_TOL, 0, TOP_RND_RAD + FIT_TOL]) {
					shoulder(0, front_scale, shoulder_len, torso_len,
						shoulder_curve_R, shoulder_rtop, shoulder_rbot,
						shoulder_atop, shoulder_abot,
						TOP_SCALE, BOTTOM_SCALE);
				translate([shoulder_len-FUSE_SHIFT, 0, 0])
					torso(0, front_scale, torso_len, BODY_RAD, 
					TOP_SCALE, BOTTOM_SCALE); 
				translate([0, -100, -100+FUSE_SHIFT])
					cube([200, 200, 100]);
			}
        }
    }
    
    // tounge into shoulder groove
    if (!is_cut && (V_GAP > 0 || FORCE_FRETBD_TANG) && F_GAP > 0) {
        translate([NECK_LEN -FIT_TOL -FUSE_SHIFT, 0, 0]) 
            trapezoid(FRETBD_TOUNGE_WTH, FRETBD_TOUNGE_WTH, 
                      fretbd_neck_tck -2, 
                      fretbd_tl_tck -2, 
                      FRETBD_TOUNGE_LEN);
    }
    
    // inserts into spine groove
    if (!is_cut && SPINE_STYLE == 3 && F_GAP > 0) {
        difference() {
            for (lr = USE_SCREWS ? [1, -1] : [0]) {
                translate([SPINE_PRE_LEN, lr*SPINE_GAP/2, SPINE_RAISE +SPINE_HT]) 
                rotate([0, SPINE_STYLE ==3 ? SPINE_DIP :0, lr*SPINE_FAN]) 
                rect_spine(SPINE_LEN, SPINE_HT, SPINE_WTH, tented=SPINE_TENTED, beveled=false);
            }
            translate([0, -500, FUSE_SHIFT]) cube([1000, 1000, 1000]);
            translate([-1000, -500, -500]) cube([1000, 1000, 1000]);
            translate([FRETBD_LEN +(V_GAP > 0 ? -FIT_TOL : FRETBD_EXTN), -500, -500]) cube([1000, 1000, 1000]);
        }
    }
}


module bridge(is_cut = false) {
    brdg_hole_gap = SCALE_LEN*NECK_SLOPE*2/NUM_STRS +NUT_HOLE_GAP;
    cut_adj = (is_cut ?FIT_TOL :0);
    cut_rad = HEAD_STYLE==1 ? (STRTIE_STYLE == 1 ? .4 : 1)*BRDG_WTH -SDDL_RAD : (BRDG_WTH/2)-SDDL_RAD;
    cut_scale = HEAD_STYLE==1 ? BRDG_CARVE_SCALE : BRDG_CARVE_SCALE*2;
    brdg_bottom = BRDG_TCK -cut_rad*cut_scale;
    side_cut_rad = BRDG_TCK +SDDL_RAD -brdg_bottom;
    brdg_len = BRDG_LEN;
    
    difference() {
        if (HEAD_STYLE==0 || HEAD_STYLE==2 || (HEAD_STYLE==1 && STRTIE_STYLE==2)) {
            // bridge block
            translate([-BRDG_WTH /2 -cut_adj, -brdg_len/2 -cut_adj, -cut_adj]) 
            cube([BRDG_WTH +2*cut_adj, brdg_len +2*cut_adj, BRDG_TCK +cut_adj]);
            
            // saddle
            if (!is_cut)
            translate([0, brdg_len/2, BRDG_TCK]) 
            rotate([90,0,0]) cylinder(h=brdg_len, r=SDDL_RAD);
        } else {
            // bridge block
            translate([-SDDL_RAD -cut_adj, -brdg_len/2 -cut_adj, -cut_adj]) 
            cube([BRDG_WTH +2*cut_adj, brdg_len +2*cut_adj, BRDG_TCK +cut_adj]);
            
            // saddle
            if (!is_cut)
            translate([0, brdg_len/2, BRDG_TCK]) 
            rotate([90,0,0]) cylinder(h=brdg_len, r=SDDL_RAD);

			if (!is_cut && STRTIE_STYLE == 1) {
				// string tie block
				translate([-1+BRDG_WTH/2, -brdg_len/2, BRDG_TCK-FUSE_SHIFT]) 
				cube([BRDG_WTH/2, brdg_len, SDDL_RAD]);
			}
        }
         
        if ((HEAD_STYLE==0 || HEAD_STYLE==2 || (HEAD_STYLE==1 && STRTIE_STYLE==2)) && !is_cut) {
            // bridge front/back carves
            for (x = [-1, 1]) { 
                translate([x*(SDDL_RAD+cut_rad), brdg_len/2 +1, BRDG_TCK]) {
					scale([1, 1, cut_scale])  
					rotate([90, 0, 0]) cylinder(r=cut_rad, h=brdg_len+2, $fn=2*DEFRES);
				}
            } 
            // bridge left/right carves
            for (y = [-1, 1]) { 
                translate([-BRDG_WTH, y*brdg_len/2, BRDG_TCK+SDDL_RAD]) 
                rotate(90,[0,1,0]) cylinder(h=2*BRDG_WTH, r=side_cut_rad, $fn=2*DEFRES);
            }
        } else if (HEAD_STYLE==1 && !is_cut) {
            // bridge back carve
            translate([STRTIE_STYLE == 1 ? cut_rad+SDDL_RAD : BRDG_WTH, brdg_len/2 +1, BRDG_TCK]) {
				translate([-cut_rad, -brdg_len-2, -FUSE_SHIFT]) 
					cube([cut_rad*2, brdg_len+2, BRDG_TCK]);
				scale([1, 1, (STRTIE_STYLE == 1 ? 1.2 : 1)*cut_scale])
				rotate([90, 0, 0]) cylinder(r=cut_rad, h=brdg_len+2, $fn=2*DEFRES);
            }

            if (STRTIE_STYLE != 1) {
				// bridge left/right carves
				for (y = [-1, 1]) { 
					translate([-BRDG_WTH, y*brdg_len/2, BRDG_TCK+SDDL_RAD]) 
					rotate(90,[0,1,0]) cylinder(h=2*BRDG_WTH, r=side_cut_rad, $fn=2*DEFRES);
				}

				if (STRTIE_STYLE == 0) thru_holes();
			} 
        }
        
        // string grooves on top of saddle
        if (!is_cut) {
			translate([-10, 0, BRDG_TCK +SDDL_RAD +.25*STR_HOLE_RAD]) 
			string_holes(90, brdg_hole_gap, STR_HOLE_RAD, strlen=brdg_hole_gap); // .5);

			if (STRTIE_STYLE == 1) {
				translate([BRDG_WTH/2, 0, BRDG_TCK +SDDL_RAD]) 
				string_holes(115, brdg_hole_gap, .5);

				// groove at back of bridge for string knots
				translate([BRDG_WTH, 0, .5*BRDG_TCK])
				rotate([90, 0, 0])
				translate([0, 0, -BRDG_LEN])
					cylinder(h=2*BRDG_LEN, r=.3*BRDG_TCK);
			}

		}
                
        if (USE_SCREWS && B_GAP > 0 && !is_cut)
        for (y = (STRTIE_STYLE==1 ? [.95, -.95] : [1, -1])) {
            translate([ (HEAD_STYLE!=1 || STRTIE_STYLE==2 ?0 : STRTIE_STYLE==1? .4*BRDG_WTH:BRDG_SCREW_HEAD_RAD), 
                        y*(brdg_len - 2.1*BRDG_SCREW_HEAD_RAD)/2, 
                        brdg_bottom+(STRTIE_STYLE==1 ? -2 :.25)]) {
                cylinder(r=BRDG_SCREW_HEAD_RAD +FIT_TOL, h=BRDG_TCK);
                screw(BRDG_SCREW_MDL, thread=SCREW_THREAD);
            }
        }
    } 
        
    if (USE_SCREWS && B_GAP > 0)
    for (y = (STRTIE_STYLE==1 ? [.95, -.95] : [1, -1])) {
        if (is_cut) {
            translate([(HEAD_STYLE!=1 || STRTIE_STYLE == 2 ? 0 : STRTIE_STYLE==1? .4*BRDG_WTH:BRDG_SCREW_HEAD_RAD), 
                    y*(brdg_len - 2.1*BRDG_SCREW_HEAD_RAD)/2, 
                    brdg_bottom+(STRTIE_STYLE==1 ? -2 :.25)]) {
                cylinder(r=BRDG_SCREW_HEAD_RAD +FIT_TOL, h=BRDG_TCK);
                screw(BRDG_SCREW_MDL, thread=SCREW_THREAD);
            }
        } else if (SHOW_SCREWS) {
            translate([(HEAD_STYLE!=1 || STRTIE_STYLE == 2 ? 0 : STRTIE_STYLE==1? .4*BRDG_WTH:BRDG_SCREW_HEAD_RAD), 
                    y*(brdg_len - 2.1*BRDG_SCREW_HEAD_RAD)/2, 
                    brdg_bottom - .5*B_GAP]) {
                screw(BRDG_SCREW_MDL, thread=SCREW_THREAD);
            }
        }
    }
}

module strings_guide(is_cut = false) {
    rad = STR_GUIDE_ROD_RAD+(is_cut? FIT_TOL :0);
    ht = rad +3*STR_HOLE_RAD +STR_GUIDE_SET_OFF_BRDG;
    wth = NUM_STRS*NUT_HOLE_GAP +2*NECK_SLOPE*STR_GUIDE_PLCMT -2*rad;   
    gap = wth/(NUM_STRS-1);
    difference() {   
        union() {
            rod_arch(wth +2*rad, ht, rad);
            for ( i = [0 : (NUM_STRS/2 -1)] ) {
                lrd = i == 0 ? .5 :.55;
                for (lr = [lrd, -lrd]) {
                    translate([0, lr*(wth -2*i*gap), FUSE_SHIFT]) {
                        if (i>0) cylinder(r=rad, h=ht-rad); // inner rods 
                        if (USE_SCREWS && G_GAP > 0) {
                            if (is_cut) {
                                translate([0, 0, ht-rad-1])  {
                                    screw(GUIDE_SCREW_MDL, thread=SCREW_THREAD);
                                }
                            } else if (SHOW_SCREWS) {
                                translate([0, 0, ht -rad -.5*G_GAP]) 
                                screw(GUIDE_SCREW_MDL, thread=SCREW_THREAD);
                            }
                        }
                    }
                }
            }
        }
        
        // screw top and bottom of body together
        if (!is_cut && USE_SCREWS && G_GAP > 0) {    
            for ( i = [0 : (NUM_STRS/2 -1)] ) {
                lrd = i == 0 ? .5 :.55;
                for (lr = [lrd, -lrd]) {
                    translate([0, lr*(wth -2*i*gap), ht-rad-1]) {
                        cylinder(r=GUIDE_SCREW_HEAD_RAD +FIT_TOL, h=ht);
                        screw(GUIDE_SCREW_MDL, thread=SCREW_THREAD);
                    }
                }
            }
        }
    }
}

module lay_frets_from_nut(last_offset,last_fwth, n) {    
    fretbd_hd_wth = NUT_HOLE_GAP*NUM_STRS;
    ftck = FRETBD_HD_TCK + last_offset*tan(FRETBD_RISE);
    flen = fretbd_hd_wth + 2*NECK_SLOPE*last_offset - FRET_RAD/2;
	fret_res = DEFRES/2;
    
    if (last_offset < FRETBD_LEN +0.5*last_fwth && 
        last_fwth > MIN_FRET_WTH && n<=24) {        
        translate([last_offset, 0, FRETBD_HD_TCK -FRET_INSET]) 
        scale([1, 1/4, 1]) 
            round_rod(4*flen, FRET_RAD, fret_res);
            
        lay_frets_from_nut(last_offset + last_fwth, 
            last_fwth / SEMI_RATIO, n+1);
    } else {
        echo("Max num of frets: ",n-1);
    }
}

module deco_frets_from_nut(last_offset,last_fwth,n, 
        is_cut = true, from = 0, to = 24) {
    use_screw = (USE_SCREWS && V_GAP + F_GAP + N_GAP +S_GAP > 0 || FORCE_FRETBD_SCREWS);
    fretbd_hd_wth = NUT_HOLE_GAP*NUM_STRS;
	screw_res = DEFRES/2;

    if (last_offset<FRETBD_LEN+last_fwth && last_fwth > MIN_FRET_WTH && n <= to) {
        cut_dep = 0.1;
        if (len(search(n, [3, 7, NUM_STRS < 6 ? 10 : 9, 15, 19, NUM_STRS < 6 ? 21 :21])) > 0 && n >= from) {
            translate([last_offset - 0.5*last_fwth, 0, FRETBD_HD_TCK -cut_dep]) 
            if (use_screw) {
                translate([0, 0, cut_dep-NECK_SCREW_HEAD_TCK]) {
                    cylinder(r=NECK_SCREW_HEAD_RAD +FIT_TOL, 
                        h=NECK_SCREW_HEAD_TCK +FUSE_SHIFT,
						$fn=screw_res);
                    screw(SPINE_GAP > 0 ? NECK_SCREW_MDL : NECK_SHORT_SCREW_MDL, 
						thread=SCREW_THREAD);
                }
            } else {
                cylinder(r=1.5, h= cut_dep + (is_cut ? 0.1 : 0),
						$fn=screw_res);
            }
        } else if (len(search(n, [5, 17])) > 0 && n >= from) {
            translate([last_offset - 0.5*last_fwth, 0, FRETBD_HD_TCK -cut_dep]) 
            if (use_screw) {
                df = 2.5;
                for (lr = [df, -df]) {
                    translate([0, lr*NECK_SCREW_HEAD_RAD , 
                        cut_dep-NECK_SCREW_HEAD_TCK]) {
                        cylinder(r=NECK_SCREW_HEAD_RAD +FIT_TOL, 
                            h=NECK_SCREW_HEAD_TCK +FUSE_SHIFT,
						$fn=screw_res);
                        screw(NECK_SCREW_MDL, thread=SCREW_THREAD);
                    }
                }
            } else {
                translate([-1.5, -5, 0]) 
                    cube([3, 10, cut_dep + (is_cut ? 0.1 : 0)]);
            }
        } else if (len(search(n, [12, 24])) > 0 && n >= from) {
            translate([last_offset - 0.5*last_fwth, 0, FRETBD_HD_TCK -cut_dep]) 
            if (use_screw) {
                df = 6;
                for (lr = [df, 0, -df]) {
                    translate([0, lr*NECK_SCREW_HEAD_RAD , 
                        cut_dep-NECK_SCREW_HEAD_TCK]) {
                        cylinder(r=NECK_SCREW_HEAD_RAD +FIT_TOL, 
                            h=NECK_SCREW_HEAD_TCK +FUSE_SHIFT,
						$fn=screw_res);
                        screw(lr == 0 && SPINE_GAP == 0 ? NECK_SHORT_SCREW_MDL : NECK_SCREW_MDL, 
							thread=SCREW_THREAD);
                    }
                }
            } else {
                translate([-1.5, -8, 0]) 
                    cube([3, 16, cut_dep + (is_cut ? 0.1 : 0)]);
            }
        } else if (F_GAP > 0 && n == 1 && n >= from && use_screw && !FORCE_FRETBD_SCREWS) {
            df = (SPINE_GAP>0 ? 2.5 : 7.5);
            translate([last_offset - 0.5*last_fwth, 0, FRETBD_HD_TCK -cut_dep]) 
            for (lr = [df, -df]) {
                translate([0, lr*NECK_SCREW_HEAD_RAD, cut_dep-NECK_SCREW_HEAD_TCK]) {
                    cylinder(r=NECK_SCREW_HEAD_RAD +FIT_TOL, 
                        h=NECK_SCREW_HEAD_TCK +FUSE_SHIFT,
						$fn=screw_res);
                    screw(BODY_SCREW_MDL, thread=SCREW_THREAD);
                }
            }
        } 
        deco_frets_from_nut(last_offset + last_fwth, 
            last_fwth / SEMI_RATIO, n+1, is_cut, from, to);
    } 
}


module strings() {
    net_rise = (BRDG_SET + BRDG_TCK + SDDL_RAD) -(FRETBD_HD_TCK + F0_RAD);
    net_rise_deg = atan(net_rise/SCALE_LEN);
    
    translate([0, 0, FRETBD_HD_TCK + F0_RAD])
    rotate([0, 90 -net_rise_deg, 0]) 
    translate([0, 0, -100])
        cylinder(h=SCALE_LEN+200, r=0.5);
}


module xbrace(body_rad, butt_len) {    
    rod_vrad = .2*body_rad*TOP_SCALE;
	//rod_lift = [7.5, 7, 6.5, 6, 6, 5.5][MODEL]*rod_vrad;
	rod_lift = body_rad*TOP_SCALE -rod_vrad;
    
    intersection() {
        union() {
            for (lr = [1, -1]) {
                translate([N_GAP +S_GAP +SCALE_LEN -BRACE_X_PLCMT_RATIO*body_rad, 
					lr*(1-BRACE_X_WIDEN_RATIO)*body_rad, 
					SPINE_RAISE +rod_lift])
					rotate([0, 0, lr*(90-BRACE_X_ANGLE)])
					translate([-BRACE_X_MID_RATIO*body_rad*BRACE_LEN_RATIO, -.5, 0])
					scale([1, 4, 2*rod_vrad/BRACE_WTH])
						round_rod(body_rad*BRACE_LEN_RATIO, BRACE_WTH);
				}
        }
        
        translate([N_GAP +S_GAP, 0, -FUSE_SHIFT])
		difference() {
			gourd([0], NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE, 
				FRONT_BACK_RATIO, TOP_SCALE, BOTTOM_SCALE);

            if (B_GAP > 0) {
                translate([SCALE_LEN, 0, BRDG_SET]) 
                    bridge(is_cut = true);
            }
			
			// Flat butt cut
			if (HEAD_STYLE==1) {
				translate([BODY_LEN, -200, -200]) cube([400,400,400]);
			}
		}
    }
}

module tbrace(body_rad, butt_len) {    
    rod_vrad = .23*body_rad*TOP_SCALE;
    intersection() {
        union() {
            translate([N_GAP +S_GAP +SCALE_LEN -.2*body_rad, 0, 3.5*rod_vrad])
            rotate([0, 0, 90])
            scale([1, 4, 1.5*rod_vrad/BRACE_WTH])
                round_rod(body_rad*BRACE_LEN_RATIO/3, BRACE_WTH);
            
            translate([N_GAP +S_GAP +SCALE_LEN, 0, 3.5*rod_vrad])
            scale([1, 4, 1.5*rod_vrad/BRACE_WTH])
                round_rod(body_rad*BRACE_SPAN_RATIO/2, BRACE_WTH);
        }
        
        translate([N_GAP +S_GAP, 0, -FUSE_SHIFT])
        difference() {
            gourd([0], NECK_LEN, NECK_HEAD_WTH, NECK_SLOPE, SCALE_LEN, SHOULDER_FLARE, 
                FRONT_BACK_RATIO, TOP_SCALE, BOTTOM_SCALE);
            
            if (B_GAP > 0) {
                translate([SCALE_LEN, 0, BRDG_SET]) 
                    bridge(is_cut = true);
            }
			
			// Flat butt cut
			if (HEAD_STYLE==1) {
				translate([BODY_LEN, -200, -200]) cube([400,400,400]);
			}
        }
    }
}

