#!/bin/sh
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_*.csv -o ~/printer_data/config/RES_DATA/shaper_calibrate_x.png;
Rscript ~/ResHelper/X.R;
find '/tmp/' -name "resonances_x_*.csv" -print 2>/dev/null -exec rm {} \;
