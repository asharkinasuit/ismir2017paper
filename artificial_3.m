function [data] = artificial_3(b,n,m,w,f)
% produce artificial data, class 3: like 2, but with a slow section in the
% middle ~1/3 of the sample, width varying by w samples (default = m/10),
% slowing down by a factor of f (default 2)
% b = base series to create variations of;
% n = number of time series, m = length of each
if nargin < 5
    f = 1.2;
end
if nargin < 4
    w = m/10;
end

data = cell(1,n);
for i = 1:n
    data{i} = b;
    rf = randi(w);
    len = floor(m/3)+rf;
    offset = floor(m/3)-ceil(rf/2);
    space = linspace(offset,offset+len-1,len*f);
    slo = interp1(offset:offset+len-1,data{i}(:,offset:offset+len-1)',space,'spline')';
    data{i} = [data{i}(:,1:offset-1) slo data{i}(:,offset+len:end)];
    data{i} = (data{i}-min(data{i}(:)))/(max(data{i}(:))-min(data{i}(:)));
end