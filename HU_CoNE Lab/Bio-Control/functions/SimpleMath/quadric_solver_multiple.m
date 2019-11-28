%----------------------------------------------------------------------
% by Won-Du Chang, ph.D, 
% Research Professor @  Department of Biomedical Engineering, Hanyang University
% contact: 12cross@gmail.com
%---------------------------------------------------------------------
function [ r1,r2 ] = quadric_solver_multiple( a,b,c )
%2차원 방정식의 해를 구한다. ax^2+bx+c=0
    
    d = sqrt(b.^2-4*a.*c);
    
    r1 = (-b+d)./(2*a);
    r2 = (-b-d)./(2*a);
end

