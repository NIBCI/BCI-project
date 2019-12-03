%%simulation

InitVer = 'AR';

%% Set file path
CurrentDir = pwd;
Folder = 'F:\BCI\실험\BCI_func_ARBCI_experiment';
File = 'F:\BCI\실험\BCI_func_ARBCI_experiment\Dat_TJ';
%% Initialization
param = Initialization_AR;

subName = File(end-1:end);
% subNum = File(end-5:end-4);

% param.SubNum = subNum;
param.SubName = subName;
param.dir = File;
    
%% Training   
param.decoder.mode = 'training';
param.NumTrTrial = 43;
% Load data
sig = []; trig = [];
for n = 1:param.NumTrTrial % data reload
    load([File,'/',param.SubName,'_Training',num2str(n)]);
    sig = cat(2,sig,sig_vec);
    if strcmp(InitVer, 'AR')
        trig = cat(2,trig,trigger_re);
    else
        trig = cat(2,trig,trigger);
    end
end



[sig_, param]            = PreProcess(sig,param);
EP                      = Epoching(sig_, trig, param); 
[~,~,NT]                = size(EP.tar);

[C, param]      = FeatureExt_basic(EP, param);


%% 
figure;
ch = 23;
for tr = 1:param.NumTrTrial;
plot(EP.tar(ch,:,tr),'k','linewidth',2);
hold on;
plot(squeeze(EP.nar(ch,:,:,tr)));
pause;
clf;
end
%% Testing

hit = 0;
for trial = 1:param.NumTeTrial
    fprintf('Test trial %d \n',trial)
    load([param.dir,'\',param.SubInitial,'_Testing',num2str(trial)]);
    
    [label, param] = P300_processing(sig_vec,trigger,param);
    
    fprintf('Selected: %d \n.\n.\n',label)
    if param.True_Tar == label
        hit = hit + 1;
    end
end

Acc = hit/param.NumTeTrial;

fprintf('Accuracy is.. %4.2f \n',Acc);