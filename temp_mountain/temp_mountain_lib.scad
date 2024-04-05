PI = 3.14159;

WIDTH=160;
HEIGHT=160;
MONTH_ANGLE=-30;
BASE_OUTLINE=25;
BASE_THICKNESS=5;

TEXT_FONT="Mont:style=Heavy DEMO";
RIM_TEXT_SIZE=5.4;
RIM_TEXT_THICKNESS=1;
UNDER_TEXT_SIZE=6;

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

function month_index(params, year, month) = ((year - params[START_YEAR]) * 12) + (month - 1);

function year_count(params) = params[END_YEAR] - params[START_YEAR] + 1;

function years_per_section(params, sections) = floor(year_count(params) / sections);

function year_index(params, year) = year - params[START_YEAR];

module month_section(params, temp_data, year, month) {
    start_index = month_index(params, year, month);
    end_index = (start_index + 1) < len(temp_data) ? (start_index + 1) : start_index;

    years_from_end = params[END_YEAR] - year;
    start_theta = MONTH_ANGLE * (month - 1);
    end_theta = MONTH_ANGLE * month;
        
    // Pillar + month spiral + number of years
    start_inner_offset =
        year_width(params) + (12 - month + 1) * (year_width(params) / 12) +
        (years_from_end) * year_width(params);
    start_outer_offset = start_inner_offset + year_width(params);
    
    end_inner_offset =
        year_width(params) + (12 - month) * (year_width(params) / 12) +
        (years_from_end) * year_width(params);
    end_outer_offset = end_inner_offset + year_width(params);
    
    start_sin_inner = sin(start_theta) * start_inner_offset;
    start_cos_inner = cos(start_theta) * start_inner_offset;
    end_sin_inner = sin(end_theta) * end_inner_offset;
    end_cos_inner = cos(end_theta) * end_inner_offset;
    start_sin_outer = sin(start_theta) * start_outer_offset;
    start_cos_outer = cos(start_theta) * start_outer_offset;
    end_sin_outer = sin(end_theta) * end_outer_offset;
    end_cos_outer = cos(end_theta) * end_outer_offset;
    
    union() {
        // Base insert
        polyhedron(
            points = [
               [start_sin_inner, start_cos_inner,  
                    0], // inner bottom start
                [end_sin_inner, end_cos_inner,
                    0], // inner bottom end
                [end_sin_outer, end_cos_outer,
                    0], // outer bottom end
                [start_sin_outer, start_cos_outer,
                    0], // outer bottom start
                [start_sin_inner, start_cos_inner,
                    BASE_THICKNESS / 2], // inner top start
                [end_sin_inner, end_cos_inner,
                    BASE_THICKNESS / 2], // inner top end
                [end_sin_outer, end_cos_outer,
                    BASE_THICKNESS / 2], // outer top end
                [start_sin_outer, start_cos_outer,
                    BASE_THICKNESS / 2] // outer top start
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
        
        // The temperature part
        translate([0, 0, BASE_THICKNESS / 2]) {
            polyhedron(
                points = [
                    [start_sin_inner, start_cos_inner,  
                        temp_height(params, params[MIN_TEMP])], // inner bottom start
                    [end_sin_inner, end_cos_inner,
                        temp_height(params, params[MIN_TEMP])], // inner bottom end
                    [end_sin_outer, end_cos_outer,
                        temp_height(params, params[MIN_TEMP])], // outer bottom end
                    [start_sin_outer, start_cos_outer,
                        temp_height(params, params[MIN_TEMP])], // outer bottom start
                    [start_sin_inner, start_cos_inner,
                        temp_height(params, temp_data[start_index])], // inner top start
                    [end_sin_inner, end_cos_inner,
                        temp_height(params, temp_data[end_index])], // inner top end
                    [end_sin_outer, end_cos_outer,
                        temp_height(params, temp_data[end_index])], // outer top end
                    [start_sin_outer, start_cos_outer,
                        temp_height(params, temp_data[start_index])] // outer top start
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
}

module month_section_solid(params, year, month, height) {
    years_from_end = params[END_YEAR] - year;
    start_theta = MONTH_ANGLE * (month - 1);
    end_theta = MONTH_ANGLE * month;

    start_offset = year_width(params) + (12 - month + 1) *
        (year_width(params) / 12) + (years_from_end) * year_width(params) +
        year_width(params);
    
    end_offset = year_width(params) + (12 - month) *
        (year_width(params) / 12) + (years_from_end) * year_width(params) +
        year_width(params);
    
    start_sin = sin(start_theta) * start_offset;
    start_cos = cos(start_theta) * start_offset;
    end_sin = sin(end_theta) * end_offset;
    end_cos = cos(end_theta) * end_offset;
    
    linear_extrude(height) {
        polygon(points = [[0,0], [start_sin, start_cos], [end_sin, end_cos]]);
    }
}

module base(params, text) {
    difference() {
        union() {
            // Main base
            cylinder(h=BASE_THICKNESS, r=WIDTH / 2, $fn=12);

            // Rim text
            for (i = [0:11]) {
                if (RIM_TEXT[i] != "") {
                    text_angle = 180 - MONTH_ANGLE * (i + 1) + (MONTH_ANGLE / 2);
                    x_offset = (WIDTH - BASE_OUTLINE / 2) / 2 * sin(text_angle);
                    y_offset = (WIDTH - BASE_OUTLINE / 2) / 2 * cos(text_angle) * -1;
                    translate([x_offset, y_offset, BASE_THICKNESS - 0.5]) {
                        rotate(text_angle) {
                            linear_extrude(RIM_TEXT_THICKNESS + 0.5) {
                                text(text[i], font = TEXT_FONT,
                                    size = RIM_TEXT_SIZE, halign="center", valign="baseline");
                            }
                        }
                    }
                }
            }
        }
        
        // The cut-out for the month sections
        translate([0, 0, BASE_THICKNESS / 2]) {
            for (month = [1:12]) {
                month_section_solid(MODEL_PARAMS, MODEL_PARAMS[START_YEAR],
                    month, BASE_THICKNESS);
            }
        }
    }
}

module central_pillar(params) {
    // The central pillar
    cylinder(h=temp_height(params, params[LAST_TEMP]) + BASE_THICKNESS / 2,
        r=year_width(params) * 1.5, $fn=12);
}
