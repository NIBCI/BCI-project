%Eyeblink 의 실시간 검출을 위해 디자인된 클래스
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
classdef eyeblink_master_online <handle
    properties
        dataqueue       = 0;
        v_dataqueue     = 0;
        acc_dataqueue   = 0;
        msdw            = 0;
        windowSize4msdw = 0;
        indexes_localMax= 0;
        indexes_localMin= 0;
        detectedRange_inQueue   = 0;
        msdw_minmaxdiff         = 0;
        buffer_4medianfilter    = 0;

        samplingFrequency2Use = 64;
        medianfilter_size     = 5;
        min_window_width = 6;   %6 = 6/64  = about 93.8 ms
        max_window_width = 15   %15 = 15/64  = about 234.4 ms
        
        threshold = 200;
        prev_threshold  =150;
        
        idx_cur = 0;
        
        %
        nMinimalData4HistogramCalculation =0;
        nDeletedPrevRange = 0;
        
        prev_detected_range = zeros(0,2);
        cur_detected_range  = zeros(0,2);
        
        
        %for automatic thresholding
        auto_threshold_method = 0;
        bEnableAdaption = 0;
        alpha = 0;
        v = 0.4;
        histogram = accHistogram;
        initTime_4Histogram_inSec = 8;
        nBin4Histogram = 20; 
        min_th_abs_ratio = 0.4;
    
        
    end
    
    methods
        function obj = eyeblink_master_online(queuelength, medianfilter_size)
            clear v_dataqueue;
            clear acc_dataqueue;
            clear msdw;
            clear windowSize4msdw;
            clear indexes_localMax;
            clear indexes_localMin;
            clear detectedRange_inQueue;
            clear msdw_minmaxdiff; %msdw 를 local min과 max와의 차이 형태로 변환시키는 데이터
            clear buffer_4medianfilter;
            
            obj.dataqueue           = circlequeue(queuelength,1);
            obj.v_dataqueue         = circlequeue(queuelength,1);
            obj.acc_dataqueue       = circlequeue(queuelength,1);
            obj.msdw                = circlequeue(queuelength,1);
            obj.windowSize4msdw     = circlequeue(queuelength,1);
            obj.indexes_localMax    = circlequeue(queuelength/2,1);
            obj.indexes_localMin    = circlequeue(queuelength/2,1);
            obj.detectedRange_inQueue =  circlequeue(queuelength/2,2);
            obj.msdw_minmaxdiff =  circlequeue(queuelength/2,1); %msdw 를 local min과 max와의 차이 형태로 변환시키는 데이터
            obj.msdw_minmaxdiff.data(:,:) = Inf;
            
            obj.buffer_4medianfilter = circlequeue(medianfilter_size,1);
            
            obj.nMinimalData4HistogramCalculation = round(obj.initTime_4Histogram_inSec*obj.samplingFrequency2Use); %5초. queuelength 보다 짧아야 한다. histogram을 만드는데 필요한 데이터 point의 개수가 아닌, source 데이터의 길이를 의미한다.
        end
        
        function obj = add(obj,newValue)
            obj.dataqueue.add(newValue);
            obj.idx_cur = obj.dataqueue.datasize;
            if size(obj.cur_detected_range,1)>0
                obj.prev_detected_range = obj.cur_detected_range;
            end
            [obj.cur_detected_range, obj.threshold, obj.nDeletedPrevRange] = eogdetection_msdw_online(obj.dataqueue, obj.v_dataqueue, obj.acc_dataqueue, obj.idx_cur, obj.min_window_width, obj.max_window_width, obj.threshold, obj.prev_threshold, obj.msdw, obj.windowSize4msdw, obj.indexes_localMin, obj.indexes_localMax, obj.detectedRange_inQueue, obj.min_th_abs_ratio, obj.nMinimalData4HistogramCalculation, obj.msdw_minmaxdiff, obj.histogram, obj.nBin4Histogram, obj.alpha, obj.v, obj.bEnableAdaption, obj.auto_threshold_method);

        end
    end
    
    
    
end