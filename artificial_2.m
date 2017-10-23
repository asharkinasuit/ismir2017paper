function [data] = artificial_2(b,n,m,f)
% produce artificial data, class 2: base of N(0,1)^12 chroma vectors (b)
% resampled each with f more and less samples to m-nf/2...m+nf/2 samples to
% simulate uniform tempo variations; default f = 1
% n = number of time series, m = length of each
if nargin < 4
    f = 1;
end

b = (b-min(b(:)))/(max(b(:))-min(b(:)));
data = cell(1,n);
s = floor(n/2);
for i = 1:n
    space = linspace(1,m,m+(i-1-s)*f);
    data{i} = interp1(1:m,b',space,'spline')';
end