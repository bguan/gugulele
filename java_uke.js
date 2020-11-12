// Simple OpenJSCAD based implementation
// View in https://openjscad.org/

const SCALE_LEN = 400;
const HEAD_LEN = 60;
const NECK_RATIO = 0.55;
const NUT_WIDTH = 40;
const FRETBD_RATIO = 0.65;
const FRETBD_TCK = 5;
const NECK_WIDE_ANGLE = 1;
const HEAD_ANGLE = 12;
const NECK_BOTTOM_RATIO = .5;
const SIDE_RATIO = .5;
const TOP_RATIO = .05;
const BOTTOM_RATIO = .35;
const TAIL_RATIO = .5;
const BRIDGE_HT = 8;
const FRET_HT = 1.2;
const SEMI_RATIO = Math.pow(2.0,1/12);

function genBridge(bridgeLen, bridgeHt) {
    var bridge = cylinder({
        start: [0, -bridgeLen/2, 0], 
        end: [0, bridgeLen/2, 0], 
    });
    bridge = bridge.scale([2, 1, bridgeHt]);
    return bridge;
}

function accum_mult_n(x, n) {
    return (n<=0 ? 0 : x + accum_mult_n(x/SEMI_RATIO, n-1));
}

function genFrets(fretbdLen, nutWth, fretbdTck, neckWideAng, scaleLen, fretHt) {
    var frets = cylinder({
            start: [0, -nutWth/2, 0], end: [0, nutWth/2, 0], 
            round:true }).scale([1.5, 1, 1.5*fretHt]).translate([0,0,fretbdTck]);
    var fx = 0;
    var gap = (scaleLen/2) / accum_mult_n(1, 12);
    while (fx < (fretbdLen -gap)) {
        fx = fx + gap;
        var fy = nutWth/2 + tan(neckWideAng)*fx -1;
        var fz = fretbdTck + tan(neckWideAng)*fx;
        var fret = cylinder({
            start: [fx, -fy, 0], end: [fx, fy, 0], 
            round: true }).scale([1,1,fretHt]).translate([0,0,fz])
        frets = union(frets, fret);
        gap = gap / SEMI_RATIO;
    }
    return frets;
}

function genFretboard(fretbdLen, nutWth, fretbdTck, neckWideAng, scaleLen, fretHt) {
    var neckWth = nutWth + 2*tan(neckWideAng)*fretbdLen;
    var face = polygon([[0, -nutWth/2], [fretbdLen, -neckWth/2], [fretbdLen, neckWth/2], [0, nutWth/2]])
    var fretbd = face.extrude({offset: [0,0,4*fretbdTck]});
    var topCut = cube({
        center: [0, -2*nutWth, 0], 
        size: [fretbdLen*2, 2*nutWth, 5*fretbdTck]
    });
    topCut = topCut.rotateY(-neckWideAng);
    topCut = topCut.translate([0,0,fretbdTck]);
    fretbd = difference(fretbd, topCut);
    frets = genFrets(fretbdLen, nutWth, fretbdTck, neckWideAng, scaleLen, fretHt);
    return union(fretbd, frets);
}

function genSoundHole(radius) {
    return cylinder({
        start: [0, 0, 0], end: [0, 0, 10*radius], 
        r1: radius, r2:radius
    });
}

function genChamber(bodyLen, sideRatio, topRatio, bottomRatio, tailRatio){
    var chamber = genBody(bodyLen, sideRatio, topRatio, bottomRatio, tailRatio);
    chamber = chamber.scale([.8,.9,.9]);
    var soundHole = genSoundHole(bodyLen*sideRatio/6);
    soundHole = soundHole.translate([-bodyLen/5,0,0]);
    return union(chamber, soundHole);
}

function genNeck(neckLen, nutWth, bottomRatio, headLen, fretbdTck, neckWideAng, headAng) {
    var neck = cylinder({
        start: [0, 0, 0], 
        end: [neckLen, 0, 0], 
        r1: nutWth/2, 
        r2: nutWth/2 + tan(neckWideAng)*neckLen
    });
    neck = neck.scale([1, 1, bottomRatio]);
    var head = cube({round: true, radius: 2,
        size:[-headLen, 1.4*nutWth, -bottomRatio*nutWth]
    });
    head = head.translate([2, -.7*nutWth, fretbdTck]);
    head = head.rotateY(-headAng);
    var topCut = cube({
        center: [0, -nutWth, 0], 
        size: [neckLen, nutWth*2, nutWth]
    });
    neck = difference(neck, topCut);
    return union(head, neck);
}

function genBodyBase(bodyLen, sideRatio, topRatio, bottomRatio){
    const radius = bodyLen/2;
    var top = sphere({r: radius, center: true});
    const topCut = cube({
        center: [-radius, -radius, 0], 
        size: [radius*2, radius*2, -radius]
    });
    top = top.scale([1, sideRatio, topRatio]);
    top = difference(top, topCut);
    var bottom = sphere({r: radius, center: true});
    const bottomCut = cube({
        center: [-radius, -radius, 0], 
        size: [radius*2, radius*2, radius]
    });
    bottom = bottom.scale([1, sideRatio, bottomRatio]);
    bottom = difference(bottom, bottomCut);
    return union(top, bottom);
}

function genBodyTrunk(bodyLen, sideRatio, topRatio, bottomRatio){
    var trunk = genBodyBase(bodyLen, sideRatio, topRatio, bottomRatio);
    var tailCut = cube({
        center: [0, -bodyLen/2, -bodyLen/2], 
        size: [bodyLen, bodyLen, bodyLen]
    })
    return difference(trunk, tailCut);
}

function genBodyTail(bodyLen, sideRatio, topRatio, bottomRatio, tailRatio){
    var tail = genBodyBase(bodyLen, sideRatio, topRatio, bottomRatio);
    tail = tail.scale([tailRatio, 1, 1]);
    var tailCut = cube({
        center: [0, -bodyLen/2, -bodyLen/2], 
        size: [bodyLen*.4*tailRatio, bodyLen, bodyLen]
    });
    return intersection(tail, tailCut);
}

function genBody(bodyLen, sideRatio, topRatio, bottomRatio, tailRatio){
    var trunk = genBodyTrunk(bodyLen, sideRatio, topRatio, bottomRatio);
    var tail = genBodyTail(bodyLen, sideRatio, topRatio, bottomRatio, tailRatio);
    return union(trunk, tail);
}

function main () {
  var bodyLen = SCALE_LEN * 2*(1-NECK_RATIO);
  var fretbd = genFretboard(SCALE_LEN * FRETBD_RATIO,
        NUT_WIDTH, FRETBD_TCK, NECK_WIDE_ANGLE, SCALE_LEN, FRET_HT );
  var neck = genNeck(SCALE_LEN * FRETBD_RATIO, NUT_WIDTH, 
        NECK_BOTTOM_RATIO, HEAD_LEN, FRETBD_TCK, NECK_WIDE_ANGLE, HEAD_ANGLE);
  var body = genBody(bodyLen, SIDE_RATIO, TOP_RATIO, BOTTOM_RATIO, TAIL_RATIO);
  body = body.translate([SCALE_LEN, 0, 0]);
  var bridge = genBridge(1.5*NUT_WIDTH, BRIDGE_HT);
  bridge = bridge.translate([SCALE_LEN, 0, bodyLen*TOP_RATIO/2]);
  var uke = union(fretbd, neck, bridge, body);
  var chamber = genChamber(bodyLen, SIDE_RATIO, TOP_RATIO, BOTTOM_RATIO, TAIL_RATIO);
  chamber = chamber.translate([SCALE_LEN, 0, 0]);
  uke = difference(uke, chamber);
  return uke;
}
