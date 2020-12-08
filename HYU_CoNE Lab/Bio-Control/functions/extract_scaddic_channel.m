% saccade  ������ ���� �Լ�. �� ä�κ��� �����ϴ� extract_scaddic�� �����Լ���.
% extract_scaddic�� ���ؼ��� ȣ���� ��.
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
function [pd, bSaccade] = extract_scaddic_channel(d,scales, threshold)
    
    coefs = cwt(d,scales,'haar');
    len = length(d);
    coefs(1,len-ceil(scales/2)+1:len) = 0;
    
    bSaccade = abs(coefs)>threshold;
    bSaccade(floor(len-scales/2)+1:len) = 0;
    %s = std(coefs);
    %m = mean(coefs);
    
    %threshold = m+s;
    
    diff = d(2:len,1) - d(1:len-1,1);
    pd = zeros(len,1);
    for i=2:len;
        if i<=len-scales/2 && abs(coefs(i))>threshold
            pd(i) = pd(i-1) + diff(i-1);
        else
            pd(i) = pd(i-1);
        end
    end
end