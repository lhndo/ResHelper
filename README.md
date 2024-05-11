# ResHelper
A series of scripts designed to streamline Klipper's resonance testing workflow

### What does this do?

It auto generates the resonance graph, and outputs the graph images into the config folder. These can be viewed directly in Mainsail/Fluid.<br>
The Damping Ratio is automatically computed and displayed in the console and appended to the graph image filename.<br>
Throughout the process there is no need to connect to the PI by SSH or SFTP.

### Accel Per HZ

Note: An experimental [**Accel Per HZ branch**](https://github.com/lhndo/ResHelper/tree/accel_per_hz) is available, which adds the capability of directly setting the "accel_per_hz" value for resonance testing and optionally generates a "damping_ratio" value.


## Installation:

#### 1. Download and install ResHelper Scripts 

`git clone https://github.com/lhndo/ResHelper.git`<br>
`cd ResHelper`<br>
`./install.sh`<br>

#### 2. Install Rscript

`sudo apt install r-base`<br>
`sudo Rscript install_rs_lib.R`

<br> Note: *If the library install fails, try installing a Fortran compiler: `sudo apt-get install gfortran` then rerun `sudo Rscript install_rs_lib.R`*   

#### 3. Install G-Code Shell Command
**KIAUH**  
Launch ./kiauh, then go to Advance> Extras> G-Code Shell Command

**Manual Method**  
Download gcode_shell_command.py to /home/pi/klipper/klippy/extras <br>
https://github.com/th33xitus/kiauh/blob/master/resources/gcode_shell_command.py <br>
Restart the klipper service

Gcode Shell Command info:
https://github.com/th33xitus/kiauh/blob/master/docs/gcode_shell_command.md

#### 4. Include the configuration file in your printer.cfg

`[include reshelper.cfg]` <br>
Note: If your host user name is not "pi", then you have to change the paths in reshelper.cfg

#### 5. Restart Klipper

<br><br>

## Usage:

#### 1. Run the Resonance Test Macros 
Run **RESONANCE_TEST_X** or **RESONANCE_TEST_Y** macros and wait for the Console output.

#### 2. View the graph images directly in the browser by going to MACHINE (Mainsail) and then opening the RES_DATA folder.
*The files are placed in ~/printer_data/config/RES_DATA/*<br>
<img src="Images/config.png"/><br>
<img src="Images/graph.png" width=50%/>
<br>
*The damping ratio is displayed in the Console and appended to the filename.*<br><br>

<img src="Images/console.png"/>


#### 3. Add the resonance test results to your printer.cfg 
**Example:**
<pre><code>
[input_shaper]

shaper_freq_x: 68.2
shaper_type_x: mzv
damping_ratio_x: 0.055

shaper_freq_y: 54.0
shaper_type_y: zv
damping_ratio_y: 0.0523
</code></pre>

*For more information please consult: https://www.klipper3d.org/Resonance_Compensation.html*

<br>

*Enjoy!*
<br>
<br>

*Based on work by **Dmitry**, **churls** and **kmobs***<br>
https://gist.github.com/kmobs/3a09cc28ec79e62f28d8db2179be7909

## Support
<br>
<a href='https://ko-fi.com/lh_eng' target='_blank'><img height='46' style='border:0px;height:36px;' src='https://az743702.vo.msecnd.net/cdn/kofi3.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' />
