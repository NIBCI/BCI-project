%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
function diff = getAngleDifference(rad1,rad2)
    diff = abs(rad1 - rad2);
    if diff>pi()
        diff= 2*pi() - diff;
    end
    
end