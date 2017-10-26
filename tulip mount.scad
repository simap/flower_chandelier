include <threads.scad>;

d1 = 73;
d2 = 88;
pitch = 6;
threadD = 10;
threadScaleFactor = .91; //helps threads fit 
mountR = threadD/2+2;
arms = 6;

//top
mount(d=d2, bottom=true, arms=arms);

//bottom
translate([100,0,0])
mount(d=d1, bottom=false, boltH = 30, arms=arms);


//a middle-section would look like this:
//mount(d2, true, 30);

module mount(d, bottom = false, boltH = 0, arms=6) {
    armT = 5;
    r = d/2;
    h = sqrt(d*d)/2;
    difference() {
        union() {
            offset = bottom ? [0,0,0] : [0,0,h - threadD/2 - 5];
            ch = bottom ? h : 10;
            translate(offset)
            cylinder(r=mountR,h=ch, $fs=.5);
            //rotate([0,0,360/12])
            ringHolder(d/2,armT, arms);

            translate([0,0,h]) {
                if (boltH > 0) {
                    bolt(mountR, boltH);
                } else {
                    loop();
                }
            }
        }
        
        if (bottom) {
            translate([0,0,-.01])
            metric_thread(threadD, pitch, min(20,h/2), internal=true, thread_size=2);
        }
    }
}

module loop() {
    rotate([90,0,0])
    rotate_extrude(angle=180, $fs=.5)
    translate([4, 0, 0])
    circle(r = 2);
    
}

module bolt(r, boltH) {
    
    ch = boltH > 20 ? boltH - 20 : 0;
    boltH = boltH - ch;

    cylinder(r=r,h=ch, $fs=.5);
    translate([0,0,ch]) {
    scale([threadScaleFactor, threadScaleFactor, 1])
    metric_thread(threadD, pitch, boltH, internal=false, thread_size=2);
    }
}

module ringHolder(r, h, arms) {
    
    translate([0,0,6])
    difference() {
        for (i = [0:1:arms]) {
            a = 360/arms * i;
            l = sqrt(2*r*r);
            
            rotate([0,0,a])
            translate([r-2,0,-2.5])
            rotate([0,-90,180])
            //translate([0,0,0])
            clip();
            
            
            translate([0,0,r-12.5])
            rotate([0,45,a]) {
                translate([0,-h/2, -h/25])
                cube([l-6,h,h]);
            }
        }
        #ring(r,h);
        translate([0,0,-11]) cube([r*3,r*3,10], center=true);
    }
}

module ring(r, h, t=10) {
    difference() {
        cylinder(r = r + 10, h=h);
        translate([0,0,-.01])
        cylinder(r = r, h=h + 0.02);
    }
}


module clip() {
    
    $fn = 100;

    sheetT = 5; //6.35 for 1/2"
    pinR = 3/2;
    stripW = 10;
    stripT = .5;
    ledW = 6;
    ledH = 2;

    t = 3.5;
    tolerance = 0.2;

    backL = stripW + t*2;
    backW = 5;
    backT = t;

    mountW = 5;
    mountL = 7;

    spacerW = (stripW-sheetT)/2;

    //back
    //translate([-t,-backW/2,-stripT-backT])
    //cube([backL, backW, backT]);
    
    translate([-t,0 ,-stripT-1.5])
    rotate([0,90,0])
    union() {
        cylinder(r=1.5,h=backL, $fn=20);    
        translate([-t + backT,-backW/2,0])
        cube([3,backW,backL]);
    }

    for (i = [0:0]) {
        rotate([0,0,180*i]) {
            translate([-stripW*i,0,0]) {
                //arm
                translate([-t,-backW/2,-stripT-1.5-backT/2])
                cube([t, backW, backT+1.5+stripT+ledH]);

                //mount surface
                translate([-t,-mountW/2,ledH])
                difference() {
                    cube([spacerW+backT, mountW, ledH-ledH+mountL]);
                    translate([1.5,0,0])
                    rotate([0,45,0])
                    cube([spacerW+backT, mountW, ledH-ledH+mountL]);
                }
            }
        }
    }
}