// RESOLUTION SETTINGS
$fa = 1;
$fs = 0.4;

// CAR BODY
cube([60, 20, 10], center = true);
translate([5, 0, 10 - 0.01])
	cube([30, 20, 10], center = true);

// WHEELS
translate([-20, -15, 0])
	rotate([90, 0, 0])
		cylinder(h = 3, r = 8, center = true);
translate([-20, 15, 0])
	rotate([90, 0, 0])
		cylinder(h = 3, r = 8, center = true);
translate([20, 15, 0])
	rotate([90, 0, 0])
		cylinder(h = 3, r = 8, center = true);
translate([20, -15, 0])
	rotate([90, 0, 0])
		cylinder(h = 3, r = 8, center = true);

// AXLES
translate([-20, 0, 0])
	rotate([90, 0, 0])
		cylinder(h = 30, r = 2, center = true);
translate([20, 0, 0])
	rotate([90, 0, 0])
		cylinder(h = 30, r = 2, center = true);