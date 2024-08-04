**Contents:**
- [ResHelper](#reshelper)
    - [What does this do?](#what-does-this-do)
- [Installation](#installation)
  - [Switching from a previous branch](#switching-from-a-previous-branch)
- [Usage](#usage)
  - [Support](#support)


<br>

# ResHelper
A series of scripts designed to streamline Klipper's resonance testing workflow


:bulb: *This is an experimental branch that adds the possibility of directly setting the **accel_per_hz value** for resonance testing and optional **damping_ratio** value generation.*

<br>

>[!NOTE]
>This can be done from the RESONANCE TEST macro dropdown or by running the command such as:  
> **RESONANCE_TEST_Y ACCEEL_PER_HZ=90 DR=1**  
> To be able to do so, you will have to patch your resonance_test.py module with the one listed below.  
> By default **accel_per_hz** is set to your printer.cfg value, and **damping_ratio (DR)** generation is turned OFF for quick testing.
>
 <br>

### What does this do?

* Auto generates the resonance graph, and outputs the graph images into the config folder. These can be viewed directly in Mainsail/Fluid.
* The Damping Ratio is automatically computed and displayed in the console and appended to the graph image filename.
* Throughout the process there is no need to connect to the PI by SSH or SFTP.

<br>

# Installation


#### 1. Download and install ResHelper Scripts 


```
cd ~
git clone https://github.com/lhndo/ResHelper.git
cd ResHelper
git checkout accel_per_hz
./install.sh
```


<br>

#### 2. Install Rscript


```
sudo apt install r-base
sudo Rscript install_rs_lib.R
```

<br> Note: *If the library install fails, try installing a Fortran compiler: `sudo apt-get install gfortran` then re-run: `sudo Rscript install_rs_lib.R`*   

<br>

#### 3. Install G-Code Shell Command


```
cd ~/klipper/klippy/extras/
wget https://raw.githubusercontent.com/dw-0/kiauh/master/resources/gcode_shell_command.py
cd ../..
echo "klippy/extras/gcode_shell_command.py" >> .git/info/exclude
git update-index --assume-unchanged klippy/extras/gcode_shell_command.py
systemctl restart klipper
```
<br>

Gcode Shell Command info:
https://github.com/th33xitus/kiauh/blob/master/docs/gcode_shell_command.md

<br>

#### 4. Patch Klipper (Not required for Danger Klipper)

To be able to choose switch your accel per hz at runtime, you need to apply the patch below.    
:exclamation: Danger Klipper has the following patch built-in

**Klipper**:

```
cd ~/klipper/klippy/extras/
rm ~/klipper/klippy/extras/resonance_tester.py
wget https://raw.githubusercontent.com/lhndo/ResHelper/accel_per_hz/Patch/resonance_tester.py
cd ../..
echo "klippy/extras/resonance_tester.py" >> .git/info/exclude
git update-index --assume-unchanged klippy/extras/resonance_tester.py
systemctl restart klipper
```



<br>

#### 5. Include the configuration file in your printer.cfg

<br>

`[include reshelper.cfg]` <br>
❗**Note: If your host user name is not "pi", then you have to change the paths in reshelper.cfg**

<br>

#### 6. Restart Klipper

<br><br>

## Switching from a previous branch
```
cd ResHelper/
git checkout accel_per_hz
./install.sh
```

Override the old reshelper.cfg when asked during the install process, and edit your user path in reshleper.cfg it it's different than "pi"

<br>

#### Patch Klipper (Not required for Danger Klipper)

To be able to choose switch your accel per hz at runtime, you need to apply the patch below.   
:exclamation: Danger Klipper has the following patch built-in and does not require installation. 


**Klipper**:

```
cd ~/klipper/klippy/extras/
rm ~/klipper/klippy/extras/resonance_tester.py
wget https://raw.githubusercontent.com/lhndo/ResHelper/accel_per_hz/Patch/resonance_tester.py
cd ../..
echo "klippy/extras/resonance_tester.py" >> .git/info/exclude
git update-index --assume-unchanged klippy/extras/resonance_tester.py
systemctl restart klipper
```



<br>
<br>
<hr>
<br>
<br>

# Usage

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




# Support

For support please join us on the [LH Stinger Discord](https://discord.gg/EzssCfnEDS)

<br>
<a href='https://ko-fi.com/lh_eng' target='_blank'><img height='46' style='border:0px;height:36px;' src='https://az743702.vo.msecnd.net/cdn/kofi3.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' /> </a>



<br>

# Credits
*Based on work by **Dmitry**, **churls** and **kmobs***<br>
https://gist.github.com/kmobs/3a09cc28ec79e62f28d8db2179be7909