function varargout = eog_switch_gui(varargin)
% EOG_SWITCH_GUI MATLAB code for eog_switch_gui.fig
%      EOG_SWITCH_GUI, by itself, creates a new EOG_SWITCH_GUI or raises the existing
%      singleton*.
%
%      H = EOG_SWITCH_GUI returns the handle to a new EOG_SWITCH_GUI or the handle to
%      the existing singleton*.
%
%      EOG_SWITCH_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EOG_SWITCH_GUI.M with the given input arguments.
%
%      EOG_SWITCH_GUI('Property','Value',...) creates a new EOG_SWITCH_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eog_switch_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eog_switch_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eog_switch_gui

% Last Modified by GUIDE v2.5 17-Oct-2017 05:47:59

% Begin initialization code - DO NOT EDIT

cd('E:\박성훈\AR_SSVEP\Online_Experiment')

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eog_switch_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @eog_switch_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...7
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before eog_switch_gui is made visible.
function eog_switch_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eog_switch_gui (see VARARGIN)

% Choose default command line output for eog_switch_gui
global info;
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eog_switch_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% 함수 추가
addpath(genpath(fullfile(cd,'functions')));



% --- Outputs from this function are returned to the command line.
function varargout = eog_switch_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_progress.
function listbox_progress_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_progress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_progress contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_progress





% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global info;

% if info.input_mode == 0 % file mode
%     start(info.timer_main);
%     start(info.timer_onPaint);
% elseif info.input_mode == 1 % online mode
    start(info.timer_main_mem);
    start(info.timer_onPaint);
    %readdata_from_udp();
set(handles.pushbutton_initialize,'Enable','off');


% --- Executes on button press in pushbutton_stop.
function pushbutton_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myStop();
% set(handles.pushbutton_start,'Enable','off');


% --- Executes on button press in pushbutton_file.
function pushbutton_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global info;
global data_all;
[FileName,PathName,FilterIndex] = uigetfile(['.','\*.mat']);
    
if FileName==0
    return;
end
info.filepath = [PathName,FileName];
OUT=load(info.filepath);
% datanames=fieldnames(OUT);
% data_all = OUT.raw_signal_reserve.mat;
data_all = OUT.data_all;
% eval(sprintf('data_all=OUT.%s;',datanames{1}));

hObject =  findobj(info.handles.pushbutton_start);
hObject.Enable = 'on';
info.input_mode = 0; % file mode
    
    
% --- Executes on button press in pushbutton_initialize.
function pushbutton_initialize_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_initialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global setup
initialize(handles);



function edit_progress_Callback(hObject, eventdata, handles)
% hObject    handle to edit_progress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_progress as text
%        str2double(get(hObject,'String')) returns contents of edit_progress as a double


% --- Executes during object creation, after setting all properties.
function listbox_progress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_progress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global info;
global raw_signal_reserve
global save_flag
global path_name
global Subj_name

raw_signal_reserve.mat = raw_signal_reserve.mat(1:raw_signal_reserve.n_data, :);

% global EMG_online
% global EM_online
% results = handles.listbox_progress.String;
current_time=datestr(now,'yymmdd_HHMMSS');

%용량을 많이 차지하는 handle 지우기
if isfield(info,'handles')
    info=rmfield(info,'handles');
end
uisave({'raw_signal_reserve','info'},[path_name, '\', Subj_name, '\결과',current_time,'.mat']);

save_flag = 1;


% --- Executes on button press in pushbutton_debug.
function pushbutton_debug_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bDebug;
bDebug=1;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in pushbutton_exit.
function pushbutton_exit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global udpH;
global save_flag
global path_name
global Subj_name

if ~save_flag
    global info;
    global raw_signal_reserve
    raw_signal_reserve.mat = raw_signal_reserve.mat(1:raw_signal_reserve.n_data, :);
    
    current_time=datestr(now,'yymmdd_HHMMSS');
    
    %용량을 많이 차지하는 handle 지우기
    if isfield(info,'handles')
        info=rmfield(info,'handles');
    end
    uisave({'raw_signal_reserve','info'},[path_name, '\', Subj_name, '\결과',current_time,'.mat']);
end
% closePreview(info.cam);
try
    fclose(udpH);
end

close all force;
clear all;


% --- Executes on button press in pushbutton_instruction_on.
function pushbutton_instruction_on_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_instruction_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global info;
global inst_signal;
inst_signal = 1;
sound(info.sound.inst, info.sound.inst_Fs);


