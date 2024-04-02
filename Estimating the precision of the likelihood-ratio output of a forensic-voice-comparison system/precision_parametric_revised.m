% precision parametric
clear all
close all
addpath('.\cllr');


% load data from each parrallel set of LRs
load_file_name = '40s cal.mat';

load(['.\system output - revised S&J procedure\', load_file_name], 'LR_ss', 'indices_ss', 'LR_ds', 'indices_ds');

% indices are already sorted so that first col in lower num and second col higher


% convert from ln to log10
log_LR_ss = LR_ss ./ log(10);
log_LR_ds = LR_ds ./ log(10);


% get within-group mean and deviation from mean of each member of the group 
[mean_log_LR_ss, sortII_ss] = sort(mean(log_LR_ss, 2));
log_LR_ss = log_LR_ss(sortII_ss,:);
dev_from_mean_log_LR_ss = log_LR_ss - repmat(mean_log_LR_ss, 1, 2); % there are 2 members in each SS group

[mean_log_LR_ds, sortII_ds] = sort(mean(log_LR_ds, 2));
log_LR_ds = log_LR_ds(sortII_ds,:);
dev_from_mean_log_LR_ds = log_LR_ds - repmat(mean_log_LR_ds, 1, 4); % there are 4 members in each DS group

mean_log_LR = [mean_log_LR_ds; mean_log_LR_ss];


% % string out so that we can handle 4 values from ds and 2 from ss 
% dev_from_mean_log_LR = [dev_from_mean_log_LR_ds(:,1); dev_from_mean_log_LR_ds(:,2); dev_from_mean_log_LR_ds(:,3); dev_from_mean_log_LR_ds(:,4); dev_from_mean_log_LR_ss(:,1); dev_from_mean_log_LR_ss(:,1)];
% abs_dev_from_mean_log_LR = abs(dev_from_mean_log_LR);
% 
% mean_log_LR_repmat = [repmat(mean_log_LR_ds, 4, 1); repmat(mean_log_LR_ss, 2, 1)];
    
% n = length(mean_log_LR);
% n_ss = length(log_LR_ss);
% n_ds = length(log_LR_ds);
% N = n*6;

alpha = 0.05;

[num_ds, num_members_ds] = size(LR_ds);
[num_ss, num_members_ss] = size(LR_ss);

df = num_ds*(num_members_ds-1) + num_ss*(num_members_ss-1);
% N = num_ds*num_members_ds + num_ss*num_members_ss;

% CI calculation
% sigma_hat_squared = (sum(dev_from_mean_log_LR_ds(:).^2) + sum(dev_from_mean_log_LR_ss(:).^2)) / N;
sigma_hat_squared = (sum(dev_from_mean_log_LR_ds(:).^2) + sum(dev_from_mean_log_LR_ss(:).^2)) / df;
sigma_posterior = sqrt(sigma_hat_squared); % flat priors

CI_half = tinv(1-(alpha/2), df) * sigma_posterior;
CI_half

% Tippett plot with CI (using new version of plot_tippett)
plot_name = ['Fused mean LRs with 95% CI'];
plot_tippett(10.^(mean_log_LR_ss - CI_half), [], 10.^(mean_log_LR_ds - CI_half), [], [], true, '--', true, true);
plot_tippett(10.^(mean_log_LR_ss + CI_half), [], 10.^(mean_log_LR_ds + CI_half), [], [], false, '--', false, true);
plot_tippett(10.^mean_log_LR_ss, [], 10.^mean_log_LR_ds, [], plot_name, false, '-', false, false);
xlim([-6 6]); % adjust this as necessary


rmpath('.\cllr');


% HISTROGRAM PLOT
figure
hist([dev_from_mean_log_LR_ds(:); dev_from_mean_log_LR_ss(:)], 100);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','c','EdgeColor','b');
hold on
xx = [CI_half CI_half];
yy = get(gca, 'Ylim');
plot([0 0], yy, 'g');
plot(-xx, yy, 'r');
plot(xx, yy, 'r');
