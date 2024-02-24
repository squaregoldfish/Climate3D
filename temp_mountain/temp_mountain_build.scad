include <temp_mountain_lib.scad>
include <temp_mountain_data.scad>

base(MODEL_PARAMS, RIM_TEXT);

for (year = [MODEL_PARAMS[START_YEAR]:MODEL_PARAMS[END_YEAR]]) {
    for (month = [1:12]) {
        month_section(MODEL_PARAMS, MONTH_TEMPS, year, month);
    }
}

central_pillar(MODEL_PARAMS);
