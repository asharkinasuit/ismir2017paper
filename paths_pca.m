% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT

function [sorted_eigenvectors, sorted_eigenvalues, properpaths, avgpaths] = paths_pca(chroma, der, avgpaths, area, g)
%% compute a pca of the average paths of warping all the chromata to the MIDI
% der indicates whether to use the plain paths (false) or their derivatives (true) in the
% pca, area is the part of the path to consider (default: all)
% also optionally returns the avgpaths used so they don't have to be
% repeatedly computed; finally, g is the size of a gaussian smoothing
% window (default = 1, no smoothing)

if nargin < 5
    g = 1;
end

n = length(chroma);
g = gausswin(g);
g = g/sum(g);

if nargin < 3
% switch the commented sections to do all2all computation
%     avgpaths = cell(n,1);
%     parfor j = 1:n
%         avgpaths{j} = avgpath(chroma,j);
%     end
    [~,avgpaths] = avgpath(chroma,n);
end

% resample where necessary to keep paths of the same length
maxpathlen = max(cellfun(@length,avgpaths));
if nargin < 4
    area = 1:maxpathlen;
end
properpaths = zeros(length(area),n);
for j = 1:n
    l = length(avgpaths{j});
    if l < maxpathlen
        space = linspace(1,l,maxpathlen);
        avgpaths{j} = interp1(1:l,avgpaths{j}',space)';
    end
    if ~der
        properpaths(:,j) = avgpaths{j}(2,area);
    else
        avgpaths{j} = avgpaths{j}(:,area);
        pp = csaps(area,avgpaths{j}(2,:),0.001);
        dpp = fnder(pp);
        properpaths(:,j) = conv(fnval(dpp,area),g,'same');
    end
end

pathbar = mean(properpaths,2);
Y = bsxfun(@minus,properpaths,pathbar);
[V,D] = eig(Y'*Y);
principal_components = zeros(size(Y,1),length(V));
for j = 1:length(V)
    principal_components(:,j) = Y*V(:,j)/norm(Y*V(:,j));
end

eigenvalues = diag(D);
[sorted_eigenvalues,I] = sort(eigenvalues,'descend');
sorted_eigenvectors = principal_components(:,I);