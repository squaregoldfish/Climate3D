import pandas as pd

START_YEAR = 1922
END_YEAR = 2021

BASE_TEXT = ['HadCRUT', f'{START_YEAR} - {END_YEAR}', '', 'Steve Jones', '@squaregoldfish',
             '', 'Inspired by', 'Ed Hawkins', '@ed_hawkins', '', '', '']

temps = pd.DataFrame(columns=['year', 'month', 'temperature'])

hadcrut = pd.read_csv('HadCRUT.5.0.1.0.analysis.summary_series.global.monthly.csv')
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

    # The text array
    text_line = 'TEXT = ['

    for i in range(0, len(BASE_TEXT)):
        text_line += '"'
        text_line += BASE_TEXT[i]
        text_line += '"'
        if i < len(BASE_TEXT) - 1:
            text_line += ', '

    text_line += ']'

    out.write(f'{text_line};\n')

    # Initialise model
    out.write('init(MODEL_PARAMS);\n')

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

    # Text
    out.write('write_text(MODEL_PARAMS, TEXT);\n')
