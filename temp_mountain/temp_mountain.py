import re
import pandas as pd
import numpy as np

START_YEAR = 1900
END_YEAR = 2018

temps = pd.DataFrame(columns=['year', 'month', 'temperature'])
line_pattern = re.compile('^([0-9][0-9][0-9][0-9])/([0-9][0-9]) +([^ ]*)')

with open('HadCRUT.4.6.0.0.monthly_ns_avg.txt', 'r') as hadcrut:
    for line in hadcrut:
        r = re.search(line_pattern, line)
        row = list(map(float, r.groups()))
        if START_YEAR <= row[0] <= END_YEAR:
            temps.loc[len(temps.index)] = row

# If the lowest temperature is negative, adjust all temperatures
# upwards so the lowest is zero.
if min(temps["temperature"]) < 0.0:
    temps["temperature"] = temps["temperature"] + abs(min(temps["temperature"]))

with open('temp_mountain_build.scad', 'w') as out:
    out.write('use <temp_mountain_lib.scad>\n')
    out.write(f'MODEL_PARAMS = [300, 300, {START_YEAR}, {END_YEAR}, {min(temps["temperature"])}, {max(temps["temperature"]):.3f}, {temps["temperature"].iloc[-1]:.3f}];\n')
    out.write('init(MODEL_PARAMS);\n')

    for row in range(len(temps) - 1):
        out.write(f'month_section(MODEL_PARAMS, {temps["year"][row]}, {temps["month"][row]}, {temps["temperature"][row]:.3f}, {temps["temperature"][row + 1]:.3f});\n')

    out.write(
        f'month_section(MODEL_PARAMS, {temps["year"].iloc[-1]}, {temps["month"].iloc[-1]}, {temps["temperature"].iloc[-1]:.3f}, {temps["temperature"].iloc[-1]:.3f});\n')
