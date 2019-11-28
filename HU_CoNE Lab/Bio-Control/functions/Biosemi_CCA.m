% inital version of Matlab acquisition and saving tool for BIOSEMI amp
% TODO: add proper configuration, turn into function
% (C) 2010 S. Klanke 

clear;
close all;

%% Dump if exist
try
	dummy = biosemix([0 0]); %실행될때마다 버퍼에서 데이터 가져오기, 일단 한번 실행하는 것.
catch me
	if strfind(me.message,'BIOSEMI device')
		clear biosemix
	else
		rethrow(me);
	end
end
addpath(genpath('D:\KimYongWook\01_works\ADD\01_Biosemi_online\Biosemi Online'));
addpath(genpath('D:\KimYongWook\01_works\ADD\01_Biosemi_online\Biosemi Online\functions'));
%% Initialize Biosemi 
   Biosemi_Initialize
   
%% Basic Parameter Initialization
   % modes 
   DummyMode = 0; % 0 : biosemi, 1 : Dummy (fs : 2048Hz, white noise) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% check
   DownSample = 1; % 1 = downsample, 0 = 안해, Downsampleing according to Biosemi_Initialize
   
   % buffer setting for 
   nBufferLength=2048*5.5;
   signalBuffer=zeros(numEEG,nBufferLength);
   triggerBuffer=zeros(1, nBufferLength);
   
   % *** recorded signal ***
   recordedSig = [];
   recordedTri = [];
   
   % counters
   numBlocks = 0;
   numSamples = 0;
   
   %% filterbank parameters
   Stim_freq = [60/10, 60/9];   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% check
   warning('Check the Dummy mode');
   warning('Check the stimulation frequency');
   pause();
   
%    [b1, a1] = butter(3, [(6-1), 88]/2048, 'bandpass');
%    [b2, a2] = butter(3, [(6*2-1), 88]/2048, 'bandpass');
%    [b3, a3] = butter(3, [(6*3-1), 88]/2048, 'bandpass');
%    [b4, a4] = butter(3, [(6*4-1), 88]/2048, 'bandpass');
%    [b5, a5] = butter(3, [(6*5-1), 88]/2048, 'bandpass');
%    [b6, a6] = butter(3, [(6*6-1), 88]/2048, 'bandpass');
%    [b7, a7] = butter(3, [(6*7-1), 88]/2048, 'bandpass');
   
   Ref_time = pi * Stim_freq' * linspace(0,3,2048*3);   % 3 seconds length
   
   Ref_time = Ref_time(:,1:2048*3-307);
   
   Reference = permute(...
       reshape(...
       [sin(2*Ref_time); cos(2*Ref_time); sin(4*Ref_time); cos(4*Ref_time); sin(6*Ref_time); cos(6*Ref_time); sin(8*Ref_time); cos(8*Ref_time); sin(10*Ref_time); cos(10*Ref_time)]'...
       , 2048*3-307, length(Stim_freq), 10),...
       [1, 3, 2]);
   
   Iter = 1;
   Result_matrix = zeros(100,1);
   
while 1
    %% Receive
    pause(0.1); % rest
    
    if( DummyMode )
        temp = rand(numEEG+1, 2048); % random data
    else
        temp = biosemix([numEEG numAIB]);  % get data from biosemi
    end
	if isempty(temp)
		continue % loop initialize
    end

%% Translate
	N = size(temp,2);
    tri = single(temp(1,:));
    sig = single(temp(2:end,:)) * 0.262 / 2^31; % bit -> V
    if(DownSample)
        [DM, sig] = online_downsample_apply(DM, sig);
    end
    
%% Filtering
    triD=double(tri);
    sigD=double(sig);
    nSigD=size(sig,2);
    signalBuffer=[signalBuffer(:,size(sigD,2)+1:nBufferLength),sigD];
    triggerBuffer=[triggerBuffer(:,size(triD,2)+1:nBufferLength),triD];
    recordedSig = [recordedSig sigD];
    recordedTri = [recordedTri triD];
    
%% Write raw signal
% 	ft_write_data(cfg.ftOutput, sig, 'header', hdr, 'append', true);
% 	HDR = swrite(HDR, dat');

%% Report
    DruidWavePlot(double(signalBuffer), true)
	numBlocks = numBlocks + 1;
	numSamples = numSamples + N;
	fprintf(1,'%i blocks, %i samples\n', numBlocks, numSamples);
    
%% filterbank canonical correlation

    if isempty(find(diff(triD) == 127))   % end trigger (자극을 확인하세요)
    else
        Tri_index = find(diff(triggerBuffer) == +2^5)+1; % 2^5: 자극이 시작되는 순간. 자극을 확인하세요 % 이시 점 후 5초모으기!
        
        Signal_CCA = signalBuffer(:, Tri_index+307+1:Tri_index+2048*3);

        for this_freq = 1:2
            [~, ~, r] = canoncorr( Signal_CCA', Reference(:,:,this_freq) );
            CanonCoeff(this_freq) = max(r);
        end

        [~, index]  = max(CanonCoeff);

        soundFileName = ['sound/' num2str(index) '.wav'];
        [Result, ResultFs] = wavread(soundFileName); %#ok<DWVRD>
        sound(Result, ResultFs);
        
        Result_matrix(Iter) = index;
        Iter = Iter + 1;
    end
    
    if isempty(find(diff(triD) == 128))   % resting trigger (자극을 확인하세요)
    else
        CCA_Result = {recordedSig, recordedTri, signalBuffer, triggerBuffer, Result_matrix, DummyMode, DownSample, Stim_freq};
        
        try
            savefile = ['rawData/CCA_', strrep(strrep(datestr(now), ' ', '_'), ':', ''), '.mat'];
            eval(['save ' savefile ' CCA_Result']);
        catch
            mkdir(['rawData/']);
            savefile = ['rawData/CCA_', strrep(strrep(datestr(now), ' ', '_'), ':', ''), '.mat'];
            eval(['save ' savefile ' CCA_Result']);
        end
    end
    
%% Clearance
    clear temp sig N sigD nSigD singalBuffer tri;
end
