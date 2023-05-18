#!/bin/bash
PD_DIR="${HOME}/printer_data/config"

echo -e "\nResHelper Installer\n"

check_printdata()
{
    if [ ! -d "${PD_DIR}" ]; then
        echo -e "printer_data folder not found. Exiting ..."
        exit -1
    else
        echo "printer_data folder detected successfully!"
    fi

}

check_printdata

if [ -w "${HOME}/printer_data/config/reshelper.cfg" ]; then                                                                                               
	 echo -e "\n Overwrite reshelper.cfg? y/n "
	 read ANSWER
	 case $ANSWER in
  		 [yY]) echo -e "\n Overwriting .."; cp ~/ResHelper/reshelper.cfg ~/printer_data/config/reshelper.cfg;;
 		 [nN]) echo -e "\n Skipping..";;
	esac 
else
	echo -e "\n Copying configuration file to config folder...";
	cp ~/ResHelper/reshelper.cfg ~/printer_data/config/reshelper.cfg;
fi

echo -e "\nCleaning old tmp csv files..."
find '/tmp/' -name "resonances_*.csv" -print 2>/dev/null -exec rm {} \;


echo -e "\nResHelper installation complete! \nPlease add [include reshelper.cfg] to your printer.cfg. Enjoy!\n"
