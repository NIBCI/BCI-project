function [sig,param] = PreProcess(sig,param)
param.DoAsr = 'Y';

%% (essential) 0.5~ 50Hz filtering : avoid line noise & high frequency noise
if isfield(param,'filterType') && strcmp(param.filterType,'FIR')
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
    
    sig = filtfilt(b,1,double(sig)')';
    
else
    sig = filtfilt(param.HF{1}, param.HF{2}, double(sig)')'; %180213 updated: default filtering 0.5 Hz
end
fprintf('[1] 0.5Hz HPF .. Done \n')
param.NumCh = size(sig,1);


clf(figure(10));
%% 1: bad channel rejection
if ismember(1,param.prep_factor) 
    if ~isfield(param,'badch') && ~strcmp(param.decoder.mode,'testing')
        badch = prebadchannelrejection(sig,param);
        fprintf('Bad channels: %d\n', badch);
        param.badch = badch;
        for i = 1:length(param.badch)
            param.Ch{param.badch(i)} =[];
        end
        param.Ch = param.Ch(~cellfun('isempty',param.Ch));
    end
    
    if ~isempty(param.badch)
        figure(10); subplot(2,2,1); plot(sig(param.badch(1),:)); drawnow
    else
        figure(10); subplot(2,2,1); plot(sig(1,:)); drawnow
    end
    %
    fprintf('[2] Bad channel Rejection .. Done \n');
    
    if isfield(param,'interp')
        if param.interp == 1
            sig = eeg_interp_MJ(sig,param.badch,'spherical');
            fprintf('[2]_1 Interpolation .. Done \n');
        else
            sig(param.badch,:) = [];
            param.NumCh = size(sig,1);
        end
    else
        if ~isempty(param.badch)
            hold on;
            plot(sig(param.badch(1),:));
        else
            hold on;
            plot(sig(1,:));
        end
        sig(param.badch,:) = [];
        param.NumCh = size(sig,1);
        
    end
end

%% 2: CAR & REST
if ismember(2,param.prep_factor) 
    figure(10); subplot(2,2,2); plot(sig(1,:)); hold on;drawnow
    sig = sig - repmat(mean(sig,1),size(sig,1),1);
        figure(10); subplot(2,2,3); plot(sig(1,:));drawnow
    fprintf('[3] CAR .. Done  \n');
    
    %%% REST %%%
    %     if isfield(param,'REST')
    %         if ~strcmp(param.decoder.mode,'testing') && ~isfield(param.REST,'G')
    %             if param.NumCh ~= 31  % bad channel rejected -> calculate leadfield matrix again
    %                 file = 'D:\[1]EEGBCI\[2]Research\Code&Algorithm\32_ch_XYZ_loc_Nose_Y.txt';
    %                 filenew = editchanloc(file,param.badch);
    %                 param.REST.calculateG = 1;
    %                 Gfile = [];
    %             else
    %                 Gfile =  'D:\[1]EEGBCI\[2]Research\Code&Algorithm\REST\Lead_Field_32ch.dat';
    %                 param.REST.calculateG = 0;
    %             end
    %             [sig,G] = REST(sig,[],Gfile,param.NumCh,param.REST.calculateG);
    %             param.REST.LeadField = G;
    %             param.REST.calculateG = 0;
    %                     fprintf('[3]_1 REST .. Done  \n');
    %
    %         else
    %
    %             [sig,~] = REST(sig,param.REST.LeadField,param.NumCh,param.REST.calculateG);
    %                     fprintf('[3]_1 REST .. Done  \n');
    %
    %         end
    %
    %     end
    hold on;
    plot(sig(1,:));
    % % % %     interpolationÀ» ÇØ¾ß!
    
    
end
%% (essential) LP filtering (50Hz)
if isfield(param,'filterType') && strcmp(param.filterType,'FIR')
    figure;
    plot(sig(1,:))
    hicutoff = 50;
    
    TRANSWIDTHRATIO = 0.25;
    % Lowpass and bandpass
    df = hicutoff*TRANSWIDTHRATIO;
    
    cutoffArray = hicutoff + df / 2;
    
    filtorder = 3.3 / (df / param.Fs); % Hamming window
    filtorder = ceil(filtorder / 2) * 2; % Filter order must be even.
    
    winArray = windows('hamming', filtorder + 1);
    
    %%%
    b = firws(filtorder, cutoffArray / (param.Fs/2), winArray);
    sig = filtfilt(b,1,sig')';
    hold on; plot(sig(1,:));
else
    sig = filtfilt(param.dLF{1}, param.dLF{2}, double(sig)')'; %180213 updated: default filtering  50Hz
end
fprintf('[4] 50Hz LPF .. Done \n')

%% 3: ASR
if ismember(3, param.prep_factor) 
    figure(10); subplot(2,2,3); plot(sig(1,:)); hold on;drawnow
    if (isfield(param,'filterType') && strcmp(param.filterType,'FIR'))...
            ||(isfield(param,'cal') && strcmp(param.cal,'on'))
        
        
        ref = clean_windows_MJ(sig,param.Fs);
        param.state = asr_calibrate(ref,param.Fs,param.cutoff);
        
        sigout = ASR(sig,param);
        
        
    else
        if ~strcmp(param.decoder.mode,'testing')
            
            load([param.dir,'/cal_sig.mat']);
            
            param = preASR(cal_sig,param);
            %         ref = clean_windows_MJ(sig,param.Fs);
            %         param.state = asr_calibrate(ref,param.Fs,param.cutoff);
            
        end
        try
            switch param.DoAsr
                case 'Y'
                    sigout = ASR(sig,param);
                    fprintf('ASR is done..!\n');
                case 'N'
                    sigout = sig;
                    fprintf('Pass ASR ..!\n');
            end
        catch
            sigout = sig;
            fprintf('ASR is failed..!\n');
        end
    end
    
    sig = sigout;
    figure(10); subplot(2,2,3); plot(sigout(1,:)); drawnow
    fprintf('[5] Artifact rejection .. Done \n')
    
end
%% 4: LP filtering (12Hz)
if ismember(4,param.prep_factor) 
    figure(10); subplot(2,2,4); plot(sig(1,:)); hold on;drawnow
    
    if isfield(param,'filterType') && strcmp(param.filterType,'FIR')
        hicutoff =12;
        
        TRANSWIDTHRATIO = 0.25;
        % Lowpass and bandpass
        df = hicutoff*TRANSWIDTHRATIO;
        
        cutoffArray = hicutoff + df / 2;
        
        filtorder = 3.3 / (df / param.Fs); % Hamming window
        filtorder = ceil(filtorder / 2) * 2; % Filter order must be even.
        
        winArray = windows('hamming', filtorder + 1);
        
        %%%
        b = firws(filtorder, cutoffArray / (param.Fs/2), winArray);
        sig = filtfilt(b,1,sig')';
    else
        sig = filtfilt(param.LF{1},param.LF{2},sig')';
    end
    figure(10); subplot(2,2,4); plot(sig(1,:)); drawnow
    fprintf('[6] 12Hz LPF .. Done \n');
end

param.ChDraw = 1:param.NumCh;
