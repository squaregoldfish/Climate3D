'''
Generate a JSON file from a HadCRUT surface temperature data file.

Requires a HadCRUT surface temperature data file, from:
https://www.metoffice.gov.uk/hadobs/hadcrut4/data/current/download.html
'''
import sys
import pandas as pd
import math
import json

def get_year(yearmonth):
  return int(yearmonth[0:4])

def get_int_input(name, minimum, maximum, default):
  input_ok = False
  result = default

  while not input_ok:
    value = input('{} [{}]: '.format(name, default))
    try:
      if value == '':
        result = int(default)
        input_ok = True
      else:
        result = int(value)
        if result >= minimum and result <= maximum:
          input_ok = True
    except:
      pass

  return result

def main(filename):
  all_data = pd.read_csv(filename, delim_whitespace=True, header=None)
  dates = all_data[0]
  median = all_data[1]

  first_year = get_year(dates[0])
  year_count = math.floor(len(dates) / 12)
  last_month = dates[year_count * 12 - 1]
  last_year = get_year(last_month)

  print('Date range: {} to {}'.format(first_year, last_year))

  chosen_first_year = get_int_input('First year', first_year, last_year, first_year)
  chosen_last_year = get_int_input('Last year', chosen_first_year, last_year, last_year)

  out_temps = {}

  current_year = chosen_first_year
  current_index = dates.index[dates.str.match('{:d}/01'.format(chosen_first_year))][0]

  while current_year <= chosen_last_year:
    out_temps['{}'.format(current_year)] = median[current_index:current_index + 12].to_list()
    current_year += 1
    current_index += 12

  with open('HadCRUT.json', 'w') as f:
    f.write(json.dumps(out_temps))


# Run main method
if __name__ == '__main__':
  if (len(sys.argv) < 2):
     print('Usage: python3 hadcrut_to_json.py <HadCRUT file>')
     exit()

  filename = sys.argv[1]
  main(filename)
