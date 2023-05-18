# ResHelper
A series of scripts designed to streamline Klipper's resonance testing workflow

### What does this do?

It auto generates the resonance graph, and outputs the graph images in the config folder. These can be viewed directly in Mainsail/Fluid.<br>
The Damping Ratio is automatically computed and displayed in the console.<br>
Throughout the process there is no need to connect to the PI by SSH or SFTP.

## Installation:

#### 1. Download ResHelper Scripts 

`git clone https://github.com/lhndo/ResHelper.git`<br>

#### 2. Install Rscript

`sudo apt install r-base`

#### 3. Install Rscript Library

`cd ResHelper`<br>
`sudo Rscript install_rs_lib.R`

#### 4. Install G-Code Shell Command

https://github.com/th33xitus/kiauh/blob/master/docs/gcode_shell_command.md


#### 5. Add the following macros to your printer.cfg

<pre><code>
[gcode_shell_command generate_shaper_x]
command: sh /home/pi/ResHelper/gen_x.sh
timeout: 60.
verbose: True

[gcode_shell_command generate_shaper_y]
command: sh /home/pi/ResHelper/gen_y.sh
timeout: 60.
verbose: True

[gcode_macro RESONANCE_TEST_X]
gcode:
  TEST_RESONANCES axis=x
  RUN_SHELL_COMMAND cmd=generate_shaper_x

[gcode_macro RESONANCE_TEST_Y]
gcode:
  TEST_RESONANCES axis=y
  RUN_SHELL_COMMAND cmd=generate_shaper_y

</pre></code>

#### 6. Run Resonance Test Macros 
Run **RESONANCE_TEST_X** or **RESONANCE_TEST_Y** macros and wait for the Console output.

#### 7. View the graph images directly in the browser by going to MACHINE (Mainsail) and then opening the RES_DATA folder.

<img src="Images/config.png"/>

<br>*The files are placed in ~/printer_data/config/RES_DATA/*<br>
*The damping ratio is displayed in the Console and added to the filename.*<br><br>

<img src="Images/console.png"/>

<br>

*Enjoy!*
<br>
<br>

*Based on work by Dmitry, churls and kmobs*<br>
https://gist.github.com/kmobs/3a09cc28ec79e62f28d8db2179be7909
