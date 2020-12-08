% Eyeblink�� ���ŵ� ������ �����ϴ� �Լ�
%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
function d = InterpolateNans(d, bRemoveTail)
    nChannel = size(d,2);

    len = size(d,1);
    cnt = 0;
    for i=1:len
        if( isnan(d(i,1)) )
            cnt = cnt+1;
        elseif cnt>0  %nan�� ���� ���
            idx_start = i-cnt;
            if(idx_start==1)
                d_before = zeros(1,nChannel);
            else
                d_before = d(idx_start-1,:);
            end
            
            
            d_after  = d(i,:);
            dx = (d_after - d_before)./(cnt+1);
            for j=1:cnt
                d(idx_start-1+j,:) = d_before + dx*j;
            end
            cnt =0;
        end
        
    end
    
    if bRemoveTail==1
        d(isnan(d(:,1)),:) = []; %������ �κ��� nan �� ��� ��� �����Ѵ�.
    end
end