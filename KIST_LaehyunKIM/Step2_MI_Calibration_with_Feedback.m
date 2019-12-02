
clc; clear; close all;

%%%%%%%%%%%%%%%%
% Calibration for MI training (3 classes)
% 80 trials per each motor task = > total 240 trials
% 2019.08.21.
%%%%%%%%%%%%%%%%

% File Name
FileName = 'HEJ';

close all;
system('taskkill /im biosemi2ft.exe')
system('start /min biosemi2ft config.txt - -')

% SaveDirectory
Dir      = ['Data/' FileName '/'];
mkdir(Dir)
% EEG channel information loading for topoplot
load(['InfoChannel.mat']);
% Calibration data for realtime data
% variable name 'state'

Initialization;

Biosemi_initialize;

if strcmp(cfg.jumptoeof, 'yes')
    hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat);
    prevSample = hdr.nSamples * hdr.nTrials;
else
    prevSample = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Real-time EEG acquisition and preprocessing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    
    
    % read event segment from buffer
    event = ft_read_event(cfg.datafile, 'header', hdr, 'eventformat', cfg.dataformat,'minsample',begsample,'maxsample',endsample);
    
    trigger = [[event(strcmp('TRIGGER', {event.type})).value]', [event(strcmp('TRIGGER', {event.type})).sample]']; 
    
    if ~isempty(trigger)
        
        % MI event (1~4)
        % checking sample when starting MI event
         if trigger(1,1) == 1 || trigger(1,1) == 2 || trigger(1,1) == 3 || trigger(1,1) == 4
            startSample = trigger(1,2);
            Te.label(nT) = trigger(1,1); % test data label
            disp(['MI trigger ' num2str(trigger(1,1)) ]);
         end
         
         % Self-test event
        
          if trigger(1,1) == 5
            disp('Self test trigger 5 ');
            endSample   = startSample + SR*epoch_time - 1;
            % read data segment from buffer
            dat = ft_read_data(cfg.datafile, 'header', hdr, 'dataformat', cfg.dataformat, 'begsample', startSample, 'endsample', endSample, 'chanindx', chanindx, 'checkboundary', false);
    
            %%%%%%%%%%%%%%%%%%%%
            % data preprocessing
            %%%%%%%%%%%%%%%%%%%%
    
            % bandpass filter
            [temp a b] = iirfilt(dat(1:64,:),hdr.Fs,0,LPB,0, [1], 0, 0.0025, 40, 0);
            [Bandpass a b] = iirfilt(temp,hdr.Fs,HPB,0,0, [0.25], 0, 0.01, 30, 0);
            WNN = mWNN(Bandpass);
            
            %% filter (BPF)
            WNN_MI = WNN; % ch x times (0.05 ~ 50Hz)
            [WNN_MI al bl] = iirfilt(WNN_MI,SR,0,LPB,0,[0.25],0,0.01,40,0);
            [WNN_MI ah bh] = iirfilt(WNN_MI,SR,HPB,0,0,[0.25],0,0.01,40,0);
            % signal, sampling rate, low cut, high cut, 0, [pass bandwidth], 0, 0.01, ripple dB, 0);
            
            %% Extract test data
            clear MI_te ImS ImE
            ImS = 2.4; ImE = 4.4; MC = [8:19,32,43:53];
            MI_te = double(WNN_MI(MC,round(SR*ImS)+1:round(SR*ImE))); % MC x times (2.4~4.4s)
            Te.data(:,:,nT) = cov(MI_te'); % times x MC
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            
            % Calculate EEG power for topoplot by pwelch
            clear navgPwr topodata
            for ch = 1:length(SelCh) %nCh
                clear S F T P Allpwr tmp 
                tmp = squeeze(WNN_MI(SelCh(ch),:));
                [S F T P] = spectrogram(tmp',nWin,nWin-nShift,nFFT,SR);
                Allpwr = P(iFreqs,:);
                Data = 10*log10(Allpwr);
                avg_base  = mean(Data(:,iBase),2);
                navgPwr(:,:,ch) = Data-repmat(avg_base,[1 length(tFrames)]);
                for freq = 1:size(navgPwr,1)
                    basisMean = mean(navgPwr(freq,iBase,ch),2);
                    basisStd = std(navgPwr(freq,iBase,ch));
                    tmpZ = (navgPwr(freq,:,ch) - basisMean)./basisStd;
                    Te.dataP(freq,:,ch,nT) = tmpZ;
                end
            end
            topodata = squeeze(mean(mean(Te.dataP(FreqRange(1):FreqRange(2),iMove,:,nT),1),2)); % ch
           
            
        end
    
        % Neurofeedback Event
        if trigger(1,1) == 6
            disp('Neurofeedback trigger 6');
            %%
            tic
            SelChInfo = squeeze(InfoChannel(SelCh2));
            topodata2 = squeeze(topodata(SelCh2));
            
            CM = mean(abs(topodata2)); %max(abs(topodata2));  
            clear tmp idx
            [tmp idx] = sort(abs(topodata2));
            tmpM = mean(topodata2(idx(1:round(length(tmp)/2))));
            for i = 1:length(topodata2)
                if abs(topodata2(i)) > CM %*0.75
                    topodata2(i) = tmpM; %mean(topodata2);
                end
            end
            CM2 = max(abs(topodata2));    
            cmax = CM2;
            cmin = -cmax;
            scrsz =  get(0,'ScreenSize');
            f = figure('Toolbar','none','position',[scrsz],'DockControls','off','MenuBar','none','Numbertitle','off');
            topoplot_rev(topodata2,SelChInfo,'maplimits',[cmin cmax]); %,'interplimits','electrodes');
            f.Color = 'k';
            colorbarhandle = cbar(0,0,[cmin cmax]);
            dim{1} = [.33 .33 .2 .33]; 
            dim{2} = [.5  .33 .2 .33];
            dim{3} = [.42  .33 .2 .33]; 
            if Te.label(nT) == 1
                annotation('ellipse',dim{1},'Color','k','Linewidth',10,'LineStyle','--')
            elseif Te.label(nT) == 2
                annotation('ellipse',dim{2},'Color','k','Linewidth',10,'LineStyle','--')
            else
                annotation('ellipse',dim{3},'Color','k','Linewidth',10,'LineStyle','--')
            end
            drawnow
            toc
        end
    
        % Keyboard Event
        if trigger(1,1) == 7
            
            % close figure
            close all;
            nT = nT + 1
        end
        %%
        if trigger(1,1) == 8
            %%
            disp('End MI feedback experiment . . .');
            disp('Training MI . . .');
            
            % Raw EEG data saving
            
            hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat);
            total_data = ft_read_data(cfg.datafile, 'header', hdr, 'dataformat', cfg.dataformat,'chanindx', chanindx, 'checkboundary', false);
            total_event = ft_read_event(cfg.datafile, 'header', hdr, 'eventformat', cfg.dataformat);

            cfg.export.dataset    = [Dir FileName '_MIfeedback_Raw.mat']; % string with the output file name
            EventName = [Dir FileName '_MIfeedbback_event.mat'];
            cfg.export.dataformat = 'matlab'; % string describing the output file format, see FT_WRITE_DATA
            writehdr = 'Info';

            ft_write_data(cfg.export.dataset, total_data, 'dataformat', cfg.export.dataformat, 'append', true ,'event', total_event);
            save(EventName,'total_event');
            
            
            disp('after preprocessed EEG saving . . .');
            save([Dir FileName '_MIfeedback_WNN.mat'],'EEG');  % epoched raw data
            
            save([Dir 'TestResult.mat'],'Te'); % epoched data
            
            % training MI data - classification
            tic
            [acc] = Geometric_Calib(Te.data,Te.label,FileName);
            mean(acc,3)
            toc
            
            isEnd = 1;
        end
    end
    end
    
    if isEnd == 1
        
        clearvars -except Run
        system('taskkill /im biosemi2ft.exe')
        break;
    end
end % while true

