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
global A;               % A, B : butterworth ���� ���
global B;
global trg_flag;        % �ڱ� ���� Ʈ���Ű� ������ ����. + �ڱ��� �����̰� �ִ� �������� ǥ��.
global only_once        % �ϴ� �ѹ� ������ ������ ���� ��. (EOG switch 1ȸ ������ �۵�)
global buffer_size      % CCA �� ���� EEG ������ ����. (�⺻: 2.5s)
global trg_flag_forward     % ���� Ʈ���� �޾��� ��
global trg_flag_backward    % ���� Ʈ���� ���ް� ������ Ʈ���Ÿ� �޾��� ��
global disp_flag    % �ڱ� ���� Ʈ���� �޾Ҵ��� Ȯ��
global EOG_quad 
global udpH         % udp ������ ���� ���
global CCA_delay    % 0.13s �� �⺻����.
global save_flag    % save ��ư ������ �ߴ��� ���ߴ���
global on_off       % ���� �ڱ� ���õǰ� �ִ� �������� �ƴ���
% global Blink_idx    % ������� �������� 4�� �󸶳� �ݺ��Ǿ����� Ƚ�� ���.
global prev_Answer  % ���� EEG �з���. �ʱ⿡�� 0���� �س���, ���Ŀ� ������������ �ý��� ���� ų ������ �ʱ�ȭ.
global init_flag
global path_name
global Subj_name
global threshold
global block_flag

block_flag = false;
threshold = 0;

clear biosemix

path_name = 'E:\�ڼ���\AR_SSVEP\Online_Data';

% disp('==================== %%% 1. EOG_quad Ȯ�� %%% =========')
% disp('============== %%% 2. �ʱ� threshold Ȯ�� %%% =========')

disp('�������� �̸� �̴ϼ��� �Է��� �ּ���')
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

% ���α׷� ���
info.input_mode = 1; % online ���

%GUI�ʱ�ȭ 
set(handles.listbox_progress,'String','====A new experiment====')
set(handles.listbox_progress,'Value',1);

%����ϴ� ä�ι�ȣ
% info.nChannel = 4;
% info.szChannels = {'EOG_R','EOG_L','EOG_U(r)','EOG_D(r)'};
% info.ch_u = 1;
% info.ch_d = 2;
% info.ch_O1 = 3;
% info.ch_Oz = 4;
% info.ch_O2 = 5;

info.nEOG_ch = 2;
info.nEEG_ch = 4;    % 3���� O1, Oz, O2, 4��°�� Cz (re-reference) % A �� �շ������Ƿ� 32ä�α����� ��밡��, �� �̻� �Ѿ�� �׳� 0��. +1�� trigger ������ �ִ� ��. (Process_mem.m ����)
info.nSSVEP_ch = 3:5;     % biosemix �� ������ �޾ƿ� segment �ȿ���, SSVEP �м��� �� ä�� ��ȣ.
info.ReRef = 6;     % Cz

info.ch_u = info.nEOG_ch - 1;   % vEOG(��)
info.ch_d = info.nEOG_ch;   % vEOG(��)

info.channel_list = 1:info.nEEG_ch+info.nEOG_ch;    %[info.ch_u, info.ch_d,info.ch_O1,info.ch_Oz,info.ch_O2];
info.nChannel = info.nEOG_ch + info.nEEG_ch;
info.NumofChannel_used = info.nChannel;

% info.EXT_initial_num = 258;     % EX ä�� 1���� biosemix ���� ��ȣ�� 258��.
% info.EXT_total_num = 5;     % ����ϰ��� �ϴ� EX ä�� ����     %length(info.channel_list);
% info.nChannel = info.EXT_initial_num + info.EXT_total_num - 1;     
% % info.nChannel = 280;
% info.NumofChannel_used = info.nEEG_ch+info.nEOG_ch + info.nEEG_ch_EXT - 1;      % EXT ���� �� EEG ä�� ������ŭ �� ������. (��������)
%                                                                                 % �׸��� nEEG_ch ���� ������ 1 �ٽ� �������ν� ä�� ���� ����.
% info.trg_channel = 1;


% Raw data for back-up setup
raw_signal_reserve.mat = zeros(info.Fc * 60 * 20,...
    info.NumofChannel_used+1); % 60 ������
raw_signal_reserve.n_data = 0;
% audio set up
[info.sound.alert, info.sound.alert_Fs] = audioread([pwd, '\resources\sound\alert.wav']);
[info.sound.beep, info.sound.beep_Fs] = audioread([pwd, '\resources\sound\beep.wav']);
[info.sound.inst, info.sound.inst_Fs] = audioread([pwd, '\resources\sound\�����׹��������ּ���.MP3']);
sound(info.sound.alert, info.sound.alert_Fs);
    
% Onlin experiment sampling and process time setup

info.ExpectedSegmentLength = 64;
info.TimerFreq     = info.Fc/info.ExpectedSegmentLength;
info.Freq_2RefreshDrawingRegion = 8; % �׸� ���(Ÿ�̸�. 16smaple���� ����)
info.Fc4EOG        = 64;
info.queuelength_time    = 10;


option.bSmartInterpol   = 1;
option.median_width     = 5;    
option.resamplingRate4EOG   = info.Fc/info.Fc4EOG;

info.DM_sig = online_downsample_init(option.resamplingRate4EOG);


% circlequeue length setup
queuelength_orig    = info.queuelength_time* info.Fc;
queuelength_pd      = info.queuelength_time* info.Fc4EOG;
queuelength_eb_check      = 2* info.Fc4EOG; % 2�� �ȿ� 4�������̸� Triple!

pd.EOG              = circlequeue(queuelength_pd,1); %10*64, 2ä��+Trigger
pd.EOG.data(:,:)    = NaN;
dataqueue           = circlequeue(queuelength_orig,info.NumofChannel_used); %10*256, 8
trg           = circlequeue(queuelength_orig,1); %10*256, 8
pd.EOG_ebRemoved    = circlequeue(queuelength_pd,1); %10*64, 2
pd.queuelength_eb_check = circlequeue(queuelength_eb_check,1); %64, 1

% GUI setup
info.handles = handles;

% Offline (����)
pos = 1;

% filter parameters
% filter �ʱ�����
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
% CLASS ����
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
% ��ķ ����
% if ~isfield(info,'cam')
%     info.cam = cam(1);
% end
% h1 = preview(info.cam);
% CData = h1.CData;
% closePreview(info.cam);
% info.hcam = image(zeros(size(CData)),'Parent', handles.axes_webcam); 
% info.currp = preview(info.cam,info.hcam);

% Serial ����
% info.serial = serial('COM8');                                                       % ��ġ�����ڿ��� serial port Ȯ���ؼ� ���� (����� ������ ��ǻ��)
% set(info.serial, 'BaudRate', 9600, 'DataBits', 8, 'StopBits', 1, 'Parity', 'none', 'FlowControl', 'none', 'TimeOut', 0.01)
% fopen(info.serial);

% inst Trigger setting
inst_signal = 0;

% CCA �ʱ�ȭ
info.CCA.buffer_size=  ceil((buffer_size)*info.Fc) ; % 4�� ����

CCA_buffer = circlequeue(info.CCA.buffer_size, length([info.nSSVEP_ch, info.ReRef])); % time-series, 3ch // time series�� *2 �� ������, backward �� ��츦 ���ؼ���
                                                    % CCA_buffer.length �� ���̴� circlequeue �� ���̴�� ������ ����!
                                                    % Process_mem���� CCA_buffer �ʱ�ȭ�ϴ°� �ι� ����. 
                                                    % (forward, backward) �ű⿡�� �Ȱ��� �������
info.CCA_buffer_on = 0; % CCA ���� ���� 1 ������ 0;
info.CCA_buffers = zeros(length(info.CCA.Stim_freq), 5, length(info.nSSVEP_ch), buffer_size*info.Fc);

% % ���� Ű���� Ȱ��ȭ      % ���� BCI ���� 1���⵵���� ��ũ�� ���� �����ϱ� ���� �ʿ��ߴ� ��. ���� ���ʿ�
% import java.awt.Robot;
% import java.awt.event.*;
% robot = Robot();

[B, A] = butter(3, [2 54]/(info.Fc/2));

trg_flag = 0;
save_flag = 0;

% stimulus_flag = 0;

% only_once = 1;


end
