#!/bin/bash
# set -eo pipefail
#### Functions definitions

check_path() {
    local path="$1"
    # echo "checking path $1"
    if [ ! -d "$path" ]; then
        echo "ERROR: path.sconf: Path $path not valid! Please run ~/ResHelper/install.sh again. Exiting.."
        exit 1
    fi
}


SCRIPT_DIR=$(dirname "$(realpath "$0")")
if [ -f ${SCRIPT_DIR}/paths.conf ]; then
	. "${SCRIPT_DIR}/paths.conf"
else
   echo "ResHelper: ERROR: ${SCRIPT_DIR}/paths.conf not found. Please run ~/ResHelper/install.sh again. Exiting.. "
   exit 1
fi

# Check if required argument is provided
if [ $# -lt 1 ]; then
    echo "ERROR: Missing required argument. Usage: $0 <axis> [calculate_damping] [classic_mode]"
    exit 1
fi

check_path "$I_HOME"
check_path "$RH_PATH"
check_path "$CONFIG_PATH"
check_path "$KLIPPER_PATH"
check_path "$PK_PATH"
check_path "$TMP_PATH"

# Define paths
RES_DATA_PATH="${CONFIG_PATH}/RES_DATA"
echo "\nResHelper: Generating Data...\n"
name="shaper_calibrate_$1"

[ ! -d "$RES_DATA_PATH" ] && mkdir -p "$RES_DATA_PATH"

# Check upfront if resonance CSV files exist
if ls $TMP_PATH/resonances_${1}_*.csv > /dev/null 2>&1; then
	echo "ResHelper: Found resonance .csv data for the $1 axis..."
else
	echo "ResHelper: ERROR: No Klipper resonance .csv data file was generated in the $TMP_PATH folder for the $1 axis!"
	exit 1
fi

if [ "$KLIPPER_VER" = "MAIN" ] || [ "$KLIPPER_VER" = "DK" ]; then
	if [ "$3" -eq 1 ]; then
    	echo "ResHelper: Skipping Classic Mode. Required only for Kalico BE variants.\n"
	fi
    echo "ResHelper: Starting Klipper Graph Generation...\n"
    ${PK_PATH}/python ${KLIPPER_PATH}/scripts/calibrate_shaper.py "${TMP_PATH}"/resonances_"$1"_*.csv -o "${RES_DATA_PATH}"/shaper_calibrate_"$1".png --shapers zv,mzv,ei

elif [ "$KLIPPER_VER" = "DK_BE" ]; then 
	# Graph generation
	if [ "$3" -eq 0 ]; then
	    # Use default generation
	    echo "ResHelper Kalico BE: Starting Klipper Graph Generation...\n"
	    ${PK_PATH}/python ${KLIPPER_PATH}/scripts/calibrate_shaper.py "${TMP_PATH}"/resonances_"$1"_*.csv -o "${RES_DATA_PATH}"/shaper_calibrate_"$1".png
	elif [ "$3" -eq 1 ]; then
			# Classic klipper generation
			echo "ResHelper Kalico BE: Starting Classic Klipper Graph Generation...\n"

			if [ -f "${KLIPPER_PATH}/scripts/calibrate_shaper_classic.py" ]; then
					${PK_PATH}/python ${KLIPPER_PATH}/scripts/calibrate_shaper_classic.py \
							"${TMP_PATH}"/resonances_"$1"_*.csv \
							-o "${RES_DATA_PATH}"/shaper_calibrate_"$1".png \
							--shapers zv,mzv,ei --classic true
			else
					echo "Reshelper: Error: no /scripts/calibrate_shaper_classic.py module found in Kalico. Please run ~/ResHelper/install.sh again!"
			fi
	else
	    # Handle unexpected values of $3
	    echo "Invalid value for third 'Classic' argument: $3. Expected 0 or 1."
	    exit 1
	fi

else
	echo "ERROR: $KLIPPER_VER - Could not determine Klipper variant. Please run ~/ResHelper/install.sh again. Exiting.."
	exit 1
fi

# Damping ratio
if [ "$2" -eq 1 ]; then 
		echo "ResHelper: Calculating damping ratio for the $1 axis"

				PYTHON=$(command -v python3 || command -v python)
				if [ -z "$PYTHON" ]; then
						echo "ResHelper: Neither python nor python3 is installed."
				else
						DR_RESULT=$($PYTHON "${RH_PATH}/dr_solver.py" "$TMP_PATH/resonances_${1}_*.csv")

						# Validating results
						if [ "$(echo "$DR_RESULT > 0.001" | bc -l)" -eq 1 ] && \
							[ "$(echo "$DR_RESULT < 2.0" | bc -l)" -eq 1 ]; then
								dr=$DR_RESULT
								echo "ResHelper: Damping ratio calculated: $DR_RESULT"
						else
								echo "ResHelper: WARNING: The DR result is out of expected range: $DR_RESULT"
						fi
				fi
		fi


# Cleanup
if [ -f "$RES_DATA_PATH/shaper_calibrate_$1.png" ]; then
		name="$name-dr_${dr:-NA}-v$(date "+%Y%m%d_%H%M").png"
    mv "$RES_DATA_PATH/shaper_calibrate_$1.png" "$RES_DATA_PATH/$name"
    echo "ResHelper: Image generated: $RES_DATA_PATH/$name"
else
    echo "ResHelper: ERROR: Klipper's calibrate_shaper script failed to generate an image graph!"
fi

if ls $TMP_PATH/resonances_*.csv > /dev/null 2>&1; then
	rm "${TMP_PATH}"/rh-prev-run/*.csv 2>/dev/null
	mkdir -p ${TMP_PATH}/rh-prev-run
	cp "$TMP_PATH"/resonances_*.csv "${TMP_PATH}/rh-prev-run/" && rm "$TMP_PATH"/resonances_*.csv
else
	echo "ResHelper: No /tmp file cleanup needed"
fi

echo "ResHelper: Finished"
