////////////////////////////// 
// Gugulele 6 Util Functions 
///////////////////////////////

function fnl_height(fnl_curve_R, fnl_atop, fnl_abot) = 
    fnl_curve_R * (sin(fnl_abot) - sin(fnl_atop));
    
function fnl_bottom_radius(fnl_curve_R, fnl_rtop, fnl_atop, fnl_abot) = 
    fnl_rtop + fnl_curve_R * (cos(fnl_atop) - cos(fnl_abot));
    
// make funnel by rotate-extruding an eclipsed-rectangle
module funnel(fnl_curve_R, fnl_rtop, fnl_atop=0, fnl_abot=90, res=HIRES) { 
    fnl_ht = fnl_height(fnl_curve_R, fnl_atop, fnl_abot);
    fnl_rbot = fnl_bottom_radius(fnl_curve_R, fnl_rtop, fnl_atop, fnl_abot);
    
    rotate_extrude($fn=res) 
    projection(cut=true) {
        translate([-fnl_curve_R*cos(fnl_abot)-fnl_rbot, 
            fnl_curve_R*sin(fnl_atop) +fnl_ht, 0])
        difference() {
            translate([fnl_curve_R*cos(fnl_abot), 
                -fnl_curve_R*sin(fnl_atop) -fnl_ht, 0]) 
                cube([fnl_rbot, fnl_ht, 1]);
            difference() {
                cylinder(h=1, r=fnl_curve_R, $fn=res);
                translate([-fnl_curve_R, 0, 0]) 
                    cube([2*fnl_curve_R, 2*fnl_curve_R, 1]);
                translate([-2*fnl_curve_R,-fnl_curve_R, 0]) 
                    cube([2*fnl_curve_R, 2*fnl_curve_R, 1]);
                rotate([0,0,-fnl_atop]) 
                    cube([2*fnl_curve_R, 2*fnl_curve_R, 1]);
                rotate([0,0,90-fnl_abot]) 
                translate([-2*fnl_curve_R,-2*fnl_curve_R, 0]) 
                    cube([2*fnl_curve_R, 2*fnl_curve_R, 1]);
            }
        }
    }
}

module halfsphere(rad, is_hires = false) {
    difference() { 
        sphere(r=rad, $fn=(is_hires ? HIRES : DEFRES));
        translate([-rad,-rad,-2*rad]) cube([2*rad,2*rad,2*rad]);
    }
}

module quartersphere(rad, is_hires = false) {
    difference() { 
        halfsphere(rad, is_hires);
        translate([-2*rad,-rad,-rad]) cube([2*rad,2*rad,2*rad]);
    }
}

module round_rod(rod_len, rod_rad, res = DEFRES) {    
    hull() {
        translate([0, -rod_len/2, 0]) 
            sphere(r=rod_rad, $fn=res);
        translate([0, rod_len/2, 0]) 
            sphere(r=rod_rad, $fn=res);
    }
}

function hook_area(hwth, hlen) = .25 *PI *1.5 *hlen *hwth - .25 *PI *hlen *hwth;

module hook(wth=10, len=60, tck=1, is_hires = false) {
    scale([len, wth, tck])
    difference() {
        cylinder(r=1, h=1, $fn=HIRES);
        scale([3/2, 1, 1]) 
            cylinder(r=2/3, h=1, $fn=(is_hires ? HIRES : DEFRES));
        translate([-1, 0, 0]) cube([1, 1, 1]);
        translate([0, -1, 0]) cube([1, 2, 1]);
    }
}

module scurve(wth=20, len=120, tck=1, is_hires = false) {
    rotate([0, 0, 6]) {
        translate([0.0001, 5*wth/12, 0]) 
            hook(wth/2, len/2, tck, is_hires);
        translate([0,-5*wth/12, 0]) 
        rotate([0, 0, 180]) 
            hook(wth/2, len/2, tck, is_hires);
    }
}

// trapezoid for head stock and fretboard
module trapezoid(wth0, wth1, tck0, tck1, leng) {
    y0 = -0.5*wth0;
    y1 = 0.5*wth0;
    y2 = 0.5*wth1;
    y3 = -0.5*wth1;
    z0 = tck0;
    z4 = tck1;
    hull()
    polyhedron(
      points=[ [0,y0,z0],[0,y1,z0],[leng,y2,z4],[leng,y3,z4],  // top 4 pts 
               [leng,y3,0],[leng,y2,0],[0,y1,0], [0,y0,0]  ],  // low 4 pts 
      faces=[ 
              [0,1,2,3], // top
              [4,5,6,7], // low
            ]
     );
}

// a rounded corner rectangular arch with round rod
module rod_arch(wth, ht, rad, is_hires = false) {
    rotate([0, -90, 0 ]) {
        translate([ht-3*rad, -0.5*wth +3*rad, 0]) difference() {
            rotate_extrude(convexity = 10, $fn=(is_hires ? HIRES : DEFRES))
            translate([2*rad, 0, 0])
                circle(r = rad, $fn=(is_hires ? HIRES : DEFRES));
            translate([-3*rad, -3*rad, -2*rad]) 
                cube([3*rad, 6*rad, 4*rad]);
            translate([0, 0, -2*rad]) 
                cube([3*rad, 3*rad, 4*rad]);
        }
        translate([0, -0.5*wth +rad, 0]) rotate([0, 90, 0]) 
            cylinder(r=rad, h=ht-3*rad+FUSE_SHIFT, $fn=(is_hires ? HIRES : DEFRES));
        translate([ht-3*rad, 0.5*wth -3*rad, 0]) difference() {
            rotate_extrude(convexity = 10, $fn=(is_hires ? HIRES : DEFRES))
            translate([2*rad, 0, 0])
                circle(r = rad, $fn=(is_hires ? HIRES : DEFRES));
            translate([-3*rad, -3*rad, -2*rad]) 
                cube([3*rad, 6*rad, 4*rad]);
            translate([0, -3*rad, -2*rad]) 
                cube([3*rad, 3*rad, 4*rad]);
        }

        translate([0, 0.5*wth -rad, FUSE_SHIFT]) 
        rotate([0, 90, 0]) 
        cylinder(r=rad, h=ht-3*rad+FUSE_SHIFT, $fn=(is_hires ? HIRES : DEFRES));
        translate([ht-rad, 0.5*wth -3*rad +FUSE_SHIFT, 0]) 
        rotate([90, 0, 0]) 
        cylinder(r=rad, h=wth -6*rad +2*FUSE_SHIFT, $fn=(is_hires ? HIRES : DEFRES));  
    }
}

