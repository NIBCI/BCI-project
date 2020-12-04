function c= getclass(pvalue,alpha)
cInd = find(pvalue < alpha);

if isempty(cInd)
    c = -1;
else
    [~,c] = min(pvalue);
end
    