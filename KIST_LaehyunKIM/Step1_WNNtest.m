clc; clear; close all;
%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%
system('start /min biosemi2ft config.txt - -')

load(['InfoChannel.mat']);

% Number of EEG channels
nCh = 64;

% Sampling rate
SR  = 256;

% Bandpass filter spec for WNN calibration
HPB = 0.5;
LPB = 50;

isEnd = 0;
ofsVector = 10000;
ofsFactor = 25;
EEGp_B = 0;
 plotChNum = 17;
 plotChIndex = [1 33 34 37 10 47 45 15 14 13 12 48 49 50 51 52 29];

Biosemi_initialize;

if strcmp(cfg.jumptoeof, 'yes')
    hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat);
    prevSample = hdr.nSamples * hdr.nTrials;
else
    prevSample = 0;
end

startSample = prevSample+1; 
isEnd = 1;
ini = 1;
streamingWindow = 1;

%% Step 2
while true
  
  % determine number of samples available in buffer
  hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat);
  
  % see whether new samples are available
  newsamples = (hdr.nSamples*hdr.nTrials-prevSample);
  
  if newsamples>=blocksize
    
    % determine the samples to process
    if strcmp(cfg.bufferdata, 'last')
      begsample  = hdr.nSamples*hdr.nTrials - blocksize + 1;
      endsample  = hdr.nSamples*hdr.nTrials;
    elseif strcmp(cfg.bufferdata, 'first')
      begsample  = prevSample+1;
      endsample  = prevSample+blocksize ;
    else
      ft_error('unsupported value for cfg.bufferdata');
    end
    
    % this allows overlapping data segments
    if overlap && (begsample>overlap)
      begsample = begsample - overlap;
      endsample = endsample - overlap;
    end
    
    % remember up to where the data was read
    prevSample  = endsample;
    count       = count + 1;

          disp('Testing WNN')
          % determine number of samples available in buffer
           hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat);

          % read data segment from buffer
            dat = ft_read_data(cfg.datafile, 'header', hdr, 'dataformat', cfg.dataformat, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx, 'checkboundary', false);

            % initialization variable

            if ini == 1

                ini = 0;
                t = linspace(-1*streamingWindow, 0 ,hdr.Fs*streamingWindow);

                Bprocessing_buffer = zeros(hdr.nChans,hdr.Fs*streamingWindow);
                WNNprocessing_buffer = zeros(hdr.nChans,hdr.Fs*streamingWindow);

                Bplot_buffer = Bprocessing_buffer;
                WNNplot_buffer = WNNprocessing_buffer;



                set( subplot(1,2,1), 'NextPlot', 'replacechildren')
                set( subplot(1,2,2), 'NextPlot', 'replacechildren')

                Bplot = plot(t,Bplot_buffer(plotChIndex,:),'Parent', subplot(1,2,1));
                WNNplot = plot(t,WNNplot_buffer(plotChIndex,:),'Parent', subplot(1,2,2));

            end
            
            
            %%%%%%%%%%%%%%%%%%%%
            % data preprocessing
            %%%%%%%%%%%%%%%%%%%%
            
            
            [temp a b] = iirfilt(dat(1:64,:),hdr.Fs,0,LPB,0, [1], 0, 0.0025, 40, 0);
            [Bandpass a b] = iirfilt(temp,hdr.Fs,HPB,0,0, [0.25], 0, 0.01, 30, 0);
            WNN = mWNN(Bandpass);
         
                
            %%%%%%%%%%%%%%%%%%%realtimeplot%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            Bplot_buffer = Bandpass*100; 
            ofst_B = [1:size(Bplot_buffer(plotChIndex,:),1)] * ofsVector;   % 'Offset' Vector
            EEGp_B = bsxfun(@plus, Bplot_buffer(plotChIndex,:)', ofst_B)';  % Add ' Offset'To Each Row


            WNNplot_buffer = WNN*100; 
 
            ofst_WNN = [1:size(WNNplot_buffer(plotChIndex,:),1)] * ofsVector;   % 'Offset' Vector
            EEGp_WNN = bsxfun(@plus, WNNplot_buffer(plotChIndex,:)', ofst_WNN)';  % Add ' Offset'To Each Row


            subplot(1,2,1);
            title('Only Bandpass filtering', 'FontSize', 14)
            plot(t, EEGp_B, 'LineWidth',3)
            xlabel('Time(s)');
            axis([xlim -1*ofsVector ofsVector*(plotChNum+1)])
            ChLabel = hdr.label(plotChIndex);
            yt_B = ofst_B + ofsFactor;                % 'Offset' Factor
            set(gca, 'Ytick', yt_B, 'YTickLabel', ChLabel, 'FontSize' , 14)
            drawnow limitrate;


            subplot(1,2,2);
            title('WNN', 'FontSize', 14)

            plot(t, EEGp_WNN, 'LineWidth',3)
            xlabel('Time(s)');
            axis([xlim -1*ofsVector ofsVector*(plotChNum+1)])
            ChLabel = hdr.label(plotChIndex);
            yt_WNN = ofst_WNN + ofsFactor;                % 'Offset' Factor
            set(gca, 'Ytick', yt_WNN, 'YTickLabel', ChLabel, 'FontSize' , 14)
            drawnow limitrate;
    %       break;
%       end
  end % if enough new samples
end % while true

system('taskkill /im biosemi2ft.exe')