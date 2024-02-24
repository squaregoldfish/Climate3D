import pandas as pd

START_YEAR = 1924
END_YEAR = 2023

RIM_TEXT = ['HadCRUT', f'{START_YEAR}-{END_YEAR}', '', '', '',
            '', '', '', '', '', '', '']


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

# Write the data for the OpenSCAD script
with open('temp_mountain_data.scad', 'w') as out:
    # Main parameters
    out.write(
        f'MODEL_PARAMS = [{START_YEAR}, {END_YEAR}, {min(temps["temperature"])}, '
        f'{max(temps["temperature"]):.3f}, {temps["temperature"].iloc[-1]:.3f}];\n'
    )

    # Text contents
    out.write(make_text_array('RIM_TEXT', RIM_TEXT))

    # The temperature data. This is a simple array starting at January in the first
    # year and ending at December in the last year.
    out.write('MONTH_TEMPS = [')

    for row in range(len(temps)):
        out.write(f'{temps["temperature"][row]:.3f}, ')

    out.write('];\n')
