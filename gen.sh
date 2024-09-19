#!/bin/bash

#### Functions definitions

check_path() {
    local path="$1"
    # echo "checking path $1"
    if [ ! -d "$path" ]; then
        echo "ERROR: path.sconf: Path $path not valid! Exiting.."
        exit 1
    fi
}


SCRIPT_DIR=$(dirname "$(realpath "$0")")
if [ -f ${SCRIPT_DIR}/paths.conf ]; then
	. ${SCRIPT_DIR}/paths.conf
else
   echo "ERROR: ${SCRIPT_DIR}/paths.conf not found. Exiting.. "
   exit 1
fi


check_path "$I_HOME"
check_path "$RH_PATH"
check_path "$CONFIG_PATH"
check_path "$KLIPPER_PATH"
check_path "$TMP_PATH"

# Define paths
RES_DATA_PATH="${CONFIG_PATH}/RES_DATA"

echo "\nResHelper: Generating Data...\n"
name="shaper_calibrate_$1"
[ ! -d "$RES_DATA_PATH" ] && mkdir -p "$RES_DATA_PATH"

if [ "$KLIPPER_VER" = "MAIN" ] || [ "$KLIPPER_VER" = "DK" ]; then
	if [ "$3" -eq 1 ]; then
    	echo "Skipping Classic Mode. Rrequired only for DK BE variants.\n"
	fi
    echo "ResHelper: Starting Klipper Graph Generation...\n"
    ${KLIPPER_PATH}/scripts/calibrate_shaper.py "$TMP_PATH"/resonances_"$1"_*.csv -o "$RES_DATA_PATH"/shaper_calibrate_"$1".png --shapers zv,mzv,ei

elif [ "$KLIPPER_VER" == "DK_BE" ]; then 
	# Graph generation
	if [ "$3" -eq 0 ]; then
	    # Use default generation
	    echo "ResHelper DK BE: Starting Klipper Graph Generation...\n"
	    ${KLIPPER_PATH}/scripts/calibrate_shaper.py "$TMP_PATH"/resonances_"$1"_*.csv -o "$RES_DATA_PATH"/shaper_calibrate_"$1".png --shapers zv,mzv,ei
	elif [ "$3" -eq 1 ]; then
	    # Classic klipper generation
	    echo "ResHelper DK BE: Starting Classic Klipper Graph Generation...\n"
	    ${KLIPPER_PATH}/scripts/calibrate_shaper_classic.py "$TMP_PATH"/resonances_"$1"_*.csv -o "$RES_DATA_PATH"/shaper_calibrate_"$1".png --shapers zv,mzv,ei --classic true
	else
	    # Handle unexpected values of $3
	    echo "Invalid value for third 'Classic' argument: $3. Expected 0 or 1."
	    exit 1
	fi

else
	echo "ERROR: $KLIPPER_VER - Could not determine Klipper variant. Exiting.."
	exit 1
fi


# Damping ratio
if [ "$2" -eq 1 ]; then 
    echo "ResHelper : Calculating damping ratio for $1"

	PYTHON=$(command -v python3 || command -v python)
	if [ -z "$PYTHON" ]; then
	    echo "Neither python nor python3 is installed."
	    exit 1
	fi
	
	DR_RESULT=$($PYTHON dr_solver.py "${TMP_PATH}/resonances_${1}_*.csv")

	# Validating results
	if (( $(echo "$DR_RESULT > 0.001" | bc -l) )) && (( $(echo "$DR_RESULT < 2.0" | bc -l) )); then
	    dr=$DR_RESULT
	    echo -e "ResHelper : Damping ratio calculated:\ndamping_ratio: $dr\n"
	else
	    echo -e "ERROR: The DR result is out of expected range: $DR_RESULT \n"
	fi
    
fi

# Cleanup
name="$name-dr_${dr:-NA}-v$(date "+%Y%m%d_%H%M").png"
mv "$RES_DATA_PATH"/shaper_calibrate_"$1".png "$RES_DATA_PATH/$name"

rm ${TMP_PATH}/rh-prev-run/*.csv 2>/dev/null
mkdir -p ${TMP_PATH}/rh-prev-run

cp "$TMP_PATH"/resonances_*.csv "${TMP_PATH}/rh-prev-run/" && rm "$TMP_PATH"/resonances_*.csv

echo "ResHelper: Finished\n"
