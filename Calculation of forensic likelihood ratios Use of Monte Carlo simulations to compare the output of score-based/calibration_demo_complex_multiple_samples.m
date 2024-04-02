% calibration_demo_complex_multiple_samples
%
% This script runs the illustrations described in:
%   Morrison (2014 submitted) Calculation of forensic likelihood ratios:
%       Use of Monte Carlo simulations to compare the output of score-based approaches with true likelihood-ratio values
%
% tested on R2013b

clear all
% close all
% clc

addpath('./cllr', './fusion');

% number of sample sets
num_sample_sets = 10;

% number of samples to draw from population
num_sample_speakers = 100;
num_sample_tokens_per_speaker = 30;


% number of test speakers per cluster
num_test_speakers_per_population_cluster = 12;


% population parameters
num_dimensions = 2; % 2 4
num_population_clusters = 4;
spread_population = [-4 4];

sigma_population_initial = diag(ones(num_dimensions,1)*1);

num_speakers_per_population_cluster = 1000 + num_test_speakers_per_population_cluster; % 1000
spread_speaker = [-2 2];
min_sep_speaker_cluster = 2;


num_speaker_clusters = 3; % 3 5
sigma_speakers_initial = diag(ones(num_dimensions,1)*.25);

% model parameters
num_gauss_suspect = 3; % 3 5
num_gauss_population = 4;
gmm_replicates = 4;



% initiate the random number stream so we can get the same random sets each time we run this script (see "Managing the Default Stream" in help)
defaultStream = RandStream.getGlobalStream;
reset(defaultStream);


% generate a population of speaker mean vactors and covariance matrices
mu_population = random('Uniform', spread_population(1), spread_population(2), num_population_clusters, num_dimensions);

num_generate_tokens_population = num_dimensions*6;

num_speakers_total = num_speakers_per_population_cluster * num_population_clusters;

sigma_population = cell(num_population_clusters, 1);
mu_speakers_initial = NaN(num_speakers_total, num_dimensions);
for I_population_clusters = 1:num_population_clusters
    x_population_temp = mvnrnd(mu_population(I_population_clusters, :), sigma_population_initial, num_generate_tokens_population);
    sigma_population{I_population_clusters} = cov(x_population_temp);
    
    I_start = num_speakers_per_population_cluster * (I_population_clusters - 1) + 1;
    I_end = num_speakers_per_population_cluster * I_population_clusters;
    mu_speakers_initial(I_start : I_end, :) = mvnrnd(mu_population(I_population_clusters, :), sigma_population{I_population_clusters}, num_speakers_per_population_cluster);
end



offset_speakers_temp = zeros(num_speaker_clusters, num_dimensions);
for I_cluster = 2:num_speaker_clusters
    not_done = true;
    I_count = 0;
    while not_done
        I_count = I_count+1;
        if I_count == num_dimensions * 20
            error('Failed to generate separation between speaker clusters')
        end
        not_done = false;
        offset_temp = random('Uniform', spread_speaker(1), spread_speaker(2), 1, num_dimensions);
        for I_dist_check = 1:I_cluster-1
            dist_temp = pdist2(offset_speakers_temp(I_dist_check, :), offset_temp);
            if dist_temp < min_sep_speaker_cluster
                not_done = true;
                break
            end
        end
    end
    offset_speakers_temp(I_cluster, :) = offset_temp;

end



offset_speakers_rep = repmat(offset_speakers_temp, 1, 1, num_speakers_total);
offset_speakers = permute(offset_speakers_rep, [3 2 1]);



mu_speakers_clusters = repmat(mu_speakers_initial, 1, 1, num_speaker_clusters) + offset_speakers;

num_generate_tokens = num_dimensions*6;

mu_zero = zeros(1,num_dimensions);
sigma_speakers = cell(num_speakers_total,num_speaker_clusters);
for I_speaker = 1:num_speakers_total
    for I_speaker_cluster = 1:num_speaker_clusters
        x_zeroed_speaker_temp = mvnrnd(mu_zero, sigma_speakers_initial, num_generate_tokens);
        sigma_speakers{I_speaker,I_speaker_cluster} = cov(x_zeroed_speaker_temp);
        
        mu_speakers(I_speaker, :, I_speaker_cluster) = mu_speakers_clusters(I_speaker, :, I_speaker_cluster) + mean(x_zeroed_speaker_temp, 1);
    end
end

% mu_speakers [matrix]: dim 1: speakers, dim 2: dimensions, dim 3: within speaker clusters
% sigma_speakers {cell}: dim 1: speakers, dim 2: within speaker clusters




% extract test speakers
num_test_speakers = num_test_speakers_per_population_cluster * num_population_clusters;
num_population_speakers = num_speakers_total - num_test_speakers;

II_extract_temp = 1:num_test_speakers_per_population_cluster;
II_extract = [];
for I_cluster = 1:num_population_clusters
    II_extract = [II_extract, II_extract_temp + (I_cluster - 1) * num_speakers_per_population_cluster];
end

mu_test_speakers = mu_speakers(II_extract, :, :);
sigma_test_speakers = sigma_speakers(II_extract, :);


mu_speakers(II_extract, :, :) = [];
sigma_speakers(II_extract, :) = [];


% generate a set of offender tokens
x_offender_tokens = cell(num_test_speakers,1);
for I_speaker = 1:num_test_speakers
    max_temp = NaN(num_speaker_clusters, num_dimensions);
    min_temp = max_temp;
    for I_speaker_cluster = 1:num_speaker_clusters
        expand_temp = 1 .* diag(sigma_test_speakers{I_speaker, I_speaker_cluster})';
        max_temp(I_speaker_cluster, :) = mu_test_speakers(I_speaker, :, I_speaker_cluster) + expand_temp;
        min_temp(I_speaker_cluster, :) = mu_test_speakers(I_speaker, :, I_speaker_cluster) - expand_temp;
    end
    max_x = max(max_temp, [], 1);
    min_x = min(min_temp, [], 1);
    range_x = max_x - min_x;
    num_steps = 11;
    step_x = range_x ./ num_steps;
    grid_x = NaN(num_steps+1, num_dimensions);
    for I_dim = 1:num_dimensions
        grid_x(:, I_dim) = (min_x(I_dim) : step_x(I_dim) : max_x(I_dim))'; % this is a line cutting diagonally through the space
    end
    x_offender_tokens{I_speaker} = grid_x;
end
num_offender_tokens_per_suspect = num_steps+1;




% PLOTS

% figure;
% scatter(squeeze(offset_speakers_temp(:,1)), squeeze(offset_speakers_temp(:,2)));

% figure;
% scatter(mu_speakers_initial(:,1), mu_speakers_initial(:,2));
% hold on
% scatter(squeeze(offset_speakers_temp(:,1,:)), squeeze(offset_speakers_temp(:,2,:)), 'r');

% figure;
% scatter(mu_speakers(:, 1, 1), mu_speakers(:, 2, 1), 'b');
% hold on
% scatter(mu_speakers(:, 1, 2), mu_speakers(:, 2, 2), 'r');
% scatter(mu_speakers(:, 1, 3), mu_speakers(:, 2, 3), 'g');

% figure;
% scatter(mu_speakers(:, 1, 1), mu_speakers(:, 2, 1), 'b');
% hold on
% scatter(mu_speakers(:, 1, 2), mu_speakers(:, 2, 2), 'b');
% scatter(mu_speakers(:, 1, 3), mu_speakers(:, 2, 3), 'b');
% x_offender_tokens_mat = cell2mat(x_offender_tokens);
% scatter(x_offender_tokens_mat(:, 1), x_offender_tokens_mat(:, 2), 'g', 'MarkerFaceColor', 'g');
% scatter(mu_test_speakers(:, 1, 1), mu_test_speakers(:, 2, 1), 'r', 'MarkerFaceColor', 'r');
% scatter(mu_test_speakers(:, 1, 2), mu_test_speakers(:, 2, 2), 'r', 'MarkerFaceColor', 'r');
% scatter(mu_test_speakers(:, 1, 3), mu_test_speakers(:, 2, 3), 'r', 'MarkerFaceColor', 'r');








% calculate likelihood ratios given population 
numerator_population_temp = NaN(num_offender_tokens_per_suspect, num_test_speakers, num_speaker_clusters);
for I_speaker = 1:num_test_speakers
    for I_speaker_cluster = 1:num_speaker_clusters
        numerator_population_temp(:, I_speaker, I_speaker_cluster) = mvnpdf(x_offender_tokens{I_speaker}, mu_test_speakers(I_speaker, :, I_speaker_cluster), sigma_test_speakers{I_speaker, I_speaker_cluster});
    end
end
numerator_population = mean(numerator_population_temp, 3);

denominator_population_temp = NaN(num_offender_tokens_per_suspect, num_test_speakers, num_population_speakers, num_speaker_clusters);
for I_test_speaker = 1:num_test_speakers
    for I_speaker = 1:num_population_speakers
        for I_speaker_cluster = 1:num_speaker_clusters
            denominator_population_temp(:, I_test_speaker, I_speaker, I_speaker_cluster) = mvnpdf(x_offender_tokens{I_test_speaker}, mu_speakers(I_speaker, :, I_speaker_cluster), sigma_speakers{I_speaker, I_speaker_cluster});
        end
    end
end
denominator_population = mean(mean(denominator_population_temp, 4), 3);

log_LR_population = log10(numerator_population) - log10(denominator_population);




% LOOP SAMPLE SETS
set_rms_log_LR_direct = NaN(num_sample_sets,1);
set_rms_log_LR_similarity_pav = set_rms_log_LR_direct;
set_rms_log_LR_distance_pav = set_rms_log_LR_direct;
set_rms_log_LR_similarity_typicality_pav = set_rms_log_LR_direct;




base_natural = log10(exp(1));
cllr_similarity = NaN(num_sample_sets,1);
cllr_distance = cllr_similarity;
cllr_similarity_typicality = cllr_similarity;

loop_time = NaN(num_sample_sets,1);
for I_sample_sets = 1:num_sample_sets
tic
    
% select sample speakers
II_sample_speakers = randi(num_population_speakers, num_sample_speakers*2, 1);
mu_sample_speakers = mu_speakers(II_sample_speakers, :, :);
sigma_sample_speakers = sigma_speakers(II_sample_speakers, :);

% generate tokens for sample speakers
x_speaker_tokens = cell(num_sample_speakers, 1);
x_eval_same_tokens = x_speaker_tokens; %the first set is used to train models and the second set as values at which to evaluate the models
x_eval_different_tokens = x_speaker_tokens;
for I_speaker = 1:num_sample_speakers
    x_speaker_tokens_temp = NaN(num_sample_tokens_per_speaker, num_dimensions);
    x_speaker_eval_temp = x_speaker_tokens_temp;
    
    II_samples_per_cluster = randi(num_speaker_clusters, num_sample_tokens_per_speaker, 1);
    I_count = 1;
    for I_speaker_cluster = 1:num_speaker_clusters
        num_samples_this_cluster = sum(II_samples_per_cluster == I_speaker_cluster);
        I_end = I_count+num_samples_this_cluster-1;
        x_speaker_tokens_temp(I_count:I_end, 1:num_dimensions) = mvnrnd(mu_sample_speakers(I_speaker, :, I_speaker_cluster), sigma_sample_speakers{I_speaker, I_speaker_cluster}, num_samples_this_cluster);
        I_count = I_end+1;
    end
    x_speaker_tokens{I_speaker} = x_speaker_tokens_temp;
    
    II_samples_per_cluster = randi(num_speaker_clusters, num_sample_tokens_per_speaker, 1);
    I_count = 1;
    for I_speaker_cluster = 1:num_speaker_clusters
        num_samples_this_cluster = sum(II_samples_per_cluster == I_speaker_cluster);
        I_end = I_count+num_samples_this_cluster-1;
        x_speaker_eval_temp(I_count:I_end, 1:num_dimensions) = mvnrnd(mu_sample_speakers(I_speaker, :, I_speaker_cluster), sigma_sample_speakers{I_speaker, I_speaker_cluster}, num_samples_this_cluster);
        I_count = I_end+1;
    end
    x_eval_same_tokens{I_speaker} = x_speaker_eval_temp;
    
end
for I_speaker = 1:num_sample_speakers
    J_speaker = I_speaker + num_sample_speakers;
    x_speaker_tokens_temp = NaN(num_sample_tokens_per_speaker, num_dimensions);
    x_speaker_eval_temp = x_speaker_tokens_temp;
    
    II_samples_per_cluster = randi(num_speaker_clusters, num_sample_tokens_per_speaker, 1);
    I_count = 1;
    for I_speaker_cluster = 1:num_speaker_clusters
        num_samples_this_cluster = sum(II_samples_per_cluster == I_speaker_cluster);
        I_end = I_count+num_samples_this_cluster-1;
        x_speaker_tokens_temp(I_count:I_end, 1:num_dimensions) = mvnrnd(mu_sample_speakers(J_speaker, :, I_speaker_cluster), sigma_sample_speakers{J_speaker, I_speaker_cluster}, num_samples_this_cluster);
        I_count = I_end+1;
    end
    x_eval_different_tokens{I_speaker} = x_speaker_tokens_temp;
    
end
x_training_tokens = cell2mat(x_speaker_tokens);
num_sample_tokens_total = num_sample_speakers*num_sample_tokens_per_speaker;


% generate tokens for suspects
x_suspect_tokens = cell(num_test_speakers, 1);
for I_speaker = 1:num_test_speakers
    x_suspect_tokens_temp = NaN(num_sample_tokens_per_speaker, num_dimensions);
    II_samples_per_cluster = randi(num_speaker_clusters, num_sample_tokens_per_speaker, 1);
    I_count = 1;
    for I_speaker_cluster = 1:num_speaker_clusters
        num_samples_this_cluster = sum(II_samples_per_cluster == I_speaker_cluster);
        I_end = I_count+num_samples_this_cluster-1;
        x_suspect_tokens_temp(I_count:I_end, 1:num_dimensions) = mvnrnd(mu_test_speakers(I_speaker, :, I_speaker_cluster), sigma_test_speakers{I_speaker, I_speaker_cluster}, num_samples_this_cluster);
        I_count = I_end+1;
    end
    x_suspect_tokens{I_speaker} = x_suspect_tokens_temp;
end



% direct LR calculation given sample
% calculate numerator
suspect_model = cell(num_test_speakers, 1);
numerator_sample = NaN(num_offender_tokens_per_suspect, num_test_speakers);
suspect_mu = suspect_model;
suspect_sigma = suspect_mu;
if num_gauss_suspect == 1;
    for I_speaker = 1:num_test_speakers
        suspect_mu{I_speaker} = mean(x_suspect_tokens{I_speaker}, 1);
        suspect_sigma{I_speaker} = std(x_suspect_tokens{I_speaker}, 1);
        numerator_sample(:,I_speaker) = log10(mvnpdf(x_offender_tokens{I_speaker}, suspect_mu{I_speaker}, suspect_sigma{I_speaker}));
    end
else
    for I_speaker = 1:num_test_speakers
        suspect_model{I_speaker} = gmdistribution.fit(x_suspect_tokens{I_speaker}, num_gauss_suspect, 'Regularize', 0.001, 'Replicates', gmm_replicates);
        numerator_sample(:,I_speaker) = log10(pdf(suspect_model{I_speaker}, x_offender_tokens{I_speaker}));
    end
end


% calculate denominator
if num_gauss_population == 1;
    background_mu = mean(x_training_tokens, 1);
    background_sigma = std(x_training_tokens, 1);
    denominator_sample = log10(mvnpdf(cell2mat(x_offender_tokens), background_mu, background_sigma));
else
    % options = statset('gmdistribution');
    % options.MaxIter = 300;
    % options.TolX = 1e-03;
    % background_model = gmdistribution.fit(x_training_tokens, num_gauss_population, 'Regularize', 0.001, 'Replicates', gmm_replicates, 'Options', options);
    background_model = gmdistribution.fit(x_training_tokens, num_gauss_population, 'Regularize', 0.001, 'Replicates', gmm_replicates);
    denominator_sample = log10(pdf(background_model, cell2mat(x_offender_tokens)));
end

% calculate LR
log_LR_direct = numerator_sample(:) - denominator_sample;

rms_log_LR_direct = sqrt(mean((log_LR_direct(:) - log_LR_population(:)).^2));

set_rms_log_LR_direct(I_sample_sets) = rms_log_LR_direct;



% score-based likelihood ratios given sample

% note: to get reasonable run times we are not cross-validating speakers (but gmm training and eval data are different sets of tokens for same-origin, and different speakers for different-origin)

score_similarity = NaN(num_sample_tokens_per_speaker*2, num_sample_speakers);
score_similarity_typicality = score_similarity;
score_distance = score_similarity;
x_eval = NaN(num_sample_tokens_per_speaker*2, num_dimensions, num_sample_speakers);
speaker_mu = cell(num_sample_speakers, 1);
speaker_sigma = suspect_mu;

if num_gauss_suspect == 1;
    for I_speaker = 1:num_sample_speakers
        speaker_mu{I_speaker} = mean(x_speaker_tokens{I_speaker}, 1);
        speaker_sigma{I_speaker} = std(x_speaker_tokens{I_speaker}, 1);
        x_eval_temp = [x_eval_same_tokens{I_speaker}; x_eval_different_tokens{I_speaker}];
        x_eval(:,:,I_speaker) = x_eval_temp;
        score_similarity(:,I_speaker) = log10(mvnpdf(x_eval_temp, speaker_mu{I_speaker}, speaker_sigma{I_speaker}));
        
        for I_x_eval_temp = 1:num_sample_tokens_per_speaker*2
            score_distance(I_x_eval_temp,I_speaker) = mean(pdist2(x_eval_temp(I_x_eval_temp, :), x_speaker_tokens{I_speaker}));
        end

    end
else
    for I_speaker = 1:num_sample_speakers
        speaker_model{I_speaker} = gmdistribution.fit(x_speaker_tokens{I_speaker}, num_gauss_suspect, 'Regularize', 0.001, 'Replicates', gmm_replicates);        x_eval_temp = [x_eval_same_tokens{I_speaker}; x_eval_different_tokens{I_speaker}]; 
        x_eval_temp = [x_eval_same_tokens{I_speaker}; x_eval_different_tokens{I_speaker}];
        x_eval(:,:,I_speaker) = x_eval_temp;
        score_similarity(:,I_speaker) = log10(pdf(speaker_model{I_speaker}, x_eval_temp));
        
        for I_x_eval_temp = 1:num_sample_tokens_per_speaker*2
            score_distance(I_x_eval_temp,I_speaker) = mean(pdist2(x_eval_temp(I_x_eval_temp, :), x_speaker_tokens{I_speaker}));
        end
        
    end
end

if num_gauss_population == 1;
    for I_speaker = 1:num_sample_speakers
        x_eval_temp = squeeze(x_eval(:,:,I_speaker));
        score_similarity_typicality(:,I_speaker) = score_similarity(:,I_speaker) - log10(mvnpdf(x_eval_temp, background_mu, background_sigma));
    end
else
    for I_speaker = 1:num_sample_speakers
        x_eval_temp = squeeze(x_eval(:,:,I_speaker));
        score_similarity_typicality(:,I_speaker) = score_similarity(:,I_speaker) - log10(pdf(background_model, x_eval_temp));
    end
end

% separate same- and different-origin training scores
score_similarity_same = score_similarity(1:num_sample_tokens_per_speaker, :);
score_similarity_different = score_similarity(num_sample_tokens_per_speaker+1:end, :);

score_distance_same = score_distance(1:num_sample_tokens_per_speaker, :);
score_distance_different = score_distance(num_sample_tokens_per_speaker+1:end, :);

score_similarity_typicality_same = score_similarity_typicality(1:num_sample_tokens_per_speaker, :);
score_similarity_typicality_different = score_similarity_typicality(num_sample_tokens_per_speaker+1:end, :);


% calculate distance scores for suspects and offenders
score_distance_susp_off = NaN(num_steps+1, num_test_speakers);
for I_speaker = 1:num_test_speakers
    x_offender_tokens_temp = x_offender_tokens{I_speaker};
    for I_x_offender = 1:num_steps+1
        score_distance_susp_off(I_x_offender,I_speaker) = mean(pdist2(x_offender_tokens_temp(I_x_offender, :), x_suspect_tokens{I_speaker}));
    end
end




% PAV
[log_LR_similarity_pav, cllr_similarity(I_sample_sets)] = pav_model_cllr(numerator_sample(:), score_similarity_same, score_similarity_different);

[log_LR_distance_pav, cllr_distance(I_sample_sets)] = pav_model_cllr(-score_distance_susp_off(:), -score_distance_same, -score_distance_different);

[log_LR_similarity_typicality_pav, cllr_similarity_typicality(I_sample_sets)] = pav_model_cllr(log_LR_direct, score_similarity_typicality_same, score_similarity_typicality_different);

rms_log_LR_similarity_pav = sqrt(mean((log_LR_similarity_pav(:) - log_LR_population(:)).^2));
rms_log_LR_distance_pav = sqrt(mean((log_LR_distance_pav(:) - log_LR_population(:)).^2));
rms_log_LR_similarity_typicality_pav = sqrt(mean((log_LR_similarity_typicality_pav(:) - log_LR_population(:)).^2));


set_rms_log_LR_similarity_pav(I_sample_sets) = rms_log_LR_similarity_pav;
set_rms_log_LR_distance_pav(I_sample_sets) = rms_log_LR_distance_pav;
set_rms_log_LR_similarity_typicality_pav(I_sample_sets) = rms_log_LR_similarity_typicality_pav;




loop_time(I_sample_sets) = toc;
mean_time_per_loop = mean(loop_time(1:I_sample_sets));
mean_time_per_loop_min = mean_time_per_loop/60;
elapsed_time = sum(loop_time(1:I_sample_sets))/60;
fprintf('Loops complete: %0.0f\nMinutes elaspsed: %0.0f\nMean loop duration (seconds): %0.0f\nLoops to go: %0.0f\nEst minutes to go: %0.0f\n\n', I_sample_sets, elapsed_time, mean_time_per_loop, num_sample_sets-I_sample_sets, (num_sample_sets-I_sample_sets)*mean_time_per_loop_min);
end



% plot results
figure;
data_boxplot = [set_rms_log_LR_direct,...
    set_rms_log_LR_distance_pav,...
    set_rms_log_LR_similarity_pav,...
    set_rms_log_LR_similarity_typicality_pav];
boxplot(data_boxplot, 'notch', 'on', 'widths', 0.8);
figure_title = ['dim ', num2str(num_dimensions), '. spk ', num2str(num_sample_speakers), '. tkn ', num2str(num_sample_tokens_per_speaker), '. ngs ', num2str(num_gauss_suspect), '. ngp ', num2str(num_gauss_population), '.'];
title(figure_title);




mean_cllr_similarity = mean(cllr_similarity);
mean_cllr_similarity_typicality = mean(cllr_similarity_typicality);
paired_difference = cllr_similarity - cllr_similarity_typicality;
mean_paired_difference = mean(paired_difference);





rmpath('./cllr', './fusion');


