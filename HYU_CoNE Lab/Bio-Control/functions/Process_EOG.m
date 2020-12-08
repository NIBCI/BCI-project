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
global init_flag        % ������ �� �����̰� ���� ó�� ���� �ڱ����� ǥ��.
                        % (ó������ �ڱ��ε� �з���� 4 ������, on_off -> false �Ǿ���ϹǷ� �ʿ��� ����)
global tStart

try
% time setting for triple Blink
t = datevec(now);
temp_time=time_cur - t(6);
if ~isempty(temp_time)
    tstack_triple=tstack_triple+ ((-1)*temp_time); % 2��° trial �ð��� ��� ����
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
len_process_data = info.Fc4EOG; %�ֱ� 1�� �����͸� �����´�.
len_margin_4interpolation = 10; %�� ���̸�ŭ eyeblink �� �������� �ʴ� ���, ������ eyeblink �� �����ٰ� ������

for i=1:len_veog
    pd.queuelength_eb_check.addArray(0);
    EM_online.add(veog(i));
    if size(EM_online.cur_detected_range,1)>0  %���� ����� ���
        %        myStop();
        pd.EOG_ebRemoved.set(EM_online.cur_detected_range(1), EM_online.cur_detected_range(2), nan, 1);
        %pd.EOG_ebRemoved.set(EM_online.cur_detected_range(1), EM_online.cur_detected_range(2), nan);
    end
end

%Interpolation of Eyeblink Regions
len_dataQueue = pd.EOG_ebRemoved.datasize;
if len_dataQueue<len_process_data  %interpolation � �ʿ��� �����Ͱ� ������� ���� ���, �� �̻� �������� �ʴ´�.
    return;
end
tmp_d = pd.EOG_ebRemoved.getLastN(len_process_data);
bNan = isnan(tmp_d);
%eyeblink ������ �����ϸ�, �ش籸���� ����� ���
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
        fwrite(udpH, '9')   % �ý��� on/off signal       %%%%%%%%%%%%%%%%%%
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
%         if ~stimulus_flag       % EOG switch �� ���� on/off �����ϴ� ����. ����� �ǹ̾���.
%             %Cogent �� �ø��� ���!!
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