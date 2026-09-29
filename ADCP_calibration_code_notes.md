# Initial notes

## Introduction

Here is my attempt at unraveling Randy’s code for calibrating the Signature 100\. His Matlab files are found [here](https://drive.google.com/drive/folders/1kxiEQrg0iNvUglrjhY8dYJjP9mT07PUp?usp=drive_link) on Google Drive (NOAA internal).   
I’ve uploaded the files on [Github](https://github.com/acossio/Calibrate_Sig100) to start working with them there.

These files were created by Geroge R. Cutter and Sven Nylund in 2019 to calibrate the Signature 100 ADCP-echosounder. This is an echosounder centered at 100 kHz. 

All the files that Cutter created are in the archive folder. The files needed to run the calibration analysis are in the top level. I was able to run these files, without altering them, and get the same results that were run back in 2020 with the calibrations that took place in September, 2019\. Those results are in the Archive\>Results folder. The calibration was done with the same echosounder on different firmware versions. 

## Background information 

There are two email chains between Cutter and Sven in the archive folder, \_README.txt and readme.txt. The file called readme.txt is from Jun 28, 2019 and is just one email. The file \_README.txt is from Aug, 2 \- 19, 2019\. 

## Quick notes on m files

   
**calibrateSig100\_invoke.m** \- This appears to be the file to start everything. Uses \*.mat files created from \*.ad2cp files using MIDAS software.  
Dependencies:  
%     calcEchogram70kHz  
%     calcEchogram120kHz  
%     calcEchogram90kHzBinned  
%     calibrateSig100  
%     sphere\_TS  
%     f\_theorTargetStrengthBinned  
%     f\_disp\_dbstack\_info  
%     f\_report\_calibration  
%     f\_save\_calibration  
%     f\_openfile

**calibrateSig100.m** – This appears to be the main workhorse for calibrating it all.   
function \[spherePos90fm,TS\_theor\_binned,calibration\] \= calibrateSig100(Config,Data,sphereProp,WaterProp,TS\_theor\_params)  
Calls **PulseCompression.m**, **f\_disp\_dbstack\_info.m**, **f\_find\_spherepos.m**, **f\_theorTargetStrengthBinned.m**, **calcEchogram90kHzBinned.m, calcEchogram70kHz.m,**   
**calcEchogram120kHz.m, f\_TS\_from\_Sig100\_amp.m, f\_get\_TS\_meas\_of\_target.m,** 

**PulseCompression.m** \-   
function \[pcLin, r\] \= PulseCompression(Data, Config, WaterProp)

**f\_disp\_dbstack\_info.m** \- report file and line number during code execution  
function \[\] \= f\_disp\_dbstack\_info()

**F\_find\_spherepos.m** \-   
function \[spherePos\] \= f\_find\_spherepos( Data, Config, echogram, range, approxDist, rangebuffer)

**f\_theorTargetStrengthBinned.m** \-   
function \[TS\_theor\_binned\] \= f\_theorTargetStrengthBinned(TS\_theor\_params, doPLOT, doFBINNED)  Uses **LPfilter.mat, sphere\_TS.m, TS\_24mmSphere\_f68\_119copy.txt**

**calEchogram90kHzBinned.m** \-   
function \[echogramstruct,fEcho,RangeBinned,SampleBinned\] \= calcEchogram90kHzBinned(Config, Data, WaterProp, Options)  
Uses **LPfilter.mat**

**calEchogram70kHz.m** \- function \[echogram70,fEcho,RangeBinned,pulse\_length\] \= calcEchogram70kHz(Config, Data, WaterProp, Options)

**calEchogram120kHz.m** \- similar but with some differences with calEchogram70kHz.m  
function \[echogram120,fEcho,RangeBinned,pulse\_length\] \= calcEchogram120kHz(Config, Data, WaterProp, Options)  
Uses **CBF120kHz\_Tx500us.mat, or CBF120kHz\_Tx1ms.mat**

**f\_TS\_from\_Sig100\_amp.m** \-   
function \[TS, Sv, TStype, R\] \= f\_TS\_from\_Sig100\_amp(Config, Data,...  
   pulse\_length, echogramraw, fEcho, ABSORPTION, Range, soundVel, CALGAIN)  
Uses **absorption.m, f\_equivalent\_beam\_angle.m**

**f\_get\_TS\_meas\_target.m** \-   
function \[TS\_meas\_target,TS\_meas\_target\_mean\] \= f\_get\_TS\_meas\_of\_target(...  
   fEcho\_binned, TS\_binned, Range, spherePos, doTARGOFFSET, TARGSAMPOFFSET, NCELLBUFF)

**absorption.m** \- Calculating the absorption coefficient of seawater in dB/ km  
function \[alpha\] \= absorption(freq, Z, T, S, pH)  
Requires % freq \= frequency in Hz % Z \= depth in km % T \= temperature in C % S \= salinity in ppt % pH \= pH. 

**binnedTargetStrength.m** \- Loads **LPfilter** and **TS\_24mmSphere\_f68-119copy.txt.**  It appears to be looking at 5 frequencies and providing TS and mean TS by frequency bin. 

**TS\_24mmSphere\_f68-119copy.txt** \- % d is a 2x511 array, row 1 contains frequencies (kHz)  
   % and row 2 contains theoretical TS of target sphere

**sphere\_TS.m** \- used to calculate the TS of a standard sphere.   
function \[freq, TS\] \= sphere\_TS(varargin)

**call\_sphereTS.m** \- Calls **sphere\_TS** with the range of frequencies and sphere conditions, as well as sound speed and water density(rhow)

**LPfilter.mat** \- A low pass filter that contains two variables. A, which is just 1 and B, which is a 1x 97 double. B ranges from \-0.0454 to 0.2229. I’m not sure what it filters but it is used in a lot of the functions

**binnedTargetStrength\_Exper.m** \- is similar to **binnedTargetStrength.m** but with some experimental work in it.

**c\_water\_from\_t\_depth\_sal.m** \- calculates sound speed in m/s of seawater. Input of temp (C ), pressure (kPa), and salinity in ppt.   
function \[c\_mps\] \= c\_water\_from\_t\_depth\_sal(T\_degrees\_C,P\_dbar,S\_ppt)

**f\_report \_calibration**\- Reports Sig100 calibration results  
function \[\] \= f\_report\_calibration(calibration,Config,doWRITEFILE)  
Houses **f\_openfile.m** as well. 

**f\_openfile.m-** opens a file to save the calibration results. 

**f\_save\_calibration** \- save calibration results as a structure  
function \[calibration\_summary\] \= f\_save\_calibration(calibration,Config,fulloutfilename)

**complexSaturate.m** \- looks like it finds values  
function \[output\] \= complexSaturate(input, maxVal, minVal)

**Definitions\_water\_sphere\_TStheor.m** \- literal water properties, sphere properties, theoretical TS parameters for 70 and 120 kHz, and theoretical TS model parameters for 90 kHz FM mode. Values appear to be the same as in calibrateSig100\_invoke.m

**F\_assignin\_allvars.m** \- function \[\] \= f\_assignin\_allvars()

# Gemini interpretation

The MATLAB functions in this codebase form a multi-tier pipeline designed to process raw acoustic echo data and calibrate a **Nortek Signature100 echosounder**12\. They work together in a structured hierarchy, moving from high-level workflow execution down to specialized signal processing, target identification, and acoustic calibration calculations2more\_horiz.  
---

Workflow Overview & Call Hierarchy

```
calibrateSig100_invoke.m (Master Driver Script)
 └── calibrateSig100.m (Core Orchestrator)
      ├── PulseCompression.m
      ├── calcEchogram90kHzBinned.m
      ├── calcEchogram70kHz.m
      ├── calcEchogram120kHz.m
      ├── f_find_spherepos.m
      ├── f_theorTargetStrengthBinned.m
      ├── f_TS_from_Sig100_amp.m
      └── f_get_TS_meas_of_target.m
```

---

1\. Master Control & Workflow Driver

* **calibrateSig100\_invoke.m**  
  * **Role:** Serves as the top-level execution entry point2.  
  * **Function:** Loads raw acoustic data files (`Data` and `Config` structures) generated by the instrument78. It defines physical environment parameters (`WaterProp`: sound speed, temperature, salinity, density), calibration target properties (`sphereProp`: sphere diameter, material type, approximate distance), and theoretical Target Strength (TS) modeling parameters8more\_horiz.  
  * **Interaction:** Passes these configurations into `calibrateSig100`6, then formats, reports, and saves the resulting calibration metrics into output `.mat` and `.txt` files6more\_horiz.

---

2\. Core Calibration Orchestrator

* **calibrateSig100.m**  
  * **Role:** Coordinates the main processing sequence across all three echosounder frequency channels: **90 kHz FM broadband**, **70 kHz CW narrowband**, and **120 kHz CW narrowband**14more\_horiz.  
  * **Function:** Integrates pulse compression, channel-specific echogram calculation, sphere target tracking, theoretical TS modeling, and measured TS extraction3more\_horiz.  
  * **Interaction:** Receives parameters from `calibrateSig100_invoke`16, calls each specialized processing function in turn, computes calibration gain offsets (\$\\text{CALGAIN} \= \\text{TS}\_{\\text{theor}} \- \\text{TS}\_{\\text{meas}}\$) for each frequency band, and packages the results into a `calibration` output structure22more\_horiz.

---

3\. Sub-Functions & Processing Stages  
A. Initial Signal Processing & Pulse Compression

* **PulseCompression.m**  
  * **Role:** Processes raw 90 kHz broadband FM echo data26.  
  * **Function:** Performs complex convolution between the raw I/Q echo data (\$Z \= DataI \+ j \\cdot DataQ\$) and the transmitted pulse replica (\$Xmit\$)2627. It calculates the linear pulse-compressed amplitude array (`pcLin`) and the physical range vector (`rangePC`)2627.  
  * **Interaction:** Called early inside `calibrateSig100` to establish the initial range-resolved acoustic response for 90 kHz FM mode3.

B. Channel-Specific Echogram Generation

* **calcEchogram90kHzBinned.m**  
  * **Role:** Generates multi-frequency broadband echograms for the 90 kHz FM channel2829.  
  * **Function:** Uses complex bandpass filter banks (`coeffComplexBinnedFrequency`) to divide the broadband chirp spectrum into discrete frequency sub-bins (typically 5 bins), convolving filtered I/Q data to form range-binned multi-frequency echogram structures28more\_horiz.  
* **calcEchogram70kHz.m**  
  * **Role:** Computes echograms for the 70 kHz Continuous Wave (CW) channel33.  
  * **Function:** Reads raw 70 kHz I/Q data, accounts for blanking distance, bins samples into range cells, applies monochrome amplitude adjustments, and computes log-averaged echogram powers34more\_horiz.  
* **calcEchogram120kHz.m**  
  * **Role:** Computes echograms for the 120 kHz CW channel39.  
  * **Function:** Applies a complex Finite Impulse Response (FIR) filter (`BF120`) to suppress out-of-band sampling noise (since 120 kHz data is sampled at 125 kHz with wider bandwidth) before range binning and power averaging40more\_horiz.

C. Target Identification & Acoustic Measurement

* **f\_find\_spherepos.m**  
  * **Role:** Locates the calibration sphere target in the echogram data4344.  
  * **Function:** Searches ping-by-ping within a constrained range window around the expected distance (`approxDist ± rangebuffer`) for peak signal amplitude4445. It returns a `spherePos` structure containing target sample indices, physical ranges, and linear/log amplitudes4546.  
  * **Interaction:** Called separately by `calibrateSig100` for the 90 kHz FM, 70 kHz CW, and 120 kHz CW channels17more\_horiz.  
* **f\_get\_TS\_meas\_of\_target.m**  
  * **Role:** Extracts the measured Target Strength (\$TS\_{meas}\$) of the target sphere49.  
  * **Function:** Samples the measured TS echogram around the detected sphere indices (using a cell buffer `NCELLBUFF`), sums returned target energy in linear space across adjacent cells, and calculates mean measured TS values (\$TS\_{meas}\$) for each frequency band50more\_horiz.  
  * **Interaction:** Called near the end of `calibrateSig100` to feed empirical TS values directly into the calibration gain offset calculation5more\_horiz.

# Questions

1. In calEchogram120kHz.m there is a comment about loading a filter is the firmware is different. It appears that it is based on pulse length of either 500 milliseconds or 1000 milliseconds. 

if Config.fwVersionDoppler \>= 2212\. It loads CBF120kHz\_Tx500us or CBF120kHz\_1x1ms (1x39) if not.   
Does each firmware require different coefficients? I only saw this in the 120kHz not the 70 kHz. 

2. In the same file and 70kHz, there is a  fAdjMonochromeAmp \= 6.0206;  % Adjustment used in firmware \[dB\]. What is this for? Does it change with firmware versions?  
3. Is TS\_24mmSphere\_f68-119copy.txt repeatable for different water conditions and sphere sizes? Use sphere\_TS.m  
4. Where is it getting the config file info from? I’m only pointing to the data currently not at the config files?  
5. In a few of the functions and the main program, there are inputs for environmental variables, such as water temp, salinity, sound speed, etc. Looking at the data from the ADCP, the water was 20.67 where the code had 14 in it.   
6. There are multiple m files where there are repeated inputs (ie water properties, sphere properties, theoretical parameters, etc). This should be minimized where repeated inputs are put.    
7. Where did the LPfilter.mat get created from? 

