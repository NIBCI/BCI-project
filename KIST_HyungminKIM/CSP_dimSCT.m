function W_n = CSP_dimSCT(data1,data2)
% data dimension: samplepoints,channel,trial
data1 = permute(data1,[2 1 3]);
data2 = permute(data2,[2 1 3]);

% normalized covariance matrix
for i=1:size(data1,3)
    X=data1(:,:,i);
    Rx1(:,:,i)=(X*X')/trace(X*X');
end
for j=1:size(data2,3)
    Y=data2(:,:,j);
    Ry1(:,:,j)=(Y*Y')/trace(Y*Y');
end

% n=1:length(Rx);
%for o=1:length(Rx), Rx(o,:)=Rx(o,:)./norm(Rx(o,:)); end
%for p=1:length(Ry), Ry(p,:)=Ry(p,:)./norm(Ry(p,:)); end
% average covariance matrix 
Rx2=mean(Rx1,3);
Ry2=mean(Ry1,3);
% Ramoser equation (2)
R=(Rx2+Ry2);
% Sort eigenvalues in descending order
[U,Lambda] = eig(R);
[Lambda,ind] = sort(diag(Lambda),'descend');
U=U(:,ind);
% Find Whitening Transformation Matrix - Ramoser Equation (3)
P=sqrt(inv(diag(Lambda)))*U';
% Whiten Data Using Whiting Transform - Ramoser Equation (4)
S{1}=P*Rx2*P';
S{2}=P*Ry2*P';
% generalized eigenvectors/values
[B,G] = eig(S{1},S{2});
[~,ind] = sort(diag(G));
B = B(:,ind);
% csp filter
W=(B'*P);
% normalize row (why do this??), normalize for drawing: enough for scaling 
for i=1:length(ind)
    W_n(i,:)=W(i,:)./norm(W(i,:)); 
end

%A could be used for reconstructing original EEG, as shown in reference
%[7] in citations
% A=pinv(W);
end