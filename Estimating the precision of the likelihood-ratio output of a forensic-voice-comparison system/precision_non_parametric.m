% precision_non_parametric.m
%
% © 2010 Geoffrey Stewart Morrison
% http://geoff-morrison.net
% 2010-02-16
%
% See:
%   Morrison GS, Thiruvaran T, Epps J (2010) Estimating the likelihood-ratio output of a foresnsic-voice-comparison system.
%       Proceedings of Odyssey 2010 The Speaker and Language Recognition Workshop, Brno. 
%
% Use this script to estimate the credible interval for non-overlapping sets of of likelihood ratios.
% Use generate_non_overlapping_comparisons.m to create the correctly formatted input, or use supplied examples:
%   '20s cal.mat' or '40s cal.mat'.

clear all
close all
addpath('.\FoCal\cllr\'); % add path to cllr.m function (and associated functions) in Niko Brümmer's FoCal Toolkit  http://sites.google.com/site/nikobrummer/focal

% set k and ? parameters
num_nearest_neighbours = 500;
alpha = 0.05; % 95% CI


% load non-overlapping sets of of likelihood ratios 
load_file_name = '40s cal.mat';

load(['.\system output\', load_file_name], 'LR_ss', 'indices_ss', 'LR_ds', 'indices_ds');


% Cllr and Tippett plots of A lower to B higher and C lower to D higher in raw data
plot_name = 'A lower to B higher';
plot_tippett(exp(LR_ss(:,1)), [], exp(LR_ds(:,1)), [], plot_name, true, '-', true, false);
plot_name = 'C lower to D higher';
plot_tippett(exp(LR_ss(:,2)), [], exp(LR_ds(:,2)), [], plot_name, true, '-', true, false);
drawnow

Cllr_AB = cllr(LR_ss(:,1), LR_ds(:,1));
Cllr_CD = cllr(LR_ss(:,2), LR_ds(:,2));
Cllr_AB
Cllr_CD


% convert from ln to log10
log_LR_ss = LR_ss ./ log(10);
log_LR_ds = LR_ds ./ log(10);


% get within-group mean and deviation from mean of each member of the group 
[mean_log_LR_ss, sortII_ss] = sort(mean(log_LR_ss, 2));
log_LR_ss = log_LR_ss(sortII_ss,:);
dev_from_mean_log_LR_ss = log_LR_ss - repmat(mean_log_LR_ss, 1, 2); % there are 2 members in each same-speaker group

[mean_log_LR_ds, sortII_ds] = sort(mean(log_LR_ds, 2));
log_LR_ds = log_LR_ds(sortII_ds,:);
dev_from_mean_log_LR_ds = log_LR_ds - repmat(mean_log_LR_ds, 1, 4); % there are 4 members in each different-speaker group

mean_log_LR = [mean_log_LR_ds; mean_log_LR_ss];


% plot of mean logLR v deviance from mean
h_scatter = figure;
for I_dev = 1:4
    plot(mean_log_LR_ds, dev_from_mean_log_LR_ds(:,I_dev), '.r');
    hold on
end
for I_dev = 1:2
    plot(mean_log_LR_ss, dev_from_mean_log_LR_ss(:,I_dev), '.b');
    hold on
end
grid on
axis equal
xlabel('mean log10(LR)');
ylabel('deviation from mean');
hold off
drawnow


% string out so that we can handle 4 values from DS and 2 from SS 
dev_from_mean_log_LR = [dev_from_mean_log_LR_ds(:,1); dev_from_mean_log_LR_ds(:,2); dev_from_mean_log_LR_ds(:,3); dev_from_mean_log_LR_ds(:,4); dev_from_mean_log_LR_ss(:,1); dev_from_mean_log_LR_ss(:,1)];
abs_dev_from_mean_log_LR = abs(dev_from_mean_log_LR);

mean_log_LR_repmat = [repmat(mean_log_LR_ds, 4, 1); repmat(mean_log_LR_ss, 2, 1)];
    
n = length(mean_log_LR);
n_ss = length(log_LR_ss);
n_ds = length(log_LR_ds);


% eatimate CI for each comparison pair in the data
CI_half = NaN(n, 1);
hwait = waitbar(0, ['Calculating ', num2str((1-alpha)*100, '%0.0f'), '% CI for each comparison in data']);
for II = 1:n
    % find the nearest neighbours
    diff_from_mean_log_LR = mean_log_LR - mean_log_LR(II);
    abs_diff_from_mean_log_LR = abs(diff_from_mean_log_LR);
    [diff_from_mean_log_LR_sorted, II_diff] = sort(abs_diff_from_mean_log_LR);
        
    II_nearest = II_diff(1:num_nearest_neighbours);
    II_nearest_logical = false(n,1);
    II_nearest_logical(II_nearest) = true;
    II_nearest_logical_ds = II_nearest_logical(1:n_ds);
    II_nearest_logical_ss = II_nearest_logical(n_ds+1:end);
    II_nearest_repmat = [repmat(II_nearest_logical_ds, 4, 1); repmat(II_nearest_logical_ss, 2, 1)];
    
    nearest_mean_log_LR_repmat = mean_log_LR_repmat(II_nearest_repmat);
    nearest_abs_dev_from_mean_log_LR = abs_dev_from_mean_log_LR(II_nearest_repmat);
    
    % sucessively remove the alpha least extreme deviation-from-mean values
    num_tokens_remaining = length(nearest_mean_log_LR_repmat);
    num_to_discard = round(num_tokens_remaining * alpha);
    num_to_stop = round(num_tokens_remaining * alpha * 2);
    num_to_stop_plus = num_to_stop + num_to_discard;
    
    y = nearest_abs_dev_from_mean_log_LR;
    x = nearest_mean_log_LR_repmat;
    
    while num_tokens_remaining >= num_to_stop;
        % fit a linear regression
        intercept_col = ones(num_tokens_remaining, 1);
        [b, bint, residuals] = regress(y, [intercept_col, x]);
        if num_tokens_remaining == num_to_stop, break, end
        [residuals_sorted, II_residuals_sorted] = sort(residuals);
        
        % discard the portion of the data with the lowest signed residuals
        y = y(II_residuals_sorted);
        x = x(II_residuals_sorted);
        
        if num_tokens_remaining >= num_to_stop_plus
            num_tokens_remaining = num_tokens_remaining - num_to_discard;
            y = y(num_to_discard + 1 : end);
            x = x(num_to_discard + 1 : end);
        else
            num_tokens_remaining = num_to_stop;
            y = y(end - num_to_stop + 1 : end);
            x = x(end - num_to_stop + 1 : end);
        end

    end
    
    % use the linear regression fitted to the most extreme alpha*2 data points to estimate the CI
    CI_half(II) = b(1) + b(2)*mean_log_LR(II);
    
    waitbar(II/n, hwait)
end
close(hwait)


% add CIs to scatterplot
figure(h_scatter);
[mean_log_LR_sorted, II_mean_log_LR_sorted] = sort(mean_log_LR);
CI_half_sorted = CI_half(II_mean_log_LR_sorted);
hold on
plot(mean_log_LR_sorted, CI_half_sorted, '-g');
plot(mean_log_LR_sorted, -CI_half_sorted, '-g');
hold off

% Tippett plot with CI (using new version of plot_tippett)
plot_name = ['Fused mean LRs with ', num2str((1-alpha)*100, '%0.0f'), '% CI'];
CI_half_ds = CI_half(1:n_ds);
CI_half_ss = CI_half(n_ds+1:end);
plot_tippett(10.^(mean_log_LR_ss - CI_half_ss), [], 10.^(mean_log_LR_ds - CI_half_ds), [], [], true, '--', true, true);
plot_tippett(10.^(mean_log_LR_ss + CI_half_ss), [], 10.^(mean_log_LR_ds + CI_half_ds), [], [], false, '--', false, true);
plot_tippett(10.^mean_log_LR_ss, [], 10.^mean_log_LR_ds, [], plot_name, false, '-', false, false);
xlim([-6 6]); % adjust this as necessary

% calculate Cllr for means LRs
Cllr_means = cllr(log(10.^mean_log_LR_ss), log(10.^mean_log_LR_ds));
Cllr_means

mean_minus3_0 = mean(CI_half_sorted(mean_log_LR_sorted > -3 & mean_log_LR_sorted < 0));
mean_minus3_0

mean_0_3 = mean(CI_half_sorted(mean_log_LR_sorted > 0 & mean_log_LR_sorted < 3));
mean_0_3

rmpath('.\FoCal\cllr\');
