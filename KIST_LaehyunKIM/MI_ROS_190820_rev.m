clear all; 
clc


rosshutdown
rosinit('http://192.168.0.7:11311/') %ROS Network 
%%
MI_sub = rossubscriber('/interf/nav_cue', @motorimagerycueCallback);                        % (MI cue) 
state_sub = rossubscriber('/interf/robot/motion', @robotstatecueCallback);                  % (robot state)
stop_sub = rossubscriber('/move_base/result',@robotresultCallback);

global MI_cue;
global MI_cue_sec;
global MI_cue_nsec;
global state_cue;
global MI_cue_dir;
global MI_cue_dir1;
global stop_cue
scrsz =  get(0,'ScreenSize');

[pub msg] = rospublisher('/interf/cmd/intuit', 'shared_control/CmdIntuit');                     % (MI result)
[pub_dir msg_dir] = rospublisher('/interf/nav_cue', 'shared_control/NavCue');               % (MI result)
[pub_eye msg_eye] = rospublisher('/interf/cmd/assist', 'shared_control/CmdAssist');   % (eyeblink)
%%    
system('taskkill /im biosemi2ft.exe')
system('start /min biosemi2ft config.txt - -')
%%
disp('ready')
    
FileName = 'HEJ';

% SaveDirectory
Dir      = ['Data/' FileName '/'];
% EEG channel information loading for topoplot
load(['InfoChannel.mat']);

% reading audio
[Y, FS] = audioread('Tones.wav');

Initialization;
Biosemi_initialize;

if strcmp(cfg.jumptoeof, 'yes')
    hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat);
    prevSample = hdr.nSamples * hdr.nTrials;
else
    prevSample = 0;
end
disp('biosemi connection')
tri=1;
MI_cue=5;
stop_cue=0;
exe = 1; 
z = 0; 

 %%
 

while 1
         
    % determine number of samples available in buffer
    hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat);

    % see whether new samples are available
    newsamples = (hdr.nSamples*hdr.nTrials-prevSample);

    z = 1;
    if newsamples>=blocksize

        % determine the samples to process
        if strcmp(cfg.bufferdata, 'last')
            begsample  = hdr.nSamples*hdr.nTrials - blocksize + 1;
            endsample  = hdr.nSamples*hdr.nTrials;
        elseif strcmp(cfg.bufferdata, 'first') % choice
            begsample  = prevSample+1;
            endsample  = prevSample+blocksize ;
        else
            ft_error('unsupported value for cfg.bufferdata');e
        end

        % this allows overlapping data segments
        if overlap && (begsample>overlap)
            begsample = begsample - overlap;
            endsample = endsample - overlap;
        end

        % remember up to where the data was read
        prevSample  = endsample;

        
        if MI_cue==10 % 3m
            if exe==1
                disp('MI')
                obj = audioplayer(Y,FS);
                play(obj,[1 (get(obj, 'SampleRate')*0.3)]);
                exe = 99;
            end
            % read event segment from buffer for MI start
            startSample = newsamples; % begsample; 
            endSample   = startSample + SR*3 - 1; % after MI, 3s
        end
        
        %% Classification
        if stop_cue == 1  %% stop signal
            exe=0; MI_cue=5; stop_cue=0;
            if exe == 0
                disp('Processing')
                dat = ft_read_data(cfg.datafile, 'header', hdr, 'dataformat', cfg.dataformat,...
                    'begsample', startSample, 'endsample', endSample, 'chanindx', chanindx,'checkboundary', false);

                
                
                %%%%%%%%%%%%%%%%%%%%
                % data preprocessing
                %%%%%%%%%%%%%%%%%%%%
                hdr.Fs = SR;
                [temp a b] = iirfilt(dat(1:64,:),hdr.Fs,0,LPB,0, [1], 0, 0.0025, 40, 0);
                [Bandpass a b] = iirfilt(temp,hdr.Fs,HPB,0,0, [0.25], 0, 0.01, 30, 0);
                [WNN state] = mWNN(Bandpass);

             %% filter (BPF)
                WNN_MI = WNN; % ch x times (0.05 ~ 50Hz)
                [WNN_MI al bl] = iirfilt(WNN_MI,SR,0,LPB,0,[0.25],0,0.01,40,0);
                [WNN_MI ah bh] = iirfilt(WNN_MI,SR,HPB,0,0,[0.25],0,0.01,40,0);
                
             %% Extract test data
                clear MI_te ImS ImE
                ImS = 0.4; ImE = 2.4; MC = [8:19,32,43:53];
                MI_te = double(WNN_MI(MC,round(SR*ImS)+1:round(SR*ImE))); % MC x times (2.4~4.4s)
                TestingSample = cov(MI_te'); % times x MC
                load([Dir 'CalibModel.mat']);     
            
                TrainingLabel = Tr.label;
                TrainingSample = Tr.data;
                metric_mean     = {'euclid','logeuclid','ld'};
                metric_dist     = {'euclid','ld','riemann','kullback'};
                OutLabel        = fgmdm(TestingSample,TrainingSample,...
                                TrainingLabel,metric_mean{selRow},metric_dist{selCul});

                disp(['Result',' -> ', str{OutLabel}])
                ORL = {'R','L','Go'};
                figure(2)
                set(gcf,'position', [0 0  scrsz(3)/3 scrsz(4)/2]);
                tv = imread([ORL{OutLabel},'.png']);
                imagesc(tv)
                drawnow
                c_blink=[]; c_blink=clock; c_blink=c_blink(4)*60*60+c_blink(5)*60+c_blink(6);
                tri=0; % eye blink data for error detection
                exe=2;
            end
        end
      %% eye blink
        eyeblink=[]; c_blink1=[];
        if (tri~=1)

               
            % read event segment from buffer for Blink start
            startSample =  newsamples; %begsample; 
            endSample = endsample-startSample;
            eyeblink=[];
            dat_blink = ft_read_data(cfg.datafile, 'header', hdr, 'dataformat', ...
                cfg.dataformat, 'begsample', startSample, 'endsample', endsample, ...
                'chanindx', chanindx, 'checkboundary', false);
            
            % bandpass filter
            LPB=5; HPB=0.5; 
            [temp_blink a_blink b_blink] = iirfilt(dat_blink(1,:),hdr.Fs,0,LPB,0, [1], 0, 0.0025, 40, 0);
            [Bandpass_blink a_blink b_blink]=iirfilt(temp_blink,hdr.3Fs,HPB,0,0, [0.25], 0, 0.01, 30, 0);
            % wavelet transform
            CW_blink=cwt(Bandpass_blink,1:8,'bior1.3');
            c_blink1=clock; c_blink1=c_blink1(4)*60*60+c_blink1(5)*60+c_blink1(6);
         %% error detection & rotaion stop
            % If MI result is incorrect (double blink)
            for n=endSample-512:endSample-128
                if tri==0 && CW_blink(8,n-1)>-40 && CW_blink(8,n)<-40
                    eyeblink=[eyeblink n]
                    if length(eyeblink)>=2 && eyeblink(1,1)==eyeblink(1,2)
                        eyeblink(1)=[];
                    elseif length(eyeblink)==2 && abs(eyeblink(1,1)-eyeblink(1,2))>512
                        eyeblink(1)=[];
                    elseif length(eyeblink)==2 && abs(eyeblink(1,1)-eyeblink(1,2))<512 &&  eyeblink(1,1)~=eyeblink(1,2)
                        eyeblink=[];
                        close(figure(2))
                        % Redirecting Outlabel 
                        if OutLabel == 1 % OutLabel = 1(right), 2(left), 3(go)
                            OutLabel = 2;   msg_dir.Right = 0;    msg_dir.Left = 1;   msg_dir.Forward = 0;
                        elseif OutLabel == 2
                            OutLabel = 1;    msg_dir.Right = 1;    msg_dir.Left = 0;   msg_dir.Forward = 0;
                        elseif OutLabel == 3
                            OutLabel = 1;    msg_dir.Right = 1;    msg_dir.Left = 0;   msg_dir.Forward = 0;
                        end
                        msg.Dir = OutLabel;      msg.Header.Stamp.Sec = MI_cue_sec;     msg.Header.Stamp.Nsec = MI_cue_nsec;    msg_dir.Dist = 5;
                        send(pub,msg);  send(pub_dir,msg_dir);
                        f = figure(3)
                        set(gcf,'position', [0 0  scrsz(3)/3 scrsz(4)/2]);
                        v2=imread([ORL{OutLabel},'.png']); imagesc(v2); pause(1); 
                        figure(3)
                         set(gcf,'position', [0 0  scrsz(3)/3 scrsz(4)/2]);
                        v3=imread('Rotating.png'); imagesc(v3); drawnow
                        c_blink=clock; c_blink=c_blink(4)*60*60+c_blink(5)*60+c_blink(6);
                        tri=2; %change to rotation stop 
                    end
                end
            end
            
            
            
            
            
            % Rotation stop (double blink)
            for n=endSample-512:endSample-128
                if tri==2 && CW_blink(8,n-1)>-40 && CW_blink(8,n)<-40 && c_blink1-c_blink>1 % error detection
                    eyeblink=[eyeblink n]
                                
                    if length(eyeblink)>=2 && eyeblink(1,1)==eyeblink(1,2)
                        eyeblink(1)= [];
                    elseif length(eyeblink)==2 && abs(eyeblink(1,1)-eyeblink(1,2))>512
                       eyeblink(1)=[];
                    elseif length(eyeblink)==2 && abs(eyeblink(1,1)-eyeblink(1,2))<512 &&  eyeblink(1,1)~=eyeblink(1,2)
                        eyeblink=[];
                        msg_eye.Num=2; msg_dir.Right = 0;    msg_dir.Left = 0;   msg_dir.Forward = 0; msg_dir.Dist = 5;
                        send(pub_dir, msg_dir); send(pub_eye, msg_eye); % eyeblink 
                        figure(3)
                         set(gcf,'position', [0 0  scrsz(3)/3 scrsz(4)/2]);
                        v2=imread('Rotation stop.png'); imagesc(v2); pause(0.5); close(figure(3)); 
                        c_blink=clock; c_blink=c_blink(4)*60*60+c_blink(5)*60+c_blink(6);
                        exe=1; z=0; tri=1; % eye blink data 
                    end
                end
            end
            % If MI result is correct 
            if tri==0 && c_blink1-c_blink>2
                close(figure(2))
                eyeblink=[]; 
                if OutLabel==1
                    msg_dir.Right = 1;    msg_dir.Left = 0;   msg_dir.Forward = 0;
                    msg.Dir = OutLabel;      msg.Header.Stamp.Sec = MI_cue_sec;     msg.Header.Stamp.Nsec = MI_cue_nsec;    msg_dir.Dist = 5;
                    send(pub,msg);  send(pub_dir,msg_dir);
                    %fwrite(t_client, OutLabel); %Outlabel(Right=1, Left=2)
                    figure(3)
                    set(gcf,'position', [0 0  scrsz(3)/3 scrsz(4)/2]);
                    v3=imread('Rotating.png'); imagesc(v3); drawnow
                    tri=2 % Right or Left
                elseif OutLabel==2
                    msg_dir.Right = 0;    msg_dir.Left = 1;   msg_dir.Forward = 0;
                    msg.Dir = OutLabel;      msg.Header.Stamp.Sec = MI_cue_sec;     msg.Header.Stamp.Nsec = MI_cue_nsec;    msg_dir.Dist = 5;
                    send(pub,msg);  send(pub_dir,msg_dir);
                    figure(3)
                    set(gcf,'position', [0 0  scrsz(3)/3 scrsz(4)/2]);
                    v3=imread('Rotating.png'); imagesc(v3); drawnow
                    tri=2 % Right or Left
                elseif OutLabel==3
                    msg_dir.Right = 0;    msg_dir.Left = 0;   msg_dir.Forward = 1;
                    msg.Dir = OutLabel;      msg.Header.Stamp.Sec = MI_cue_sec;     msg.Header.Stamp.Nsec = MI_cue_nsec;    msg_dir.Dist = 5;
                    send(pub,msg);  send(pub_dir,msg_dir);
                    pause(2); msg_dir.Right = 0;    msg_dir.Left = 0;   msg_dir.Forward = 0; msg_dir.Dist = 5; send(pub_dir, msg_dir);
                            
                    exe=1; z = 0; tri=1; 
                   
                end
            end
        end    
    end
    drawnow
    

end
