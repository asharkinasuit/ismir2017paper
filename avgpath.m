% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT

function [avgpath,paths] = avgpath(chroma,m)
% calculates the average warping path when warping all of a set of mazurkas
% onto the mth one

n = length(chroma);

% first, resample all to the scale of the longest (no info loss please)
maxsize = max(cellfun(@length, chroma));
resampled = cell(n,1);
for i = 1:n
    l = size(chroma{i},2);
    space = linspace(1,l,maxsize)';
    resampled{i} = interp1(1:l,chroma{i}',space);
end

% then, compute the warping paths
warpto = resampled{m};
paths = cell(n,1);
parfor i = 1:n
    paths{i} = dtw_alt(warpto,resampled{i},[1 2 2; 2 1 2; 1 1 1;]);
    % _alt because a faster, non-parametrized dtw algorithm was originally used
end

% finally, take the average; interpolate paths where necessary
maxpathlen = max(cellfun(@length,paths));
avgpath = zeros(2,maxpathlen);
alphas = ones(n,1)/n; % weights: positive, summing to 1, currently use mean
for i = 1:n
    l = length(paths{i});
    if l < maxpathlen
        paths{i} = interp1(1:l,paths{i}',linspace(1,l,maxpathlen))';
    end
    avgpath = avgpath + alphas(i)*paths{i};
end