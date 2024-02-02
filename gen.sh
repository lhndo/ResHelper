#!/bin/sh
echo "\nResHelper: Generating data...\n";
name="shaper_calibrate_$1";
[ ! -d $HOME"/printer_data/config/RES_DATA/" ] && mkdir ~/printer_data/config/RES_DATA;

#graph generation
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_$1_*.csv -o ~/printer_data/config/RES_DATA/shaper_calibrate_$1.png;

#damping ratio
if [ "$2" -eq 1 ]; then 
	echo "Calculating damping ratio for $1"
	dr="$(Rscript ~/ResHelper/DR.R)";
	dr=${dr#"[1] "};
	echo "Damping ratio for $1 calculated:\n damping_ratio_$1: $dr\n ";
fi


#cleanup
name="$name-dr_$dr-v$(date "+%Y%m%d_%H%M").png";
mv ~/printer_data/config/RES_DATA/shaper_calibrate_$1.png ~/printer_data/config/RES_DATA/$name;
find '/tmp/' -name "resonances_*.csv" -print 2>/dev/null -exec rm {} \;
