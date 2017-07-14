function [data] = artificial_4(b,n,m,w,f,q)
% produce artificial data, class 4: like 2, but with a slow section in the
% middle ~1/3 of the sample, width varying by w samples (default = m/10),
% slowing down by a factor of f (default 2), with a fraction of 1/q speeding
% up again during the middle third of the slow part (default: q = 2)
if nargin < 6
    q = 2;
end
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
    if mod(i,q) == 0
        space1 = linspace(offset,offset+floor(len/3)-1,len*f/3);
        space2 = linspace(offset+floor(2*len/3),offset+len-1,len*f/3);
        slo1 = interp1(offset:offset+floor(len/3)-1,data{i}(:,offset:offset+floor(len/3)-1)',space1,'spline')';
        slo2 = interp1(offset+floor(2*len/3):offset+len-1,data{i}(:,offset+floor(2*len/3):offset+len-1)',space2,'spline')';
        data{i} = [data{i}(:,1:offset-1) slo1 data{i}(:,offset+floor(len/3):offset+floor(2*len/3)-1) slo2 data{i}(:,offset+len:end)];
    else
        space = linspace(offset,offset+len-1,len*f);
        slo = interp1(offset:offset+len-1,data{i}(:,offset:offset+len-1)',space,'spline')';
        data{i} = [data{i}(:,1:offset-1) slo data{i}(:,offset+len:end)];
    end
    data{i} = (data{i}-min(data{i}(:)))/(max(data{i}(:))-min(data{i}(:)));
end