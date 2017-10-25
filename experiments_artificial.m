%% Script for the experiments on artificial data described in the paper
% Copyright (c) 2017 J.B. Peperkamp <jbpeperkamp@gmail.com>
% released under GPL - see file COPYRIGHT

s = rng;
rng(2017);

gens = {@artificial_1 @artificial_2 @artificial_3 @artificial_4 @artificial_5 @artificial_6 @artificial_7}; % generators
n = 100; % number of variants
m = 500;%250; % length of instances
runs = 100;
k = length(gens); % number of types of data
s = 0.001; % smoothing factor for spline approximation for derivative
resmean = cell(1,runs); % mean derivative path of each run
avpaths = cell(1,runs);
respca = cell(1,runs); % PCA for each run

% compute derivatives and pcas for each run
parfor mu = 1:runs
    resmean{mu} = cell(1,k);
    avpaths{mu} = cell(1,k);
    respca{mu} = cell(1,k);
    b = randn(12,m);
    for i = 1:k
        data = gens{i}(b,n,m);
        data{end+1} = b;
        [resmean{mu}{i},avpaths{mu}{i}] = avgdpath(data,false,s);
        respca{mu}{i} = paths_pca(data,true,avpaths{mu}{i});
    end
    fprintf('run %u done\n',mu); % to give some indication of progress
end

% take average of runs; some paths turn out to have one or two extra samples, resample where necessary
results_mean = cell(1,k);
results_pca = cell(1,k);
for i = 1:k
    maxl_mean = -1;
    maxl_pca = -1;
    for j = 1:runs
        if maxl_mean < length(resmean{j}{i})
            maxl_mean = length(resmean{j}{i});
        end
        if maxl_pca < length(respca{j}{i})
            maxl_pca = length(respca{j}{i});
        end
    end
    results_mean{i} = zeros(1,maxl_mean);
    results_pca{i} = zeros(maxl_pca,runs+1);
end
for i = 1:runs
    for j = 1:k
        if length(resmean{i}{j}) ~= length(results_mean{j})
            results_mean{j} = results_mean{j} + interp1(1:length(resmean{i}{j}),resmean{i}{j},linspace(1,length(resmean{i}{j}),length(results_mean{j})))/runs;
        else
            results_mean{j} = results_mean{j} + resmean{i}{j}/runs;
        end
        if length(respca{i}{j}) ~= length(results_pca{j})
            results_pca{j} = results_pca{j} + interp1(1:length(respca{i}{j}),respca{i}{j},linspace(1,length(respca{i}{j}),length(results_pca{j})))/runs;
        else
            results_pca{j} = results_pca{j} + respca{i}{j}/runs;
        end
    end
end

% plot results
styles = {'-' '--' '-.'};
fontsizeconst = 17;
f = figure; hold on;
y = [0.9 1.2];
for i = 1:k
    if i == 5
        legend(arrayfun(@(a)sprintf('Class %u',a),1:4,'UniformOutput',0));
        set(gca,'FontSize',fontsizeconst);
        xlabel('time (normalized)');
        ylabel('$\dot{\bar\varphi}$','Interpreter','latex');
        saveas(f,'mean_der_a2m_c1234_(500,100,100).eps','epsc');
        saveas(f,'mean_der_a2m_c1234_(500,100,100).fig');
        f = figure; hold on;
    end
    l = length(results_mean{i});
	plot(linspace(0,1,l),results_mean{i},styles{mod(i,3)+1});
end
legend(arrayfun(@(a)sprintf('Class %u',a),5:7,'UniformOutput',0));
set(gca,'FontSize',fontsizeconst);
xlabel('time (normalized)');
ylabel('$\dot{\bar\varphi}$','Interpreter','latex');
saveas(f,'mean_der_a2m_c567_(500,100,100).eps','epsc');
saveas(f,'mean_der_a2m_c567_(500,100,100).fig');

i = 4; % class of artificial data to be plotted
f = figure; hold on;
plot(linspace(0,1,length(results_pca{i})),results_pca{i}(:,1),styles{mod(i,3)+1});
plot(linspace(0,1,length(results_pca{i})),results_pca{i}(:,2),styles{mod(i,3)+1});
plot(linspace(0,1,length(results_pca{i})),results_pca{i}(:,3),styles{mod(i,3)+1});
title(sprintf('3 modes of class %u',i));
legend({'1st mode','2nd mode','3rd mode'});
set(gca,'FontSize',fontsizeconst);
xlabel('time (normalized)');
% !!! mind the file names: !!!
saveas(f,'pca_c4_(500,100,100).eps','epsc');
saveas(f,'pca_c4_(500,100,100).fig');

rng(s);
% try not to clutter workspace too much but leave things that take effort to compute:
clear s gens n m runs k mu b i data maxl_mean maxl_pca styles fontsizeconst f y l;