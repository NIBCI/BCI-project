%% viz_spectra_discri.m ver 0.50
%
%% [*Input Parameter]--------------------------------------------------
%	hEEG		:	Param_Script, 파라미터 정보가 포함된 script
%	epos		:	bbci 데이터 포맷, fft 결과를 포함함
%
%% [*Output Parameter]--------------------------------------------------
%	nProc		:	처리한 데이터 수, 즉 피험자 수
%
%% [*Examples]--------------------------------------------------
%	MATLAB> help viz_spectra_discri
%	MATLAB> nProc = viz_spectra_discri(hEEG, epos);
%
% License
% ==============================================================
% This program is minlab toolbox.
% 
% Copyright (C) 2015 MinLAB. of the University of Korea. All rights reserved.
% Correspondence: tigoum@korea.ac.kr
% Web: mindbrain.korea.ac.kr
%
% ==============================================================================
% Revision Logs
% ------------------------------------------------------
% Program Editor: Ahn Min-Hee @ tigoum, University of Korean, KOREA
% User feedback welcome: e-mail::tigoum@korea.ac.kr
% ......................................................
% first created at 2016/03/23
% last  updated at 2018/03/29
% ......................................................
% ver 0.10 : 20160705. 2D 형 EEG.data 를 지원: tp x ep -> tp(*ep) vector로 처리
% ver 0.20 : 20160705. 2D 형 EEG.data 를 지원: process all data at one time
% ver 0.30 : 20170815. 병렬처리 구조화 및 속도 개선, figure 정리
% ver 0.40 : 20171121. hEEG 포맷 적용, bbci와 연결 재점검
% ver 0.50 : 20180329. 갱신: OSS를 위한 toolbox 구조화
% ==============================================================================

function [ nProc ]	=	viz_spectra_discri( hEEG, epos )
clearvars -except hEEG epos
%close all

%--------------------------------------------------------------------------------
AllRun		=	tic;									% 수행시간 계수용

% the experiment cond that is to be classified
cond		=	hEEG.CurCond;
sbj_list	=	hEEG.Inlier;

%--------------------------------------------------------------------------------
% the range of frequencies to be considered as features
n_subjects	=	length(sbj_list);
save_figs	=	1;										% save figures or not

fig_dir		=	fullfile(hEEG.Dst, 'spectralDensity_Discriminability');
if save_figs && not(exist(fig_dir, 'dir')), mkdir(fig_dir); end

mnt = mnt_setElectrodePositions(epos{1}.clab);
if hEEG.nChannel == 30
	grd = sprintf([	'scale,Fp1,_,Fp2,legend\n'							...
					'F7,F3,Fz,F4,F8\n'									...
					'FC5,FC1,FC2,FC6\n'									...
					'T7,C3,Cz,C4,T8\n'									...
					'CP5,CP1,CP2,CP6\n'									...
					'P7,P3,Pz,P4,P8\n'									...
					'PO9,O1,Oz,O2,PO10'									...
					]);		% 기본: 30채널 중 2개는 Ref, EOG
elseif hEEG.nChannel == 31
	grd = sprintf([	'scale,Fp1,EOG,Fp2,legend\n'							...
					'F7,F3,Fz,F4,F8\n'									...
					'FC5,FC1,FC2,FC6\n'									...
					'T7,C3,Cz,C4,T8\n'									...
					'CP5,CP1,CP2,CP6\n'									...
					'P7,P3,Pz,P4,P8\n'									...
					'PO9,O1,Oz,O2,PO10'									...
					]);		% EOG 추가
elseif hEEG.nChannel == 32
	grd = sprintf([	'scale,Fp1,_,Fp2,legend\n'							...
					'F7,F3,Fz,F4,F8\n'									...
					'FC5,FC1,FCz,FC2,FC6\n'								...
					'T7,C3,Cz,C4,T8\n'									...
					'CP5,CP1,CPz,CP2,CP6\n'								...
					'P7,P3,Pz,P4,P8\n'									...
					'PO9,O1,Oz,O2,PO10'									...
					]);		% FCz, CPz 추가
elseif hEEG.nChannel == 63
	grd = sprintf([	'scale,Fp1,_,Fp2,legend\n'							...
					'AF7,AF3,AF4,AF8\n'									...
					'F7,F5,F3,F1,Fz,F2,F4,F6,F8\n'						...
					'FT9,FT7,FC5,FC3,FC1,FCz,FC2,FC4,FC6,FT8,FT10\n'	...
					'T7,C5,C3,C1,Cz,C2,C4,C6,T8\n'						...
					'TP7,CP5,CP3,CP1,CPz,CP2,CP4,CP6,TP8\n'				...
					'P7,P5,P3,P1,Pz,P2,P4,P6,P8\n'						...
					'PO7,PO3,POz,PO4,PO8\n'								...
					'PO9,O1,Oz,O2,PO10'									...
					]);		% 기본: 64채널 중 1개는 EOG
elseif hEEG.nChannel == 64
	grd = sprintf([	'scale,Fp1,_,Fp2,legend\n'							...
					'AF7,AF3,AFz,AF4,AF8\n'								...
					'F7,F5,F3,F1,Fz,F2,F4,F6,F8\n'						...
					'FT9,FT7,FC5,FC3,FC1,FCz,FC2,FC4,FC6,FT8,FT10\n'	...
					'T7,C5,C3,C1,Cz,C2,C4,C6,T8\n'						...
					'TP7,CP5,CP3,CP1,CPz,CP2,CP4,CP6,TP8\n'				...
					'P7,P5,P3,P1,Pz,P2,P4,P6,P8\n'						...
					'PO7,PO3,POz,PO4,PO8\n'								...
					'PO9,O1,Oz,O2,PO10'									...
					]);		% AFz 추가
elseif hEEG.nChannel == 66
	grd = sprintf([	'scale,Fp1,_,Fp2,legend\n'							...
					'AF7,AF3,AFz,AF4,AF8\n'								...
					'F7,F5,F3,F1,Fz,F2,F4,F6,F8\n'						...
					'FT9,FT7,FC5,FC3,FC1,FCz,FC2,FC4,FC6,FT8,FT10\n'	...
					'T7,C5,C3,C1,Cz,C2,C4,C6,T8\n'						...
					'TP9,TP7,CP5,CP3,CP1,CPz,CP2,CP4,CP6,TP8,TP10\n'	...
					'P7,P5,P3,P1,Pz,P2,P4,P6,P8\n'						...
					'PO7,PO3,POz,PO4,PO8\n'								...
					'PO9,O1,Oz,O2,PO10'									...
					]);		% TP9, TP10 추가
end
mnt = mnt_setGrid(mnt, grd);

%% compute spectral features
sampling_freq			=	epos{1}.fs;
fv						=	cell(1,n_subjects);
epo_spec				=	cell(1,n_subjects);
fft_window		=	hanning(sampling_freq* (1/hEEG.FreqBins) ); %edited by tigoum

fprintf('\n\n --- computing spectal features ---\n\n')
for sbj_idx = 1:n_subjects		% 실행속도를 개선하고 싶으면, parfor 사용할 것
	fprintf('processing sbj %02d/%02d\n', sbj_idx, n_subjects)

	epo_spec{sbj_idx}	=	proc_spectrum(epos{sbj_idx}, epos{sbj_idx}.band, ...
					'Win',fft_window, 'Step',sampling_freq*hEEG.FreqBins);

%	reshape the channel-wise spectra to obtain feature vectors
	fv{sbj_idx}			=	proc_flaten(epo_spec{sbj_idx});
end
    [n_freq_bins, n_channels, n_epos] = size(epo_spec{1}.x);
	n_classes			=	size(epo_spec{1}.y, 1);
	if n_classes == 2, n_classes = 1; end				% 2개면 한쪽만 알면 됨
%	freqs				=	epo_spec{1}.t;				% 주파수 구간
%	freqs				=	epo_spec{sbj_idx}.t;
fprintf('done\n')

%% compute discriminability for each feature
fprintf('\n\n --- computing featurewise discriminability ---\n\n')
scores = cell(size(fv));
for n = 1:n_subjects	% 실행속도를 개선하고 싶으면, parfor 사용할 것
    fprintf('processing sbj %02d/%02d\n', n, n_subjects)
    scores{n} = proc_rSquare(proc_normalize(fv{n}),'policy','each-against-rest');
    
    scores{n}.x = reshape(scores{n}.x, [n_freq_bins, n_channels, n_classes]);
end
score_ga = proc_grandAverage(scores);
fprintf('done\n')

%% average spectra over trials
epo_spec_avg = epo_spec;
fprintf('\n\n --- averaging across trials---\n\n')
for n = 1:n_subjects	% 실행속도를 개선하고 싶으면, parfor 사용할 것
    fprintf('processing sbj %02d/%02d\n', n, n_subjects)
    epo_spec_avg{n} = proc_average(epo_spec{n}, 'Stats', 1);
end
epo_spec_ga = proc_grandAverage(epo_spec_avg, 'Stats', 1);
score_ga.className	=	epo_spec_ga.className;	% label 너무 길어서 대체
fprintf('done\n')

%% plot individual spectra
epo_spec_avg = epo_spec;
for n = 1:n_subjects	% 실행속도를 개선하고 싶으면, parfor 사용할 것
    fprintf('processing sbj %02d/%02d\n', n, n_subjects)
    epo_spec_avg{n} = proc_average(epo_spec{n}, 'Stats', 1);
	figure('visible','off');		% 화면 draw는 끔
    grid_plot(epo_spec_avg{n}, mnt ... % defopt_erps);%, 'colorOrder',colOrder);
        ,'ScaleHPos', 'left' ...
        ,'ShrinkAxes', [0.9 0.8] ...
    );
    if save_figs
        fname = sprintf('%s__sbj_%02d__spectral_density', cond, n);
        if not(exist(fullfile(fig_dir, 'individual_subjects'), 'dir'))
            mkdir(fullfile(fig_dir, 'individual_subjects'));
        end
        save2figure(gcf, fullfile(fig_dir,'individual_subjects',fname), 35, 20)
    end
end
fprintf('done\n')

%% plot grand average spectra
figure('Position',[0 0 1024 576], 'visible','off');		% 화면 draw는 끔
grid_plot(epo_spec_ga, mnt ...
    ,'ScaleHPos', 'left' ...
    ,'ShrinkAxes', [0.9 0.8] ...
	,'LegendVerticalAlignment',	'bottom'	...
    );
if save_figs
    fname = sprintf('%s__grand_average__spectral_density', cond);
    save2figure(gcf, fullfile(fig_dir, fname), 35, 20)
end

%% plot grand average discriminability
figure('Position',[0 0 1024 576], 'visible','off');		% 화면 draw는 끔
grid_plot(score_ga, mnt ...
    ,'ScaleHPos', 'left' ...
    ,'ShrinkAxes', [0.9 0.8] ...
	,'LegendVerticalAlignment',	'bottom'	...
    );
if save_figs
    fname = sprintf('%s__grand_average__discriminability', cond);
    save2figure(gcf, fullfile(fig_dir, fname), 35, 20)
end

%--------------------------------------------------------------------------------
toc(AllRun);
fprintf('Working complete.\nThe results are available in the %s\n', fig_dir);

nProc	=	n_subjects;
return

