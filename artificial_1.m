function [data] = artificial_1(b,n,m,s)
% produce artificial data, type 2: chroma vectors that form variants of a
% base chroma time series (b) with each vector ~ N(0,1)^12; variants are
% additive noise
% n = number of time series, m = length of each, s = noise reduction
% (higher means less noisy; default = 4)
if nargin < 4
    s = 2;
end

%base = randn(12,m);
data = cell(1,n);
for i = 1:n
    data{i} = b+randn(12,m)/s;
    data{i} = (data{i}-min(data{i}(:)))/(max(data{i}(:))-min(data{i}(:)));
end