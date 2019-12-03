function param                  = Initialization_AR()

param.Ch                        = {'FP1'    'FPZ'    'FP2'    'F7'    'F3'    'FZ'    'F4'    'F8' ...
                                      'FC5'    'FC1'    'FC2'    'FC6'           'C3'...
                                    'CZ'    'C4'        'CP5'    'CP1'    'CP2'    'CP6'    ...
                                    'P3'    'PZ'    'P4'        'O1'    'OZ'    'O2'};
param.NumCh                     = length(param.Ch);
param.Fs                        = 500;
param.dFs                       = 125;
[pB, pA]                        = butter(2, [0.5 1]./(param.Fs/2),'bandpass');
param.pBF                       = {pB, pA};
[B,A]                           = butter(4, [0.5 12]./(param.Fs/2),'bandpass');
param.BF                        = {B, A};
[hB,hA]                           = butter(4, [0.5]./(param.Fs/2),'high');
param.HF                        = {hB, hA};
[dlB,dlA]                           = butter(4, [50]./(param.Fs/2),'low');
param.dLF                        = {dlB, dlA};
[lB,lA]                           = butter(4, [ 12]./(param.Fs/2),'low');
param.LF                        = {lB, lA};
param.repeat                    = 10; 
param.prep_factor = [1:4];

% param.BFFIR                     = fir1(param.Fs*3/0.1 , [0.1 100]./(param.Fs/2) , 'bandpass');
param.Epoctime                  = 0.6;
param.Basetime                  = 0.2;
param.Epocline                  = param.Epoctime * param.Fs;
param.Baseline                  = param.Basetime * param.Fs;
param.Totalepoc                 = param.Epocline + param.Baseline;
param.Totaltrial                = param.Totalepoc*40 + 10*param.Fs;
param.Time                      = -param.Basetime : 1/param.Fs : param.Epoctime-1/param.Fs;
param.Numtrial                 = 0;


param.Stimtype                  = 'Single' ; 
param.Stims                     = 1 : 4;
param.Sys                       = [12 13];
param.Targets                   = [];

param.NumTrTrial                  = 50;
param.NumTeTrial                  = 30;

param.decoder.mode              = 'training'; % 'training' : training decoder , 'testing' : testing decoder
param.channel.mode              = 'both'; 


param.NumRep                    = 10;
param.NumStims                  = size(param.Stims,2);

param.switch_on                 = false;
param.nbchan                    = length(param.Ch);

param.H                         = figure(1); clf;
set(param.H, 'color', 'w');

for i = 1:length(param.Ch)
    param.SH(i)                       = axes;
    hold(param.SH(i),'on');
    
    subplot(6,6,i,param.SH(i));
    
    param.h(i,1)                        = plot(nan,nan, 'parent',param.SH(i));
    param.h(i,2)                        = plot(nan,nan, 'parent',param.SH(i));
    param.h(i,3)                        = plot(nan,nan, 'parent',param.SH(i));
    param.h(i,4)                        = plot(nan,nan, 'parent',param.SH(i));
    
end


set(gcf, 'Position', [200, 50, 1800, 1000])
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 10])

% param.h1                        = plot(nan,nan, 'parent',param.SH);
% hold(param.SH,'on');
% set(param.h1, 'xdata', [], 'ydata',[]); drawnow; %  outside of this func.

param.Targ                      = [];
param.kfold                     = 10;

param.windowlen = 0.5;
param.stepsize = floor(param.Fs*param.windowlen/2);
param.cutoff = 10;
param.maxdims = 0.66;

param.tmp.data = [];
param.tmp.srate = param.Fs;
param.tmp.cutoff = 1;

param.calibrate = false;
param.trD.w                     = {};

