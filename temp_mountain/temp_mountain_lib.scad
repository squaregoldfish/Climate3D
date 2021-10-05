MONTH_ANGLE=-30;
MODEL_WIDTH=300;
MODEL_HEIGHT=300;
BASE_THICKNESS=5;

FIRST_YEAR=1950;
LAST_YEAR=1980;

YEARS=LAST_YEAR - FIRST_YEAR + 1;

year_width = MODEL_WIDTH / (YEARS * 2);

last_temp = 30;

//cylinder(h=BASE_THICKNESS, r=MODEL_WIDTH / 2, $fn=12);

// Lift us onto the base
translate([0, 0, BASE_THICKNESS]) {
    // The central pillar
    cylinder(h=last_temp, r=year_width, $fn=12);
    
    // Spiral out one cycle at the same height to get
    // us to the first proper year
    for (i = [1:12]) {
        
        start_theta = MONTH_ANGLE * (i - 1);
        end_theta = MONTH_ANGLE * i;
        
        start_sin_inner = sin(start_theta) * year_width;
        start_cos_inner = cos(start_theta) * year_width;
        end_sin_inner = sin(end_theta) * year_width;
        end_cos_inner = cos(end_theta) * year_width;
        start_sin_outer = sin(start_theta) * ((i - 1) * year_width / 12 + year_width);
        start_cos_outer = cos(start_theta) * ((i - 1) * year_width / 12 + year_width);
        end_sin_outer = sin(end_theta) * (i * year_width / 12 + year_width);
        end_cos_outer = cos(end_theta) * (i * year_width / 12 + year_width);
        
        polyhedron(
            points = [
                [start_sin_inner, start_cos_inner, 0], // inner bottom start
                [end_sin_inner, end_cos_inner, 0], // inner bottom end
                [end_sin_outer, end_cos_outer, 0], // outer bottom end
                [start_sin_outer, start_cos_outer, 0], // outer bottom start
                [start_sin_inner, start_cos_inner, last_temp], // inner top start
                [end_sin_inner, end_cos_inner, last_temp], // inner top end
                [end_sin_outer, end_cos_outer, last_temp], // outer top end
                [start_sin_outer, start_cos_outer, last_temp] // outer top start
            ],
            faces = [
                [0,1,2,3],  // bottom
                [4,5,1,0],  // inside
                [7,6,5,4],  // top
                [5,6,2,1],  // end
                [6,7,3,2],  // outside
                [7,4,0,3]   // start
            ]
        );
    }
}

