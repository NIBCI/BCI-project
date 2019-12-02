addpath(['video/']); 

% bandpass filter spec
HPB = 1;
LPB = 50;

epoch_period   = [-2 3];
base_period    = [-1 0]; 
move_period    = [0.4 2.4]; %0.2 2]; % MI 3s

% Number of EEG channels
nCh = 64;

% Sampling rate
SR  = 256;
Fs                    = SR;
T                     = 1/Fs;
nWin                  = round(Fs*0.5);        % 63msec;
nFFT                  = Fs;
nShift                = round(Fs*0.05);       % 6msec;
times                 = (epoch_period(1):T:epoch_period(2)-T)*1000;
nTimes                = length(times);

tStimRed              = 0;
tStimGreen            = 1*1000;
[C I]                 = min(abs(times+tStimRed));
iStimRed              = I;
[C I]                 = min(abs(times));
iStimGreen            = I;

F                     = Fs/2*linspace(0,1,nFFT/2+1);
iFreqs                = find(F >= HPB & F <= LPB);
freqs                 = F(iFreqs);
nFreqs                = length(freqs);
nFrames               = ceil((nTimes-nWin)/nShift);

iFrames               = zeros(nFrames,1);
iFrames               = nShift*(0:nFrames-1)+(nWin*0.5);
tFrames               = (iFrames-iStimGreen)/Fs*1000;
iBase                 = find(tFrames >= base_period(1)*1000 & tFrames <= base_period(2)*1000);
iMove                 = find(tFrames >= move_period(1)*1000 & tFrames <= move_period(2)*1000);

nFFT = SR;

% epoch time
epoch_time = epoch_period(2)-epoch_period(1);
nTrials = 320; % 80 trials per each motor task
nT = 1

% variable declare for saving
EEG = zeros(nCh, epoch_time*SR);

trigger = [];
isEnd = 0;

SelCh = [1:64]; % neurofeedback topoplot 시 사용
SelCh2 = [1:64]; % 마찬가지
str = {'Right','Left','Go','Back'};
FreqRange = [8 30];

FTime = -1*epoch_period(1); % fixation 
MTime = epoch_period(2); % Motor imagery