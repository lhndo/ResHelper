#!/bin/bash
rm -f log.txt
set -eo pipefail

{
SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR"

#### Functions definitions

check_path() {
    local path="$1"
    
    if [ ! -d "$path" ]; then
        echo "Path $path not valid"
        exit 1
    fi
}


#### MAIN


echo -e "\n-------------------------------------"
echo -e "\nWelcome to ResHelper Installation!\n"
echo -e  "-------------------------------------\n"

echo -e "$(date '+%Y-%m-%d %H:%M:%S') - Saving installation log into log.txt\n "

if [ "$(whoami)" = "root" ]; then
    echo 'ERROR: This script cannot be run as the root user. Please do not use "sudo"'
    exit 1
fi


#### Check for updates

if [ "$(git rev-parse --show-toplevel 2>/dev/null)" = "$(pwd)" ]; then
    if ! git diff --quiet HEAD origin/main; then  # Change 'main' if needed
        read -p "An update is available. Do you want to update to the latest version? (y/n): " choice
        case "$choice" in
            y|Y )
                echo "Updating to the latest version..."
                git reset --hard origin/main  # Change 'main' if needed
                echo "Update complete. Please restart the installation process."
                exit 0
                ;;
            n|N )
                echo "Continuing without update."
                ;;
            * )
                echo "Invalid choice. Please enter 'y' or 'n'."
                exit 1
                ;;
        esac
    fi
fi


######## Path setup
echo -e "Detecting Paths...\n"



if [ -f ./defaults.conf ]; then
	echo -e "default.conf file found! Using specified defaults.\n"
	. ./defaults.conf  
else 
	I_USER=""
	I_HOME=""
	RH_PATH=""
	CONFIG_PATH=""
	KLIPPER_PATH=""
	KLIPPER_VER=""
	TMP_PATH=""
fi


if [ -z "$I_USER" ]; then
	I_USER="$USER"
fi
echo "User : ${I_USER}"

if [ -z "$I_HOME" ]; then
	I_HOME="$HOME"
fi
echo "User Home Path: ${I_HOME}"
check_path "$I_HOME"

if [ -z "$RH_PATH" ]; then
	RH_PATH="$(dirname "$(realpath "$0")")"
fi
check_path "$RH_PATH"
echo "ResHelper Path: ${RH_PATH}"

if [ -z "$KLIPPER_PATH" ]; then
	KLIPPER_PATH=$(find ${I_HOME} -type d -path '*/klipper' | head -n 1); 
	if [ ! -d "$KLIPPER_PATH" ]; then
	    echo "Error: No valid printer_data/config  path found."
	    exit 1
	fi
fi
check_path "$KLIPPER_PATH"
echo "Klipper Path: ${KLIPPER_PATH}"

if [ -z "$KLIPPER_VER" ]; then
	if [ -e "${KLIPPER_PATH}/README.md" ]; then
		if grep -q "Danger Klipper" ${KLIPPER_PATH}/README.md; then
			if [ -f "${KLIPPER_PATH}/klippy/extras/extruder_smoother.py" ]; then
				KLIPPER_VER="DK_BE"
			else
		    	KLIPPER_VER="DK"
	    	fi
		else
		    KLIPPER_VER="MAIN"
		fi
	else
		echo "Couldn't determine Klipper Version."
		exit 1
	fi
fi
echo "Klipper Version: ${KLIPPER_VER}"


if [ -z "$CONFIG_PATH" ]; then
	CONFIG_PATH=$(find ${I_HOME} -type d -path '*/printer_data/config' | head -n 1); 
	if [ ! -d "$CONFIG_PATH" ]; then
	    echo "Error: No valid printer_data/config  path found."
	    exit 1
	fi
fi
check_path "$CONFIG_PATH"
echo "Klipper Config Path: ${CONFIG_PATH}"

if [ -z "$TMP_PATH" ]; then
	TMP_PATH="/tmp"
fi
check_path "$TMP_PATH"
echo "Temp Path: ${TMP_PATH}"

echo -e "\nPaths detected successfully!"


######### Saving Paths
echo -e "\nSaving Paths to paths.conf file..."
rm -f paths.conf

cat << EOF > paths.conf
### Paths auto-generated by ResHelper install.sh 

I_USER="${I_USER}"
I_HOME="${I_HOME}"
RH_PATH="${RH_PATH}"
CONFIG_PATH="${CONFIG_PATH}"
KLIPPER_PATH="${KLIPPER_PATH}"
KLIPPER_VER="${KLIPPER_VER}"
TMP_PATH="${TMP_PATH}"
EOF

echo -e "Paths saved into paths.conf!\n"


#### Check Prerequisites

## Check Klipper
echo -e "\nChecking Klipper modules..."

PK_PATH=$(find ${I_HOME} -type d -path '*/klippy-env/bin' | head -n 1); 
if [ ! -d "$PK_PATH" ]; then
    echo "Error: No valid PK_PATH path found."
    exit 1
fi
PK_VERSION=$(${PK_PATH}/python --version 2>&1 | awk '{print $2}')
if [[ "$PK_VERSION" > "3.0" ]]; then
    echo "Klipper Python version is ${PK_VERSION}"
else
    echo "WARNING: Klipper Python version is ${PK_VERSION}!"
    echo "It is highly recommended to upgrade Klipper to a Python 3.x version!"
    echo "Use KIAUH to remove and reinstall Klipper (Python 3.x)"
fi


## Check Numpy
echo -e "\nChecking Numpy module..."

if ${PK_PATH}/python -c 'import numpy' 2>/dev/null; then
    echo "Numpy is installed!"
else
    echo -e "\nNumpy is not installed."
    echo -e "Installing Numpy module...\n"
    ${PK_PATH}/pip install -v numpy
    echo -e "\nDone: Numpy Installed!\n"
    echo -e "\nNOTE: If you encouter Numpy issues, make sure that you are running a Klipper Python 3.x version"
    echo -e "If the issue is still not resolved, you can also try installing the following modules:"
    echo -e '"sudo apt install python3-numpy python3-matplotlib libatlas-base-dev libopenblas-dev"\n'
fi


#### Patching klipper 
echo -e "\nDetermining required Klipper patches...\n"

if [ "$KLIPPER_VER" = "DK" ]; then
    echo "Danger Klipper Master detected. No patches required! Skipping.."
elif [ "$KLIPPER_VER" = "DK_BE" ]; then 
    echo "Preparing Classic Mode patch for Danger Klipper with Smooth Shapers..."
	cp ./patches/dk_be/shaper_calibrate_classic.py ${KLIPPER_PATH}/klippy/plugins/
	cp ./patches/dk_be/calibrate_shaper_classic.py ${KLIPPER_PATH}/scripts/
	echo "Added shaper_calibrate_classic.py to klipper/klippy/plugins/"
	echo "Added calibrate_shaper_classic.py to klipper/scripts"
	echo "Patching Done!"
    
elif [ "$KLIPPER_VER" = "MAIN" ]; then
		echo -e "Setting up patch for mainline Klipper..."
	    echo -e "Note: For ResHelper to work resonance_tester.py will need to be patched"
	    echo -e "To restore the previous file run: git restore --source=HEAD -- /klippy/extras/resonance_tester.py" 

	    echo -e "\nInstalling resonance_tester accel_per_hz patch...\n" 
	    cp ./patches/main/resonance_tester.py ${KLIPPER_PATH}/klippy/extras/
	    cd $KLIPPER_PATH
	    echo "klippy/extras/resonance_tester.py" >> .git/info/exclude
	    git update-index --assume-unchanged klippy/extras/resonance_tester.py > /dev/null 2>&1

		if [ -f "${KLIPPER_PATH}/klippy/extras/gcode_shell_command.py" ]; then
			 echo "GCode Shell Command found. Skipping..."
		else
			 echo -e "\nInstalling gcode_shell_command...\n"
			 cd ${KLIPPER_PATH}/klippy/extras
		  	 wget https://raw.githubusercontent.com/DangerKlippers/danger-klipper/refs/heads/master/klippy/extras/gcode_shell_command.py
			 cd ${KLIPPER_PATH}
			 echo "klippy/extras/gcode_shell_command.py" >> .git/info/exclude
			 git update-index --assume-unchanged klippy/extras/gcode_shell_command.py > /dev/null 2>&1
    	fi		
	    
	    echo -e "\nKlipper Patching Done!\n"      
else
	echo -e "Failed to detect Klipper variant. Exiting.."
    exit 1  
fi


#### Setting up reshelper.cfg
echo -e "\nSetting up reshelper.cfg..."
echo -e "Path set to: ${RH_PATH}/gen.sh \n"

cd $RH_PATH
rm -f reshelper.cfg
cp reshelper.cfg.ref reshelper.cfg
sed -i "s|<rh_path>|${RH_PATH}/gen.sh|g" reshelper.cfg

echo -e "\nCopying reshelper.cfg to $CONFIG_PATH"
if [ -f "${CONFIG_PATH}/reshelper.cfg" ]; then
	echo -e "Existing reshelper.cfg found. Renaming it to reshelper.cfg.old"
	# mv "${CONFIG_PATH}/reshelper.cfg" "${CONFIG_PATH}/reshelper.cfg.old"
fi	
# cp reshelper.cfg "${CONFIG_PATH}"
echo -e "Done!\n"


#### Finishing	
echo -e "Restarting klipper\n"
systemctl restart klipper
echo -e "Installation Finished!\n"
echo -e "Remember to add [include reshelper.cfg] to your printer.cfg!"

if [ "$KLIPPER_VER" != "MAIN" ];then 
	echo -e "\nFor Danger Klipper also add the following:"
	echo -e "[danger_options]"
	echo -e "allow_plugin_override: True\n"
fi

echo -e "Wow, this actually worked :O Enjoy!\n"
exit 0
} | tee -a log.txt
