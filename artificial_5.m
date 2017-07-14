function [data] = artificial_5(b,n,m,f,w)
% produce artificial data, class 5: gradually modify tempo instead of jumping 

if nargin < 5
    w = floor(m/18);
end
if nargin < 4
    f = 1.2;
end

data = cell(1,n);
for i = 1:n
    data{i} = b;
    X = randi(w);
    l1 = round(1/4*m-1/2*X); l2 = round(5/12*m+1/2*X);
    h1 = round(7/12*m-1/2*X); h2 = round(3/4*m+1/2*X);
    len1 = l2-l1;
    len2 = h1-l2;
    len3 = h2-h1;
    space1 = linspace(l1^f,l2^f,len1).^(1/f);
    space2 = linspace(l2+1,h1-1,len2*f);
    space3 = linspace(h1^(1/f),h2^(1/f),len3).^f;
    p1 = interp1(l1:l2,data{i}(:,l1:l2)',space1,'spline')';
    p2 = interp1(l2+1:h1-1,data{i}(:,l2+1:h1-1)',space2,'spline')';
    p3 = interp1(h1:h2,data{i}(:,h1:h2)',space3,'spline')';
    data{i} = [data{i}(:,1:l1-1) p1 p2 p3 data{i}(:,h2+1:end)];
    data{i} = (data{i}-min(data{i}(:)))/(max(data{i}(:))-min(data{i}(:)));
end