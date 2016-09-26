include <../nutsnbolts/cyl_head_bolt.scad>;
include <G6-specs.scad>;
include <G6-utils.scad>;
include <G6-cuts.scad>;
include <G6-parts.scad>;
include <G6-assembly.scad>;

$fn=DEFRES;

 if (!SKIP_ASSEMBLY) assemble();
