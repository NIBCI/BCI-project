%----------------------------------------------------------------------
% by Won-Du Chang, ph.D,
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
function Process_mem(  )
%PROCESS 이 함수의 요약 설명 위치
%   timer에 의해서 주기적으로 동작한다
%   데이터를 하나 (세그먼트 단위) 가져와서 처리한다.



global info;
% global option;
global dataqueue;
% global pd;
%global EM_online;
global raw_signal_reserve;
global trg inst_signal;
global CCA_buffer
global A;
global B;
% global trg_flag
% global stimulus_flag
% global buffer_size
global trg_flag_forward
global trg_flag_backward
global disp_flag
global EOG_quad
global udpH
global CCA_delay
global on_off
global tStart
global init_flag
global prev_Answer
global threshold
global block_flag

% start_ch = 258;
% end_ch = 262;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 데이터 읽어오는 코드 - 시작
try
%add to original data
try
    seg_from_bio = biosemix([info.nChannel 0]);
    
    if isempty(seg_from_bio)
        return;
    end
    
    segment = 10^6*double(single(seg_from_bio(2:end, :)') * 0.262 / 2^31);
    
catch me
    if strfind(me.message,'BIOSEMI device')
        
        fprintf(strrep([me.message 'Recalling the BIOSEMI device again.'], sprintf('\n'),'. '));
        
        clear biosemix;
        seg_from_bio = biosemix([info.nChannel 0]);
        segment = 10^6*double(single(seg_from_bio(2:end, :)') * 0.262 / 2^31);

    else
        rethrow(me);
    end
end

% segment = biosemi_signal_recieve();

if size(segment,1) ==0
   return;
else
    trg_sig = seg_from_bio(1,:)';
end
segment = segment(:, 1:end);
segLength_dynamic = size(segment,1);

% myStop;
dataqueue.addArray(segment);

% CCA 코드

if on_off               % 눈깜빡임을 통해 현재 기기제어 시스템이 켜져 있는지, 꺼져 있는지 판단함.
    
    % ----------------------- a-b 버전
    if ~isempty(find(trg_sig == 97, 1)) % 정상적으로 시작 트리거 전송된 경우
        
        trg_flag_forward = 1;
        tStart = tic;
        disp_flag = 1;
    
    
    elseif exist('tStart', 'var') && ~isempty(tStart) && ~trg_flag_forward
        if ~isempty(find(trg_sig == 98, 1)) && (round(toc(tStart), 2) >= 3)

            trg_flag_backward = 1;
            disp('Backward')
            disp_flag = 1;
            tStart = tic;
        end
    end
    
    
    CCA_seg = segment(:, [info.nSSVEP_ch info.ReRef]);      % SSVEP 3ch 와 Cz 모두 받음
    
    if disp_flag
        disp('자극 트리거 인식')
        disp_flag = 0;
    end
    for i = 1 : size(CCA_seg, 1)                            % 트리거 관계없이 항상 데이터 계속 circlequeue 에 저장
        CCA_buffer.addArray(CCA_seg(i, :));
        %     if CCA_buffer.datasize == CCA_buffer.length
        %         break;
        %     end
    end
    
    if exist('tStart', 'var') && ~isempty(tStart)
        if trg_flag_forward && (round(toc(tStart), 2) >= (2.5+CCA_delay))
            temp = CCA_buffer.getLastN(CCA_buffer.length);  % 2.5 초 데이터 정확히 가져오기 위함. datasize 로 하면 몇샘플 모자랄때 있으니까.
            Signal_CCA = zeros(CCA_buffer.length, length(info.nSSVEP_ch));
            for i = 1:length(info.nSSVEP_ch)
                Signal_CCA(:, i) = temp(:, i) - temp(:, end);       % Cz 로 re-referencing
            end
            Signal_CCA = filtfilt(B, A, Signal_CCA);
            [Answer, S] = EMSI_S(info.CCA.Stim_freq, Signal_CCA', info.Fc, 4, true);
            %         eval(['fwrite([udpH, ', num2str(Answer),'])'])
            
            if max(S) > threshold
                fwrite(udpH, num2str(Answer));
                
                fprintf('classification result is %d \n', Answer);
                %             CCA_buffer = circlequeue(info.CCA.buffer_size, length([info.nSSVEP_ch, info.ReRef])); %4초 CCA_buffer 초기화. 저기 3은 초가 아니라 3채널 데이터.
                
                if (init_flag || prev_Answer == 4) && Answer == 4
                    on_off = false;
                    trg_flag_forward = 0;
                    trg_flag_backward = 0;
                    disp_flag = 0;
                end
                
                prev_Answer = Answer;
                
                if init_flag
                    init_flag = false;
                end
            else
                disp('== Blocked ==')
                block_flag = true;
            end

            trg_flag_forward = 0;
            trg_flag_backward = 0;
            tStart = tic;
            
        elseif trg_flag_backward && (round(toc(tStart), 2) >= CCA_delay)
            temp = CCA_buffer.getLastN(CCA_buffer.length);
            Signal_CCA = zeros(CCA_buffer.length, length(info.nSSVEP_ch));
            
            for i = 1:length(info.nSSVEP_ch)
                Signal_CCA(:, i) = temp(:, i) - temp(:, end);       % Cz 로 re-referencing
            end
            
            Signal_CCA = filtfilt(B, A, Signal_CCA);
            
            [Answer, S] = EMSI_S(info.CCA.Stim_freq, Signal_CCA', info.Fc, 4, true);
            
            if max(S) > threshold
                fwrite(udpH, num2str(Answer));
                
                fprintf('classification result is %d \n',Answer);
                %             CCA_buffer = circlequeue(info.CCA.buffer_size, length([info.nSSVEP_ch, info.ReRef])); %4초 CCA_buffer 초기화. 저기 3은 초가 아니라 3채널 데이터.
                
                if (init_flag || prev_Answer == 4) && Answer == 4
                    on_off = false;
                    trg_flag_forward = 0;
                    trg_flag_backward = 0;
                    disp_flag = 0;
                end
                
                prev_Answer = Answer;
                
                if init_flag
                    init_flag = false;
                end
            else
                disp('== Blocked ==')
                block_flag = true;
            end
            
            trg_flag_backward = 0;
            trg_flag_forward = 0;
            tStart = tic;
            
        end
    end
end




% Trigger 주고 받기
%instruction 눈을 네번깜박여주세요: 10
for i = 1 : segLength_dynamic
    if inst_signal == 1
        trg.add(10);        % instruction 버튼 누르면 트리거로 10 보냄.
        inst_signal = 0;
%         threshold = 0.0065;
    elseif EOG_quad == 1
        trg.add(11);
        EOG_quad = 0;
    elseif exist('Answer', 'var') && Answer
        trg.add(Answer);
        Answer = 0;
    elseif block_flag
        trg.add(1111);
        block_flag = false;
    else
        trg.add(trg_sig(i));
    end
end
% if getCogentTRG == 1
%    SSVEP_CCA 
% end
%Cogent 로 시리얼 통신!!
% tic
% fscanf(info.serial)  
% toc;
        

% Instruction Trigger 확인
% for i = 1 : segLength_dynamic
%     trg.add(trg_sig(i));
% end
% Raw Signal Reserve (데이터 백업용)
% myStop;
raw_signal_reserve.mat(raw_signal_reserve.n_data+1:raw_signal_reserve.n_data+segLength_dynamic, :) = [segment, trg.getLastN(segLength_dynamic)];
raw_signal_reserve.n_data = raw_signal_reserve.n_data + segLength_dynamic;

% filtering notch, BPF
if isempty(info.f.lZn)
    [EOG_seg,info.f.lZn] = filter(info.f.lB,info.f.lA,...
       segment,[],1);
else
    [EOG_seg,info.f.lZn] = filter(info.f.lB,info.f.lA,segment,info.f.lZn,1);
end 
% notch_segment = segment;



%resampling
[info.DM, segment_resmapled] = online_downsample_apply(info.DM, EOG_seg');
% segment_resmapled = notch_segment(option.resamplingRate4EOG:option.resamplingRate4EOG:info.ExpectedSegmentLength,:);
% segment_resmapled = segment_resmapled';
% myStop;
veog = segment_resmapled(:,info.ch_u) - segment_resmapled(:,info.ch_d);
% heog = segment_resmapled(:,info.ch_r) - segment_resmapled(:,info.ch_l);

    
% 데이터 읽어오는 코드 - 끝
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% myStop;
Process_EOG (veog);
catch er
    myStop;
    keyboard;
end

end




    

