% This file wraps Dan Ellis' DTW computation; it is called dtw_alt for
% historical reasons. Compile dpcore.c before running this.

% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT

function [p,D] = dtw_alt(s,t,C)
% another way of computing the dtw distance, optionally specifying the
% steps that may be taken in rows of C as [i j c] for steps (i,j) at cost c
% (default = [1 2 2.0; 2 1 1.0; 1 1 1.0]: only diagonal steps, encouraging
% (1,1)); returns the path p and the distance matrix D

if nargin < 3
    C = [0 1 1.0; 1 0 1.0; 1 1 1.0];
end

M = pdist2(s,t);
[p,q,D,~] = dpfast(M,C);
p = [p; q]; %for compatibility with other functions