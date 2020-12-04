function FBCSP_Online
% this code is 2 class in 3 state problem.
% 1st binary class problem in "stand ready" state (standup or donothing), 
% 2nd binary class problem in "gait ready" state (gait or sitdown).
% 3nd binary class problem in "turn ready" state (left or right). Updated 20200504
% (We should adopt 3 class problem in gait ready state)
% robot command output is commented out
% + 20190915 triple eye blink is not robust
% + 20191119 2and2class, ver2 consist of one + two binary classes
% + 20200504 2class, left/right binary classes
% one in sit MI: gait vs. donothing
% the other in stand MI: gait vs. donothing + sit vs. donothing
% in stand MI, the possible output is gait(1), donothing(0), sit(2)
% the new in stand MI: left vs. right
% 20191119 JHC & 20200227 JJH & 20200504 JHC 

clc
close all
recorderip = '127.0.0.1';
con = pnet('tcpconnect', recorderip, 51244);
stat = pnet(con,'status');
if stat > 0
    disp('<RDA connection established>');
end

%% for PRE-REQUISITE parameters 
% 1. global prerequisits
STATE = 1;
TEB = 0;
fs = 500;
data_raw = []; % RAW amplifier data
channumb = 31;
counter = 0;

% 2. MI signal processing step parameters
MainWindowSize = 1000; % in datapoint
MainWindowShift = 250; % in datapoint
onset_size = 10; % make MI buffer
drop_size = 2;
Buffer_gait = 0;
Buffer_stand = 0;
Buffer_sit = 0;
Buffer_left = 0; % Updated 20200504
Buffer_right = 0;% Updated 20200504

% 3. Design filter! JH needs five parameters with initial Buffer
% Here is the 7 bands: 7-9 10-12 13-15 16-20 21-25 26-34 Hz
% [stop_low_f, pass_low_f, pass_high_f, stop_high_f, passbandripple]
filterparameter(1,:) = [ 3     7     9     13    5  ]; % pick this for topo drawing 
filterparameter(2,:) = [ 7     10    12    15    5  ];
filterparameter(3,:) = [ 10    13    15    18    5  ];
filterparameter(4,:) = [ 12    16    20    24    5  ];
filterparameter(5,:) = [ 17    21    25    29    5  ];
filterparameter(6,:) = [ 18    26    34    42    5  ];
filterparameter(7,:) = [ 70    80    90    100   5  ]; % Updated 20200504 
filterparameter(8,:) = [ 80    90    100   110   5  ]; % Updated 20200504 
filterparameter(9,:) = [ 90    100   110   120   5  ]; % Updated 20200504 
for i = 1:size(filterparameter,1)
    iirbp = designfilt('bandpassiir', 'StopbandFrequency1', filterparameter(i,1), 'PassbandFrequency1', filterparameter(i,2), 'PassbandFrequency2', filterparameter(i,3), 'StopbandFrequency2', filterparameter(i,4), 'StopbandAttenuation1', 25, 'PassbandRipple', filterparameter(i,5), 'StopbandAttenuation2', 25, 'SampleRate', 500, 'MatchExactly', 'passband');
    eval(['[Bb' num2str(i) ', Ba' num2str(i) '] = sos2tf(iirbp.Coefficients);'])
    eval(['buffer' num2str(i) ' = zeros(size(Bb' num2str(i) ',2)-1, channumb);'])
end
band_L = size(filterparameter,1)-3; % Updated 20200504 
band_L2 = size(filterparameter,1);  % Updated 20200504 
% check visualize if needed isstable(iirbp.Coefficients); fvtool(iirbp);
disp('1/7. Filters are Ready.')
pause(1)

% 4. Load svm models and Mutual information parameters
CSP_pick = 2;
load sX_train1.mat % X_train = number of Trial X (band(8) X 4), best_features
load sX_train2.mat % X_train = number of Trial X (band(8) X 4), best_features
load sX_train3.mat % X_train = number of Trial X (band(8) X 4), best_features % Updated 20200504 
load sY_train1.mat % Y_train = band(8) X 4, label (0 or 1) no MI or MI
load sY_train2.mat % Y_train = band(8) X 4, label (0 or 1) no MI or MI
load sY_train3.mat % Y_train = band(8) X 4, label (0 or 1) no MI or MI % Updated 20200504 
load sz_W1.mat % z_W CSP
load sz_W2.mat % z_W CSP
load sz_W3.mat % z_W CSP % Updated 20200504
load sbest_rank_save1.mat % save all, and pick here.
load sbest_rank_save2.mat % save all, and pick here.
load sbest_rank_save3.mat % save all, and pick here. % Updated 20200504
% for gait vs. dnth
best_rank1 = sort(ranking_mibif1([1 2])); % pick top n features.. 
best_features1 = best_rank1; % separate to 8 band
for best_N = 1:band_L-1
    best_feature1{best_N} = best_rank1(find(best_rank1 < best_N*CSP_pick*2+1));
    best_rank1(find(best_rank1 < best_N*CSP_pick*2+1)) = [];
end; best_feature1{band_L} = best_rank1;
clear best_rank best_N best_rank_save
SVMModel1 = fitcsvm(X_train1(:,best_features1),Y_train1); % Make SVM model
% for sit vs. dnth
best_rank2 = sort(ranking_mibif2([1 2 4 5 6])); % pick top n features.. 
best_features2 = best_rank2; % separate to 8 band
for best_N = 1:band_L-1
    best_feature2{best_N} = best_rank2(find(best_rank2 < best_N*CSP_pick*2+1));
    best_rank2(find(best_rank2 < best_N*CSP_pick*2+1)) = [];
end; best_feature2{band_L} = best_rank2;
clear best_rank best_N best_rank_save
SVMModel2 = fitcsvm(X_train2(:,best_features2),Y_train2); % Make SVM model
% for left vs. right % Updated 20200504 
best_rank3 = sort(ranking_mibif3([1 2 3 4])); % pick top n features.. 
best_features3 = best_rank3; % separate to 8 band
for best_N = 1:band_L2-1 % Updated 20200504 
    best_feature3{best_N} = best_rank3(find(best_rank3 < best_N*CSP_pick*2+1));
    best_rank3(find(best_rank3 < best_N*CSP_pick*2+1)) = [];
end; best_feature3{band_L} = best_rank3;
clear best_rank best_N best_rank_save
SVMModel3 = fitcsvm(X_train3(:,best_features3),Y_train3); % Make SVM model
disp('2/7. Model is Loaded.')
pause(1)

% 5. Set TEB prerequisits
filterparameter = [ 0.001  2     15     40    13 ];
iirbp = designfilt('bandpassiir', 'StopbandFrequency1', filterparameter(1,1), 'PassbandFrequency1', filterparameter(1,2), 'PassbandFrequency2', filterparameter(1,3), 'StopbandFrequency2', filterparameter(1,4), 'StopbandAttenuation1', 25, 'PassbandRipple', filterparameter(1,5), 'StopbandAttenuation2', 25, 'SampleRate', 500, 'MatchExactly', 'passband');
[Bb_EOG, Ba_EOG] = sos2tf(iirbp.Coefficients);
TEBbuffer = zeros(size(Bb_EOG,2)-1, 1); clearvars iirbp i filterparamter
TEBWindowSize = 800;
TEBWindowShift = 200;
TEBthreshold = 3000;
global EB_time; EB_time = 0; % Updated 20200227 
warning('off')
[y,Fs] = audioread('beep.mp3'); % soundfile variation declare
beep = audioplayer(y,Fs); pause(0.1)
play(beep);
pause(1)

% 6. STATE DISPLAY FIGURE >>>> FIGURE no.1
figure('Position',[0 0 400 250]); % figure location [left bottom width height]
set(gca,'xtick',[]); set(gca,'ytick',[]);
title('CURRENT STATE'); % title
x = [-1 1 1 -1]; y = [-1 -1 1 1];
patch(x,y,'black');
text(-0.4,0,'Idle','fontsize',40,'color','w'); % mark a word
disp('3/7. State Figure is Ready.')
pause(1)

% 7. Set bluteooth device for communicate ROBOT
RoboWear10 = serial('COM3','BaudRate',115200,'DataBits',8);
fopen(RoboWear10);
disp('4/7. RoboWear10 Bluetooth connected.')
fwrite(RoboWear10,70,'uchar') % battery check
pause(3)
disp('5/7. RoboWear10 Motor on and go home position.')
fwrite(RoboWear10,68,'uchar') % motor on
pause(1)
fwrite(RoboWear10,66,'uchar') % sit down (home)
pause(6)
disp('6/7. RoboWear10 is Ready.')

% 8. Visual Feedback Image >> REPLACE unity 3D or sound feedback >>>> FIGURE no.1
load('IMAGES_R3.mat') % Updated 20200504
figure(2); clf; imshow(VS.S_sit)
disp('7/7. Feedback Images are Ready.')
pause(1)

disp('<NOW ready to run the BV Recorder>') % than run RECORDER
pause(1)

%% --- Main reading loop ---
header_size = 24;
finish = false;
while ~finish
    try
        % check for existing data in socket buffer
        tryheader = pnet(con, 'read', header_size, 'byte', 'network', 'view', 'noblock');
        while ~isempty(tryheader)
            % Read header of RDA message
            hdr = ReadHeader(con);
            % Perform some action depending of the type of the data package
            switch hdr.type
                case 1       % Start, Setup information like EEG properties
                    disp('Start');
                    % Read and display EEG properties
                    props = ReadStartMessage(con, hdr);
                    disp(props);
                    % Reset block counter to check overflows
                    lastBlock = -1;
                    % set data buffer to empty
                    data1s = [];
                    
                case 4       % 32Bit Data block
                    % button figure update
                    drawnow;
                    % Read data and markers from message
                    [datahdr, data, markers] = ReadDataMessage(con, hdr, props);
                    % check tcpip buffer overflow
                    if lastBlock ~= -1 && datahdr.block > lastBlock + 1
                        disp(['******* Overflow with ' int2str(datahdr.block - lastBlock) ' blocks ******']);
                    end
                    lastBlock = datahdr.block;
                    % print marker info to MATLAB console
                    if datahdr.markerCount > 0
                        for m = 1:datahdr.markerCount
                            disp(markers(m));
                        end
                    end

                    
                    %% Process EEG data,
                    % in this case extract last recorded second,
                    EEGData = reshape(data, props.channelCount, length(data) / props.channelCount);
                    data_raw = [data_raw EEGData]; % EEGData = 31(channel)*10(datapoint)

                    switch STATE
                        case 1 % sit
                            if counter == 0
                                figure(1); patch(x,y,'b'); text(-0.6,0,'Sit','fontsize',40,'color','w');
                                figure(2); clf; imshow(VS.S_sit)
                            end
                            counter = counter + 10/TEBWindowShift;
                            if size(data_raw,2) >= TEBWindowSize && mod(size(data_raw,2),TEBWindowShift) == 0
                                disp(['SIT state running...' num2str(counter*TEBWindowShift/fs) ' s']);
                                TEBdata = data_raw(1,end-TEBWindowSize+1:end);
                                [TEB, TEBbuffer] = findTEB(Bb_EOG, Ba_EOG, TEBdata, TEBbuffer, TEBthreshold);
                            end
                            if TEB == 3
                                play(beep);
                                STATE = 4;
                                TEB = 0;
                                counter = 0;
                            end

                        case 2 % stand
                            if counter == 0
                                figure(1); patch(x,y,'b'); text(-0.6,0,'Stand','fontsize',40,'color','w');
                                figure(2); clf; imshow(VS.S_stand)
                            end
                            counter = counter + 10/TEBWindowShift;
                            %  TEB check in STAND
                            if size(data_raw,2) >= TEBWindowSize && mod(size(data_raw,2),TEBWindowShift) == 0
                                disp(['STAND state running...' num2str(counter*TEBWindowShift/fs) ' s']);
                                TEBdata = data_raw(1,end-TEBWindowSize+1:end);
                                [TEB, TEBbuffer] = findTEB(Bb_EOG, Ba_EOG, TEBdata, TEBbuffer, TEBthreshold);
                            end
                            if TEB == 3
                                play(beep);
                                STATE = 5;
                                TEB = 0;
                                counter = 0;
                                data_raw = [];
                            elseif TEB = 5 % Updated 20200504
                                play(beep);
                                STATE = 10;
                                TEB = 0;
                                counter = 0;
                                data_raw = [];
                            end

                        case 3 % gait
                            if counter == 0
                                figure(1); patch(x,y,'r'); text(-0.6,0,'Gait','fontsize',40,'color','w');
                                figure(2); clf; imshow(VS.S_gait)
                            end
                            counter = counter + 10/TEBWindowShift;
                            %  TEB check in gait 
                            if size(data_raw,2) >= TEBWindowSize && mod(size(data_raw,2),TEBWindowShift) == 0
                                disp(['GAIT state running...' num2str(counter*TEBWindowShift/fs) ' s']);
                                TEBdata = data_raw(1,end-TEBWindowSize+1:end);
                                [TEB, TEBbuffer] = findTEB(Bb_EOG, Ba_EOG, TEBdata, TEBbuffer, TEBthreshold);
                            end
                            if TEB == 3
                                play(beep);
                                STATE = 9;
                                TEB = 0;
                                counter = 0;
                                data_raw = [];
                            end

                        case 4 % stand ready. DO MI!!
                            if counter == 0
                                figure(1); patch(x,y,'y'); text(-0.6,0,'Ready','fontsize',40,'color','w');
                                figure(2); clf; imshow(VS.S_ready)
                            end
                            counter = counter + 10/MainWindowShift;
                            %  MI in SIT 
                            if size(data_raw,2) >= MainWindowSize && mod(size(data_raw,2),MainWindowShift) == 0
                                datain = data_raw(:,end-MainWindowSize+1:end);
                                size_L = 0;
                                for band_i = 1:band_L
                                    if ~isempty(best_feature1{band_i})
                                        eval(['[data_filt_tmp, buffer' num2str(band_i) '] = filter(Bb' num2str(band_i) ', Ba' num2str(band_i) ', datain, buffer' num2str(band_i) ',2);'])
                                        data_csp(1+size_L:size_L+length(best_feature1{band_i}),:) = z_W_1(best_feature1{band_i},:)*data_filt_tmp;
                                        size_L = size_L + length(best_feature1{band_i});
                                        clear data_filt_tmp
                                    end
                                end
                                var_data_csp = var(data_csp'); % data_csp dimension: comp * time >> variance: numb. of comp
                                test_model = log10(var_data_csp/sum(var_data_csp));
                                svmclass = predict(SVMModel1,test_model); % classification
                            
                            % fill buffer [gait(1) vs. donothing(0)]
                            if svmclass == 1 % gait. onset buffer filled one by one
                                Buffer_stand = Buffer_stand+1;
                            else % donothing.
                                if Buffer_stand > 4
                                    Buffer_stand = Buffer_stand - drop_size; % onset buffer dumpted in size of three
                                else
                                    Buffer_stand = 0;
                                end
                            end
                            eval(['figure(2); clf; imshow(VS.C1_' num2str(Buffer_stand) ')'])
                            disp(['Buffer_stand: ' num2str(Buffer_stand) '/10'])
                            if Buffer_stand == onset_size
                                STATE = 6;
                                Buffer_stand = 0; % dump
                                counter = 0;
                                data_raw = [];
                            end
                            end
                            clear data_csp var_data_csp test_model svmclass


                        case 5 % gait ready. DO MI!!
                            if counter == 0
                                figure(1); patch(x,y,'y'); text(-0.6,0,'Ready','fontsize',40,'color','w');
                                figure(2); clf; imshow(VS.S_ready);
                            end
                            counter = counter + 10/MainWindowShift;
                            %  MI in STAND
                            if size(data_raw,2) >= MainWindowSize && mod(size(data_raw,2),MainWindowShift) == 0
                                datain = data_raw(:,end-MainWindowSize+1:end);
                                
                                % classifier no.1 <gait(1) vs. donothing(0)>
                                size_L = 0;
                                for band_i = 1:band_L
                                    if ~isempty(best_feature1{band_i})
                                        eval(['[data_filt_tmp, buffer' num2str(band_i) '] = filter(Bb' num2str(band_i) ', Ba' num2str(band_i) ', datain, buffer' num2str(band_i) ',2);'])
                                        data_csp(1+size_L:size_L+length(best_feature1{band_i}),:) = z_W_1(best_feature1{band_i},:)*data_filt_tmp;
                                        size_L = size_L + length(best_feature1{band_i});
                                        clear data_filt_tmp
                                    end
                                end
                                var_data_csp = var(data_csp'); % data_csp dimension: comp * time >> variance: numb. of comp
                                test_model = log10(var_data_csp/sum(var_data_csp));
                                svmclass1 = predict(SVMModel1,test_model); % classification
                                clearvars data_csp var_data_csp test_model
                            
                                % classifier no.2 <sit(2) vs. donothing(0)>
                                size_L = 0;
                                for band_i = 1:band_L
                                    if ~isempty(best_feature2{band_i})
                                        eval(['[data_filt_tmp, buffer' num2str(band_i) '] = filter(Bb' num2str(band_i) ', Ba' num2str(band_i) ', datain, buffer' num2str(band_i) ',2);'])
                                        data_csp(1+size_L:size_L+length(best_feature2{band_i}),:) = z_W_2(best_feature2{band_i},:)*data_filt_tmp;
                                        size_L = size_L + length(best_feature2{band_i});
                                        clear data_filt_tmp
                                    end
                                end
                                var_data_csp = var(data_csp'); % data_csp dimension: comp * time >> variance: numb. of comp
                                test_model = log10(var_data_csp/sum(var_data_csp));
                                svmclass2 = predict(SVMModel2,test_model); % classification
                                clearvars data_csp var_data_csp test_model
                                
                            % fill buffer (20191119 two binaris)
                            if svmclass1 == 0 && svmclass2 == 0 % empty both buffers
                                if Buffer_gait > drop_size+1
                                    Buffer_gait = Buffer_gait - drop_size; % onset buffer dumpted in size of three
                                else
                                    Buffer_gait = 0;
                                end
                                if Buffer_sit > drop_size+1
                                    Buffer_sit = Buffer_sit - drop_size; % onset buffer dumpted in size of three
                                else
                                    Buffer_sit = 0;
                                end
                                
                            elseif svmclass1 == 1 && svmclass2 == 0 % fill gait buffer one. stay the other
                                Buffer_gait = Buffer_gait+1;
                                
                            elseif svmclass1 == 0 && svmclass2 == 2 % fill sit buffer one. stay the other
                                Buffer_sit = Buffer_sit+1;
                                
                            else % svmclass1 == 1 && svmclass2 == 2 % stay!! don't fill both!
                                if Buffer_gait > 0
                                    Buffer_gait = Buffer_gait-1;
                                end
                                if Buffer_sit > 0
                                    Buffer_sit = Buffer_sit-1;
                                end
                            end
                            % it is impossible to fill both buffers at the same time. so no worries :)
                            
                            disp([svmclass1 svmclass2])
                            eval(['figure(2); clf; imshow(VS.C2_' num2str(Buffer_gait) '_' num2str(Buffer_sit) ')'])
                            
                            if Buffer_gait == onset_size
                                STATE = 8;
                                Buffer_gait = 0; Buffer_sit = 0; % dump
                                counter = 0;
                                data_raw = [];
                            end
                            
                            if Buffer_sit == onset_size
                                STATE = 7;
                                Buffer_sit = 0; Buffer_gait = 0; % dump
                                counter = 0;
                                data_raw = [];
                            end
                            end
                            clear data_csp var_data_csp test_model
                            
                        case 10 % stand ready. DO SA!! (Left vs Right) Updated 20200504
                            if counter == 0
                                figure(1); patch(x,y,'y'); text(-0.6,0,'Ready','fontsize',40,'color','w');
                                figure(2); clf; imshow(VS.S_ready)
                            end
                            counter = counter + 10/MainWindowShift;
                            %  SA in STAND Updated 20200504
                            if size(data_raw,2) >= MainWindowSize && mod(size(data_raw,2),MainWindowShift) == 0
                                datain = data_raw(:,end-MainWindowSize+1:end);
                                size_L = 0;
                                for band_i = 1:band_L2 % Updated 20200504
                                    if ~isempty(best_feature3{band_i})
                                        eval(['[data_filt_tmp, buffer' num2str(band_i) '] = filter(Bb' num2str(band_i) ', Ba' num2str(band_i) ', datain, buffer' num2str(band_i) ',2);'])
                                        data_csp(1+size_L:size_L+length(best_feature3{band_i}),:) = z_W_3(best_feature3{band_i},:)*data_filt_tmp;
                                        size_L = size_L + length(best_feature3{band_i});
                                        clear data_filt_tmp
                                    end
                                end
                                var_data_csp = var(data_csp'); % data_csp dimension: comp * time >> variance: numb. of comp
                                test_model = log10(var_data_csp/sum(var_data_csp));
                                svmclass = predict(SVMModel3,test_model); % classification % Updated 20200504
                            
                            % fill buffer [left(3) vs. right(4)]
                            if svmclass == 3 % left. onset buffer filled one by one
                                Buffer_left = Buffer_left+1;
                                if Buffer_right > 4
                                    Buffer_right = Buffer_right - drop_size; % onset buffer dumpted in size of three
                                else
                                    Buffer_right = 0;
                                end
                            else % right.
                                Buffer_right = Buffer_right+1;
                                if Buffer_left > 4
                                    Buffer_left = Buffer_left - drop_size; % onset buffer dumpted in size of three
                                else
                                    Buffer_left = 0;
                                end
                            end
                            eval(['figure(2); clf; imshow(VS.C3_' num2str(Buffer_left) '_' num2str(Buffer_right) ')'])
                            disp(['Buffer_left: ' num2str(Buffer_left) '/10'])
                            disp(['Buffer_right: ' num2str(Buffer_right) '/10'])
                            if Buffer_left == onset_size
                                STATE = 11;
                                Buffer_left = 0; % dump
                                counter = 0;
                                data_raw = [];
                            end
                            if Buffer_right == onset_size
                                STATE = 12;
                                Buffer_right = 0; % dump
                                counter = 0;
                                data_raw = [];
                            end
                            end
                            clear data_csp var_data_csp test_model svmclass

                        case 6 % [ACT] sit to stand
                            figure(1); patch(x,y,'k'); text(-0.6,0,'Stand UP','fontsize',40,'color','w');
                            figure(2); clf; imshow(VS.S_standup)
                            fwrite(RoboWear10,67,'uchar'); pause(0.5)% stand up
                            STATE = 2;
                            data_raw = [];


                        case 7 % [ACT] stand to sit
                            figure(1); patch(x,y,'k'); text(-0.6,0,'Sit Down','fontsize',40,'color','w');
                            figure(2); clf; imshow(VS.S_sitdown)
                            fwrite(RoboWear10,66,'uchar'); pause(0.5) % sit down
                            STATE = 1;
                            data_raw = [];

                        case 8 % [ACT] stand to gait
                            figure(1); patch(x,y,'k'); text(-0.6,0,'Go','fontsize',40,'color','w');
                            figure(2); clf; imshow(VS.S_gait)
                            fwrite(RoboWear10,65,'uchar'); pause(0.5) % gait                       
                            STATE = 3;
                            data_raw = [];

                        case 9 % [ACT] gait to stand
                            figure(1); patch(x,y,'k'); text(-0.6,0,'Stop','fontsize',40,'color','w');
                            figure(2); clf; imshow(VS.S_stand)
                            fwrite(RoboWear10,67,'uchar'); pause(0.5) % stop % Updated 20200504
                            STATE = 2;
                            data_raw = [];
                        case 11 % [ACT] stand to left gait % Updated 20200504
                            figure(1); patch(x,y,'k'); text(-0.6,0,'LT','fontsize',40,'color','w');
                            figure(2); clf; imshow(VS.A_LT)
                            fwrite(RoboWear10,71,'uchar'); pause(0.5) % left turn
                            STATE = 3;
                            data_raw = [];
                        case 12 % [ACT] stand to right gait % Updated 20200504
                            figure(1); patch(x,y,'k'); text(-0.6,0,'RT','fontsize',40,'color','w');
                            figure(2); clf; imshow(VS.A_RT)
                            fwrite(RoboWear10,72,'uchar'); pause(0.5) % right turn
                            STATE = 3;
                            data_raw = [];
                    end
                    
                    
                case 3       % Stop message
                    disp('BCI System Stop');
                    data = pnet(con, 'read', hdr.size - header_size);
                    finish = true;

                    pause(0.5)
                    figure(2); clf; imshow(VS.S_EStop)
                    fwrite(RoboWear10,69,'uchar') % motor off
                    pause(1)
                    fwrite(RoboWear10,70,'uchar') % battery check
                    fclose(RoboWear10) % must close bluetooth connection
                    disp('All system off. motor off. bluetooth disconnected.');

                otherwise    % ignore all unknown types, but read the package from buffer
                  data = pnet(con, 'read', hdr.size - header_size);
                  
            end
            tryheader = pnet(con, 'read', header_size, 'byte', 'network', 'view', 'noblock');
        end
    catch
        er = lasterror;
        disp(er.message);
    end
end % Main loop

% Close all open socket connections
pnet('closeall');

% Display a message
disp('EEG connection closed');

end


%% ***********************************************************************
% Read the message header
function hdr = ReadHeader(con)
% con    tcpip connection object

% define a struct for the header
hdr = struct('uid',[],'size',[],'type',[]);

% read id, size and type of the message
% swapbytes is important for correct byte order of MATLAB variables
% pnet behaves somehow strange with byte order option
hdr.uid = pnet(con,'read', 16);
hdr.size = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
hdr.type = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
end

%% ***********************************************************************
% Read the start message
function props = ReadStartMessage(con, hdr)
% con    tcpip connection object
% hdr    message header
% props  returned eeg properties

% define a struct for the EEG properties
props = struct('channelCount',[],'samplingInterval',[],'resolutions',[],'channelNames',[]);

% read EEG properties
props.channelCount = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
props.samplingInterval = swapbytes(pnet(con,'read', 1, 'double', 'network'));
props.resolutions = swapbytes(pnet(con,'read', props.channelCount, 'double', 'network'));
allChannelNames = pnet(con,'read', hdr.size - 36 - props.channelCount * 8);
props.channelNames = SplitChannelNames(allChannelNames);
end

%% ***********************************************************************
% Read a data message
function [datahdr, data, markers] = ReadDataMessage(con, hdr, props)
% con       tcpip connection object
% hdr       message header
% props     eeg properties
% datahdr   data header with information on datalength and number of markers
% data      data as one dimensional arry
% markers   markers as array of marker structs

% Define data header struct and read data header
datahdr = struct('block',[],'points',[],'markerCount',[]);

datahdr.block = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
datahdr.points = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
datahdr.markerCount = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));

% Read data in float format
data = swapbytes(pnet(con,'read', props.channelCount * datahdr.points, 'single', 'network'));

% Define markers struct and read markers
markers = struct('size',[],'position',[],'points',[],'channel',[],'type',[],'description',[]);
for m = 1:datahdr.markerCount
    marker = struct('size',[],'position',[],'points',[],'channel',[],'type',[],'description',[]);
    
    % Read integer information of markers
    marker.size = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
    marker.position = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
    marker.points = swapbytes(pnet(con,'read', 1, 'uint32', 'network'));
    marker.channel = swapbytes(pnet(con,'read', 1, 'int32', 'network'));
    
    % type and description of markers are zero-terminated char arrays
    % of unknown length
    c = pnet(con,'read', 1);
    while c ~= 0
        marker.type = [marker.type c];
        c = pnet(con,'read', 1);
    end
    
    c = pnet(con,'read', 1);
    while c ~= 0
        marker.description = [marker.description c];
        c = pnet(con,'read', 1);
    end
    
    % Add marker to array
    markers(m) = marker;
end
end

%% ***********************************************************************
% Helper function for channel name splitting, used by function
% ReadStartMessage for extraction of channel names
function channelNames = SplitChannelNames(allChannelNames)
% allChannelNames   all channel names together in an array of char
% channelNames      channel names splitted in a cell array of strings

% cell array to return
channelNames = {};

% helper for actual name in loop
name = [];

% loop over all chars in array
for i = 1:length(allChannelNames)
    if allChannelNames(i) ~= 0
        % if not a terminating zero, add char to actual name
        name = [name allChannelNames(i)];
    else
        % add name to cell array and clear helper for reading next name
        channelNames = [channelNames {name}];
        name = [];
    end
end
end

% function my_button()
% hfig = figure('Position',[700 300 200 100]);
% button1 = uicontrol('Parent', hfig,'Style','pushbutton',...
%     'Units','normalized',...
%     'Position',[0.1 0.1 0.8 0.8],...
%     'String','BCI_onoff',...
%     'Callback',@button_callback1);
% end
% 
% function button_callback1(hObject,eventdata)
% global BCI_onoff
% if BCI_onoff == 0
%     BCI_onoff=1;
% elseif BCI_onoff == 1
%     BCI_onoff=0;
% end
% end

function [TEB, TEBbuffer] = findTEB(Bb, Ba, TEBdata, TEBbuffer, TEBthreshold)  % Updated 20200227
global EB_time; % Updated 20200227
[data_TEB_filt, TEBbuffer] = filter(Bb, Ba, TEBdata, TEBbuffer, 2);
CW_Fp1 = cwt(data_TEB_filt,30,'bior1.3');
[~,locs] = findpeaks(CW_Fp1,'MinPeakHeight', TEBthreshold);
if sum(locs < 100) ~= 0
    locs(locs < 100) = [];
end
TEB = optionEB(locs); % Updated 20200227
EB_time = EB_time + 1;
end

function TEB = optionEB(locs)   % Updated 20200227
global EB_time;
peaknum = size(locs,2);
if sum (locs > 800) ~= 0
    peaknum = 0;
elseif sum(diff(locs) > 200) ~= 0   % Updated 20200809
    peaknum = 0;                    
elseif sum(diff(locs) < 50) ~= 0    % Updated 20200811
    peaknum = 0;                    
end
% TEB Detection
if peaknum >= 3 && peaknum < 5 && EB_time > 5
    TEB = 3;
    EB_time = 0;
%  QEB Detection
elseif peaknum >= 5 && EB_time > 5
    TEB = 5;
    EB_time = 0;
else
    TEB = 0;
end
% disp(EB)
end
