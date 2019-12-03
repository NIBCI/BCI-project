function [C, param]   = P300_processing(sig, trig, param)
try

%  keyboard
if isfield(param.trD, 'mdl')
    param.decoder.mode  = 'testing';
    fprintf('Testing start!..\n');
else
    fprintf('Training start!..\n');
end
[sig, param]            = PreProcess(sig,param);
EP                      = Epoching(sig, trig, param); 

switch param.Stimtype
    case 'Single'
        [C, param]      = FeatureExt_basic(EP, param);
    case 'RC'
        [Features, Label, param]= FeatureExt_RC(EP, param);        
end
% clearvars -except C param
catch 
    keyboard
end