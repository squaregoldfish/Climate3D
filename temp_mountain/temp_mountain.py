'''
Generate XYZ co-ordinates to build a mountain of global average surface
temperature over time.

Requires a HadCRUT surface temperature data file, from:
https://www.metoffice.gov.uk/hadobs/hadcrut4/data/current/download.html
'''

import sys
import math
import pandas as pd

MAX_HEIGHT = 200
OUT_FILE = "temp_mountain_vertices.csv"

def get_year(yearmonth):
	return int(yearmonth[0:4])

def get_int_input(minimum, maximum, default):
	input_ok = False
	result = default

	while not input_ok:
		value = input("First year [%d]: " % default)
		try:
			if value == "":
				result = int(default)
				input_ok = True
			else:
				result = int(value)
				if result >= minimum and result <= maximum:
					input_ok = True
		except:
			pass

	return result

def make_vertices(first_year, last_year, dates, values):
	first_index = dates.index[dates.str.match("%d/01" % first_year)][0]
	last_index = dates.index[dates.str.match("%d/12" % last_year)][0]
	year_count = last_year - first_year + 1

	# Shift values so minumum is zero
	values = values + abs(min(values))

	# Scale to maximum height
	values = values * (MAX_HEIGHT / max(values))

	current_month = 1
	year_index = year_count

	out = open(OUT_FILE, "w")

	for i in range(first_index, last_index + 1):
		angle = (360 / 12 * (current_month - 1)) * (math.pi / 180)

		# Calculate two positions one for the current year index, and one for the
		# next year. This gives a 2D surface to make a 'track' for each year
		xpos = math.sin(angle) * year_index
		xpos2 = math.sin(angle) * (year_index - 1)
		ypos = math.cos(angle) * year_index
		ypos2 = math.cos(angle) * (year_index - 1)

		zpos = values[i]

		out.write("%.4f,%.4f,%.4f\n" % (xpos, ypos, zpos))
		out.write("%.4f,%.4f,%.4f\n" % (xpos2, ypos2, zpos))

		current_month += 1
		if current_month > 12:
			current_month = 1
			year_index -= 1

	out.close()

def main(filename):
	all_data = pd.read_csv(filename, delim_whitespace=True, header=None)
	dates = all_data[0]
	median = all_data[1]
	first_year = get_year(dates[0])
	year_count = math.floor(len(dates) / 12)
	last_month = dates[year_count * 12 - 1]
	last_year = get_year(last_month)

	print("Date range: %d to %d" % (first_year, last_year))

	chosen_first_year = get_int_input(first_year, last_year, first_year)
	chosen_last_year = get_int_input(chosen_first_year, last_year, last_year)

	vertices = make_vertices(chosen_first_year, chosen_last_year, dates, median)


# Run main method
if __name__ == '__main__':
  if (len(sys.argv) < 2):
   	print("Usage: python3 temp_mountain.py <HadCRUT file>")
   	exit()

  filename = sys.argv[1]
  main(filename)