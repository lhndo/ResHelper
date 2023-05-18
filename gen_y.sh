#!/bin/sh
echo "\nResHelper: Generating data...\n";
name="shaper_calibrate_y";
[ ! -d $HOME"/printer_data/config/RES_DATA/" ] && mkdir ~/printer_data/config/RES_DATA;

graph generation
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_*.csv -o ~/printer_data/config/RES_DATA/shaper_calibrate_y.png;

#damping ratio
dr=$(Rscript ~/ResHelper/Y.R);
dr=${dr#"[1] "};
echo "Damping ratio for Y calculated:\ndamping_ratio_y: $dr\n ";
name=$name"_dr-"$dr"_v"$(date "+%Y%m%d-%H%M")".png";


#cleanup
mv ~/printer_data/config/RES_DATA/shaper_calibrate_y.png ~/printer_data/config/RES_DATA/$name;
find '/tmp/' -name "resonances_y_*.csv" -print 2>/dev/null -exec rm {} \;
