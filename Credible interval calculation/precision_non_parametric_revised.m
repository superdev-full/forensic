% precision non-parametric
clear all
close all
addpath('.\cllr');


% load data from each parrallel set of LRs
load_file_name = '40s cal.mat';

load(['.\system output - revised S&J procedure\', load_file_name], 'LR_ss', 'indices_ss', 'LR_ds', 'indices_ds');

% indices are already sorted so that first col in lower num and second col higher


% Cllr and Tippett plots of A lower to B higher and C lower to D higher
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
dev_from_mean_log_LR_ss = log_LR_ss - repmat(mean_log_LR_ss, 1, 2); % there are 2 members in each SS group

[mean_log_LR_ds, sortII_ds] = sort(mean(log_LR_ds, 2));
log_LR_ds = log_LR_ds(sortII_ds,:);
dev_from_mean_log_LR_ds = log_LR_ds - repmat(mean_log_LR_ds, 1, 4); % there are 4 members in each DS group

mean_log_LR = [mean_log_LR_ds; mean_log_LR_ss];

% plot of mean logLR v deviance from mean
figure;
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


% running nearest-neighbours 95% credible[?] interval, successive linear regression to find 95% percentile

% string out so that we can handle 4 values from ds and 2 from ss 
dev_from_mean_log_LR = [dev_from_mean_log_LR_ds(:,1); dev_from_mean_log_LR_ds(:,2); dev_from_mean_log_LR_ds(:,3); dev_from_mean_log_LR_ds(:,4); dev_from_mean_log_LR_ss(:,1); dev_from_mean_log_LR_ss(:,1)];
abs_dev_from_mean_log_LR = abs(dev_from_mean_log_LR);

mean_log_LR_repmat = [repmat(mean_log_LR_ds, 4, 1); repmat(mean_log_LR_ss, 2, 1)];
    
n = length(mean_log_LR);
n_ss = length(log_LR_ss);
n_ds = length(log_LR_ds);


num_nearest_neighbours = 500; % note n = 6216
alpha = 0.05;
% num_to_discard = num_nearest_neighbours * alpha;


hwait = waitbar(0, 'Calculating 95% CI for each comparison in data');

CI_half = NaN(n, 1);
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
    
    %nearest_mean_log_LR = mean_log_LR(II_nearest,:);
    nearest_mean_log_LR_repmat = mean_log_LR_repmat(II_nearest_repmat);
    nearest_abs_dev_from_mean_log_LR = abs_dev_from_mean_log_LR(II_nearest_repmat);
    
%     % tri-cube kernel - see Hastie, Tibshirani, Friedman (200) p. 192–197
%     hk = abs_diff_from_mean_log_LR(num_nearest_neighbours);
%     t = abs_diff_from_mean_log_LR / hk;
%     t(t>1) = 1;
%     D = (1 - t.^3).^3;
%     D_ds = D(1:n_ds);
%     D_ss = D(n_ds+1:end);
%     D_repmat = [repmat(D_ds, 4, 1); repmat(D_ss, 2, 1)];
%     nearest_D = D_repmat(II_nearest_repmat);
    
    
    % sucessively remove the alpha lest extreme deviation-from-mean values
    num_tokens_remaining = length(nearest_mean_log_LR_repmat);
    num_to_discard = round(num_tokens_remaining * alpha);
    num_to_stop = round(num_tokens_remaining * alpha * 2);
    num_to_stop_plus = num_to_stop + num_to_discard;
    
    y = nearest_abs_dev_from_mean_log_LR;
%     y = nearest_abs_dev_from_mean_log_LR .* nearest_D; % kernel applied
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
    
    CI_half(II) = b(1) + b(2)*mean_log_LR(II);
    
    
    waitbar(II/n, hwait)
end

close(hwait)
% add CIs to scatterplot
[mean_log_LR_sorted, II_mean_log_LR_sorted] = sort(mean_log_LR);
CI_half_sorted = CI_half(II_mean_log_LR_sorted);
hold on
plot(mean_log_LR_sorted, CI_half_sorted, '-g');
plot(mean_log_LR_sorted, -CI_half_sorted, '-g');
hold off

% Tippett plot with CI (using new version of plot_tippett)
plot_name = ['Fused mean LRs with 95% CI'];
CI_half_ds = CI_half(1:n_ds);
CI_half_ss = CI_half(n_ds+1:end);
plot_tippett(10.^(mean_log_LR_ss - CI_half_ss), [], 10.^(mean_log_LR_ds - CI_half_ds), [], [], true, '--', true, true);
plot_tippett(10.^(mean_log_LR_ss + CI_half_ss), [], 10.^(mean_log_LR_ds + CI_half_ds), [], [], false, '--', false, true);
plot_tippett(10.^mean_log_LR_ss, [], 10.^mean_log_LR_ds, [], plot_name, false, '-', false, false);
xlim([-5 5]); % adjust this as necessary

% calculate Cllr for means LRs
Cllr_means = cllr(log(10.^mean_log_LR_ss), log(10.^mean_log_LR_ds));
Cllr_means

mean_CI = mean(CI_half_sorted);
mean_CI

% mean_minus3_0 = mean(CI_half_sorted(mean_log_LR_sorted > -3 & mean_log_LR_sorted < 0));
% mean_minus3_0
% 
% mean_0_3 = mean(CI_half_sorted(mean_log_LR_sorted > 0 & mean_log_LR_sorted < 3));
% mean_0_3

rmpath('.\cllr');
