%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
function Process(  )
%PROCESS �� �Լ��� ��� ���� ��ġ
%   timer�� ���ؼ� �ֱ������� �����Ѵ�
%   �����͸� �ϳ� (���׸�Ʈ ����) �����ͼ� ó���Ѵ�.
%     global cnt;
%     cnt = cnt +1;
%     fprintf('%d\n',cnt');

    global data_all;
    global pos;
    global info;
    global option;
    global dataqueue;
    global pd;
    global EM_online;
    global trg
    %data input
    if pos+info.ExpectedSegmentLength-1 > size(data_all,1)
        myStop();
        return;
    end
%     myStop;
    segment = data_all(pos:pos+info.ExpectedSegmentLength-1,1:info.nTotalChannel);
    trg_segment = data_all(pos:pos+info.ExpectedSegmentLength-1,end);
    pos = pos+ info.ExpectedSegmentLength;

    

    %add to original data
    dataqueue.addArray(segment);
    trg.addArray(trg_segment);
    
    % notch filtering ���� (60Hz)
    if isempty(info.notchfilter.zf)
        tmp_d = dataqueue.getLastN(dataqueue.datasize);
        [notch_segment,info.notchfilter.zf]=filter(info.notchfilter.b,info.notchfilter.a,tmp_d,[],1);
    else
        [notch_segment,info.notchfilter.zf]=filter(info.notchfilter.b,info.notchfilter.a,segment,info.notchfilter.zf,1);
    end
    segment = notch_segment;
    
    %resampling
    segment_resmapled = segment(option.resamplingRate4EOG:option.resamplingRate4EOG:info.ExpectedSegmentLength,:);
    veog = segment_resmapled(:,info.ch_u) - segment_resmapled(:,info.ch_d);
    heog = segment_resmapled(:,info.ch_r) - segment_resmapled(:,info.ch_l);

    for i=1:size(veog,1)
        Process_EOG(heog(i),veog(i));
    end
end

function Process_EOG(heog,veog)    
    global pd;
    global info;
    global EM_online;
    global option;
    global output;
    global tstack_triple;
    persistent time_cur
    
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
    disp(tstack_triple);
    
    pd.EOG.addArray([heog,veog]);
    pd.EOG_ebRemoved.addArray([heog,veog]);
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
            pd.EOG_ebRemoved.set(EM_online.cur_detected_range(1), EM_online.cur_detected_range(2), nan, 2);
            %pd.EOG_ebRemoved.set(EM_online.cur_detected_range(1), EM_online.cur_detected_range(2), nan);
        end
    end

    %Interpolation of Eyeblink Regions
    len_dataQueue = pd.EOG_ebRemoved.datasize;
    if len_dataQueue<len_process_data  %interpolation � �ʿ��� �����Ͱ� ������� ���� ���, �� �̻� �������� �ʴ´�.
        return;
    end
    tmp_d = pd.EOG_ebRemoved.getLastN(len_process_data); 
    bNan = isnan(tmp_d(:,2));
    %eyeblink ������ �����ϸ�, �ش籸���� ����� ���
    if  sum(bNan)>0 && sum(bNan(len_process_data-len_margin_4interpolation+1:len_process_data))==0
        tmp_d(:,2) = InterpolateNans(tmp_d(:,2),1);
        pd.EOG_ebRemoved.set(len_dataQueue-len_process_data+1,len_dataQueue,tmp_d(:,2),2); 
        
        %Tripple blink check
%         myStop;        
        pd.queuelength_eb_check.addArray(1);

        nEB_inAShortTime = sum(pd.queuelength_eb_check.data);
%         disp(nEB_inAShortTime);
%         disp(info.EMG.time_stack4tripple);

        if nEB_inAShortTime > 2 && tstack_triple>3 
%         triple blink �߻��� 3�ʵ����� �߻����ϵ��� ����
%         if randi(20)==1 && info.EMG.time_stack4tripple>3 
%             myStop;
            tstack_triple=0;
            
            bTripleBlink = 1;
            fprintf('Tripple Blink\n');   
        end

    end
end

