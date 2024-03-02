include <temp_mountain_lib.scad>
include <temp_mountain_data.scad>

SECTIONS = 5;

base(MODEL_PARAMS, RIM_TEXT);

for (year = [MODEL_PARAMS[START_YEAR]:MODEL_PARAMS[END_YEAR]]) {
    y_index = year_index(MODEL_PARAMS, year);
    section = floor(y_index / years_per_section(MODEL_PARAMS, SECTIONS));
    offset = SECTIONS == 0 ? 0 : (section + 1) * (WIDTH + 20);
    
    for (month = [1:12]) {
        translate([offset, 0, 0]) {
            month_section(MODEL_PARAMS, MONTH_TEMPS, year, month);
        }
    }
}

y_index = year_index(MODEL_PARAMS, MODEL_PARAMS[END_YEAR]);
section = floor(y_index / years_per_section(MODEL_PARAMS, SECTIONS));
offset = SECTIONS == 0 ? 0 : (section + 1) * (WIDTH + 20);

translate([offset, 0, 0]) {
    central_pillar(MODEL_PARAMS);
}
