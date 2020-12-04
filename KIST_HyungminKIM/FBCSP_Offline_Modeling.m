
% the version 3 is consist of the one + two + one binary classes
% one in sit MI: gait vs. donothing
% the two in stand MI: gait vs. donothing + sit vs. donothing
% in stand MI, the possible output is gait(1), donothing(0), sit(2)
% the one in stand MI: Left vs Right (Updated 20201204)
% in new binary classes, the possible output is left(3), right(4) (Updated 20201204)

clear; close all; clc
mainbuffersize = 1000;
channumb = 31;
fs = 500; % data sampling rate

%% load all data, preprocessing, and cut into trials. from CJ format (E-prime protocol)

load Modelingdata_sample.mat % Gait, Dnth, Sit
EEGData_raw1 = EEGData_raw;
MarkerData1 = MarkerData;
load Modelingdata_sample2.mat % Left, Right % Updated 20201204
EEGData_raw2 = EEGData_raw;
MarkerData2 = MarkerData;
clearvars EEGData_raw MarkerData EMGData_raw

% extract L R.. from bro.KTK_BBCItoolbox format
% EEGData_raw_gait = permute(epo.x(1:2000,:,find(epo.y(1,:))),[2 1 3]);
% EEGData_raw_dnth = permute(epo.x(1:2000,:,find(epo.y(2,:))),[2 1 3]);

% cut with endpoint from JC. Brainvision format % Updated 20201204
EEGData_raw_temp = fliplr(EEGData_raw1);
nonzerotemp = find(EEGData_raw_temp(1,:) ~=0);
endpoint = size(EEGData_raw1,2) - nonzerotemp(1) + 1;
clearvars nonzerotemp EEGData_raw_temp
EEGData_raw_GS = EEGData_raw1(:,1:endpoint);
MarkerData_new_GS = MarkerData1(:,1:endpoint);
clearvars EEGData_raw1 MarkerData1 EMGData_raw endpoint

% cut with endpoint from JC. Brainvision format % Updated 20201204
EEGData_raw_temp = fliplr(EEGData_raw2);
nonzerotemp = find(EEGData_raw_temp(1,:) ~=0);
endpoint = size(EEGData_raw2,2) - nonzerotemp(1) + 1;
clearvars nonzerotemp EEGData_raw_temp
EEGData_raw_LR = EEGData_raw2(:,1:endpoint);
MarkerData_new_LR = MarkerData2(:,1:endpoint);
clearvars EEGData_raw2 MarkerData2 EMGData_raw endpoint

% Design filter! JH needs five parameters and initial Buffer 
% Here is the 6 bands: 7-9 10-12 13-15 16-20 21-25 26-34 Hz
% Here is the added 3 bands (for SA): 80-90 90-100 100-110 Hz % Updated 20201204
% [stop_low_f, pass_low_f, pass_high_f, stop_high_f, passbandripple]
% for FBCSP % Updated 20201204
filterparameter1(1,:) =  [ 3     7     9     13    5 ]; % ERD1
filterparameter1(2,:) =  [ 7     10    12    15    5 ]; % ERD2
filterparameter1(3,:) =  [ 10    13    15    18    5 ]; % ERD3
filterparameter1(4,:) =  [ 12    16    20    24    5 ]; % ERD4
filterparameter1(5,:) =  [ 17    21    25    29    5 ]; % ERD5
filterparameter1(6,:) =  [ 18    26    34    42    5 ]; % ERD6
% for SSSEP
filterparameter2(1,:) =  [ 70    80    90   100   5 ]; % SSSEP1 % Updated 20201204
filterparameter2(2,:) =  [ 80    90   100   110   5 ]; % SSSEP2 % Updated 20201204
filterparameter2(3,:) = [ 90   100   110   120   5 ]; % SSSEP3  % Updated 20201204
% for Eyeblink
filterparameter0(1,:) = [ 0.01  2     5     10    10 ]; % EOG

% for Gait, Sit, Donothing (continuous)
for i = 1:size(filterparameter1,1)
    iirbp = designfilt('bandpassiir', 'StopbandFrequency1', filterparameter1(i,1), 'PassbandFrequency1', filterparameter1(i,2), 'PassbandFrequency2', filterparameter1(i,3), 'StopbandFrequency2', filterparameter1(i,4), 'StopbandAttenuation1', 25, 'PassbandRipple', filterparameter1(i,5), 'StopbandAttenuation2', 25, 'SampleRate', 500, 'MatchExactly', 'passband');
    eval(['[Bb' num2str(i) ', Ba' num2str(i) '] = sos2tf(iirbp.Coefficients);'])
    eval(['EEGData_bpf_GS(:,:,i) = filter(Bb' num2str(i) ',Ba' num2str(i) ',EEGData_raw_GS,[],2);'])
end
clearvars iirbp i
clearvars iirbp indata outdata trial
clearvars Ba1 Bb1 Ba2 Bb2 Ba3 Bb3 Ba4 Bb4 Ba5 Bb5 Ba6 Bb6 
clearvars EEGData_raw_GS

% for Left, Right [low band] (continuous) % Updated 20201204
for i = 1:size(filterparameter1,1)
    iirbp = designfilt('bandpassiir', 'StopbandFrequency1', filterparameter1(i,1), 'PassbandFrequency1', filterparameter1(i,2), 'PassbandFrequency2', filterparameter1(i,3), 'StopbandFrequency2', filterparameter1(i,4), 'StopbandAttenuation1', 25, 'PassbandRipple', filterparameter1(i,5), 'StopbandAttenuation2', 25, 'SampleRate', 500, 'MatchExactly', 'passband');
    eval(['[Bb' num2str(i) ', Ba' num2str(i) '] = sos2tf(iirbp.Coefficients);'])
    eval(['EEGData_bpf_LR1(:,:,i) = filter(Bb' num2str(i) ',Ba' num2str(i) ',EEGData_raw_LR,[],2);'])
end
clearvars iirbp i
clearvars iirbp indata outdata trial
clearvars Ba1 Bb1 Ba2 Bb2 Ba3 Bb3 Ba4 Bb4 Ba5 Bb5 Ba6 Bb6 

% for Left, Right [high band] (continuous) % Updated 20201204
for i = 1:size(filterparameter2,1)
    iirbp = designfilt('bandpassiir', 'StopbandFrequency1', filterparameter2(i,1), 'PassbandFrequency1', filterparameter2(i,2), 'PassbandFrequency2', filterparameter2(i,3), 'StopbandFrequency2', filterparameter2(i,4), 'StopbandAttenuation1', 25, 'PassbandRipple', filterparameter2(i,5), 'StopbandAttenuation2', 25, 'SampleRate', 500, 'MatchExactly', 'passband');
    eval(['[Bb' num2str(i) ', Ba' num2str(i) '] = sos2tf(iirbp.Coefficients);'])
    eval(['EEGData_bpf_LR2(:,:,i) = filter(Bb' num2str(i) ',Ba' num2str(i) ',EEGData_raw_LR,[],2);'])
end
clearvars iirbp i
clearvars iirbp indata outdata trial
clearvars Ba1 Bb1 Ba2 Bb2 Ba3 Bb3
clearvars EEGData_raw_LR

% combine LR1 and LR2 % Updated 20201204
EEGData_bpf_LR = cat(3,EEGData_bpf_LR1, EEGData_bpf_LR2);
clearvars EEGData_bpf_LR1 EEGData_bpf_LR2

% cut trigger! all data
counter1 = 1; counter2 = 1; counter3 = 1 ;
for i = 1:length(MarkerData_new)-1
    if MarkerData_new(i+1)-MarkerData_new(i) == 1 % Gait
        trigger_C1(counter1) = i;
        counter1 = counter1 + 1;
    elseif MarkerData_new(i+1)-MarkerData_new(i) == 2 % Donothing
        trigger_C2(counter2) = i;
        counter2 = counter2 + 1;
    elseif MarkerData_new(i+1)-MarkerData_new(i) == 3 % Sit
        trigger_C3(counter3) = i;
        counter3 = counter3 + 1;
    end
end
clearvars counter1 counter2 counter3 i

% cut gait execution 5 seconds for MI % Updated 20201204
for trial = 1:length(trigger_C1)
    EEGData_bpf_Class1_trial(:,:,trial,:) = EEGData_bpf(:,trigger_C1(trial)+501:trigger_C1(trial)+3000,:);
end
for trial = 1:length(trigger_C2)
    EEGData_bpf_Class2_trial(:,:,trial,:) = EEGData_bpf(:,trigger_C2(trial)+501:trigger_C2(trial)+3000,:);
end
for trial = 1:length(trigger_C3)
    EEGData_bpf_Class3_trial(:,:,trial,:) = EEGData_bpf(:,trigger_C3(trial)+501:trigger_C3(trial)+3000,:);
end
% clearvars trial EEGData_raw_gait1 EMGData_raw_gait1 EEGData_raw_gait2 EMGData_raw_gait2 EEGData_raw_gait3 EMGData_raw_gait3

% find Left, Right trigger(cue) % Updated 20201204
counter4 = 1; counter5 = 1;
for i = 1:length(MarkerData_new_LR)-1
    if MarkerData_new_LR(i+1)-MarkerData_new_LR(i) == 4 % Left
        trigger_C4(counter4) = i;
        counter4 = counter4 + 1;
    elseif MarkerData_new_LR(i+1)-MarkerData_new_LR(i) == 5 % Right
        trigger_C5(counter5) = i;
        counter5 = counter5 + 1;
    end
end
clearvars counter4 counter5 i

% cut L/R trigger(cue) [low band]  % Updated 20201204
for trial = 1:length(trigger_C4)
    EEGData_bpf_Class4_trial(:,:,trial,:) = EEGData_bpf_LR(:,trigger_C4(trial)+501:trigger_C4(trial)+3000,:);
end
for trial = 1:length(trigger_C5)
    EEGData_bpf_Class5_trial(:,:,trial,:) = EEGData_bpf_LR(:,trigger_C5(trial)+501:trigger_C5(trial)+3000,:);
end
clearvars trial 
clearvars trigger_C4 trigger_C5
clearvars EEGData_bpf_LR MarkerData_new_LR

% Updated 20201204
MI_EEGData_raw_gait_m = reshape(EEGData_bpf_Class1_trial,[channumb,mainbuffersize,(size(EEGData_bpf_Class1_trial,2)/mainbuffersize)*size(EEGData_bpf_Class1_trial,3),size(filterparameter1,1)]);
MI_EEGData_raw_dnth_m = reshape(EEGData_bpf_Class2_trial,[channumb,mainbuffersize,(size(EEGData_bpf_Class2_trial,2)/mainbuffersize)*size(EEGData_bpf_Class2_trial,3),size(filterparameter1,1)]);
MI_EEGData_raw_sit_m = reshape(EEGData_bpf_Class3_trial,[channumb,mainbuffersize,(size(EEGData_bpf_Class3_trial,2)/mainbuffersize)*size(EEGData_bpf_Class3_trial,3),size(filterparameter1,1)]);
MI_EEGData_raw_left_m = reshape(EEGData_bpf_Class4_trial,[channumb,mainbuffersize,(size(EEGData_bpf_Class4_trial,2)/mainbuffersize)*size(EEGData_bpf_Class4_trial,3),size(filterparameter1,1)+size(filterparameter2,1)]);
MI_EEGData_raw_right_m = reshape(EEGData_bpf_Class5_trial,[channumb,mainbuffersize,(size(EEGData_bpf_Class5_trial,2)/mainbuffersize)*size(EEGData_bpf_Class5_trial,3),size(filterparameter1,1)+size(filterparameter2,1)]);
% MI_EEGData_R_m = EEGData_bpf_R_trial;
clearvars EEGData_bpf_Gait_trial EEGData_bpf_Dnth_trial EEGData_bpf_Sit_trial EEGData_bpf_L_trial EEGData_bpf_R_trial

%% Select data and Feature extract.. 
% on sight data: MI_EEGData_bpf_go and _stop
% data dimension: channel * time * trial
% clearvars data1 data2 data1_fb data2_fb data1_test data1_train data2_test data2_train data1_trials data2_trials

dataA = MI_EEGData_raw_gait_m;
dataB = MI_EEGData_raw_dnth_m;
dataC = MI_EEGData_raw_sit_m;
dataD = MI_EEGData_raw_left_m; % Updated 20201204
dataE = MI_EEGData_raw_right_m; % Updated 20201204
% SS_SEP = EEGData_raw(32:33,data_st:end)';

% channel selection
selected_ch = 1:channumb; % all channels

clearvars a b band_ed band_i band_st HF LF order
clearvars trial data1 data2 data0 data01 data02
clearvars selected_ch

dataA_fb = permute(dataA,[2 1 3 4]); dataB_fb = permute(dataB,[2 1 3 4]); dataC_fb = permute(dataC,[2 1 3 4]); dataD_fb = permute(dataD,[2 1 3 4]); dataE_fb = permute(dataE,[2 1 3 4]); % Updated 20201204
clearvars dataA dataB

%% CSP and Mutual information based Feature extraction to SVM classifier, through Bootstrap Resampling Method
clearvars class_A_test_CSP class_A_test_CSPfeat_temp class_A_test_Normvar class_A_train_CSP class_A_train_CSPfeat_temp class_A_train_Normvar class_A_var_temp1
clearvars class_B_test_CSP class_B_test_CSPfeat_temp class_B_test_Normvar class_B_train_CSP class_B_train_CSPfeat_temp class_B_train_Normvar class_B_var_temp1
clearvars accu_svm

dataA_train = dataA_fb(:,:,:,:); % ALL IN!!
dataB_train = dataB_fb(:,:,:,:); % ALL IN!!
dataC_train = dataC_fb(:,:,:,:); % ALL IN!!
dataD_train = dataD_fb(:,:,:,:); % ALL IN!! % Updated 20201204
dataE_train = dataE_fb(:,:,:,:); % ALL IN!! % Updated 20201204

% make CSP matrix for each of 8 subbands
csp_pick = 2; % Selected first & last CSP component(CSP filtered_variance maximized signal)
for band_i = 1:size(filterparameter,1)
    % data dimension: CSPcomponent * time * trial * band
    % CSP data
    csp_input_A = dataA_train(:,:,:,band_i); % gait
    csp_input_B = dataB_train(:,:,:,band_i); % donth
    csp_input_C = dataC_train(:,:,:,band_i); % sit

    % make CSP matrix
    W1 = CSP_dimSCT(csp_input_A,csp_input_B); % gait vs. dnth
    W2 = CSP_dimSCT(csp_input_C,csp_input_B); % sit vs. dnth
    Win1 = inv(W1);
    Win2 = inv(W2);

    % TRAIN for gait vs. dnth
    for trial = 1:size(dataA_train,3)
        class_A_train_CSP(:,:,trial,band_i) = W1*dataA_train(:,:,trial,band_i)'; %time * chan * trial * band
        class_A_train_CSPfeat_temp1 = class_A_train_CSP(1:csp_pick,:,trial,band_i); %first2 %comp * time * trial * band
        class_A_train_CSPfeat_temp2 = class_A_train_CSP(end-csp_pick+1:end,:,trial,band_i); %last2 %comp * time * trial * band
        class_A_train_CSPfeat = [class_A_train_CSPfeat_temp1; class_A_train_CSPfeat_temp2];
        class_A_train_var_temp = var(class_A_train_CSPfeat');
        % Log normalizing CSPed component's variance
        class_A_train_Normvar_trial(trial,:) = log10(class_A_train_var_temp/sum(class_A_train_var_temp)); % == Fp_A in Dr.Cha's
    end
    for trial = 1:size(dataB_train,3)
        class_B_train_CSP1(:,:,trial,band_i) = W1*dataB_train(:,:,trial,band_i)';
        class_B_train_CSPfeat1_temp1 = class_B_train_CSP1(1:csp_pick,:,trial,band_i);
        class_B_train_CSPfeat1_temp2 = class_B_train_CSP1(end-csp_pick+1:end,:,trial,band_i);
        class_B_train_CSPfeat1 = [class_B_train_CSPfeat1_temp1; class_B_train_CSPfeat1_temp2];
        class_B_train_var_temp1 = var(class_B_train_CSPfeat1');
        % Log normalizing CSPed component's variance
        class_B_train_Normvar_trial1(trial,:) = log10(class_B_train_var_temp1/sum(class_B_train_var_temp1)); % == Fp_B in Dr.Cha's
    end
    % make feature matrix for train
    class_A_train_Normvar(:,(band_i-1)*(csp_pick*2)+1:(band_i)*(csp_pick*2)) = class_A_train_Normvar_trial;
    class_B_train_Normvar1(:,(band_i-1)*(csp_pick*2)+1:(band_i)*(csp_pick*2)) = class_B_train_Normvar_trial1;
    
    z_W_1(1+(band_i-1)*csp_pick*2:(band_i)*csp_pick*2,:) = W1([1:csp_pick channumb-csp_pick+1:channumb],:); % first and last two.. ckecked!

    % TRAIN for sit vs. dnth
    for trial = 1:size(dataC_train,3)
        class_C_train_CSP(:,:,trial,band_i) = W2*dataC_train(:,:,trial,band_i)'; %time * chan * trial * band
        class_C_train_CSPfeat_temp1 = class_C_train_CSP(1:csp_pick,:,trial,band_i); %first2 %comp * time * trial * band
        class_C_train_CSPfeat_temp2 = class_C_train_CSP(end-csp_pick+1:end,:,trial,band_i); %last2 %comp * time * trial * band
        class_C_train_CSPfeat = [class_C_train_CSPfeat_temp1; class_C_train_CSPfeat_temp2];
        class_C_train_var_temp = var(class_C_train_CSPfeat');
        % Log normalizing CSPed component's variance
        class_C_train_Normvar_trial(trial,:) = log10(class_C_train_var_temp/sum(class_C_train_var_temp)); % == Fp_A in Dr.Cha's
    end
    for trial = 1:size(dataB_train,3)
        class_B_train_CSP2(:,:,trial,band_i) = W2*dataB_train(:,:,trial,band_i)';
        class_B_train_CSPfeat2_temp1 = class_B_train_CSP2(1:csp_pick,:,trial,band_i);
        class_B_train_CSPfeat2_temp2 = class_B_train_CSP2(end-csp_pick+1:end,:,trial,band_i);
        class_B_train_CSPfeat2 = [class_B_train_CSPfeat2_temp1; class_B_train_CSPfeat2_temp2];
        class_B_train_var_temp2 = var(class_B_train_CSPfeat2');
        % Log normalizing CSPed component's variance
        class_B_train_Normvar_trial2(trial,:) = log10(class_B_train_var_temp2/sum(class_B_train_var_temp2)); % == Fp_B in Dr.Cha's
    end
    % make feature matrix for train
    class_C_train_Normvar(:,(band_i-1)*(csp_pick*2)+1:(band_i)*(csp_pick*2)) = class_C_train_Normvar_trial;
    class_B_train_Normvar2(:,(band_i-1)*(csp_pick*2)+1:(band_i)*(csp_pick*2)) = class_B_train_Normvar_trial2;
    
    z_W_2(1+(band_i-1)*csp_pick*2:(band_i)*csp_pick*2,:) = W2([1:csp_pick channumb-csp_pick+1:channumb],:); % first and last two.. ckecked!

    clearvars class_A_train_CSP class_A_train_CSPfeat_temp1 class_A_train_CSPfeat_temp2 class_A_train_CSPfeat class_A_train_var_temp class_A_train_Normvar_trial
    clearvars class_C_train_CSP class_C_train_CSPfeat_temp1 class_C_train_CSPfeat_temp2 class_C_train_CSPfeat class_C_train_var_temp class_C_train_Normvar_trial
    clearvars class_B_train_CSP1 class_B_train_CSPfeat1_temp1 class_B_train_CSPfeat1_temp2 class_B_train_CSPfeat1 class_B_train_var_temp1 class_B_train_Normvar_trial1
    clearvars class_B_train_CSP2 class_B_train_CSPfeat2_temp1 class_B_train_CSPfeat2_temp2 class_B_train_CSPfeat2 class_B_train_var_temp2 class_B_train_Normvar_trial2
    clearvars csp_input_A csp_input_B csp_input_C
    clearvars W1 Win1 W2 Win2

end
% dump
clearvars test_A train_A test_B train_B test_C train_C

% For Left/Right Classification % Updated 20201204
for band_i2 = 1:(size(filterparameter1,1)+size(filterparameter2,1))
    % data dimension: CSPcomponent * time * trial * band
    % CSP data % Updated 2020120
    csp_input_D = dataD_train(:,:,:,band_i2); % left
    csp_input_E = datae_train(:,:,:,band_i2); % right

    % make CSP matrix % Updated 20201204
    W3 = CSP_dimSCT(csp_input_D,csp_input_E); % left vs. right
    Win3 = inv(W3);

    % TRAIN for left vs. right % Updated 20201204
    for trial = 1:size(dataD_train,3)
        class_D_train_CSP(:,:,trial,band_i2) = W3*dataD_train(:,:,trial,band_i2)'; %time * chan * trial * band
        class_D_train_CSPfeat_temp1 = class_D_train_CSP(1:csp_pick,:,trial,band_i2); %first2 %comp * time * trial * band
        class_D_train_CSPfeat_temp2 = class_D_train_CSP(end-csp_pick+1:end,:,trial,band_i2); %last2 %comp * time * trial * band
        class_D_train_CSPfeat = [class_D_train_CSPfeat_temp1; class_D_train_CSPfeat_temp2];
        class_D_train_var_temp = var(class_D_train_CSPfeat');
        % Log normalizing CSPed component's variance
        class_D_train_Normvar_trial(trial,:) = log10(class_D_train_var_temp/sum(class_D_train_var_temp)); % == Fp_A in Dr.Cha's
    end
    for trial = 1:size(dataE_train,3)
        class_E_train_CSP(:,:,trial,band_i2) = W3*dataE_train(:,:,trial,band_i2)';
        class_E_train_CSPfeat_temp1 = class_E_train_CSP(1:csp_pick,:,trial,band_i2);
        class_E_train_CSPfeat_temp2 = class_E_train_CSP(end-csp_pick+1:end,:,trial,band_i2);
        class_E_train_CSPfeat = [class_E_train_CSPfeat_temp1; class_E_train_CSPfeat_temp2];
        class_E_train_var_temp = var(class_E_train_CSPfeat');
        % Log normalizing CSPed component's variance % Updated 20201204
        class_E_train_Normvar_trial(trial,:) = log10(class_E_train_var_temp/sum(class_E_train_var_temp)); % == Fp_B in Dr.Cha's
    end
    % make feature matrix for train % Updated 20201204
    class_D_train_Normvar(:,(band_i2-1)*(csp_pick*2)+1:(band_i2)*(csp_pick*2)) = class_D_train_Normvar_trial;
    class_E_train_Normvar(:,(band_i2-1)*(csp_pick*2)+1:(band_i2)*(csp_pick*2)) = class_E_train_Normvar_trial;
    
    z_W_3(1+(band_i2-1)*csp_pick*2:(band_i2)*csp_pick*2,:) = W3([1:csp_pick channumb-csp_pick+1:channumb],:); % first and last two.. ckecked!

    clearvars class_D_train_CSP class_D_train_CSPfeat_temp1 class_D_train_CSPfeat_temp2 class_D_train_CSPfeat class_D_train_var_temp class_D_train_Normvar_trial
    clearvars class_E_train_CSP class_E_train_CSPfeat_temp1 class_E_train_CSPfeat_temp2 class_E_train_CSPfeat class_E_train_var_temp class_E_train_Normvar_trial
    clearvars csp_input_D csp_input_E
    clearvars W3 Win3

end
% dump
clearvars test_A train_A test_B train_B test_C train_C

% X is feature
X_train1 = [class_A_train_Normvar; class_B_train_Normvar1];
X_train2 = [class_C_train_Normvar; class_B_train_Normvar2];
X_train3 = [class_D_train_Normvar; class_E_train_Normvar]; % Updated 20201204
% Y is label (A:1 or B:0 or C:2)
Y_train1 = [ones(size(class_A_train_Normvar,1),1); zeros(size(class_B_train_Normvar1,1),1)];
Y_train2 = [ones(size(class_C_train_Normvar,1),1)*2; zeros(size(class_B_train_Normvar2,1),1)];
Y_train3 = [ones(size(class_D_train_Normvar,1),1)*3; ones(size(class_E_train_Normvar,1),1)*4]; % Updated 20201204

%% Mutual information > best features
% mutual information based best individual feature (feature rank)
% X_train Dimension: (trial length of Class A + Class B) * ((first 2 + last 2) * 8 band) = 60 * 32
numF = 24;
numF2 = 36;% Updated 20201204 
rank_score1 = zeros(size(X_train1,2),1);
% selection_method='mutinffs';
rank1 = [];
for ii = 1:size(X_train1,2)
    rank1 = [rank1; -muteinf_2class1(X_train1(:,ii),Y_train1) ii];
end
rank1 = sortrows(rank1,1);
ranking_mibif1 = rank1(1:numF, 2);
rank_score1(ranking_mibif1) = rank_score1(ranking_mibif1) + 1;
clear rank1
% on-line system will use this (traing model)
best_rank_save1 =[]; % IDONNO
best_rank1 = find(rank_score1 == max(rank_score1));
best_rank_save1 = [best_rank_save1 best_rank1];
clear rank_score1

rank_score2 = zeros(size(X_train2,2),1);
% selection_method='mutinffs';
rank2 = [];
for ii = 1:size(X_train2,2)
    rank2 = [rank2; -muteinf_2class2(X_train2(:,ii),Y_train2) ii];
end
rank2 = sortrows(rank2,1);
ranking_mibif2 = rank2(1:numF, 2);
rank_score2(ranking_mibif2) = rank_score2(ranking_mibif2) + 1;
clear rank2
% on-line system will use this (traing model)
best_rank_save2 =[]; % IDONNO
best_rank2 = find(rank_score2 == max(rank_score2));
best_rank_save2 = [best_rank_save2 best_rank2];
clear rank_score2
% Updated 20201204 
rank_score3 = zeros(size(X_train3,2),1);
% selection_method='mutinffs'; % Updated 20201204 
rank2 = [];
for ii = 1:size(X_train3,2)
    rank3 = [rank3; -muteinf_2class3(X_train3(:,ii),Y_train3) ii];
end
rank3 = sortrows(rank3,1);
ranking_mibif3 = rank3(1:numF2, 2);
rank_score3(ranking_mibif3) = rank_score3(ranking_mibif3) + 1;
clear rank3
% on-line system will use this (traing model) % Updated 20201204
best_rank_save3 =[]; % IDONNO 
best_rank3 = find(rank_score3 == max(rank_score3));
best_rank_save3 = [best_rank_save3 best_rank3];
clear rank_score3

%% classification
% Use a linear support vector machine classifier >> OLD
% svmStruct = svmtrain(X_train(:,best_rank),Y_train,'showplot',false);
% svmclass = svmclassify(svmStruct,X_train(:,best_rank));

% NEW SVM
SVMModel1 = fitcsvm(X_train1(:,ranking_mibif1),Y_train1);
SVMModel2 = fitcsvm(X_train2(:,ranking_mibif2),Y_train2);
SVMModel3 = fitcsvm(X_train3(:,ranking_mibif3),Y_train3); % Updated 20201204 
% SVMModel = fitcsvm(X_train,Y_train);
% svmclass = predict(SVMModel,X_train);

%% plot hyperplane and save variables
figure;
for feati = 1:numF
    subplot(4,6,feati); gscatter(X_train1(:,ranking_mibif1(feati)),Y_train1); ylim([-1 2])
    title(feati);
end
figure;
for feati = 1:numF
    subplot(4,6,feati); gscatter(X_train2(:,ranking_mibif2(feati)),Y_train2); ylim([-1 3])
    title(feati);
end
for feati = 1:numF2 % Updated 20201204 
    subplot(4,6,feati); gscatter(X_train3(:,ranking_mibif3(feati)),Y_train3); ylim([-1 3])
    title(feati);
end
% sv = SVMModel.SupportVectors;
% plot(sv(:,1),sv(:,2),'ko','MarkerSize',10); 

save('sX_train1.mat','X_train1')
save('sX_train2.mat','X_train2')
save('sX_train3.mat','X_train3')% Updated 20201204 
save('sY_train1.mat','Y_train1')
save('sY_train2.mat','Y_train2')
save('sY_train3.mat','Y_train3')% Updated 20201204 
save('sbest_rank_save1.mat','best_rank_save1', 'ranking_mibif1')
save('sbest_rank_save2.mat','best_rank_save2', 'ranking_mibif2')
save('sbest_rank_save3.mat','best_rank_save3', 'ranking_mibif3') % Updated 20201204 
save('sz_W1.mat','z_W_1')
save('sz_W2.mat','z_W_2')
save('sz_W3.mat','z_W_3') % Updated 20201204 
