function p = getpval(D)

Nclass = size(D,1);
Niter = size(D,2);
Nsample = size(D,3);
p = zeros(Nclass,Nsample);
for n = 1:Nclass
    D1 = squeeze(D(n,:,:));
    D2 = squeeze(reshape(D(setdiff(1:Nclass,n),:,:),(Nclass-1)*Niter,Nsample));
[~,P]=ttest2(D1,D2);
p(n,:) = P;

end