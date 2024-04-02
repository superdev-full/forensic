% calibration_demo_multiple_samples
%
% This script runs the illustrations described in:
%   Morrison (2014 submitted) Calculation of forensic likelihood ratios:
%       Use of Monte Carlo simulations to compare the output of score-based approaches with true likelihood-ratio values
%
% tested on R2013b

clear all
close all
clc

addpath('./cllr', './fusion');

% number of sets of samples to draw from population
num_sample_sets = 100;

% population parameters
mu_population = 0;
sigma_population = 2;
sigma_speaker = 1;
num_population_speakers = 1000;


% initiate the random number stream so we can get the same random sets each time we run this script (see "Managing the Default Stream" in help)
defaultStream = RandStream.getGlobalStream;
reset(defaultStream);


% generate a population of speaker means and standard deviations
mu_population_speakers_initial = normrnd(mu_population, sigma_population, num_population_speakers, 1);

num_generate_tokens = 10;

mu_population_speakers_rep = repmat(mu_population_speakers_initial, 1, num_generate_tokens);

population_tokens = normrnd(mu_population_speakers_rep, sigma_speaker);

mu_population_speakers = mean(population_tokens, 2);
sigma_population_speakers = std(population_tokens, 0, 2);

% test parameters
x_suspect = [0 1] * sigma_population;
x_offender = (-2 : .1 : 2) * sigma_speaker;

num_test_suspects = length(x_suspect);
num_test_offenders = length(x_offender);




% draw distributions
xx_plot_min = min(x_offender) + min(x_suspect) -.5;
xx_plot_max = max(x_offender) + max(x_suspect) +.5;
new_xlim = [xx_plot_min xx_plot_max];
xx_num = 100;
xx_step = (xx_plot_max - xx_plot_min) / (xx_num - 1);
xx_plot = xx_plot_min: xx_step : xx_plot_max;

xx_plot_rep = repmat(xx_plot, num_test_suspects, 1);
mu_x_suspect_plot_rep = repmat(x_suspect', 1, xx_num);
sigma_speaker_plot_rep = repmat(sigma_speaker, num_test_suspects, xx_num);
pdf_plot = normpdf(xx_plot_rep, mu_x_suspect_plot_rep, sigma_speaker_plot_rep);

xx_plot_rep = repmat(xx_plot, num_population_speakers, 1);
mu_population_speakers_plot_rep = repmat(mu_population_speakers, 1, xx_num);
sigma_population_speaker_plot_rep = repmat(sigma_population_speakers, 1, xx_num);
pdf_plot_temp = normpdf(xx_plot_rep, mu_population_speakers_plot_rep, sigma_population_speaker_plot_rep);
pdf_plot(3, :) = sum(pdf_plot_temp, 1) / num_population_speakers;



% calculate likelihood ratios given population
log_LR_population = NaN(num_test_suspects, num_test_offenders);
log_denominator_population = log_LR_population;
x_plot = log_LR_population;

log_numerator_population = log10(normpdf(x_offender, 0, sigma_speaker));

for I_suspect = 1:num_test_suspects
    x = x_suspect(I_suspect) + x_offender;
    x_plot(I_suspect, :) = x;
    
    x_rep = repmat(x, num_population_speakers, 1);
    mu_population_speakers_rep = repmat(mu_population_speakers, 1, num_test_offenders);
    sigma_population_speakers_rep = repmat(sigma_population_speakers, 1, num_test_offenders);
    denominator_population_temp = normpdf(x_rep, mu_population_speakers_rep, sigma_population_speakers_rep);
    
    log_denominator_population(I_suspect, :) = log10(sum(denominator_population_temp, 1) / num_population_speakers);
    log_LR_population(I_suspect, :) = log_numerator_population - log_denominator_population(I_suspect, :);
end




% LOOP SAMPLE SETS
set_log_LR_sample = NaN(num_test_suspects, num_test_offenders, num_sample_sets);
set_rms_log_LR_sample = NaN(num_sample_sets,1);

set_log_LR_sample_notpooledsigma = set_log_LR_sample;
set_rms_log_LR_sample_notpooledsigma = set_rms_log_LR_sample;

set_log_LR_distance = set_log_LR_sample;
set_rms_log_LR_distance = set_rms_log_LR_sample;

set_log_LR_distance_pav = set_log_LR_sample;
set_rms_log_LR_distance_pav = set_rms_log_LR_sample;

set_log_LR_similarity = set_log_LR_sample;
set_rms_log_LR_similarity = set_rms_log_LR_sample;

set_log_LR_similarity_pav = set_log_LR_sample;
set_rms_log_LR_similarity_pav = set_rms_log_LR_sample;

set_log_LR_similarity_typicality_kd = set_log_LR_sample;
set_rms_log_LR_similarity_typicality_kd = set_rms_log_LR_sample;

set_log_LR_similarity_typicality_logreg = set_log_LR_sample;
set_rms_log_LR_similarity_typicality_logreg = set_rms_log_LR_sample;

set_log_LR_similarity_typicality_gau1 = set_log_LR_sample;
set_rms_log_LR_similarity_typicality_gau1 = set_rms_log_LR_sample;

set_log_LR_similarity_typicality_gau2 = set_log_LR_sample;
set_rms_log_LR_similarity_typicality_gau2 = set_rms_log_LR_sample;

set_log_LR_similarity_typicality_pav = set_log_LR_sample;
set_rms_log_LR_similarity_typicality_pav = set_rms_log_LR_sample;

set_log_LR_scoring_method_kd = set_log_LR_sample;
set_rms_log_LR_scoring_method_kd = set_rms_log_LR_sample;

set_log_LR_scoring_method_susp_anch_1 = set_log_LR_sample;
set_rms_log_LR_scoring_method_susp_anch_1 = set_rms_log_LR_sample;

set_log_LR_scoring_method_susp_anch_2 = set_log_LR_sample;
set_rms_log_LR_scoring_method_susp_anch_2 = set_rms_log_LR_sample;

set_log_LR_scoring_method_pav_susp_anch_1 = set_log_LR_sample;
set_rms_log_LR_scoring_method_pav_susp_anch_1 = set_rms_log_LR_sample;

set_log_LR_scoring_method_pav_susp_anch_2 = set_log_LR_sample;
set_rms_log_LR_scoring_method_pav_susp_anch_2 = set_rms_log_LR_sample;

set_log_LR_scoring_method_pav = set_log_LR_sample;
set_rms_log_LR_scoring_method_pav = set_rms_log_LR_sample;

set_log_LR_svm_logreg = set_log_LR_sample;
set_rms_log_LR_svm_logreg = set_rms_log_LR_sample;

set_log_LR_svm_pav = set_log_LR_sample;
set_rms_log_LR_svm_pav = set_rms_log_LR_sample;

set_log_LR_joint_likelihood = set_log_LR_sample;
set_rms_log_LR_joint_likelihood = set_rms_log_LR_sample;


waitbar_message_part = [' of ', num2str(num_sample_sets, '%0.0f'), ' sample sets complete'];
waitbar_message = ['0', waitbar_message_part];
h_waitbar = waitbar(0, waitbar_message);
for I_sample_sets = 1:num_sample_sets

% select a sample of speakers from the population and generate sample tokens
num_sample_speakers = 100;
num_sample_tokens = 30;

II_sample_speakers = randi(num_population_speakers, num_sample_speakers, 1);
mu_sample_speakers = mu_population_speakers(II_sample_speakers);
sigma_sample_speakers = sigma_population_speakers(II_sample_speakers);

mu_sample_speakers_rep = repmat(mu_sample_speakers, 1, num_sample_tokens);
sigma_speaker_rep = repmat(sigma_sample_speakers, 1, num_sample_tokens);

sample_tokens = normrnd(mu_sample_speakers_rep, sigma_speaker_rep);

mu_sample_speakers_empiric = mean(sample_tokens, 2);
sigma_sample_speakers_empiric = std(sample_tokens, 0, 2);
sigma_sample_speakers_empiric_pooled = sqrt(mean(var(sample_tokens, 0, 2)));

% non-pooled sigma for suspects
mu_rep = repmat(x_suspect', 1, num_sample_tokens);
suspect_tokens_not_centred = normrnd(mu_rep, sigma_speaker);
suspect_tokens_centred = suspect_tokens_not_centred - repmat(mean(suspect_tokens_not_centred, 2), 1, num_sample_tokens) + mu_rep; % put sample means at predifined mean
sigma_suspect_tokens = std(suspect_tokens_centred, 0, 2);



% calculate likelihood ratios given sample
log_LR_sample = NaN(num_test_suspects, num_test_offenders);
log_denominator_sample = log_LR_sample;
log_LR_sample_notpooledsigma = log_LR_sample;

log_numerator_sample = log10(normpdf(x_offender, 0, sigma_sample_speakers_empiric_pooled));

for I_suspect = 1:num_test_suspects
    x = x_plot(I_suspect, :);
    
    x_rep = repmat(x, num_sample_speakers, 1);
    mu_sample_speakers_empiric_rep = repmat(mu_sample_speakers_empiric, 1, num_test_offenders);
    sigma_sample_speakers_empiric_pooled_rep = repmat(sigma_sample_speakers_empiric_pooled, num_sample_speakers, num_test_offenders);
    denominator_sample_temp = normpdf(x_rep, mu_sample_speakers_empiric_rep, sigma_sample_speakers_empiric_pooled_rep);
    
    log_denominator_sample(I_suspect, :) = log10(sum(denominator_sample_temp, 1) / num_sample_speakers);
    log_LR_sample(I_suspect, :) = log_numerator_sample - log_denominator_sample(I_suspect, :);
    
    numerator_sample_notpooledsigma = normpdf(x, x_suspect(I_suspect), sigma_suspect_tokens(I_suspect, :));
%     log_numerator_sample_notpooledsigma = log10(sum(numerator_sample_notpooledsigma, 1) / num_sample_speakers);
    log_numerator_sample_notpooledsigma = log10(numerator_sample_notpooledsigma);

    sigma_sample_speakers_empiric_rep = repmat(sigma_sample_speakers_empiric, 1, num_test_offenders);
    denominator_sample_notpooledsigma = normpdf(x_rep, mu_sample_speakers_empiric_rep, sigma_sample_speakers_empiric_rep);
    log_denominator_sample_notpooledsigma = log10(sum(denominator_sample_notpooledsigma, 1) / num_sample_speakers);
    
    log_LR_sample_notpooledsigma(I_suspect, :) = log_numerator_sample_notpooledsigma - log_denominator_sample_notpooledsigma;
end


rms_log_LR_sample = sqrt(mean((log_LR_sample(:) - log_LR_population(:)).^2));
rms_log_LR_sample_notpooledsigma = sqrt(mean((log_LR_sample_notpooledsigma(:) - log_LR_population(:)).^2));

set_log_LR_sample(:,:,I_sample_sets) = log_LR_sample;
set_rms_log_LR_sample(I_sample_sets) = rms_log_LR_sample;

set_log_LR_sample_notpooledsigma(:,:,I_sample_sets) = log_LR_sample_notpooledsigma;
set_rms_log_LR_sample_notpooledsigma(I_sample_sets) = rms_log_LR_sample_notpooledsigma;





% calculate distance-score-based likelihood ratios given sample
II_tokens = true(num_sample_tokens,1);
distance_same = NaN(num_sample_speakers, num_sample_tokens);
for I_tokens = 1 : num_sample_tokens;
    II = II_tokens;
    II(I_tokens) = false;
    distance_same(:, I_tokens) = sample_tokens(:, I_tokens) - mean(sample_tokens(:, II), 2);
end
distance_same = distance_same(:);

distance_different = [];
for I_sample_speakers_A = 1 : num_sample_speakers - 1;
    for I_sample_speakers_B = I_sample_speakers_A + 1 : num_sample_speakers;
        distance_different = [distance_different, sample_tokens(I_sample_speakers_A, :) - mean(sample_tokens(I_sample_speakers_B, :))];
    end
end



% guarentee symmetry about zero
mu_distance_same = 0;
std_distance_same = std(distance_same, 0);
mu_distance_different = 0;
std_distance_different = std(distance_different, 0);


x_distance = x_offender;

log_numerator_distance = log10(normpdf(x_distance, mu_distance_same, std_distance_same));
log_denominator_distance = log10(normpdf(x_distance, mu_distance_different, std_distance_different));

log_LR_distance(1, :) = log_numerator_distance - log_denominator_distance;
log_LR_distance(2, :) = log_LR_distance(1, :);


rms_log_LR_distance = sqrt(mean((log_LR_distance(:) - log_LR_population(:)).^2));





set_log_LR_distance(:,:,I_sample_sets) = log_LR_distance;

set_rms_log_LR_distance(I_sample_sets) = rms_log_LR_distance;



% log_LR_distance_pav = pav_model (-x_distance, -distance_same, -distance_different);
log_LR_distance_pav = pav_model (-abs(x_distance), -abs(distance_same), -abs(distance_different));
log_LR_distance_pav = [log_LR_distance_pav; log_LR_distance_pav];

rms_log_LR_distance_pav = sqrt(mean((log_LR_distance_pav(:) - log_LR_population(:)).^2));

set_log_LR_distance_pav(:,:,I_sample_sets) = log_LR_distance_pav;

set_rms_log_LR_distance_pav(I_sample_sets) = rms_log_LR_distance_pav;


% calculate similarity-score-based likelihood ratios given sample [NOTE scores are not logged]
I_count = 0;
for I_sample_speakers = 1:num_sample_speakers
    for I_tokens = 1 : num_sample_tokens
        I_count = I_count + 1;
        II = false(num_sample_tokens, 1);
        II(I_tokens) = true;
        mu_temp = mean(sample_tokens(I_sample_speakers, ~II));
        similarity_score_same(I_count) = normpdf(sample_tokens(I_sample_speakers, II), mu_temp, sigma_sample_speakers_empiric_pooled);
    end
end

similarity_score_different = [];
for I_sample_speakers_A = 1 : num_sample_speakers - 1;
    mu_temp = mean(sample_tokens(I_sample_speakers_A, :));
    for I_sample_speakers_B = I_sample_speakers_A + 1 : num_sample_speakers;
        similarity_score_different = [similarity_score_different, normpdf(sample_tokens(I_sample_speakers_B, :), mu_temp, sigma_sample_speakers_empiric_pooled)];
    end
end


smoother_width = 0.02; %0.02

x_similarity = normpdf(x_offender, 0, sigma_sample_speakers_empiric_pooled);


numerator_similarity = ksdensity(similarity_score_same, x_similarity, 'width', smoother_width);
denominator_similarity = ksdensity(similarity_score_different, x_similarity, 'width', smoother_width);
log_LR_similarity = log10(numerator_similarity) - log10(denominator_similarity);

log_LR_similarity = [log_LR_similarity; log_LR_similarity];


rms_log_LR_similarity = sqrt(mean((log_LR_similarity(:) - log_LR_population(:)).^2));

set_log_LR_similarity(:,:,I_sample_sets) = log_LR_similarity;

set_rms_log_LR_similarity(I_sample_sets) = rms_log_LR_similarity;



log_LR_similarity_pav = pav_model (x_similarity, similarity_score_same, similarity_score_different);
log_LR_similarity_pav = [log_LR_similarity_pav; log_LR_similarity_pav];

rms_log_LR_similarity_pav = sqrt(mean((log_LR_similarity_pav(:) - log_LR_population(:)).^2));

set_log_LR_similarity_pav(:,:,I_sample_sets) = log_LR_similarity_pav;

set_rms_log_LR_similarity_pav(I_sample_sets) = rms_log_LR_similarity_pav;



% calculate similarity-and-typicality-score-based likelihood ratios given sample
% (reusing the similarity scores from above [convert to log10], calculating the typiciality part of the scores)
typicality_score_same = [];
for I_sample_speakers = 1:num_sample_speakers
    II = false(num_sample_speakers, 1);
    II(I_sample_speakers) = true;
    
    sample_tokens_rep = repmat(sample_tokens(I_sample_speakers, :), num_sample_speakers-1, 1);
    mu_sample_speakers_empiric_rep = repmat(mu_sample_speakers_empiric(~II), 1, num_sample_tokens);
    sigma_sample_speakers_empiric_pooled_rep = repmat(sigma_sample_speakers_empiric_pooled, num_sample_speakers-1, num_sample_tokens);
    
    typicality_score_same_temp = normpdf(sample_tokens_rep, mu_sample_speakers_empiric_rep, sigma_sample_speakers_empiric_pooled_rep);
    
    typicality_score_same = [typicality_score_same, log10(sum(typicality_score_same_temp, 1) / (num_sample_speakers-1))];
end
similarity_typicality_score_same = log10(similarity_score_same) - typicality_score_same;


typicality_score_different = [];
for I_sample_speakers_A = 1 : num_sample_speakers - 1;
    for I_sample_speakers_B = I_sample_speakers_A + 1 : num_sample_speakers;
        II = true(num_sample_speakers, 1);
        II(I_sample_speakers_A) = false;
        II(I_sample_speakers_B) = false;
        
        sample_tokens_rep = repmat(sample_tokens(I_sample_speakers_B, :), num_sample_speakers-2, 1);
        mu_sample_speakers_empiric_rep = repmat(mu_sample_speakers_empiric(II), 1, num_sample_tokens);
        sigma_sample_speakers_empiric_pooled_rep = repmat(sigma_sample_speakers_empiric_pooled, num_sample_speakers-2, num_sample_tokens);
 
        typicality_score_different_temp = normpdf(sample_tokens_rep, mu_sample_speakers_empiric_rep, sigma_sample_speakers_empiric_pooled_rep);

        typicality_score_different = [typicality_score_different, log10(sum(typicality_score_different_temp, 1) / (num_sample_speakers-2))];
    end
end
similarity_typicality_score_different = log10(similarity_score_different) - typicality_score_different;



% similarity-and-typicality-score-based likelihood ratios via kernel densities
smoother_width = 0.2; %0.2

log_LR_similarity_typicality_kd = NaN(num_test_suspects, num_test_offenders);
for I_suspect = 1:num_test_suspects % note that the scores here are the log_LR_sample values we calculated earlier
    numerator_similarity_typicality_kd = ksdensity(similarity_typicality_score_same, log_LR_sample(I_suspect, :), 'width', smoother_width);
    denominator_similarity_typicality_kd = ksdensity(similarity_typicality_score_different, log_LR_sample(I_suspect, :), 'width', smoother_width);
    log_LR_similarity_typicality_kd(I_suspect, :) = log10(numerator_similarity_typicality_kd) - log10(denominator_similarity_typicality_kd);
end


rms_log_LR_similarity_typicality_kd = sqrt(mean((log_LR_similarity_typicality_kd(:) - log_LR_population(:)).^2));


set_log_LR_similarity_typicality_kd(:,:,I_sample_sets) = log_LR_similarity_typicality_kd;

set_rms_log_LR_similarity_typicality_kd(I_sample_sets) = rms_log_LR_similarity_typicality_kd;




% similarity-and-typicality-score-based likelihood ratios via logistic regression
convert_base = log10(2);
weights = train_llr_fusion(similarity_typicality_score_same / convert_base, similarity_typicality_score_different / convert_base);

log_LR_similarity_typicality_logreg = NaN(num_test_suspects, num_test_offenders);
for I_suspect = 1:num_test_suspects % note that the scores here are the log_LR_sample values we calculated earlier
    log_LR_similarity_typicality_logreg(I_suspect, :) = lin_fusion(weights, log_LR_sample(I_suspect, :) / convert_base); 
end
log_LR_similarity_typicality_logreg = log_LR_similarity_typicality_logreg / log2(10);


rms_log_LR_similarity_typicality_logreg = sqrt(mean((log_LR_similarity_typicality_logreg(:) - log_LR_population(:)).^2));


set_log_LR_similarity_typicality_logreg(:,:,I_sample_sets) = log_LR_similarity_typicality_logreg;

set_rms_log_LR_similarity_typicality_logreg(I_sample_sets) = rms_log_LR_similarity_typicality_logreg;





% similarity-and-typicality-score-based likelihood ratios via Gaussian distributions (pooled variance)
mu_similarity_typicality_score_same = mean(similarity_typicality_score_same);
mu_similarity_typicality_score_different = mean(similarity_typicality_score_different);
sigma_similarity_typicality_score_same = std(similarity_typicality_score_same, 0);
sigma_similarity_typicality_score_different = std(similarity_typicality_score_different, 0);
% pooled equally weighted per category
sigma_similarity_typicality_score_pooled = sqrt((sum((similarity_typicality_score_same - mu_similarity_typicality_score_same).^2) + sum((similarity_typicality_score_different - mu_similarity_typicality_score_different).^2)) / (length(similarity_typicality_score_same) + length(similarity_typicality_score_different) - 2));

numerator_similarity_typicality_gau1 = normpdf(log_LR_sample, mu_similarity_typicality_score_same, sigma_similarity_typicality_score_pooled);
denominator_similarity_typicality_gau1 = normpdf(log_LR_sample, mu_similarity_typicality_score_different, sigma_similarity_typicality_score_pooled);
log_LR_similarity_typicality_gau1 = log10(numerator_similarity_typicality_gau1) - log10(denominator_similarity_typicality_gau1);

numerator_similarity_typicality_gau2 = normpdf(log_LR_sample, mu_similarity_typicality_score_same, sigma_similarity_typicality_score_same);
denominator_similarity_typicality_gau2 = normpdf(log_LR_sample, mu_similarity_typicality_score_different, sigma_similarity_typicality_score_different);
log_LR_similarity_typicality_gau2 = log10(numerator_similarity_typicality_gau2) - log10(denominator_similarity_typicality_gau2);


rms_log_LR_similarity_typicality_gau1 = sqrt(mean((log_LR_similarity_typicality_gau1(:) - log_LR_population(:)).^2));


set_log_LR_similarity_typicality_gau1(:,:,I_sample_sets) = log_LR_similarity_typicality_gau1;

set_rms_log_LR_similarity_typicality_gau1(I_sample_sets) = rms_log_LR_similarity_typicality_gau1;




rms_log_LR_similarity_typicality_gau2 = sqrt(mean((log_LR_similarity_typicality_gau2(:) - log_LR_population(:)).^2));


set_log_LR_similarity_typicality_gau2(:,:,I_sample_sets) = log_LR_similarity_typicality_gau2;

set_rms_log_LR_similarity_typicality_gau2(I_sample_sets) = rms_log_LR_similarity_typicality_gau2;



% similarity-and-typicality-score-based likelihood ratios via PAV
log_LR_similarity_typicality_pav = pav_model (log_LR_sample, similarity_typicality_score_same, similarity_typicality_score_different);

rms_log_LR_similarity_typicality_pav = sqrt(mean((log_LR_similarity_typicality_pav(:) - log_LR_population(:)).^2));

set_log_LR_similarity_typicality_pav(:,:,I_sample_sets) = log_LR_similarity_typicality_pav;

set_rms_log_LR_similarity_typicality_pav(I_sample_sets) = rms_log_LR_similarity_typicality_pav;



% similarity scores and typicality scores - LOGGED SCORES

% scores for suspect model v each tokens in a suspect "control" database
control_scores = log10(normpdf(suspect_tokens_not_centred, repmat(x_suspect', 1, num_sample_tokens), sigma_sample_speakers_empiric_pooled));

    mu_sample_speakers_empiric_back_rep = repmat(mu_sample_speakers_empiric, 1, num_sample_tokens);

smoother_width = .4; 

% scores for offender v models for each background speaker
log_LR_scoring_method_pav = NaN(num_test_suspects, num_test_offenders);
for I_suspect = 1:num_test_suspects
    x = x_plot(I_suspect, :);
    
    x_rep = repmat(x, num_sample_speakers, 1);
    mu_sample_speakers_empiric_rep = repmat(mu_sample_speakers_empiric, 1, num_test_offenders);
    sigma_sample_speakers_empiric_pooled_rep = repmat(sigma_sample_speakers_empiric_pooled, num_sample_speakers, num_test_offenders);
    background_scores = log10(normpdf(x_rep, mu_sample_speakers_empiric_rep, sigma_sample_speakers_empiric_pooled_rep));
    
    offender_score = log10(normpdf(x, x_suspect(I_suspect), sigma_sample_speakers_empiric_pooled));
    
    numerator_scoring_method_kd = ksdensity(control_scores(I_suspect, :), offender_score, 'width', smoother_width);

        % suspect anchored: susp_anch_1 = suspect model evalauted at background token values (Note: variant 1 and 2 are reversed in paper)
        background_scores_susp_anch_1 = log10(normpdf(sample_tokens, x_suspect(I_suspect), sigma_sample_speakers_empiric_pooled));
        background_scores_susp_anch_1 = background_scores_susp_anch_1(:);

        % suspect anchored: susp_anch_2 = background-source models evalauted at control scores
        suspect_tokens_not_centred_back_rep = repmat(suspect_tokens_not_centred(I_suspect, :), num_sample_speakers, 1);
        background_scores_susp_anch_2 = log10(normpdf(suspect_tokens_not_centred_back_rep, mu_sample_speakers_empiric_back_rep, sigma_sample_speakers_empiric_pooled));
        background_scores_susp_anch_2 = background_scores_susp_anch_2(:);

        
    for I_offender = 1:num_test_offenders
        denominator_scoring_method_kd(I_offender) = ksdensity(background_scores(:, I_offender), offender_score(I_offender), 'width', smoother_width);
        
            denominator_scoring_method_susp_anch_1(I_offender) = ksdensity(background_scores_susp_anch_1, offender_score(I_offender), 'width', smoother_width);
            denominator_scoring_method_susp_anch_2(I_offender) = ksdensity(background_scores_susp_anch_2, offender_score(I_offender), 'width', smoother_width);

        log_LR_scoring_method_pav(I_suspect, I_offender) = pav_model(offender_score(I_offender), control_scores(I_suspect, :), background_scores(:, I_offender));
    end
    
    log_LR_scoring_method_kd(I_suspect, :) = log10(numerator_scoring_method_kd) - log10(denominator_scoring_method_kd);
    
    log_LR_scoring_method_susp_anch_1(I_suspect, :) = log10(numerator_scoring_method_kd) - log10(denominator_scoring_method_susp_anch_1);
    log_LR_scoring_method_susp_anch_2(I_suspect, :) = log10(numerator_scoring_method_kd) - log10(denominator_scoring_method_susp_anch_2);
    log_LR_scoring_method_pav_susp_anch_1(I_suspect, :) = pav_model(offender_score, control_scores(I_suspect, :), background_scores_susp_anch_1);
    log_LR_scoring_method_pav_susp_anch_2(I_suspect, :) = pav_model(offender_score, control_scores(I_suspect, :), background_scores_susp_anch_2);
end




rms_log_LR_scoring_method_kd = sqrt(mean((log_LR_scoring_method_kd(:) - log_LR_population(:)).^2));
set_log_LR_scoring_method_kd(:,:,I_sample_sets) = log_LR_scoring_method_kd;
set_rms_log_LR_scoring_method_kd(I_sample_sets) = rms_log_LR_scoring_method_kd;


rms_log_LR_scoring_method_susp_anch_1 = sqrt(mean((log_LR_scoring_method_susp_anch_1(:) - log_LR_population(:)).^2));
set_log_LR_scoring_method_susp_anch_1(:,:,I_sample_sets) = log_LR_scoring_method_susp_anch_1;
set_rms_log_LR_scoring_method_susp_anch_1(I_sample_sets) = rms_log_LR_scoring_method_susp_anch_1;

rms_log_LR_scoring_method_susp_anch_2 = sqrt(mean((log_LR_scoring_method_susp_anch_2(:) - log_LR_population(:)).^2));
set_log_LR_scoring_method_susp_anch_2(:,:,I_sample_sets) = log_LR_scoring_method_susp_anch_2;
set_rms_log_LR_scoring_method_susp_anch_2(I_sample_sets) = rms_log_LR_scoring_method_susp_anch_2;

rms_log_LR_scoring_method_pav_susp_anch_1 = sqrt(mean((log_LR_scoring_method_pav_susp_anch_1(:) - log_LR_population(:)).^2));
set_log_LR_scoring_method_pav_susp_anch_1(:,:,I_sample_sets) = log_LR_scoring_method_pav_susp_anch_1;
set_rms_log_LR_scoring_method_pav_susp_anch_1(I_sample_sets) = rms_log_LR_scoring_method_pav_susp_anch_1;

rms_log_LR_scoring_method_pav_susp_anch_2 = sqrt(mean((log_LR_scoring_method_pav_susp_anch_2(:) - log_LR_population(:)).^2));
set_log_LR_scoring_method_pav_susp_anch_2(:,:,I_sample_sets) = log_LR_scoring_method_pav_susp_anch_2;
set_rms_log_LR_scoring_method_pav_susp_anch_2(I_sample_sets) = rms_log_LR_scoring_method_pav_susp_anch_2;




rms_log_LR_scoring_method_pav = sqrt(mean((log_LR_scoring_method_pav(:) - log_LR_population(:)).^2));
set_log_LR_scoring_method_pav(:,:,I_sample_sets) = log_LR_scoring_method_pav;
set_rms_log_LR_scoring_method_pav(I_sample_sets) = rms_log_LR_scoring_method_pav;









% SVM plus logistic regression

svm_kernel_sigma = 1.5;

convert_base = log10(2);
log_LR_svm_logreg = NaN(num_test_suspects, num_test_offenders);
log_LR_svm_pav = log_LR_svm_logreg;

for I_suspect = 1:num_test_suspects
    x = x_plot(I_suspect, :)';
    
    svm_training_data = [suspect_tokens_not_centred(I_suspect,:)'; sample_tokens(:)];
    svm_training_groupID = [true(num_sample_tokens, 1); false(num_sample_tokens * num_sample_speakers, 1)];
    
    SVMStruct = svmtrain(svm_training_data, svm_training_groupID, 'kernel_function', 'rbf', 'rbf_sigma', svm_kernel_sigma);
    
    svm_score_suspect = - svmclassify_soft(suspect_tokens_not_centred(I_suspect,:)', SVMStruct);
    svm_score_background = - svmclassify_soft(sample_tokens(:), SVMStruct);
    svm_score_offender = - svmclassify_soft(x, SVMStruct);
    
    weights = train_llr_fusion(svm_score_suspect' / convert_base, svm_score_background' / convert_base);
    log_LR_svm_logreg(I_suspect, :) = lin_fusion(weights, svm_score_offender' / convert_base); 

    
    log_LR_svm_pav(I_suspect, :) = pav_model(svm_score_offender, svm_score_suspect, svm_score_background);
end
log_LR_svm_logreg = log_LR_svm_logreg / log2(10);


rms_log_LR_svm_logreg = sqrt(mean((log_LR_svm_logreg(:) - log_LR_population(:)).^2));

set_log_LR_svm_logreg(:,:,I_sample_sets) = log_LR_svm_logreg;
set_rms_log_LR_svm_logreg(I_sample_sets) = rms_log_LR_svm_logreg;


rms_log_LR_svm_pav = sqrt(mean((log_LR_svm_pav(:) - log_LR_population(:)).^2));
set_log_LR_svm_pav(:,:,I_sample_sets) = log_LR_svm_pav;
set_rms_log_LR_svm_pav(I_sample_sets) = rms_log_LR_svm_pav;



waitbar_message = [num2str(I_sample_sets, '%0.0f'), waitbar_message_part];
waitbar(I_sample_sets/num_sample_sets, h_waitbar, waitbar_message);
end
delete(h_waitbar);

new_ylim = [-1.25 1.25];

plot_LR_ranges(set_log_LR_sample, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs given sample (pooled sigma)');

plot_LR_ranges(set_log_LR_sample_notpooledsigma, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs given sample (not pooled sigma)');

plot_LR_ranges(set_log_LR_distance, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on distance scores - Gaussian model');

plot_LR_ranges(set_log_LR_distance_pav, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on distance scores - pav model');

plot_LR_ranges(set_log_LR_similarity, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on similarity scores - kernel density');

plot_LR_ranges(set_log_LR_similarity_pav, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on similarity scores - pav model');

plot_LR_ranges(set_log_LR_similarity_typicality_kd, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on similarity-and-typicality scores - kernel density model');

plot_LR_ranges(set_log_LR_similarity_typicality_logreg, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on similarity-and-typicality scores - logistic regression model');

plot_LR_ranges(set_log_LR_similarity_typicality_gau1, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on similarity-and-typicality scores - Gaussian model (pooled variance)');

plot_LR_ranges(set_log_LR_similarity_typicality_gau2, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on similarity-and-typicality scores - Gaussian model (non-pooled variances)');

plot_LR_ranges(set_log_LR_similarity_typicality_pav, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on similarity-and-typicality scores - PAV model');

plot_LR_ranges(set_log_LR_scoring_method_kd, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on scoring method - kernel density');

plot_LR_ranges(set_log_LR_scoring_method_susp_anch_1, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on scoring method - susp anch 1');

plot_LR_ranges(set_log_LR_scoring_method_susp_anch_2, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on scoring method - susp anch 2');

plot_LR_ranges(set_log_LR_scoring_method_pav, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on scoring method - PAV models');

plot_LR_ranges(set_log_LR_svm_logreg, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on SVM - logistic regression model');

plot_LR_ranges(set_log_LR_svm_pav, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, 'logLRs based on SVM - PAV model');




% mean_std_rms_log_LR_sample = [mean(set_rms_log_LR_sample), std(set_rms_log_LR_sample, 0)]
% 
% mean_std_rms_log_LR_sample_notpooledsigma = [mean(set_rms_log_LR_sample_notpooledsigma), std(set_rms_log_LR_sample_notpooledsigma, 0)]
% 
% mean_std_rms_log_LR_distance = [mean(set_rms_log_LR_distance), std(set_rms_log_LR_distance, 0)]
% 
% mean_std_rms_log_LR_distance_pav = [mean(set_rms_log_LR_distance_pav), std(set_rms_log_LR_distance_pav, 0)]
% 
% mean_std_rms_log_LR_similarity = [mean(set_rms_log_LR_similarity), std(set_rms_log_LR_similarity, 0)]
% 
% mean_std_rms_log_LR_similarity_pav = [mean(set_rms_log_LR_similarity_pav), std(set_rms_log_LR_similarity_pav, 0)]
% 
% mean_std_rms_log_LR_similarity_typicality_kd = [mean(set_rms_log_LR_similarity_typicality_kd), std(set_rms_log_LR_similarity_typicality_kd, 0)]
% 
% mean_std_rms_log_LR_similarity_typicality_logreg = [mean(set_rms_log_LR_similarity_typicality_logreg), std(set_rms_log_LR_similarity_typicality_logreg, 0)]
% 
% mean_std_rms_log_LR_similarity_typicality_gau1 = [mean(set_rms_log_LR_similarity_typicality_gau1), std(set_rms_log_LR_similarity_typicality_gau1, 0)]
% 
% mean_std_rms_log_LR_similarity_typicality_gau2 = [mean(set_rms_log_LR_similarity_typicality_gau2), std(set_rms_log_LR_similarity_typicality_gau2, 0)]
% 
% mean_std_rms_log_LR_similarity_typicality_pav = [mean(set_rms_log_LR_similarity_typicality_pav), std(set_rms_log_LR_similarity_typicality_pav, 0)]
% 
% mean_std_rms_log_LR_scoring_method_kd = [mean(set_rms_log_LR_scoring_method_kd), std(set_rms_log_LR_scoring_method_kd, 0)]
% 
% mean_std_rms_log_LR_scoring_method_susp_anch_1 = [mean(set_rms_log_LR_scoring_method_susp_anch_1), std(set_rms_log_LR_scoring_method_susp_anch_1, 0)]
% 
% mean_std_rms_log_LR_scoring_method_susp_anch_2 = [mean(set_rms_log_LR_scoring_method_susp_anch_2), std(set_rms_log_LR_scoring_method_susp_anch_2, 0)]
% 
% mean_std_rms_log_LR_scoring_method_pav_susp_anch_1 = [mean(set_rms_log_LR_scoring_method_pav_susp_anch_1), std(set_rms_log_LR_scoring_method_pav_susp_anch_1, 0)]
% 
% mean_std_rms_log_LR_scoring_method_pav_susp_anch_2 = [mean(set_rms_log_LR_scoring_method_pav_susp_anch_2), std(set_rms_log_LR_scoring_method_pav_susp_anch_2, 0)]
% 
% mean_std_rms_log_LR_scoring_method_pav = [mean(set_rms_log_LR_scoring_method_pav), std(set_rms_log_LR_scoring_method_pav, 0)]
% 
% mean_std_rms_set_log_LR_svm_logreg = [mean(set_rms_log_LR_svm_logreg), std(set_rms_log_LR_svm_logreg, 0)]
% 
% mean_std_rms_set_log_LR_svm_pav = [mean(set_rms_log_LR_svm_pav), std(set_rms_log_LR_svm_pav, 0)]


median_rms_log_LR_sample = median(set_rms_log_LR_sample)

median_rms_log_LR_sample_notpooledsigma = median(set_rms_log_LR_sample_notpooledsigma)

median_rms_log_LR_distance = median(set_rms_log_LR_distance)

median_rms_log_LR_distance_pav = median(set_rms_log_LR_distance_pav)

median_rms_log_LR_similarity = median(set_rms_log_LR_similarity)

median_rms_log_LR_similarity_pav = median(set_rms_log_LR_similarity_pav)

median_rms_log_LR_similarity_typicality_kd = median(set_rms_log_LR_similarity_typicality_kd)

median_rms_log_LR_similarity_typicality_logreg = median(set_rms_log_LR_similarity_typicality_logreg)

median_rms_log_LR_similarity_typicality_gau1 = median(set_rms_log_LR_similarity_typicality_gau1)

median_rms_log_LR_similarity_typicality_gau2 = median(set_rms_log_LR_similarity_typicality_gau2)

median_rms_log_LR_similarity_typicality_pav = median(set_rms_log_LR_similarity_typicality_pav)

median_rms_log_LR_scoring_method_kd = median(set_rms_log_LR_scoring_method_kd)

median_rms_log_LR_scoring_method_susp_anch_1 = median(set_rms_log_LR_scoring_method_susp_anch_1)

median_rms_log_LR_scoring_method_susp_anch_2 = median(set_rms_log_LR_scoring_method_susp_anch_2)

median_rms_log_LR_scoring_method_pav_susp_anch_1 = median(set_rms_log_LR_scoring_method_pav_susp_anch_1)

median_rms_log_LR_scoring_method_pav_susp_anch_2 = median(set_rms_log_LR_scoring_method_pav_susp_anch_2)

median_rms_log_LR_scoring_method_pav = median(set_rms_log_LR_scoring_method_pav)

median_rms_set_log_LR_svm_logreg = median(set_rms_log_LR_svm_logreg)

median_rms_set_log_LR_svm_pav = median(set_rms_log_LR_svm_pav)

figure;
data_boxplot = [set_rms_log_LR_sample,...
    set_rms_log_LR_sample_notpooledsigma,...
    set_rms_log_LR_distance,...
    set_rms_log_LR_similarity,...
    set_rms_log_LR_similarity_typicality_kd,...
    set_rms_log_LR_similarity_typicality_logreg,...
    set_rms_log_LR_similarity_typicality_gau1,...
    set_rms_log_LR_similarity_typicality_gau2,...
    set_rms_log_LR_similarity_typicality_pav,...
    set_rms_log_LR_scoring_method_kd,...
    set_rms_log_LR_scoring_method_susp_anch_1,...
    set_rms_log_LR_svm_logreg];
boxplot(data_boxplot, 'notch', 'on', 'widths', 0.8);
ylim([0 .8]);

figure;
data_boxplot_pav = [set_rms_log_LR_distance_pav,...
    set_rms_log_LR_similarity_pav,...
    set_rms_log_LR_similarity_typicality_pav,...
    set_rms_log_LR_scoring_method_pav,...
    set_rms_log_LR_scoring_method_pav_susp_anch_1,...
    set_rms_log_LR_svm_pav];%,...
%     set_rms_log_LR_similarity_pav, set_rms_log_LR_similarity_pav, set_rms_log_LR_similarity_pav, set_rms_log_LR_similarity_pav, set_rms_log_LR_similarity_pav, set_rms_log_LR_similarity_pav];
boxplot(data_boxplot_pav, 'notch', 'on', 'widths', 0.8);
ylim([0 .8]);


% numeric comparisons of selected pairs of approaches
% NOTE: Bayesian estimation alternative to a paired-sample t test run in R
prop_stkd_greater = sum(set_rms_log_LR_similarity_typicality_kd > set_rms_log_LR_similarity_typicality_logreg) / num_sample_sets
odds_stkdv_greater = prop_stkd_greater / (1-prop_stkd_greater)

prop_stkd_lesser = sum(set_rms_log_LR_similarity_typicality_kd < set_rms_log_LR_similarity_typicality_logreg) / num_sample_sets
odds_stkd_lesser = prop_stkd_lesser / (1-prop_stkd_lesser)


prop_stpav_greater = sum(set_rms_log_LR_similarity_typicality_pav > set_rms_log_LR_similarity_typicality_logreg) / num_sample_sets
odds_stpav_greater = prop_stpav_greater / (1-prop_stpav_greater)

prop_stpav_lesser = sum(set_rms_log_LR_similarity_typicality_pav < set_rms_log_LR_similarity_typicality_logreg) / num_sample_sets
odds_stpav_lesser = prop_stpav_lesser / (1-prop_stpav_lesser)


prop_stpav_kd_greater = sum(set_rms_log_LR_similarity_typicality_pav > set_rms_log_LR_similarity_typicality_kd) / num_sample_sets
odds_stpav_kd_greater = prop_stpav_greater / (1-prop_stpav_greater)

prop_stpav_kd_lesser = sum(set_rms_log_LR_similarity_typicality_pav < set_rms_log_LR_similarity_typicality_kd) / num_sample_sets
odds_stpav_kd_lesser = prop_stpav_lesser / (1-prop_stpav_lesser)



prop_scoring_greater = sum(set_rms_log_LR_scoring_method_kd > set_rms_log_LR_similarity_typicality_logreg) / num_sample_sets
odds_scoring_greater = prop_scoring_greater / (1-prop_scoring_greater)

prop_scoring_lesser = sum(set_rms_log_LR_scoring_method_kd < set_rms_log_LR_similarity_typicality_logreg) / num_sample_sets
odds_scoring_lesser = prop_scoring_lesser / (1-prop_scoring_lesser)


prop_svm_greater = sum(set_rms_log_LR_svm_logreg > set_rms_log_LR_similarity_typicality_logreg) / num_sample_sets
odds_svm_greater = prop_svm_greater / (1-prop_svm_greater)

prop_svm_lesser = sum(set_rms_log_LR_svm_logreg < set_rms_log_LR_similarity_typicality_logreg) / num_sample_sets
odds_svm_lesser = prop_svm_lesser / (1-prop_svm_lesser)





rmpath('./cllr', './fusion');


