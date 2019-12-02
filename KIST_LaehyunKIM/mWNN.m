function [y t] = mWNN(x)
tic;
load network;

[m n] = size(x);

level = wmaxlev(n, 'coif3');

for i = 1:m
[inputs(i,:) L] = wavedec(x(i,:), level, 'coif3');
end

for i = 1:m
outputs(i,:) = net3(inputs(i,:));    
end

for i = 1:m
y(i,:) = waverec(outputs(i,:), L, 'coif3'); 
end

toc;
t = toc;
end