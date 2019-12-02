function [acc] = Geometric_Calib(data,label,FileName)

    Dir      = ['Data/' FileName '/'];
    
    p = 0.1;
    metric_mean     = {'euclid','logeuclid'}; % 'euclid','logeuclid',,'ld'
    metric_dist     = {'euclid','logeuclid','riemann'}; % 'euclid','ld'

    trials = length(label);
    disp('classification')
    %%
    clear Ytest tmp_acc
    
    for h = 1:10
        h
        clear Train Test TrainingSample TrainingLabel TestingSample ...
            TestingLabel Outlabel2 DM inij TrainingSampleij TraingLabelij OutLabel
        % delete the empty power data
        clear testT0
        testT0 = squeeze(mean(mean(data,1),2));
        data(:,:,testT0==0) = [];
        label(testT0==0) = [];
        % delete the empty label
        clear labelL0
        labelL0 = (label == 0);
        label(labelL0) = [];
        data(:,:,labelL0) = [];
        
        [Train,Test] = crossvalind('HoldOut',label,p);
        
        TrainingSample = data(:,:,Train); 
        TrainingLabel = label(1,Train);
        TestingSample = data(:,:,Test);
        TestingLabel = label(1,Test);
                
        idx                   = length(TestingLabel);
         
       
            for i = 1:length(metric_mean)
                for j = 1:length(metric_dist)
                    Ytest{i,j}    = fgmdm(TestingSample,TrainingSample,...
                                    TrainingLabel,metric_mean{i},metric_dist{j});
                    tmp_acc(i,j,h) = 100*sum(Ytest{i,j}==TestingLabel)/length(TestingLabel);
                end
            end
        acc = tmp_acc;
    end

    clear selR selCul selRow
    [~, selR] = max(acc);
    [~, selCul] = max(max(acc));
    selRow = selR(selCul);
    
    clear Tr
    Tr.data = data; Tr.label = label;
    save([Dir 'CalibModel.mat'], 'Tr','selRow','selCul');