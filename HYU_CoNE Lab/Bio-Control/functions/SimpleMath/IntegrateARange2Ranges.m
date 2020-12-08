% range �� range_set�� ���Խ�Ų��. ��ġ�� ������ ������ ��ģ��.
%range_set�� assending order�� ��Ʈ �Ǿ� �־�� �Ѵ�.
% ����ð��� ������ �ϱ� ���� range_set�� �̸� allocate �� ������ ���� ���� �ִ�. �� ���, range set��
% �ִ� range �� ������ nRange�� ���� �־�� �ϰ� ��� �ִ� range_set �� row �� Inf �� ���� assign
% �Ǿ� �־�� �Ѵ�.
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
    if nRanges==0 %������ �ϳ��� ���� ��
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

        if mod(i,2)==1 && range(1,1)>r2check(1) && range(1,1)<r2check(2)          %range�� ������ %range���� ���� (inter-range)���� ã�� ���
            pos_NewRange(1) = range(1,1);
            pos_overlapping_current_range_id(1) = (i+1)/2; % following range�� overapping range�� ��������
        elseif mod(i,2)==0 && range(1,1)>=r2check(1) && range(1,1)<=r2check(2)    %range�� ������ %range �ȿ��� ã�� ���
            pos_NewRange(1) = r2check(1);
            pos_overlapping_current_range_id(1) = i/2;  
        end
        if mod(i,2)==1 && range(1,2)>r2check(1) && range(1,2)<r2check(2)      %range�� ����   %range���� ���� (inter-range)���� ã�� ���
            pos_NewRange(2) = range(1,2);
            pos_overlapping_current_range_id(2) = (i-1)/2; % previous range�� overapping range�� ��������
            break;
        elseif mod(i,2)==0 && range(1,2)>=r2check(1) && range(1,2)<=r2check(2)    %range�� ����   %range �ȿ��� ã�� ���
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

