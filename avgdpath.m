% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT
% Special thanks to K.A. Hildebrandt for help figuring out the spline approximation

function [path,avgpaths] = avgdpath(chroma,all2all,s,avgpaths,n)
% compute the average of the derivatives of all paths when warping chroma,
% all on all if all2all, otherwise all to the nth (default: all2all=true);
% default n: |chroma| (due to convention of placing MIDI there)
% enable caching avgpaths as well: pass the avgpaths output from a previous run
% of this function as the fourth argument to prevent recomputation
% s is the smoothing factor for the spline approximation used in derivative calculation

if nargin < 2
    all2all = true;
end
if nargin < 3
    s = 0.1;
end
if nargin < 5
    n = length(chroma);
end

if nargin < 4
    if all2all
        avgpaths = cell(n,1);
        parfor j = 1:n
            avgpaths{j} = avgpath(chroma,j);
        end
    else
        [~,avgpaths] = avgpath(chroma,n);
    end
end

% resample if needed to keep all paths same length
maxpathlen = max(cellfun(@length,avgpaths));
derivatives = zeros(n,maxpathlen);
for j = 1:n
    l = length(avgpaths{j});
    if l < maxpathlen
        space = linspace(1,l,maxpathlen);
        avgpaths{j} = interp1(1:l,avgpaths{j}',space)';
    end
    space = linspace(1,maxpathlen,maxpathlen);
    pp = csaps(space,avgpaths{j}(2,:),s);
    dpp = fnder(pp);
    derivatives(j,:) = fnval(dpp,space)/n;
end
path = sum(derivatives);