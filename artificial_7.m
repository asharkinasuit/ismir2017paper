function [data] = artificial_8(b,n,m)
% produce artificial data, class 7: gradually increase or decrease the tempo
% (based on fair coin toss)

data = cell(1,n);
for i = 1:n
    data{i} = b;
    q = rand();
    if q > 0.5
        f = 6/5;
    else
        f = 5/6;
    end
    l1 = round(1/4*m); l2 = round(5/12*m);
    h1 = round(7/12*m); h2 = round(3/4*m);
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