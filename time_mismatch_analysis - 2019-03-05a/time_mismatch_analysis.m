% time_mismatch_analysis
%
% Morrison GS, Kelly F (2019) A statistical procedure to adjust for time-interval mismatch in forensic voice comparison
%
% A statistical procedure to adjust for mismatches in time intervals within training data versus between questioned- and known-speaker recordings in forensic voice comparison analyses
%
% This script has been tested in Matlab version 2017a (Base + Statistics Toolbox) running under Windows 10
%
% Data © 2019 Finnian Kelly
% Code © 2019 Geoffrey Stewart Morrison

% clean start
close all
clear all
addpath(genpath('.\functions'));

% options

weight_by_num_speaker = false; % true: weight regression by number of speakers per interval. false: weight regression by number of recordigns per interval

trim_pcnt = 10; % percentage to trim means by for training and testing time-interval-adjustment model

target_interval = 102; % target interval for Example

trim_score_for_logreg = false; % true: trim same-speaker data for training logistic regression
trim_proportion = .01; % proportion of data to trim from same-speaker data if trim_score_for_logreg is set to true (the lowest values are trimmed)

regularize_logreg = false; % true: regularize the logistic regression models
kappa = 1; % pseudo degrees of freedom for regularization

line_plot_options = {'-k' '-r' '-c' '--b'}; % options for line plotting for the Example: different-speaker, same-speaker origin, same-speaker target, same-speaker shifted


% load data
[data_d, ~] = xlsread('scores_d.xlsx');
[data_s, ~] = xlsread('scores_s.xlsx');

    % data_d col 1: speaker ID 1
    % data_d col 2: speaker ID 2
    % data_d col 3: score

    % data_s col 1: speaker ID
    % data_s col 2: time interval
    % data_s col 3: score
    
% split data into scores and indices
scores_s = data_s(:,2:3);
speakers_s = data_s(:,1);
scores_d = data_d(:,3);
speakers_d = data_d(:,1:2);

% delete same-speaker data from same session
II_delete = scores_s(:,1) == 0;
scores_s(II_delete,:) = [];
speakers_s(II_delete) = [];

% delete same-speaker data from intervals with less than 10 speakers or less than 100 scores
unique_intervals = unique(scores_s(:,1));
num_intervals = length(unique_intervals);
speaker_counts = NaN(num_intervals,1);
scores_per_interval_counts = NaN(num_intervals,1);
for I_interval = 1:num_intervals
    II_interval = scores_s(:,1) == unique_intervals(I_interval);
    speaker_counts(I_interval) = length(unique(speakers_s(II_interval)));
    scores_per_interval_counts(I_interval) = sum(II_interval);
end
speaker_and_score_counts_original = [unique_intervals, speaker_counts, scores_per_interval_counts];

II_intervals_delete = speaker_counts < 10 | scores_per_interval_counts < 100;
II_delete = false(length(scores_s),1);
for I_interval_delete = find(II_intervals_delete)'
    II_delete_temp = scores_s(:,1) == unique_intervals(I_interval_delete);
    II_delete = II_delete | II_delete_temp;
end
scores_s(II_delete,:) = [];
speakers_s(II_delete) = [];

unique_intervals = unique(scores_s(:,1));
num_intervals = length(unique_intervals);

speaker_counts(II_intervals_delete) = [];
scores_per_interval_counts(II_intervals_delete) = [];


% speaker indices (unified)
num_scores_s = length(scores_s);
num_scores_d = length(scores_d);

speakers_all_raw = [speakers_s; speakers_d(:,1); speakers_d(:,2)];
speakers_all = grp2idx(speakers_all_raw);

unique_speakers = unique(speakers_all);
num_speakers = length(unique_speakers);

speakers_s = speakers_all(1:num_scores_s);
speakers_d = [speakers_all(num_scores_s+1:num_scores_s+num_scores_d), speakers_all(num_scores_s+num_scores_d+1:end)];

speaker_count_d = length(unique(speakers_d(:)));

speaker_and_score_counts = [unique_intervals, speaker_counts, scores_per_interval_counts];


% separate scores_s according to time interval
scores_s_cell = cell(num_intervals,1);
speakers_s_cell = cell(num_intervals,1);
for I_interval = 1:num_intervals
    II_scores_this_time_inverval = scores_s(:,1) == unique_intervals(I_interval);
    scores_s_cell{I_interval} = scores_s(II_scores_this_time_inverval,2);
    speakers_s_cell{I_interval} = speakers_s(II_scores_this_time_inverval);
end


% kernel density plots
scores_all = [scores_d; scores_s(:,2)];
x_max = max(scores_all);
x_min = min(scores_all);
x_plot = x_min : (x_max-x_min)/199 : x_max;

[f_d,~,bw] = ksdensity(scores_d, x_plot);

figure(1);
plot(x_plot, f_d, '-k', 'LineWidth', 1.5);
hold on

colors = colormap(copper(num_intervals));
for I_interval = 1:num_intervals
    [f_s,~] = ksdensity(scores_s_cell{I_interval}, x_plot, 'bandwidth',bw);
    plot(x_plot, f_s, '-', 'Color', colors(I_interval,:), 'LineWidth', 1.5);
end
xlim([x_min x_max])


% calculate trimmed means
mu_d = trimmean(scores_d, trim_pcnt);
mu_s = cellfun(@trimmean, scores_s_cell, mat2cell(ones(num_intervals,1)*trim_pcnt, ones(num_intervals,1)));

mu_diff = mu_s - mu_d;


% linear regression (exponential link function, weighted)
xx = [ones(num_intervals,1),unique_intervals];

if weight_by_num_speaker
    weights = speaker_counts / max(speaker_counts);
else % weight by num scores
    weights = scores_per_interval_counts / max(scores_per_interval_counts);
end

b = lscov(xx, log(mu_diff), weights);

% plot regression results
interval_plot = [0:120]';
xx_plot = [ones(length(interval_plot),1),interval_plot];
mu_diff_hat_plot = exp(xx_plot*b);

figure(2);
plot(interval_plot, mu_diff_hat_plot, '-b', 'LineWidth', 1.5);
hold on
scatter(unique_intervals, mu_diff, weights*75, 'or', 'LineWidth', 1.5);
xlabel('time interval (months)')
ylabel('distance between ss and ds score means')
set(gca, 'XTick', [0:12:120]); % put ticks at 1 year intervals

% origin: 1 day. target: 6 years
t0t1 = [1/30; 12*6];
xx_t0t1 = [[1;1],t0t1];
mu_diff_hat_t0t1 = exp(xx_t0t1*b);

lim_y = get(gca, 'YLim');
lim_y(1) = 0;

for I_t = 1:2
    plot([t0t1(I_t), t0t1(I_t)], [lim_y(1), mu_diff_hat_t0t1(I_t)], '-g', 'LineWidth', .5);
    plot([0, t0t1(I_t)], [mu_diff_hat_t0t1(I_t), mu_diff_hat_t0t1(I_t)], '-g', 'LineWidth', .5);
end
set(gca, 'YLim', lim_y);

delta_for_case = 1-mu_diff_hat_t0t1(2)/mu_diff_hat_t0t1(1);


% validation
% leave one speaker out + leave two intervals out cross validation
% shift shortest interval to each longer interval

figure(3);

scores_origin = scores_s_cell{1};
speakers_origin = speakers_s_cell{1};

score_s_shifted_cross  = NaN(scores_per_interval_counts(1), num_intervals);
shift_cross = NaN(num_speakers, num_intervals);

for I_speaker = 1:num_speakers
    % split training and test sets for this speaker
    II_s_cross = speakers_s == unique_speakers(I_speaker);
    II_d_cross = speakers_d(:,1) == unique_speakers(I_speaker) | speakers_d(:,2) == unique_speakers(I_speaker);
    scores_s_cross_train = scores_s(~II_s_cross,:);
    scores_d_cross_train = scores_d(~II_d_cross);

    % divide scores_s_cross_train according to time interval
    scores_s_cell_cross = cell(num_intervals,1);
    for I_interval = 1:num_intervals
        II_scores_this_time_inverval = scores_s_cross_train(:,1) == unique_intervals(I_interval);
        scores_s_cell_cross{I_interval} = scores_s_cross_train(II_scores_this_time_inverval,2);
    end

    % calculate means for different-speaker scores and for same-speaker scores at each interval
    mu_d_cross = trimmean(scores_d_cross_train, trim_pcnt);
    mu_s_cross = cellfun(@trimmean, scores_s_cell_cross, mat2cell(ones(num_intervals,1)*trim_pcnt, ones(num_intervals,1)));
    mu_diff_cross = mu_s_cross - mu_d_cross;

    score_count_cross = cellfun(@length, scores_s_cell_cross);
    weights_cross = score_count_cross ./ max(score_count_cross);

    mu_diff_hat_t0t1_cross = NaN(2,num_intervals);
    for I_interval = 2:num_intervals
        % split training and test data for this interval
        II_include = true(num_intervals,1);
        II_include(1) = false; 
        II_include(I_interval) = false;
        
        % calculate regression of means on intervals
        b_cross = lscov(xx(II_include,:), log(mu_diff_cross(II_include)), weights_cross(II_include));
        xx_t0t1_cross = xx([1,I_interval],:);
        mu_diff_hat_t0t1_cross(:,I_interval) = exp(xx_t0t1_cross*b_cross);

        % plot regression line
        mu_diff_hat_plot_cross = exp(xx_plot*b_cross);
        plot(interval_plot, mu_diff_hat_plot_cross, '-c', 'LineWidth', .5);
        hold on
    end
    
    % shift for this speaker at all intervals
    delta_cross = 1 - mu_diff_hat_t0t1_cross(2,:) ./ mu_diff_hat_t0t1_cross(1,:);
    shift_cross(I_speaker,:) = mu_diff_cross(1).*delta_cross;

    II_speakers_origin = speakers_origin == unique_speakers(I_speaker);

    score_s_shifted_cross(II_speakers_origin,2:end) = scores_origin(II_speakers_origin) - shift_cross(I_speaker, 2:end);

end

% estimated means at target intervals
mu_s_shifted_cross = trimmean(score_s_shifted_cross, trim_pcnt, 1);
mu_diff_shifted_cross = mu_s_shifted_cross - mu_d;

shift_cross_mean = [unique_intervals, mean(shift_cross)'./mu_diff(1), 1 - mu_diff_shifted_cross'./mu_diff(1)];

% plot actual and estimated target means at target intervals
plot(unique_intervals, mu_diff, 'or', 'LineWidth', 1.5);
plot(unique_intervals(2:end), mu_diff_shifted_cross(2:end), '+k', 'LineWidth', 1.5);
xlabel('time interval (months)')
ylabel('distance between ss and ds score means')
set(gca, 'XTick', [0:12:120]); % put ticks at 1 year intervals
set(gca, 'YLim', lim_y);


% RMS error as a percentage of the original distance between the same-speaker score mean and the different-speaker score mean
error_per_interval = [unique_intervals(2:end), (mu_diff(2:end)-mu_diff_shifted_cross(2:end)')./mu_diff(1)];
RMS_error = sqrt(mean(error_per_interval(:,2).^2));



% Example 

% get shift for example
I_target_interval = find(unique_intervals==target_interval);
example_shift = mu_diff(1).*delta_cross(I_target_interval);

% kernel density plots
figure(4);
plot(x_plot, f_d, line_plot_options{1}, 'LineWidth', 1.5); % different-speaker scores
hold on
[f_s_2,~] = ksdensity(scores_s_cell{1}, x_plot, 'bandwidth',bw); % 2-month-interval same-speaker scores
plot(x_plot, f_s_2, line_plot_options{2}, 'LineWidth', 1.5);
[f_s_target,~] = ksdensity(scores_s_cell{I_target_interval}, x_plot, 'bandwidth',bw); % actual target-interval same-speaker scores
plot(x_plot, f_s_target, line_plot_options{3}, 'LineWidth', 1.5);
[f_s_shifted,~] = ksdensity(score_s_shifted_cross(:,I_target_interval), x_plot, 'bandwidth',bw); % shifted same-speaker scores
plot(x_plot, f_s_shifted, line_plot_options{4}, 'LineWidth', 1.5);
xlim([x_min x_max]);
xlabel('score');
ylabel('probability density');
legend({'ds' 'ss origin' 'ss target' 'ss shifted'}, 'Location', 'northwest');


% logistic regression plots
x_plot_min_max = [-75 75]; %[x_min, x_max];

scores_origin = scores_s_cell{1};
scores_shifted = score_s_shifted_cross(:,I_target_interval);
scores_target = scores_s_cell{I_target_interval};
speakers_target = speakers_s_cell{I_target_interval};

% trim data
if trim_score_for_logreg
    scores_origin_sorted = sort(scores_origin);
    I_trim = ceil(scores_per_interval_counts(1)*trim_proportion);
    I_trim_threshold = scores_origin_sorted(I_trim);
    II_trim = scores_origin <= I_trim_threshold;
    scores_origin(II_trim) = [];
    speakers_origin(II_trim) = [];
    scores_shifted(II_trim) = [];
end

% logistic regression
if regularize_logreg
    % the kappa value is set in the options as the beginning of the script
    df = mean([speaker_counts(I_target_interval), speaker_count_d]);
else
    kappa = 0;
    df = [];
end

weights_origin = train_llr_fusion_regularized(scores_origin', scores_d', 0.5, kappa, df);
y_logit_origin = lin_fusion(weights_origin, x_plot_min_max) / log(10);
weights_target = train_llr_fusion_regularized(scores_target', scores_d', 0.5, kappa, df);
y_logit_target = lin_fusion(weights_target, x_plot_min_max) / log(10);
weights_shifted = train_llr_fusion_regularized(scores_origin'-example_shift, scores_d', 0.5, kappa, df);
y_logit_example_shifted = lin_fusion(weights_shifted, x_plot_min_max) / log(10);

% plot
figure(5);
plot(x_plot_min_max', [0; 0], line_plot_options{1}, 'LineWidth', .5);
hold on
logit_plot_2 = plot(x_plot_min_max', y_logit_origin', line_plot_options{2}, 'LineWidth', 1.5);
logit_plot_target = plot(x_plot_min_max', y_logit_target', line_plot_options{3}, 'LineWidth', 1.5);
logit_plot_shifted = plot(x_plot_min_max', y_logit_example_shifted', line_plot_options{4}, 'LineWidth', 1.5);
xlim(x_plot_min_max);
set(gca, 'XTick', [-75:25:75]);
grid on
xlabel('score');
ylabel('log10(LR)');
legend([logit_plot_2 logit_plot_target logit_plot_shifted] ,{'origin' 'target' 'shifted'}, 'Location', 'northwest');

ylim([-8 +8])



% Tippett plots and Cllr

num_scores_origin = length(scores_origin);
ln_LR_s_origin = NaN(num_scores_origin,1);
ln_LR_d_origin = NaN(num_scores_d,1);
ln_LR_s_shifted = NaN(num_scores_origin,1);
ln_LR_d_shifted = NaN(num_scores_d,1);
num_scores_target = length(scores_target);
ln_LR_s_target = NaN(num_scores_target,1);
ln_LR_d_target = NaN(num_scores_d,1);
ln_LR_s_mismatched = NaN(num_scores_target,1);

% cross-validations
for I_speaker_1 = 1:num_speakers
    current_speaker_1 = unique_speakers(I_speaker_1);
    for I_speaker_2 = I_speaker_1:num_speakers 
        current_speaker_2 = unique_speakers(I_speaker_2);
        II_d = (speakers_d(:,1) == current_speaker_1 & speakers_d(:,2) == current_speaker_2) | (speakers_d(:,1) == current_speaker_2 & speakers_d(:,2) == current_speaker_1);
        
        if current_speaker_1 == current_speaker_2
            same_speaker = true;
        else
            same_speaker = false;
        end
        
        % origin and shifted scores
        if same_speaker
            II_s = speakers_origin == current_speaker_1;
        end
        
        II_s_cross = speakers_origin == current_speaker_1 | speakers_origin == current_speaker_2;
        II_d_cross = speakers_d(:,1) == current_speaker_1 | speakers_d(:,2) == current_speaker_1 | speakers_d(:,1) == current_speaker_2 | speakers_d(:,2) == current_speaker_2;
        scores_s_cross_train = scores_origin(~II_s_cross,:);
        scores_d_cross_train = scores_d(~II_d_cross);

        % logistic regression models
        weights_origin = train_llr_fusion_regularized(scores_s_cross_train', scores_d_cross_train', 0.5, kappa, df);
        ln_LR_d_origin(II_d) = lin_fusion(weights_origin, scores_d(II_d)'); 
        if same_speaker
            ln_LR_s_origin(II_s) = lin_fusion(weights_origin, scores_origin(II_s)');
        end

        weights_shifted = train_llr_fusion_regularized(scores_s_cross_train'-example_shift, scores_d_cross_train', 0.5, kappa, df);
        ln_LR_d_shifted(II_d) = lin_fusion(weights_shifted, scores_d(II_d)'); 
        if same_speaker
            ln_LR_s_shifted(II_s) = lin_fusion(weights_shifted, scores_shifted(II_s)');
        end

        % target scores
        if same_speaker
            II_s = speakers_target == current_speaker_1;
            if sum(II_s) == 0
                same_speaker = false;
            end
        end
        II_s_cross = speakers_target == current_speaker_1 | speakers_target == current_speaker_2;
        scores_s_cross_train = scores_target(~II_s_cross,:);
        
        % logistic regression model
        weights_target = train_llr_fusion_regularized(scores_s_cross_train', scores_d_cross_train', 0.5, kappa, df);
        ln_LR_d_target(II_d) = lin_fusion(weights_target, scores_d(II_d)'); 
        if same_speaker
            ln_LR_s_target(II_s) = lin_fusion(weights_target, scores_target(II_s)');
            
            % mismatched training and testing
            ln_LR_s_mismatched(II_s) = lin_fusion(weights_origin, scores_target(II_s)');
        end

    end
end
ln_LR_d_mismatched = ln_LR_d_origin;

% Tippet plots
lim_x = [-4 4];

LR_s_2 = exp(ln_LR_s_origin)';
LR_d_2 = exp(ln_LR_d_origin)';
plot_tippett(LR_s_2, [], LR_d_2, [], 'origin');
xlim(lim_x);

LR_s_shifted = exp(ln_LR_s_shifted)';
LR_d_shifted = exp(ln_LR_d_shifted)';
plot_tippett(LR_s_shifted, [], LR_d_shifted, [], 'shifted');
xlim(lim_x);

LR_s_target = exp(ln_LR_s_target)';
LR_d_target = exp(ln_LR_d_target)';
plot_tippett(LR_s_target, [], LR_d_target, [], 'target');
xlim(lim_x);

LR_s_mismatched = exp(ln_LR_s_mismatched)';
LR_d_mismatched = exp(ln_LR_d_mismatched)';
plot_tippett(LR_s_mismatched, [], LR_d_mismatched, [], 'mismatched');
xlim(lim_x);

% Cllr
Cllr_origin = cllr(ln_LR_s_origin, ln_LR_d_origin);
Cllr_shifted = cllr(ln_LR_s_shifted, ln_LR_d_shifted);
Cllr_target = cllr(ln_LR_s_target, ln_LR_d_target);
Cllr_mismatched = cllr(ln_LR_s_mismatched, ln_LR_d_mismatched);



% rmpath(genpath('.\functions'));