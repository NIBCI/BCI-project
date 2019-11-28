function [output, S] = EMSI_S(Stim_freq, Data, fs, Nh, sub_hf, L)
% Multivariate synchronization index; EEG & reference 간의 correlation 을 계산하는 대신(CCA),
% S-estimator 를 계산하여 EEG 데이터와 최대의 synchronization 을 보이는 reference frequency 를 
% 분류 결과로서 출력하는 알고리즘
% 
% made by Hodam Kim, Computational Neuroengineering (CoNE) Laboratory, Hanyang University, South Korea
% rhg910907@hanyang.ac.kr 
%
% ===========================================================================
%
% ==== Input Arguments ====
%  - Stim_freq : the frequencies (Hz) used in the experiment
%  - Data : n (channel) x t (time) raw data to analyze
%  - fs : sampling rate
%  - Nh : number of harmonics. if it's not defined, 5 harmonic components are used (defualt).
%  - sub_hf : sub-harmonics 를 사용하고 싶은 경우, 1 입력 (default: 0)
%  - L : window size of the data to be analyzed in seconds. If it's not defined, the ratio of length of 'Data' to 'fs' is the default.
%
% ==== Output Arguments ====
%  - output : classification result as an index for 'Stim_freq'
%
% Reference : Zhang, Yangsong, et al. "Multivariate synchronization index for frequency recognition of SSVEP-based brain?computer interface." Journal of neuroscience methods 221 (2014): 32-40.

if nargin == 3 || nargin == 6
elseif nargin > 6
    error('At most 6 input arguments are acceptable');
elseif nargin < 3
    error('At least 3 input arguments are needed.');
end

if nargin == 3
    Nh = 5;
    sub_hf = false;
    L = size(Data, 2)/fs;
elseif nargin == 4
    sub_hf = false;
    L = size(Data, 2)/fs;
elseif nargin == 5
    L = size(Data, 2)/fs;
end

Ref_time = pi * Stim_freq' * linspace(0 , L, fs*L);

Ref_signal = zeros(fs*L,2*length(Stim_freq)*Nh);
for i = 1 : Nh
    Ref_signal(:,2*length(Stim_freq)*(i-1)+1:2*length(Stim_freq)*i) = [sin(2*i*Ref_time); cos(2*i*Ref_time)]';
end

Reference = permute(reshape(Ref_signal, fs*L, length(Stim_freq), 2*Nh), [3, 1, 2]);

if sub_hf
    Reference(end+1, :, :) = sin(Ref_time)';
    Reference(end+1, :, :) = cos(Ref_time)';
end

S = zeros(1,length(Stim_freq));
X = Data(:,1:fs*L);
X = [X;circshift(X,1,2)];
X = (X-mean2(X))/std2(X);
for this_freq = 1:length(Stim_freq)
    Y = squeeze(Reference(:,:,this_freq));
    Y = (Y-mean2(Y))/std2(Y);    
    C11 = (X*X')/(fs*L); % C = [C11, C12; C21, C22]; 
    C12 = (X*Y')/(fs*L); % U = [C11^(-1/2), zeros; zeros, C22^(-1/2)]
    C21 = (Y*X')/(fs*L); % R = U*C*U'
    C22 = (Y*Y')/(fs*L);
    R = [eye(size(X,1)),C11^(-1/2)*C12*C22^(-1/2); C22^(-1/2)*C21*C11^(-1/2),eye(size(Y,1))];
    % C = cov(X',Y');
    % U = C.^(-1/2);
    % U(1,2) = 0; U(2,1) = 0;
    % R = U*C*U'
    e = eig(R);
    e = e/trace(R);
    S(this_freq) = 1+e'*log(e)/log(trace(R));
end

[~, output]  = max(S);