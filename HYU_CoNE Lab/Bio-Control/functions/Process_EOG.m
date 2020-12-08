function Process_EOG(veog)
global pd;
global info;
global EM_online;
global tstack_triple;
persistent time_cur
global inst_signal 
% global biosemi2cogent_signal;
% global stimulus_flag
global only_once
% global trg
global EOG_quad
global udpH
global on_off
global trg_flag_forward
global trg_flag_backward
global disp_flag
global init_flag        % 지금이 눈 깜빡이고 나서 처음 보는 자극인지 표시.
                        % (처음보는 자극인데 분류결과 4 나오면, on_off -> false 되어야하므로 필요한 변수)
global tStart

try
% time setting for triple Blink
t = datevec(now);
temp_time=time_cur - t(6);
if ~isempty(temp_time)
    tstack_triple=tstack_triple+ ((-1)*temp_time); % 2번째 trial 시간을 계속 쌓음
end
time_cur = t(6);
if tstack_triple<0
    tstack_triple=0;
end
% disp(tstack_triple);
% myStop;
pd.EOG.addArray([veog]);
pd.EOG_ebRemoved.addArray([veog]);
%     pd.EOG_2checkSaccade.addArray([heog,veog]);
%     pd.EOG_saccade.addArray([heog,veog]);



%Eyeblink Detection
len_veog = size(veog,1);
len_process_data = info.Fc4EOG; %최근 1초 데이터를 가져온다.
len_margin_4interpolation = 10; %이 길이만큼 eyeblink 가 존재하지 않는 경우, 이전의 eyeblink 가 끝났다고 가정함

for i=1:len_veog
    pd.queuelength_eb_check.addArray(0);
    EM_online.add(veog(i));
    if size(EM_online.cur_detected_range,1)>0  %새로 검출된 경우
        %        myStop();
        pd.EOG_ebRemoved.set(EM_online.cur_detected_range(1), EM_online.cur_detected_range(2), nan, 1);
        %pd.EOG_ebRemoved.set(EM_online.cur_detected_range(1), EM_online.cur_detected_range(2), nan);
    end
end

%Interpolation of Eyeblink Regions
len_dataQueue = pd.EOG_ebRemoved.datasize;
if len_dataQueue<len_process_data  %interpolation 등에 필요한 데이터가 충분하지 않은 경우, 더 이상 진행하지 않는다.
    return;
end
tmp_d = pd.EOG_ebRemoved.getLastN(len_process_data);
bNan = isnan(tmp_d);
%eyeblink 구간이 존재하며, 해당구간이 종료된 경우
if  sum(bNan)>0 && sum(bNan(len_process_data-len_margin_4interpolation+1:len_process_data))==0 %|| only_once
    tmp_d = InterpolateNans(tmp_d,1);
    pd.EOG_ebRemoved.set(len_dataQueue-len_process_data+1,len_dataQueue,tmp_d,1);
    
    %Tripple blink check
    %         myStop;
    pd.queuelength_eb_check.addArray(1);
    
    nEB_inAShortTime = sum(pd.queuelength_eb_check.data);
    %         disp(nEB_inAShortTime);
    %         disp(info.EMG.time_stack4tripple);
    
    if nEB_inAShortTime > 3 && tstack_triple>3 %|| only_once
                %% 
        fwrite(udpH, '9')   % 시스템 on/off signal       %%%%%%%%%%%%%%%%%%
        if on_off
            on_off = false;
            trg_flag_forward = 0;
            trg_flag_backward = 0;
            disp_flag = 0;
            
        else
            on_off = true;
            init_flag = true;
            trg_flag_forward = 0;
            trg_flag_backward = 0;
            disp_flag = 0;
            
            tStart = tic;
        end
            %%
        tstack_triple=0;
        info.triple_count = info.triple_count + 1;
        string_cell = info.handles.listbox_progress.String;
        currt_cellsize = size(string_cell,1);
        cell_triple = {['Eye Blink(',num2str(info.triple_count),')']};
        set(info.handles.listbox_progress,'String',[string_cell;cell_triple])
        set(info.handles.listbox_progress,'Value',currt_cellsize+1);
        %%
        EOG_quad = 1;           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
%         if ~stimulus_flag       % EOG switch 에 의해 on/off 조절하는 변수. 현재는 의미없음.
%             %Cogent 로 시리얼 통신!!
% %             fwrite(info.serial, '1')
%             stimulus_flag = 1;
%         else
%             stimulus_flag = 0;
%         end
        
        only_once = 0;
    end
    
end

catch er
   myStop;
   keyboard; 
end

end