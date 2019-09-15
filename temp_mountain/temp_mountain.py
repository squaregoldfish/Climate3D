'''
Generate XYZ co-ordinates to build a mountain of global average surface
temperature over time.

Requires a HadCRUT surface temperature data file, from:
https://www.metoffice.gov.uk/hadobs/hadcrut4/data/current/download.html
'''

import sys
import pandas

def main(filename):
	print(filename)


# Run main method
if __name__ == '__main__':
  if (len(sys.argv) < 2):
   	print("Usage: python3 temp_mountain.py <HadCRUT file>")
   	exit()

  filename = sys.argv[1]
  main(filename)