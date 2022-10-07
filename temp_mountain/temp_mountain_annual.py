import pandas as pd

START_YEAR = 1922
END_YEAR = 2021

RIM_TEXT = f'HadCRUT {START_YEAR}-{END_YEAR}'
UNDER_TEXT = ['Steve Jones', '@squaregoldfish', '', 'Inspired by', 'Ed Hawkins', '@ed_hawkins']

def make_text_array(name, contents):
    # The text array
    line = f'{name} = ['

    for i in range(0, len(contents)):
        line += '"'
        line += contents[i]
        line += '"'
        if i < len(contents) - 1:
            line += ', '

    line += '];\n'

    return line


temps = pd.DataFrame(columns=['year', 'temperature'])
hadcrut = pd.read_csv('HadCRUT.5.0.1.0.analysis.summary_series.global.monthly.csv')

year_total = 0
year_count = 0
for index, row in hadcrut.iterrows():
    year, month = row['Time'].split("-")
    year_total += row['Anomaly (deg C)']
    year_count += 1

    if month == '12':
        temps.loc[len(temps.index)] = [year, year_total / year_count]
        year_total = 0
        year_count = 0

# If the lowest temperature is negative, adjust all temperatures
# upwards so the lowest is zero.
if min(temps["temperature"]) < 0.0:
    temps["temperature"] = temps["temperature"] + abs(min(temps["temperature"]))

# Write the OpenSCAD script
with open('temp_mountain_annual_build.scad', 'w') as out:
    # Import the background library
    out.write('use <temp_mountain_lib.scad>\n')

    # Main parameters
    out.write(
        f'MODEL_PARAMS = [{START_YEAR}, {END_YEAR}, {min(temps["temperature"])}, '
        f'{max(temps["temperature"]):.3f}, {temps["temperature"].iloc[-1]:.3f}];\n'
    )

    # Text contents
    out.write(f'RIM_TEXT = "{RIM_TEXT}";\n')
    out.write(make_text_array('UNDER_TEXT', UNDER_TEXT))

    # Overall rotation
    out.write('rotate([0, 0, 180]) {\n')

    # Difference from main model to base text
    out.write('difference() {\n')

    out.write('union() {\n')

    # Base and centre column
    out.write('annual_base(MODEL_PARAMS);\n')

    # Month sections
    for row in range(len(temps) - 1):
        out.write(
            f'year_cylinder(MODEL_PARAMS, {temps["year"][row]}, {temps["temperature"][row]:.3f});\n'
        )

    # Rim Text
    out.write('write_annual_rim_text(MODEL_PARAMS, RIM_TEXT);\n')

    out.write('}\n')

    # Under text cutout
    out.write('union() {\n')
    out.write('write_under_text(MODEL_PARAMS, UNDER_TEXT);\n')
    out.write('}\n')

    # End of difference
    out.write('}\n')

    # End of rotation
    out.write('}\n')
