% analyse_speaker_lineup
%
% Rosas C., Sommerhoff J., Morrison G.S. (2019) Data and software for "A method for calculating the strength of evidence associated with an earwitness’s claimed recognition of a familiar speaker"
%
% This code has been tested and verified to work on Matlab R2017a running under Windows 10.
%
% Required data file: 'data - speaker lineup - trunk of car condition - anonymized - 2018-11-03a.xlsx'
%
% Required toolbox: statistics_toolbox


clear all
close all
rng(0);


%% read in and format data
data = xlsread('data - speaker lineup - trunk of car condition - anonymized - 2018-11-03a.xlsx');

recording_ID = data(:,2);
listener_responses = data(:,4:end);

[num_recordings, num_listeners] = size(listener_responses);

% convert recording IDs to 3 digit speaker indices
true_speaker_II = arrayfun(@(x) convert_index_to_3_digits(x), floor(recording_ID / 10));
listener_responses = arrayfun(@(x) convert_index_to_3_digits(x), listener_responses);

speaker_ID = unique(true_speaker_II);
num_speakers = length(speaker_ID);

num_responses_per_speaker = sum(listener_responses > 0, 1);


%% calculate Bayes factors

% get counts
count_1_plus_minus = NaN(num_speakers, num_listeners, 2);
for I_speaker = 1:num_speakers
    II_response = listener_responses == speaker_ID(I_speaker);
    II_true = true_speaker_II == speaker_ID(I_speaker);
    for I_listener = 1: num_listeners
        count_1_plus_temp = sum(II_response(:,I_listener) & II_true);
        count_1_minus_temp = sum(II_response(:,I_listener)) - count_1_plus_temp;
        count_1_plus_minus(I_speaker, I_listener, 1) = count_1_plus_temp;
        count_1_plus_minus(I_speaker, I_listener, 2) = count_1_minus_temp;
    end
end

count_1_plus = count_1_plus_minus(:,:,1);
count_1_minus = count_1_plus_minus(:,:,2);

% totals
n_plus = 6; % num target recordings per speaker
n_minus = (num_speakers-1)*n_plus;  % num non-target recordings per speaker

% hyperparameters for prior beta distribution
% numerator
a_plus = .5;
b_plus = a_plus;
m_plus = a_plus + b_plus;
% denominator – effect proportional to that on numerator
a_minus = (num_speakers-1) * a_plus;
b_minus = (num_speakers-1) * b_plus;
m_minus = a_minus + b_minus;

% Bayes factor based on posterior means (expected values of theta)
% BF per speaker per listener
theta_mean_plus = (count_1_plus + a_plus) ./ (n_plus + m_plus);
theta_mean_minus = (count_1_minus + a_minus) ./ (n_minus + m_minus);

BF_speak_list = theta_mean_plus ./ theta_mean_minus;

% naïve Bayes fusion across speakers
BF_across_speakers = prod(BF_speak_list, 2);
inv_BF_across_speakers = 1./BF_across_speakers;

% replace BF=1 due to 0|0 with NaN
II_NaN = count_1_plus == 0 & count_1_minus == 0;
BF_speak_list(II_NaN) = NaN;
inv_BF_speak_list = 1./BF_speak_list;

% display results in graphical editing tool
openvar('BF_speak_list');


%% Monte Carlo distribution of posterior likelihood ratio

% select combination of speaker and listener (row and column in 'BF_speak_list')
spk = 5;
lst = 7;

% parameter values for posterior beta distributions
c1a_plus = count_1_plus(spk,lst) + a_plus;
c0b_plus = n_plus - count_1_plus(spk,lst) + b_plus;

c1a_minus = count_1_minus(spk,lst) + a_minus;
c0b_minus = n_minus - count_1_minus(spk,lst) + b_minus;

% plot posterior beta distributions
xx = 0:0.0025:1;
yy_plus = betapdf(xx, c1a_plus, c0b_plus);
yy_minus = betapdf(xx, c1a_minus, c0b_minus);

figure(1);
plot(xx, yy_plus, 'r', 'LineWidth', 1);
hold on
plot(xx, yy_minus, 'b', 'LineWidth', 1);
lim_y = get(gca, 'YLim');
theta_mean_plus_plot = theta_mean_plus(spk,lst);
theta_mean_minus_plot = theta_mean_minus(spk,lst);
plot([theta_mean_plus_plot theta_mean_plus_plot], lim_y, '--r', 'LineWidth', 1);
plot([theta_mean_minus_plot theta_mean_minus_plot], lim_y, '--b', 'LineWidth', 1);
axis tight
xlabel(char(952)) % theta
ylabel('probability density')
hold off


% plot Monte Carlo estimate of posterior likelihood ratio distribution
num_samples = 1E6;
rand_plus = betarnd(c1a_plus, c0b_plus, num_samples, 1);
rand_minus = betarnd(c1a_minus, c0b_minus, num_samples, 1);
log_LR_star = log10(rand_plus) - log10(rand_minus);

figure(2);
h = histogram(log_LR_star, 'LineStyle', 'none', 'Normalization', 'pdf');
hold on
lim_y = get(gca, 'YLim');
plot([0 0], lim_y, 'k', 'LineWidth', 0.5);
logBF_plot = log10(BF_speak_list(spk,lst));
plot([logBF_plot logBF_plot], lim_y, '--b', 'LineWidth', 1);
axis tight
xlabel('log_{10}(\it{LR}*)')
ylabel('probability density')
hold off

