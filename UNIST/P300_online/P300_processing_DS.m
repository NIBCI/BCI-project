function [C, param]   = P300_processing_DS(sig, trig, param)
global DS
sig = sig*0.04883;
try

if isfield(param.trD, 'mdl')
    param.decoder.mode  = 'testing';
    fprintf('Testing start!..\n');
else
    fprintf('Training start!..\n');
end
[sig, param]            = PreProcess(sig,param);
EP                      = Epoching_DS(sig, trig, param); 

switch param.Stimtype
    case 'Single'
        [C, param]      = FeatureExt_basic(EP, param);      
end

% If iteration end but block not end,
% decide to stop or not
if (~param.switch_on) && isfield(param,'switch_on_iter')
   dat = reshape(param.decoder.data,param.NumStims,size(param.decoder.data,1)/param.NumStims);
   
   DS.data = dat;
   DS = getpval(DS);
   [param.DS.stop,param.DS.class] = decidestopping(DS);
end

% clearvars -except C param
catch 
    keyboard
end