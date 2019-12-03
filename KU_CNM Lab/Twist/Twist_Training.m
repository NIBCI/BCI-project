%% Twist_Training.m

% initializing
clc; clear; close all;

%% Load converted data files (Training data)
dd='C:\Users\';
filelist={'1'};

frq_point=[5,8,13,15,20,25,30];
com = nchoosek(1:7,2);

for n=1:length(filelist)
    n
    for frq=1:length(com)
        frq
        [cnt, mrk, mnt]=eegfile_loadMatlab([dd filelist{n}]); % Load cnt, mrk, mnt variables to Matlab
        ival= [0 4000]; % time interval length
     
        [cnt, mrk]=proc_downsample(cnt,mrk,10); % 100Hz Downsampling
        cnt=proc_filtButter(cnt,3,[frq_point(com(frq,1)) frq_point(com(frq,2))]); % Band-pass filtering
        epo= cntToEpo(cnt, mrk, ival);
      
        epo=proc_selectChannels(epo,[8,9,10,11,13,14,15,18,19,20,21,43,44,47,48,49,50,52,53,54]); % Select 20 channels
        epo=proc_commonAverageReference(epo); % Applying Common Average Reference (CAR)
        
        %  time segment
        time_interval=[1,100; 51,150; 101,200];

        for time=1:length(time_interval)
            X=epo.x(time_interval(time,1):time_interval(time,2),:,:);
            diff_X=diff(X);
            diff2_X=diff(diff_X);
    
             fv_time=squeeze(log(var(diff2_X)));
             fv(:,:,time)=fv_time;
            
            clear X diff_X diff2_X fv_time
        end
        
        fv=permute(fv,[1 3 2]);
        fv=reshape(fv,[size(fv,1)*size(fv,2),size(fv,3)]);
        epo.x=fv;
        clear fv
        
        epoleft=proc_selectClasses(epo,'Left');
        eporight=proc_selectClasses(epo,'Right');
        clear epo
        

        left_idx=randperm(length(epoleft.y));
        right_idx=randperm(length(eporight.y));
        
        kfold=5;
        
       %% Cross-validation for performance evaluation
        % 5 fold cross validation
        for fold=1:kfold
            %fold
            left_train=left_idx;
            left_train(length(left_idx)/5*(fold-1)+1:length(left_idx)/5*fold)=[];
            left_test=left_idx(length(left_idx)/5*(fold-1)+1:length(left_idx)/5*fold);
            
            right_train=right_idx;
            right_train(length(right_idx)/5*(fold-1)+1:length(right_idx)/5*fold)=[];
            right_test=left_idx(length(right_idx)/5*(fold-1)+1:length(right_idx)/5*fold);
            
            trueYtest=cat(1,ones(length(left_idx)/5,1),2*ones(length(right_idx)/5,1));
            Ytrain=cat(1,ones(4*length(left_idx)/5,1),2*ones(4*length(right_idx)/5,1));
            
            epotrain_left=proc_selectEpochs(epoleft,left_train);
            epotrain_right=proc_selectEpochs(eporight,right_train);
            epotrain=proc_appendEpochs(epotrain_left,epotrain_right);
            epotrain.x=reshape(epotrain.x,[size(epotrain.x,1),size(epotrain.x,2)*size(epotrain.x,3)]);
            
            epotest_left=proc_selectEpochs(epoleft,left_test);
            epotest_right=proc_selectEpochs(eporight,right_test);
            epotest=proc_appendEpochs(epotest_left,epotest_right);
            epotest.x=reshape(epotest.x,[size(epotest.x,1),size(epotest.x,2)*size(epotest.x,3)]);
            
            clear epotrain_left epotrain_right epotrain_rest epotest_left epotest_right epotest_rest
            
            for k=1:length(Ytrain)
                if(Ytrain(k)==1)
                    y_train(1,k)=1;
                end
                if(Ytrain(k)==2)
                    y_train(2,k)=1;
                end
                if(Ytrain(k)==3)
                    y_train(3,k)=1;
                end
            end
            
            C= train_RLDAshrink(epotrain.x,y_train);
            train_result=C.w'*epotrain.x+C.b;
            test_result=C.w'*epotest.x+C.b;
                
             correct_cnt=0;
            for k=1:length(trueYtest)/2
                if(test_result(k)<0)
                    correct_cnt=correct_cnt+1;
                end
            end
            
            for k=length(trueYtest)/2+1:length(trueYtest)
                if(test_result(k)>0)
                    correct_cnt=correct_cnt+1;
                end
            end
 
            acc(frq,n,fold)=100*correct_cnt/length(trueYtest);
            clear train_result test_result C correct_cnt y_train trueYtest Ytrain TSM_train TSM_test rest_test rest_train move_test move_train Ytest COVtrain COVtest
            
        end
        mean_acc=mean(acc,3);
        save(['C:\Users'+string(n)+'.mat']);
        clear epoleft eporight eporest rest_idx move_idx
    end
    
end



