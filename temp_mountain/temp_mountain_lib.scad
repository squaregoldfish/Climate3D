MONTH_ANGLE=-30;
BASE_THICKNESS=2.5;

WIDTH = 0;
HEIGHT = 1;
START_YEAR = 2;
END_YEAR = 3;
MIN_TEMP = 4;
MAX_TEMP = 5;
LAST_TEMP = 6;

function temp_height(params, temp) =
    ((params[HEIGHT] - BASE_THICKNESS) / (params[MAX_TEMP] - params[MIN_TEMP])) * (temp - params[MIN_TEMP]);

function years(params) = params[END_YEAR] - params[START_YEAR] + 1;

function year_width(params) = (params[WIDTH] - 10) / ((years(params) + 2) * 2);

module month_section(params, year, month, start_temp, end_temp) {
    years_from_end = params[END_YEAR] - year;
    start_theta = MONTH_ANGLE * (month - 1);
    end_theta = MONTH_ANGLE * month;
        
    // Pillar + month spiral + number of years
    start_inner_offset =
        year_width(params) + (12 - month + 1) * (year_width(params) / 12) + (years_from_end) * year_width(params);
    start_outer_offset = start_inner_offset + year_width(params);
    end_inner_offset =
        year_width(params) + (12 - month) * (year_width(params) / 12) + (years_from_end) * year_width(params);
    end_outer_offset = end_inner_offset + year_width(params);
    
    start_sin_inner = sin(start_theta) * start_inner_offset;
    start_cos_inner = cos(start_theta) * start_inner_offset;
    end_sin_inner = sin(end_theta) * end_inner_offset;
    end_cos_inner = cos(end_theta) * end_inner_offset;
    start_sin_outer = sin(start_theta) * start_outer_offset;
    start_cos_outer = cos(start_theta) * start_outer_offset;
    end_sin_outer = sin(end_theta) * end_outer_offset;
    end_cos_outer = cos(end_theta) * end_outer_offset;
    
    translate([0, 0, BASE_THICKNESS]) {
        polyhedron(
            points = [
                [start_sin_inner, start_cos_inner, temp_height(params, params[MIN_TEMP])], // inner bottom start
                [end_sin_inner, end_cos_inner, temp_height(params, params[MIN_TEMP])], // inner bottom end
                [end_sin_outer, end_cos_outer, temp_height(params, params[MIN_TEMP])], // outer bottom end
                [start_sin_outer, start_cos_outer, temp_height(params, params[MIN_TEMP])], // outer bottom start
                [start_sin_inner, start_cos_inner, temp_height(params, start_temp)], // inner top start
                [end_sin_inner, end_cos_inner, temp_height(params, end_temp)], // inner top end
                [end_sin_outer, end_cos_outer, temp_height(params, end_temp)], // outer top end
                [start_sin_outer, start_cos_outer, temp_height(params, start_temp)] // outer top start
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

module init(params) {    
    // Make the base and the middle column
    cylinder(h=BASE_THICKNESS, r=params[WIDTH] / 2, $fn=12);
    
    // The central pillar
    translate([0, 0, BASE_THICKNESS]) {
        cylinder(h=temp_height(params, params[LAST_TEMP]), r=year_width(params), $fn=12);
    }    

    // Spiral out one cycle at the same height to get
    // us to the end of the last year
    for (i = [1:12]) {
        month_section(params, params[END_YEAR] + 1, i, params[LAST_TEMP], params[LAST_TEMP]);
    }
}
