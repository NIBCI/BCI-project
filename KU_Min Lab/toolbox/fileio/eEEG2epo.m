%% eEEG2epo v0.20
% This work load & convert eEEG(minlab type) -> epo(bbci)
%
%% [*Input Parameter]--------------------------------------------------
%	hEEG		:	Param_Script, 파라미터 정보가 포함된 script
%	sbj_idx		:	subject의 번호, hEEG.CurSbj 에 명시된 경우 생략 가능
%
%% [*Output Parameter]--------------------------------------------------
%	epo			:	bbci의 data format
%
%% [*Examples]--------------------------------------------------
%	MATLAB> epo = eEEG2epo( hEEG )
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
% first created at 2016/01/18
% last  updated at 2016/04/24
% ......................................................
% ver 0.10 : 20160118. 기본 골격 구성
% ver 0.20 : 20160424. hEEG 구조 조정
% ==============================================================================

function epo = eEEG2epo( hEEG, sbj_idx )

	data_folder	=	fullfile(hEEG.PATH, hEEG.Src);
	com			=	hEEG.Head;
	cond		=	hEEG.CurCond;

if		nargin <= 1
	sbj			=	hEEG.CurSbj;						% hEEG 내부 설정 이용
elseif	nargin <= 2										% index 여부따라 반응
	sbj			=	hEEG.Inlier{sbj_idx};
end

if isfield(hEEG, 'FreqWindow')
	fwin		=	hEEG.FreqWindow;
elseif length(hEEG.FOI{1}) == 2
	fwin		=	hEEG.FOI{1};						% freq win없으면 FOI적용
else
	fwin		=	[hEEG.FOI{1}(1) hEEG.FOI{1}(end)];	% vector면 구간값 취함
end

	%% load the data
	epo = [];

	%% create the filename and load the data of the current block
	file_name = sprintf('%s_%s_%s.mat', com, sbj, cond);

	fprintf('loading %s\n', file_name);
	dat = load(fullfile(data_folder, file_name));

	%% create marker labels that match the BBCI toolbox format
	if size(dat.eMRK, 1) > 1, dat.eMRK=	dat.eMRK'; end	% 반드시 1 x len 일 것!
	y			=	dat.eMRK;
	classes		=	unique(y);
	n_classes	=	length(classes);
	n_trials	=	length(y);
	className	=	cell(1,n_classes);
	labels		=	repmat(unique(y)', 1, n_trials) == repmat(y, n_classes, 1);
	labels		=	double(labels);			% must be !
%	className	=	arrayfun(@(x)({ sprintf('St%d', x) }), [1:n_classes]);
	className	=	arrayfun(@(x)({ sprintf('Stimulus %d', x) }), [1:n_classes]);

	% 채널 정보의 구성
	if isfield(dat, 'eCHN')					% 이미 data에 채널 목록이 있으면
		nChannel	=	length(dat.eCHN);
	else
		nChannel	=	size(dat.eEEG, 2);	% tp x ch x ep
											%	= time point x channel x trial
	end

%	if 0 < hEEG.nChannel & hEEG.nChannel ~= nChannel
%		fprintf('[Warning] : channel size mismatch, Ignore the hEEG.nChannel\n');
%	end

    %% create the epoched data structure that matches the BBCI format
	if isfield(dat, 'eCHN')					% 이미 data에 채널 목록이 있으면
	fprintf('[Detect]  : Channel Info. in data file, apply to this\n');
	clab	=	dat.eCHN;
	elseif nChannel + 0 == 32				% 30 + EOG + NULL
	clab	={	'Fp1',	'Fp2',	'F7',	'F3',	'Fz',	'F4',	'F8',	'FC5',...
				'FC1',	'FC2',	'FC6',	'T7',	'C3',	'Cz',	'C4',	'T8', ...
				'EOG',	'CP5',	'CP1',	'CP2',	'CP6',	'NULL',	'P7',	'P3', ...
				'Pz',	'P4',	'P8',	'PO9',	'O1',	'Oz',	'O2',	'PO10' };
	elseif nChannel + 0 == 31				% 30 + EOG
	clab	={	'Fp1',	'Fp2',	'F7',	'F3',	'Fz',	'F4',	'F8',	'FC5',...
				'FC1',	'FC2',	'FC6',	'T7',	'C3',	'Cz',	'C4',	'T8', ...
				'EOG',	'CP5',	'CP1',	'CP2',	'CP6',			'P7',	'P3', ...
				'Pz',	'P4',	'P8',	'PO9',	'O1',	'Oz',	'O2',	'PO10' };
	elseif nChannel + 0 == 30				% 30
	clab	={	'Fp1',	'Fp2',	'F7',	'F3',	'Fz',	'F4',	'F8',	'FC5',...
				'FC1',	'FC2',	'FC6',	'T7',	'C3',	'Cz',	'C4',	'T8', ...
						'CP5',	'CP1',	'CP2',	'CP6',			'P7',	'P3', ...
				'Pz',	'P4',	'P8',	'PO9',	'O1',	'Oz',	'O2',	'PO10' };
	elseif nChannel + 0 == 64				% 63 + EOG
	clab	={	'Fp1',	'Fp2',	'F7',	'F3',	'Fz',	'F4',	'F8',	'FC5',...
				'FC1',	'FC2',	'FC6',	'T7',	'C3',	'Cz',	'C4',	'T8', ...
				'EOG',	'CP5',	'CP1',	'CP2',	'CP6',	'FCz',	'P7',	'P3', ...
				'Pz',	'P4',	'P8',	'PO9',	'O1',	'Oz',	'O2',  'PO10',...
				'AF7',	'AF3',	'AF4',	'AF8',	'F5',	'F1',	'F2',	'F6', ...
				'FT9',	'FT7',	'FC3',	'FC4',	'FT8',	'FT10',	'C5',	'C1', ...
				'C2',	'C6',	'TP7',	'CP3',	'CPz',	'CP4',	'TP8',	'P5', ...
				'P1',	'P2',	'P6',	'PO7',	'PO3',	'POz',	'PO4',	'PO8' };
	else
	clab	=	dat.eCHN;				% 적당한 것이 없으면 그냥 대체
	end

%--------------------------------------------------------------------------------
	if isfield(dat, 'eFS')
		fs				=	dat.eFS;
	else
		fs				=	500;		% 필드 없으면 lab default 설정
	end
	ts					=	hEEG.tInterval;
	twin				=	hEEG.TimeWindow;
	epo_tmp				=	[];
	epo_tmp.clab		=	clab;
	epo_tmp.band		=	fwin;		% [ 5, 13.5 ];
	epo_tmp.fs			=	fs;

	epo_tmp.t			= [twin(1)/1000: 1/fs : (twin(2)-1)/1000]; % 시간구간구성

	epo_tmp.className	= className;	% 자극 갯수

	tidx				= find(ismember([ts(1)  : 1000/fs : ts(2)],		...
										[twin(1): 1000/fs : twin(2)-1]));
	epo_tmp.x			= dat.eEEG(tidx,:,:);	% 유효data만 추출, tp x ch x ep
	epo_tmp.y			= labels;				% marker * trial

	marker				=	dat.eMRK;
	if isfield(epo, 'marker')			% marker(brain recorder의) append 해줄것
		marker			=	[ epo.marker marker ];	% append
	end

	epo = proc_appendEpochs(epo, epo_tmp);
	epo.marker			=	marker;		% 추가 및 append 값 갱신
end	% fxn
