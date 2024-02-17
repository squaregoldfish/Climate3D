import pandas as pd

START_YEAR = 1924
END_YEAR = 2023

RIM_TEXT = ['HadCRUT', f'{START_YEAR}-{END_YEAR}', '', '', '',
            '', '', '', '', '', '', '']

UNDER_TEXT = ['Steve Jones', '@squaregoldfish', '@mastodon.social', '',
              'Inspired by', 'Ed Hawkins', '@ed_hawkins', '@fediscience.org']


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

temps = pd.DataFrame(columns=['year', 'month', 'temperature'])
hadcrut = pd.read_csv('HadCRUT.5.0.2.0.analysis.summary_series.global.monthly.csv')
for index, row in hadcrut.iterrows():
    year, month = row['Time'].split("-")
    if START_YEAR <= int(year) <= END_YEAR:
        temps.loc[len(temps.index)] = [year, month, row['Anomaly (deg C)']]

# If the lowest temperature is negative, adjust all temperatures
# upwards so the lowest is zero.
if min(temps["temperature"]) < 0.0:
    temps["temperature"] = temps["temperature"] + abs(min(temps["temperature"]))

# Write the OpenSCAD script
with open('temp_mountain_build.scad', 'w') as out:
    # Import the background library
    out.write('use <temp_mountain_lib.scad>\n')

    # Main parameters
    out.write(
        f'MODEL_PARAMS = [{START_YEAR}, {END_YEAR}, {min(temps["temperature"])}, '
        f'{max(temps["temperature"]):.3f}, {temps["temperature"].iloc[-1]:.3f}];\n'
    )

    # Text contents
    out.write(make_text_array('RIM_TEXT', RIM_TEXT))
    out.write(make_text_array('UNDER_TEXT', UNDER_TEXT))

    # Overall rotation
    out.write('rotate([0, 0, 180]) {\n')

    # Difference from main model to base text
    out.write('difference() {\n')

    out.write('union() {\n')

    # Base and centre column
    out.write('base_and_centre(MODEL_PARAMS);\n')

    # Month sections
    for row in range(len(temps) - 1):
        out.write(
            f'month_section(MODEL_PARAMS, {temps["year"][row]}, {temps["month"][row]}, '
            f'{temps["temperature"][row]:.3f}, {temps["temperature"][row + 1]:.3f});\n'
        )

    out.write(
        f'month_section(MODEL_PARAMS, {temps["year"].iloc[-1]}, {temps["month"].iloc[-1]}, '
        f'{temps["temperature"].iloc[-1]:.3f}, {temps["temperature"].iloc[-1]:.3f});\n'
    )

    # Rim Text
    out.write('write_rim_text(MODEL_PARAMS, RIM_TEXT);\n')

    out.write('}\n')

    # Under text cutout
    out.write('union() {\n')
    out.write('write_under_text(MODEL_PARAMS, UNDER_TEXT);\n')
    out.write('}\n')

    # End of difference
    out.write('}\n')

    # End of rotation
    out.write('}\n')
