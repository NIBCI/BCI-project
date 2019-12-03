function sig = ASR(sig,param)

% extrapolate last few samples of the signal
sig = [sig bsxfun(@minus,2*sig(:,end),sig(:,(end-1):-1:end-round(param.windowlen/2*param.Fs)))];
% process signal using ASR
[sig,param.state] = asr_process(sig,param.Fs,param.state,param.windowlen,param.windowlen/2,param.stepsize,param.maxdims,[],false);
% shift signal content back (to compensate for processing delay)
sig(:,1:size(param.state.carry,2)) = [];

end
 