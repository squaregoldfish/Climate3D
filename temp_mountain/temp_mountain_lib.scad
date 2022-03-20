WIDTH=150;
HEIGHT=150;
MONTH_ANGLE=-30;
BASE_OUTLINE=20;
BASE_THICKNESS=2.5;

TEXT_FONT="DejaVu Sans";
TEXT_SIZE=3;
TEXT_THICKNESS=1;

// params parameter indices
START_YEAR = 0;
END_YEAR = 1;
MIN_TEMP = 2;
MAX_TEMP = 3;
LAST_TEMP = 4;

function temp_height(params, temp) =
    ((HEIGHT - BASE_THICKNESS) / (params[MAX_TEMP] - params[MIN_TEMP])) * (temp - params[MIN_TEMP]);

function years(params) = params[END_YEAR] - params[START_YEAR] + 1;

function year_width(params) = (WIDTH - BASE_OUTLINE) / ((years(params) + 2) * 2);

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

module write_text(params, text) {
    for (i = [0:11]) {
        if (text[i] != "") {
            text_angle = 180 - MONTH_ANGLE * (i + 1) + (MONTH_ANGLE / 2);
            x_offset = (WIDTH - BASE_OUTLINE / 2) / 2 * sin(text_angle);
            y_offset = (WIDTH - BASE_OUTLINE / 2) / 2 * cos(text_angle) * -1;
            translate([x_offset, y_offset, BASE_THICKNESS - 0.5]) {
                rotate(text_angle) {
                    linear_extrude(TEXT_THICKNESS + 0.5) {
                        text(text[i], font = TEXT_FONT, size = TEXT_SIZE, halign="center", valign="baseline");
                    }
                }
            }
        }
    }
}

module init(params) {    
    // Make the base and the middle column
    cylinder(h=BASE_THICKNESS, r=WIDTH / 2, $fn=12);
    
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
