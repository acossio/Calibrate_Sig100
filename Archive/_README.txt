<Sig 100 proc & calibration>  20190816, 20190819, 20190827


TO DO – 
implement the rest of the calibration process in calibrateSig100.m
(draft solution: calibrateSig100-gc01.m) 



[---
From: Sven Nylund <Sven.Nylund@nortekgroup.com>
Date: Mon, Aug 19, 2019 at 12:25 PM
Subject: RE: calibration data
To: George Cutter - NOAA Federal <george.cutter@noaa.gov>


Hi Randy,
 
You should not need to make any changes to the calcEchogram scripts, they should be complete I think and I would rather keep them separate from the calibration process. So you can implement the rest of the calibration process in calibrateSig100.m
 
Typically, one section for each of the various echograms with the spherePost distance I have implemented already. I suggest you use hard coded values for the binned target strengths for now (you should already have received some weeks ago), I can generalize that part later.
 
I suggest we stick to the 1-inch sphere at the distance you used in the last measurements. Due to the long transmit pulse, we cannot move it much further out and as I said, the saturation is only a problem in the verification process here. We can verify the scheme of things using the latest version of firmware. We have also verified the script and the old firmware version at longer ranges, you can take a look at the previously collected data if you like and compare those to the values calculated with the Matlab script.
 
Just let me know if you have further questions but it is very good if you can continue the coding from here, as you know more about the calibration part itself. I should mention though that I plan to distribute this code to whoever might be interested, I hope you do not have any problem with that.
 
Cheers,
Sven
 
From: George Cutter - NOAA Federal [mailto:george.cutter@noaa.gov] 
Sent: 16. august 2019 21:13
To: Sven Nylund <Sven.Nylund@nortekgroup.com>
Subject: Re: calibration data
 
Hi Sven, 
 
Thank you! I received the files and downloaded the new firmware. 
 
I will work on the code to try to estimate TS and calibration gain. Do you want me to work on all three of the "calcEchogram..." scripts, or something else?  
 
To prevent saturation, would you want me to calibrate with the 1-inch diameter sphere at a larger range? Keep in mind that the tank is only about 9 m deep. I could also use a smaller sphere, I have 0.5 inch and 0.75 inch diameter spheres, although I'm not sure if there are nulls that might cause problems if using those. 
 
Cheers, 
Randy
 
 
 
 
On Fri, Aug 16, 2019 at 1:59 PM Sven Nylund <Sven.Nylund@nortekgroup.com> wrote:
Hi Randy,
 
We finally completed the Matlab processing for the binned frequency processing (attached). We found a couple of issues with the firmware regarding the binned frequency processing. A minor issue was that we had some slight saturation of some filter coefficients. The only consequence appears to be less attenuation in the stop band so that should be nothing to worry about. Then we also found some internal saturation which is more of a problem but only when it comes to the calibration I think. I see some saturation of the sphere itself which corresponds to maybe 2-3 dB discrepancy. As long as we calculate the calibration values from the raw data I do not think this will affect the deployment data. We are talking strong signals here after all with the short distance to the sphere. The Matlab file accounts for the saturation of the filter values but not the other problem since we rather want correct calibration values than matching the firmware results at these short distances.
 
Here is the link to the new firmware which solves these issues for the next round:
https://www.dropbox.com/s/yb1ol5wewj3wueo/Signature100_SECV5248_BBPV2212_1.ad2?dl=0
 
I have also started on the calibration script where I measure the distance to the sphere through pulse compression. I was hoping you could continue on that script and adding the calculation of the calibration values. It should only be a matter of running the three calcEchogram scripts I have sent you and implementing the appropriate equations for target strength as well as correcting the distance for the actual sound velocity. We should also make a linear average of the target around the measured distance to arrive at the estimated target strength.
 
Regards,
Sven
---]




[---
From: Sven Nylund <Sven.Nylund@nortekgroup.com>
Date: Fri, Aug 16, 2019 at 1:59 PM
Subject: RE: calibration data
To: George Cutter - NOAA Federal <george.cutter@noaa.gov>

Hi Randy,
 
We finally completed the Matlab processing for the binned frequency processing (attached). We found a couple of issues with the firmware regarding the binned frequency processing. A minor issue was that we had some slight saturation of some filter coefficients. The only consequence appears to be less attenuation in the stop band so that should be nothing to worry about. Then we also found some internal saturation which is more of a problem but only when it comes to the calibration I think. I see some saturation of the sphere itself which corresponds to maybe 2-3 dB discrepancy. As long as we calculate the calibration values from the raw data I do not think this will affect the deployment data. We are talking strong signals here after all with the short distance to the sphere. The Matlab file accounts for the saturation of the filter values but not the other problem since we rather want correct calibration values than matching the firmware results at these short distances.
 
Here is the link to the new firmware which solves these issues for the next round:
https://www.dropbox.com/s/yb1ol5wewj3wueo/Signature100_SECV5248_BBPV2212_1.ad2?dl=0
 
I have also started on the calibration script where I measure the distance to the sphere through pulse compression. I was hoping you could continue on that script and adding the calculation of the calibration values. It should only be a matter of running the three calcEchogram scripts I have sent you and implementing the appropriate equations for target strength as well as correcting the distance for the actual sound velocity. We should also make a linear average of the target around the measured distance to arrive at the estimated target strength.
 
Regards,
Sven
 
From: George Cutter - NOAA Federal [mailto:george.cutter@noaa.gov] 
Sent: 2. august 2019 20:19
To: Sven Nylund <Sven.Nylund@nortekgroup.com>
Subject: Re: calibration data
 
I was surprised to see the battery voltage near 18.8 V today. 
 
 
On Fri, Aug 2, 2019 at 6:09 PM Sven Nylund <Sven.Nylund@nortekgroup.com> wrote:
Ok, I will work on this on Monday. It might probably the temperature that confused me, the voltage dropped in Antartica due to the low temperatures.
Thanks,
Sven
Skaff deg Outlook for Android
 
________________________________________
From: George Cutter - NOAA Federal <george.cutter@noaa.gov>
Sent: Friday, August 2, 2019 7:52:39 PM
To: Sven Nylund <Sven.Nylund@nortekgroup.com>
Subject: Re: calibration data 
 
Yes, I disconnected today and collected about 12 min worth of data with the sphere at close to 5 m range. The data are attached, and the notes doc is updated. 
Thank you,
Randy
 
 
On Fri, Aug 2, 2019 at 4:31 PM Sven Nylund <Sven.Nylund@nortekgroup.com> wrote:
Hi Randy, 
I just saw 24V so I got suspicious but do use the batteries.
It will run on the higher voltage, did you remember to disconnect the transformer?
Regards,
Sven
Skaff deg Outlook for Android
 
________________________________________
From: George Cutter - NOAA Federal <george.cutter@noaa.gov>
Sent: Friday, August 2, 2019 5:41:27 PM
To: Sven Nylund <Sven.Nylund@nortekgroup.com>
Subject: Re: calibration data 
 
Hi Sven, 
I can repeat this with sphere at > 4 m this morning.  
 
I thought that you had said to run it on battery, so the power was from the same battery packs it used in the field. I can run it from the transformer if that would be better. 
 
Please clarify if it is better to run it off battery, or off the transformer, as I do not have a power supply available currently. 
 
Thanks 
Randy
 
On Fri, Aug 2, 2019 at 12:05 PM Sven Nylund <Sven.Nylund@nortekgroup.com> wrote:
Hi Randy,
 
I get a distance of 3.27 m from the transducer face, could that be the actual distance?
I can get started with these data but note that a 5 ms transmit pulse used here is equivialent to a distance of 3.75 m at 1500 m/s sound velocity. This means that the first return from the transmit pulse is received before that transmit pulse has finished. You see this in the data below, negative distance is the transmit pulse and there is no silent period before we receive the first echo (from the sphere). Next time you should move the sphere out to 4.5-5 m distance as we have a longer silent period than we need there, see image below.
 
Ideally, you should also run version 2208_0 with 18V input voltage like I mentioned, perhaps you can get hold of a power supply running at 18 Volts?
 

 
Thanks,
Sven
 
From: George Cutter - NOAA Federal [mailto:george.cutter@noaa.gov] 
Sent: 2. august 2019 01:59
To: Sven Nylund <Sven.Nylund@nortekgroup.com>
Subject: calibration data
 
Hi Sven, 
Here is the data from today's calibration effort. This should include raw data. I deployed and then downloaded from the device this time. 
Sphere is tungsten carbide, 1.0" diameter, and was suspended around 3.8 m from transducer. Let me know if these data look good or if you need anything else. 
Thank you,
Randy
 
---]
