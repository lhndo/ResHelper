#!/bin/sh
[ ! -d $HOME"/printer_data/config/RES_DATA/" ] && mkdir ~/printer_data/config/RES_DATA;
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_*.csv -o ~/printer_data/config/RES_DATA/shaper_calibrate_y.png;
Rscript ~/ResHelper/Y.R;
find '/tmp/' -name "resonances_y_*.csv" -print 2>/dev/null -exec rm {} \;
