function param = preASR(cal_sig,param)
cal_sig = double(cal_sig);

orderASR = find(param.prep_factor == 3);
orderBadCh = find(param.prep_factor == 1);

if ~isfield(param,'interp') || param.interp ~= 1
    if ismember(1,param.prep_factor) && orderBadCh < orderASR && ~isfield(param,'REST')
        cal_sig(param.badch,:) = [];
    end
end

if isfield(param,'filterType') && strcmp(param.filterType,'FIR') 
    
    %% HPF
     lowcutoff = 0.5;
    df = 0.5;
    
    if strcmp(param.decoder.mode, 'training')
        filtorder = 3.3 / (df / param.Fs); % Hamming window
    elseif strcmp(param.decoder.mode, 'testing')
        filtorder = 1500;
    end
    
    filtorder= ceil(filtorder / 2) * 2; % Filter order must be even.
    
    cutoffArray = lowcutoff - df/2;
    winArray = windows('hamming', filtorder + 1);
    
    b = firws(filtorder, cutoffArray / (param.Fs/2),'high', winArray);
    
    cal_sig = filtfilt(b,1,double(cal_sig)')';
    
    %% LPF
        hicutoff = 50;
    
    TRANSWIDTHRATIO = 0.25;
    % Lowpass and bandpass
    df = 30*TRANSWIDTHRATIO;
    
    cutoffArray = hicutoff + df / 2;
    
    filtorder = 3.3 / (df / param.Fs); % Hamming window
    filtorder = ceil(filtorder / 2) * 2; % Filter order must be even.
    
    winArray = windows('hamming', filtorder + 1);
    
    %%%
    b = firws(filtorder, cutoffArray / (param.Fs/2), winArray);
    cal_sig = filtfilt(b,1,cal_sig')';
    
else
    cal_sig = filtfilt(param.HF{1}, param.HF{2}, double(cal_sig)')'; %180213 updated: default filtering 0.5 ~ Hz
    cal_sig = filtfilt(param.dLF{1}, param.dLF{2}, double(cal_sig)')'; %180213 updated: default filtering ~ 50Hz
end

%
% if ismember(2,param.prep_factor) && orderFilter < orderASR
%     cal_sig = filtfilt(param.BF{1},param.BF{2},cal_sig')';
% % else
% %     cal_sig = filtfilt(param.HF{1},param.HF{2},cal_sig')';
% end

% figure(3); plot(cal_sig');
ref = clean_windows_MJ(cal_sig,param.Fs);
param.state = asr_calibrate(ref,param.Fs,param.cutoff);
% figure(4); plot(ref');
