% range 를 range_set에 포함시킨다. 겹치는 구간이 없도록 합친다.
%range_set은 assending order로 소트 되어 있어야 한다.
% 수행시간을 빠르게 하기 위해 range_set을 미리 allocate 한 다음에 보낼 수도 있다. 이 경우, range set에
% 있는 range 의 개수를 nRange에 보내 주어야 하고 비어 있는 range_set 의 row 는 Inf 로 값이 assign
% 되어 있어야 한다.
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
function [FP_Range_Integrated, nRanges] = IntegrateARange2Ranges(range_set, range, nRanges)
    bRangeSetAllocated = 1;
    if nargin<3
        nRanges = size(range_set,1);
        bRangeSetAllocated = 0;
    end
    if nRanges==0 %구간이 하나도 없을 때
        if bRangeSetAllocated==1
            FP_Range_Integrated = range_set;
            FP_Range_Integrated(1,:) = range;
        else
            FP_Range_Integrated = range;
        end
        nRanges = 1;
        return;
    end
    
    pos_overlapping_current_range_id = [];
    
    pos_NewRange = [];
    for i=1:nRanges*2+1
        if i==1
            r2check = [-Inf range_set(1,1)];
        elseif i==2*nRanges+1
            r2check = [range_set(nRanges,2) Inf];
        elseif mod(i,2)==1
            r2check = [range_set((i-1)/2,2) range_set((i+1)/2,1)];
        else
            r2check = [range_set(i/2,1) range_set(i/2,2)];
        end

        if mod(i,2)==1 && range(1,1)>r2check(1) && range(1,1)<r2check(2)          %range의 시작점 %range들의 사이 (inter-range)에서 찾은 경우
            pos_NewRange(1) = range(1,1);
            pos_overlapping_current_range_id(1) = (i+1)/2; % following range를 overapping range의 시작으로
        elseif mod(i,2)==0 && range(1,1)>=r2check(1) && range(1,1)<=r2check(2)    %range의 시작점 %range 안에서 찾은 경우
            pos_NewRange(1) = r2check(1);
            pos_overlapping_current_range_id(1) = i/2;  
        end
        if mod(i,2)==1 && range(1,2)>r2check(1) && range(1,2)<r2check(2)      %range의 끝점   %range들의 사이 (inter-range)에서 찾은 경우
            pos_NewRange(2) = range(1,2);
            pos_overlapping_current_range_id(2) = (i-1)/2; % previous range를 overapping range의 시작으로
            break;
        elseif mod(i,2)==0 && range(1,2)>=r2check(1) && range(1,2)<=r2check(2)    %range의 끝점   %range 안에서 찾은 경우
            pos_NewRange(2) = r2check(2);
            pos_overlapping_current_range_id(2) = i/2; 
            break;
        end
    end
    
    FP_Range_Integrated = range_set;
    
    if isempty(pos_NewRange)
        return;
    else
        FP_Range_Integrated(nRanges+1,:) = pos_NewRange;
        nRanges = nRanges+1;
    end
    if ~isempty(pos_overlapping_current_range_id) && pos_overlapping_current_range_id(2)>=pos_overlapping_current_range_id(1)
        if pos_overlapping_current_range_id(1)<=0
            pos_overlapping_current_range_id(1) = 1;
        elseif pos_overlapping_current_range_id(1)>=nRanges-1
            pos_overlapping_current_range_id(2) = nRanges-1;
        end
        FP_Range_Integrated(pos_overlapping_current_range_id(1):pos_overlapping_current_range_id(2),:) = Inf;
        nRanges = nRanges - (pos_overlapping_current_range_id(2) - pos_overlapping_current_range_id(1)+1);
    end
    FP_Range_Integrated = sortrows(FP_Range_Integrated,1);
end

