%% script_SSVEP_NEW ver 0.60
%
%% [*Examples]--------------------------------------------------
%	script_SSVEP_NEW.m 을 열어서 필요한 parameter들을 조정한 후, 아래 실행
%	[주의사항] MATLAB 2016a 이전 릴리즈로 실행해야 함 (bbci 의 내장함수 이슈)
%
%	MATLAB> help script_SSVEP_NEW
%	MATLAB> script_SSVEP_NEW
%	(실행 결과는 아래에서 명시하는 hEEG.Dst 에 설정된 폴더 아래에 저장됨)
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
% ver 0.10 : 20160325. H_class.m 함수 구조 설계
% ver 0.20 : 20160722. SSVEP 수직, 수평 주파수 재점검 -> 문제없음
% ver 0.30 : 20170817. sub함수의 병렬처리 구조화 및 속도 개선에 대응하는 test
% ver 0.40 : 20170925. 주파수 변경으로 accuracy 개선 가능성 점검
% ver 0.50 : 20171119. hEEG 포맷 적용, bbci와 연결 재점검
% ver 0.60 : 20180327. 갱신: OSS를 위한 toolbox 구조화
% ==============================================================================
%
% first created by tigoum 2015/11/18
% last  updated by tigoum 2018/03/30

%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% MATLAB release 점검, bbci 문제 <- MATLAB2016b 이후 버전부터
Version				=	ver;
Release				=	Version.Release;					% 형식: R(2016a)
nRel				=	str2num(Release(3:6));
Half				=	Release(7);
if 2016 < nRel | (2016==nRel & 'b' <= Half)
 error('MATLAB version too big, because bbci is issued on MATLAB2016b later');
end

%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%	Top Down SSVEP의 원리:
%
%	기본 구조는 밭 '전' 자의 가로와 세로에 각기 다른 주파수를 할당하고 조합함
%		┏┳┓
%		┣╋┫
%		┗┻┛
%	위 그림에 대해 아래와 같이 주파수를 배당함.
%
%%		5.5	6.5 7.5
%%		|	|	|
%%	5.0- ┏  ┳  ┓	R1
%%	6.0- ┣  ╋  ┫	R2
%%	7.0- ┗  ┻  ┛	R3
%%		C1	C2	C3
%
%	이를 기준으로 아래와 같이 구성되는 문자별로 주파수 조합(harmonic)이 결정됨
%	tgr	R/C		char	R-freq	C-freq
%	1x1	R1C3	(┓)	5.0 Hz	7.5 Hz
%	1x2	R3C1	(┗)	7.0 Hz	5.5 Hz
%	1x3	R2C1	(┣)	6.0 Hz	5.5 Hz
%	1x4	R2C3	(┫)	6.0 Hz	7.5 Hz
%	1x5	R3C2	(┻)	7.0 Hz	6.5 Hz
%	1x6	R1C2	(┳)	5.0 Hz	6.5 Hz
%	->	tgr 1x. 에서 x == 1(top down), 2(intermediate), 3(bottom up)

% ---------------------------------------------------------------------------
% 실행을 위한 환경설정
% ---------------------------------------------------------------------------
%% 기본적으로 m file의 path설정이므로, MATLAB상에서 경로설정 해줘도 됨.
%addpath( genpath( fullfile( '/usr/local', 'bbci_public' ) ), '-end');	% 맨밑
%addpath( genpath( fullfile( '../', 'bbci_public-master' ) ) );

addpath( genpath( fullfile( '../', 'fileio' ) ) );
addpath( genpath( fullfile( '../', 'SpectralDensity_Discriminability' ) ) );
addpath( genpath( fullfile( '../', 'examples' ) ) );

% ---------------------------------------------------------------------------
% 데이터를 로딩하기 위한 path 및 file 관련 설정
% ---------------------------------------------------------------------------
	%% initialize variables
	hEEG.Condi		=	{ 'TopDown', }; %'Intermediate', 'BottomUp', };
	%----------------------------------------------------------------------------
	hEEG.PATH		=	'../'
	hEEG.Src		=	'samples';
	hEEG.Dst		=	fullfile('.', 'Results');			% examples/Results

	hEEG.Head		=	'SSVEP_NEW';
	hEEG.Inlier		=	{	'su0003', 'su0004', 'su0005',	};

% ---------------------------------------------------------------------------
% 데이터를 계산하기 위한 초기값 설정
% ---------------------------------------------------------------------------
	hEEG.SmplRate	=	500;								% sampling rate
	fBin			=	1/2;
	hEEG.FreqBins	=	fBin;								% freq step

	%----------------------------------------------------------------------------
	% FOI == band of interest
	hEEG.FOI		=	{ [5:fBin:13.5] };					% 핵심 관심 주파수
	% 다음은 위 FOI에 대한 설명문 (그래프에 주석문을 출력하기 위한 용도)
	hEEG.sFOI		=	{ 'over stimulation frequencies', };% 위의 FOI 설명문
%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	hEEG.FreqWindow	=	[min(cell2mat(hEEG.FOI)), max(cell2mat(hEEG.FOI))];

	%----------------------------------------------------------------------------
%	hEEG.tInterval	=	[-2000, 5000];						% -2000~5000msec
	hEEG.tInterval	=	[0, 5000];							% 0 ~ 5000msec
	hEEG.TimeWindow	=	[0, 5000];							% 0 ~ 5000msec

	%----------------------------------------------------------------------------
	hEEG.nFolds		=	4;									% 4 session
	hEEG.Chan		=	{		...	% 여기에 명시하는 채널에 대해서 plotting 됨.
				'Fp1',	'Fp2',	'F7',	'F3',	'Fz',	'F4',	'F8',	'FC5',...
				'FC1',	'FC2',	'FC6',	'T7',	'C3',	'Cz',	'C4',	'T8', ...
						'CP5',	'CP1',	'CP2',	'CP6',			'P7',	'P3', ...
				'Pz',	'P4',	'P8',	'PO9',	'O1',	'Oz',	'O2',	'PO10' };
				 % 만약 위 30채널 대신, {'O1','Oz','O2'} 명시 -> 3개만 plot
%	hEEG.ChRemv		=	{	'not',	'NULL*', '*EOG*'	};	%제거: 앞에'not'추가
	hEEG.nChannel	=	length(hEEG.Chan);					% 정식 사용 총 채널

%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
for condi			=	1 : length(hEEG.Condi)
	hEEG.CurCond	=	hEEG.Condi{condi};

	% ___________________________________________________________________________
	epos			=	cell(1,length(hEEG.Inlier));		% data 구성
	for ix 	= 1:length(hEEG.Inlier)	% 실행속도를 개선하고 싶으면, parfor 쓸것
		fprintf('loading subject %s\n', hEEG.Inlier{ix})

		epos{ix}	=	eEEG2epo( hEEG, ix );

		if isfield(hEEG, 'Chan')
			epos{ix}=	proc_selectChannels(epos{ix}, hEEG.Chan);	% 선택방식
		else
			epos{ix}=	proc_selectChannels(epos{ix}, hEEG.ChRemv);	% 제거방식
		end
	end
	hEEG.nChannel	=	length(epos{1}.clab);				% 갱신

	%% drawing for spectral-density & discriminability -------------------
	Cnt				=	viz_spectra_discri( hEEG, epos );
end		% for cond

