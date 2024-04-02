% precision_non_parametric_at_specified_value.m
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

% specified value
x0 = 2;


% set k and ? parameters
num_nearest_neighbours = 500;
alpha = 0.05; % 95% CI


% load non-overlapping sets of of likelihood ratios
load_file_name = '40s cal.mat';

load(['.\system output\', load_file_name], 'LR_ss', 'indices_ss', 'LR_ds', 'indices_ds');


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


% string out so that we can handle 4 values from DS and 2 from SS 
dev_from_mean_log_LR = [dev_from_mean_log_LR_ds(:,1); dev_from_mean_log_LR_ds(:,2); dev_from_mean_log_LR_ds(:,3); dev_from_mean_log_LR_ds(:,4); dev_from_mean_log_LR_ss(:,1); dev_from_mean_log_LR_ss(:,1)];
abs_dev_from_mean_log_LR = abs(dev_from_mean_log_LR);

mean_log_LR_repmat = [repmat(mean_log_LR_ds, 4, 1); repmat(mean_log_LR_ss, 2, 1)];
    
n = length(mean_log_LR);
n_ss = length(log_LR_ss);
n_ds = length(log_LR_ds);


% find the nearest neighbours
diff_from_mean_log_LR = mean_log_LR - x0;
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

    % CI calculation plot
    h_CIplot = figure;
    plot(nearest_mean_log_LR_repmat, nearest_abs_dev_from_mean_log_LR, '.b');
    hold on
    xx = get(gca, 'XLim');

while num_tokens_remaining >= num_to_stop;
    % fit a linear regression
    intercept_col = ones(num_tokens_remaining, 1);
    [b, bint, residuals] = regress(y, [intercept_col, x]);
    
        % CI calculation plot
        figure(h_CIplot);
        yy = b(1) + b(2)*xx;
        plot(xx, yy, '-g');
    
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
CI_half = b(1) + b(2)*x0;
CI_half

    % CI calculation plot
    figure(h_CIplot);
    plot(x, y, '.r');
    plot(x0, CI_half, '^r');
    xlabel('mean log10(LR)');
    ylabel('absolute deviation from mean log10(LR)');
    axis equal
    ylim([0 3]) % adjust as necessary

% histogram of nearest neighbours
figure;
nearest_signed_dev_from_mean_log_LR = dev_from_mean_log_LR(II_nearest_repmat);
hist(nearest_signed_dev_from_mean_log_LR, 50);
h_bars = findobj(gca, 'Type', 'patch');
set(h_bars, 'FaceColor', 'b', 'EdgeColor', 'none');
xlabel('deviation from mean log10(LR)');
ylabel('count');
y_range = get(gca, 'YLim');
hold on
plot([-CI_half, -CI_half], y_range, '-r');
plot([CI_half, CI_half], y_range, '-r');
hold off

