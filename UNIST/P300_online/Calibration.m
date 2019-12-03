function [ param] = Calibration(sig,param)

% sig = filtfilt(param.HF{1}, param.HF{2}, sig')';

% param.tmp.data = sig;
% % param = FindBadChannel(param.tmp,trig,param);
% % [sig, param] = RejectBadChannel(sig,param);
% 
% param.tmp.data = sig;
% out = pop_eegfiltnew_MJ(param.tmp,0.5);
cal_sig = double(sig);

save(['./Dat_',param.SubName,'/cal_sig.mat'],'cal_sig');


% ref = clean_windows_MJ(sig,param.Fs);
% param.state = asr_calibrate(ref,param.Fs,param.cutoff);