<readme>
This code is for MI based exoskeleton control.

by Ph.D Student Junhyuk Choi(h14505@kist.re.kr) 20191203
KIST Center for Bionics, Neuro-Robotic LAB. 

Proceedure..
1. Run the 'Training' folder, based on E-prime 3.0 with Black Box ToolKit USB TTL.
2. Record EEG data via BrainVision Recorder (Brain Products) through RDA Matlab. use PRDA_DataAcq.m' with pnet.mexw64, mind the Marker preference! 
3. Prepare the training data(3 class, gaitMI/sitMI/donothing), refer the 'Modelingdata_sample.mat'
4. Run 'FBCSP_Offline_Modeling.m' to prepare prerequisits for online code
5. Run 'FBCSP_Online.m'
