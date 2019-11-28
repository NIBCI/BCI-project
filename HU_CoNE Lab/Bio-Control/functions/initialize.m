function initialize(handles)
global info;
global option;
global pd;
global EM_online;
global pos;
global dataqueue;
global trg inst_signal;
global tstack_triple;
global raw_signal_reserve;
global CCA_buffer;
global robot;
global A;               % A, B : butterworth 필터 계수
global B;
global trg_flag;        % 자극 시작 트리거가 들어오면 켜짐. + 자극이 깜박이고 있는 상태인지 표시.
global only_once        % 일단 한번 실행해 보려고 만든 것. (EOG switch 1회 무조건 작동)
global buffer_size      % CCA 에 쓰일 EEG 데이터 길이. (기본: 2.5s)
global trg_flag_forward     % 시작 트리거 받았을 때
global trg_flag_backward    % 시작 트리거 못받고 끝나는 트리거만 받았을 때
global disp_flag    % 자극 시작 트리거 받았는지 확인
global EOG_quad 
global udpH         % udp 전송을 위한 헤더
global CCA_delay    % 0.13s 로 기본세팅.
global save_flag    % save 버튼 눌러서 했는지 안했는지
global on_off       % 현재 자극 제시되고 있는 상태인지 아닌지
% global Blink_idx    % 현재까지 눈깜빡임 4번 얼마나 반복되었는지 횟수 계산.
global prev_Answer  % 이전 EEG 분류값. 초기에는 0으로 해놓고, 이후에 눈깜빡임으로 시스템 새로 킬 때마다 초기화.
global init_flag
global path_name
global Subj_name
global threshold
global block_flag

block_flag = false;
threshold = 0;

clear biosemix

path_name = 'E:\박성훈\AR_SSVEP\Online_Data';

% disp('==================== %%% 1. EOG_quad 확인 %%% =========')
% disp('============== %%% 2. 초기 threshold 확인 %%% =========')

disp('피험자의 이름 이니셜을 입력해 주세요')
Subj_name = input(': ', 's');
if exist([path_name, '\', Subj_name], 'dir')
else
    mkdir([path_name, '\', Subj_name])
end

prev_Answer = 0;
init_flag = true;
on_off = false;

EOG_quad = 0;

udpH = udp('192.168.1.55', 8053);
fopen(udpH);

info.CCA.Stim_freq = [7.4 8.3 10 11.7];

disp_flag = 0;
trg_flag_forward = 0;
trg_flag_backward = 0;

buffer_size = 2.5; % buffer size
CCA_delay = 0.13;


% BIOSEMI info
info.Fc = 2048;

% 프로그램 모드
info.input_mode = 1; % online 모드

%GUI초기화 
set(handles.listbox_progress,'String','====A new experiment====')
set(handles.listbox_progress,'Value',1);

%사용하는 채널번호
% info.nChannel = 4;
% info.szChannels = {'EOG_R','EOG_L','EOG_U(r)','EOG_D(r)'};
% info.ch_u = 1;
% info.ch_d = 2;
% info.ch_O1 = 3;
% info.ch_Oz = 4;
% info.ch_O2 = 5;

info.nEOG_ch = 2;
info.nEEG_ch = 4;    % 3개는 O1, Oz, O2, 4번째는 Cz (re-reference) % A 만 뚫려있으므로 32채널까지만 사용가능, 그 이상 넘어가면 그냥 0값. +1은 trigger 때문에 있는 것. (Process_mem.m 참조)
info.nSSVEP_ch = 3:5;     % biosemix 로 데이터 받아온 segment 안에서, SSVEP 분석에 쓸 채널 번호.
info.ReRef = 6;     % Cz

info.ch_u = info.nEOG_ch - 1;   % vEOG(상)
info.ch_d = info.nEOG_ch;   % vEOG(하)

info.channel_list = 1:info.nEEG_ch+info.nEOG_ch;    %[info.ch_u, info.ch_d,info.ch_O1,info.ch_Oz,info.ch_O2];
info.nChannel = info.nEOG_ch + info.nEEG_ch;
info.NumofChannel_used = info.nChannel;

% info.EXT_initial_num = 258;     % EX 채널 1번의 biosemix 상의 번호가 258임.
% info.EXT_total_num = 5;     % 사용하고자 하는 EX 채널 개수     %length(info.channel_list);
% info.nChannel = info.EXT_initial_num + info.EXT_total_num - 1;     
% % info.nChannel = 280;
% info.NumofChannel_used = info.nEEG_ch+info.nEOG_ch + info.nEEG_ch_EXT - 1;      % EXT 에서 쓸 EEG 채널 개수만큼 더 더해줌. (마지막항)
%                                                                                 % 그리고 nEEG_ch 에서 더해준 1 다시 빼줌으로써 채널 개수 맞춤.
% info.trg_channel = 1;


% Raw data for back-up setup
raw_signal_reserve.mat = zeros(info.Fc * 60 * 20,...
    info.NumofChannel_used+1); % 60 데이터
raw_signal_reserve.n_data = 0;
% audio set up
[info.sound.alert, info.sound.alert_Fs] = audioread([pwd, '\resources\sound\alert.wav']);
[info.sound.beep, info.sound.beep_Fs] = audioread([pwd, '\resources\sound\beep.wav']);
[info.sound.inst, info.sound.inst_Fs] = audioread([pwd, '\resources\sound\눈을네번깜빡여주세요.MP3']);
sound(info.sound.alert, info.sound.alert_Fs);
    
% Onlin experiment sampling and process time setup

info.ExpectedSegmentLength = 64;
info.TimerFreq     = info.Fc/info.ExpectedSegmentLength;
info.Freq_2RefreshDrawingRegion = 8; % 그림 출력(타이머. 16smaple마다 갱신)
info.Fc4EOG        = 64;
info.queuelength_time    = 10;


option.bSmartInterpol   = 1;
option.median_width     = 5;    
option.resamplingRate4EOG   = info.Fc/info.Fc4EOG;

info.DM_sig = online_downsample_init(option.resamplingRate4EOG);


% circlequeue length setup
queuelength_orig    = info.queuelength_time* info.Fc;
queuelength_pd      = info.queuelength_time* info.Fc4EOG;
queuelength_eb_check      = 2* info.Fc4EOG; % 2초 안에 4번깜박이면 Triple!

pd.EOG              = circlequeue(queuelength_pd,1); %10*64, 2채널+Trigger
pd.EOG.data(:,:)    = NaN;
dataqueue           = circlequeue(queuelength_orig,info.NumofChannel_used); %10*256, 8
trg           = circlequeue(queuelength_orig,1); %10*256, 8
pd.EOG_ebRemoved    = circlequeue(queuelength_pd,1); %10*64, 2
pd.queuelength_eb_check = circlequeue(queuelength_eb_check,1); %64, 1

% GUI setup
info.handles = handles;

% Offline (파일)
pos = 1;

% filter parameters
% filter 초기조건
filter_order = 4; Fn = info.Fc/2;
LPF_cutoff_Freq = [50];
[info.f.lB,info.f.lA] = butter(filter_order,LPF_cutoff_Freq/Fn,'low');
info.f.lZn = []; 
% 
% n =5;
% Wn = [57 63];    
% Fn = info.Fc/2;
% ftype = 'stop'; % notch
% [b, a] = butter(n, Wn/Fn, ftype);
% info.notchfilter.b=b;
% info.notchfilter.a=a;
% info.notchfilter.zf=[];
% down sapmling
info.DM = online_downsample_init(option.resamplingRate4EOG);

    

% clearing timer in memory
if ~isempty(timerfind)
    stop(timerfind);
    delete(timerfind);
end
if isfield(info,'timer_main') && isvalid(info.timer_main)
    delete(info.timer_main);
end
if isfield(info,'timer_onPaint') && isvalid(info.timer_onPaint)
    delete(info.timer_onPaint);
end

% timer setup

info.period_for_timer_main_mem     =  round(info.ExpectedSegmentLength/info.Fc, 3);
% info.timer_main                     = timer('TimerFcn','Process','StartDelay', round(info.ExpectedSegmentLength/info.Fc,3), 'Period', round(info.ExpectedSegmentLength/info.Fc,3), 'ExecutionMode', 'fixedRate');
% info.timer_onPaint                  = timer('TimerFcn','onPaint','StartDelay', round(1/info.Freq_2RefreshDrawingRegion,3), 'Period', round(1/info.Freq_2RefreshDrawingRegion,3), 'ExecutionMode', 'fixedRate');
info.timer_onPaint                  = timer('TimerFcn','onPaint','StartDelay', round(info.ExpectedSegmentLength/info.Fc,3), 'Period', round(info.ExpectedSegmentLength/info.Fc,3), 'ExecutionMode', 'fixedRate');
info.timer_main_mem                 = timer('TimerFcn','Process_mem','StartDelay', info.period_for_timer_main_mem, 'Period',info.period_for_timer_main_mem, 'ExecutionMode', 'fixedRate');
tstack_triple = 0;
info.triple_count = 0;
info.idle_count = 0;
info.control_count = 0;
% CLASS 설정
% Eyeblink Master
EM_online = eyeblink_master_online(queuelength_pd, option.median_width);

% % TCP/IP
% Channels = 8;             %set to the same value as in Actiview "Channels sent by TCP"
% Samples = 16;               %set to the same value as in Actiview "TCP samples/channel"
% %variable%
% words = Channels*Samples;
% 
% %configure% the folowing 4 values should match with your setings in Actiview and your network settings 
% port = 8888;                %the port that is configured in Actiview , delault = 8888
% ipadress = 'localhost';     %the ip adress of the pc that is running Actiview Cone_exp_main,localhost


%open tcp connection%
% if  ~exist('info.tcpipClient')
% info.tcpipClient = tcpip(ipadress,port,'NetworkRole','Client');
% set(info.tcpipClient,'InputBufferSize',words*9); %input buffersize is 3 times the tcp block size %1 word = 3 bytes
% set(info.tcpipClient,'Timeout',5);
% try
%     fopen(info.tcpipClient);
% catch
% %     myStop;
%     disp('Actiview is unreachable please check if Actiview is running on the specified ip address and port number');
% end
% end
% 웹캠 연결
% if ~isfield(info,'cam')
%     info.cam = cam(1);
% end
% h1 = preview(info.cam);
% CData = h1.CData;
% closePreview(info.cam);
% info.hcam = image(zeros(size(CData)),'Parent', handles.axes_webcam); 
% info.currp = preview(info.cam,info.hcam);

% Serial 세팅
% info.serial = serial('COM8');                                                       % 장치관리자에서 serial port 확인해서 설정 (실험실 오른쪽 컴퓨터)
% set(info.serial, 'BaudRate', 9600, 'DataBits', 8, 'StopBits', 1, 'Parity', 'none', 'FlowControl', 'none', 'TimeOut', 0.01)
% fopen(info.serial);

% inst Trigger setting
inst_signal = 0;

% CCA 초기화
info.CCA.buffer_size=  ceil((buffer_size)*info.Fc) ; % 4초 버퍼

CCA_buffer = circlequeue(info.CCA.buffer_size, length([info.nSSVEP_ch, info.ReRef])); % time-series, 3ch // time series에 *2 한 이유는, backward 일 경우를 위해서임
                                                    % CCA_buffer.length 의 길이는 circlequeue 의 길이대로 고정된 값임!
                                                    % Process_mem에도 CCA_buffer 초기화하는거 두번 나옴. 
                                                    % (forward, backward) 거기에도 똑같이 해줘야함
info.CCA_buffer_on = 0; % CCA 버퍼 차면 1 안차면 0;
info.CCA_buffers = zeros(length(info.CCA.Stim_freq), 5, length(info.nSSVEP_ch), buffer_size*info.Fc);

% % 가상 키보드 활성화      % 예전 BCI 과제 1차년도에서 매크로 통해 제어하기 위해 필요했던 것. 이제 노필요
% import java.awt.Robot;
% import java.awt.event.*;
% robot = Robot();

[B, A] = butter(3, [2 54]/(info.Fc/2));

trg_flag = 0;
save_flag = 0;

% stimulus_flag = 0;

% only_once = 1;


end
