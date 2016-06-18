#!/bin/sh

MDL=`basename $1 .scad`
date > $MDL.txt
nohup time openscad -o $MDL.stl $MDL.scad >> $MDL.txt 2>>$MDL.txt &
