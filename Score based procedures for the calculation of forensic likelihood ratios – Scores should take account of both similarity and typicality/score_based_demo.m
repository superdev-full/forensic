% score_based_demo.m
% Morrison GS (2016) Score based procedures for the calculation of forensic likelihood ratios – scores must take account of both similarity and typicality
% Matlab version: 8.6.0.267246 (R2015b)
% Script version: 2016-10-30b

clear all
close all
clc
addpath('./cllr');

defaultStream = RandStream.getGlobalStream; % random number generator
reset(defaultStream);


% specified Monte Carlo distributions

mu_b = 0;
sigma_b = 2;
sigma_w = 1;

sigma_bw = sqrt(sigma_b^2 + sigma_w ^2);

K = 2;
mu_k = [0, 2]; 

for k = 1:K
    x_q(:,k) = [mu_k(k)-2:.1:mu_k(k)+2]';
end
Q = length(x_q);

% thresholds for match/non-match
x_threshold = [.1:.1:2]';
s_threshold = log10(normpdf(x_threshold, 0, sigma_w));
n_threshold = length(s_threshold);
x_q_centre = ((Q-1)/2)+1;


x_plot = [mu_k(1)-sigma_w*4 : .1 : mu_k(end)+sigma_w*4]; %[-4:.1:6];
y_plot_pop = normpdf(x_plot, mu_b, sigma_bw);
y_plot_k = NaN(length(x_plot), K);
for k = 1:K
    y_plot_k(:,k) = normpdf(x_plot, mu_k(k), sigma_w);
end

figure(3);
plot(x_plot, y_plot_pop, '-r');
hold on
lines = {'-b', '-g'};
lines_dashed = {'--b', '--g'};
for k = 1:K
    plot(x_plot, y_plot_k(:,k), lines{k});
    hold on
end



% reference LR values

LAMBDA = NaN(Q, K);
for k = 1:K
    LAMBDA(:,k) = log10(normpdf(x_q(:,k), mu_k(k), sigma_w)) - log10(normpdf(x_q(:,k), mu_b, sigma_bw));
end


range_x_q = [min(x_q(:)), max(x_q(:))];
I_mu_k = NaN(1,K);
for k = 1:K
    I_mu_k(k) = find(x_q(:,k) == mu_k(k)); % only works if there as an x_q at mu_k
end

plot_title = 'reference';
draw_xq_lambda(4, x_q, range_x_q, LAMBDA, lines, 'true', mu_k, I_mu_k, plot_title);


% Monte Carlo samples

num_samples = 1000;
W = 300;
R = 90;


n_test = 90;
x_test = NaN(n_test, K);
for k = 1:K
    x_test(:,k) = normrnd(mu_k(k), sigma_w, n_test, 1);
end

LAMBDA_test_so = NaN(n_test, K);
LAMBDA_test_do = NaN(n_test, K);
for k = 1:K
    LAMBDA_test_so(:,k) = log(normpdf(x_test(:,k), mu_k(k), sigma_w)) - log(normpdf(x_test(:,k), mu_b, sigma_bw));
    k_cross = 3-k;
    LAMBDA_test_do(:,k) = log(normpdf(x_test(:,k_cross), mu_k(k), sigma_w)) - log(normpdf(x_test(:,k_cross), mu_b, sigma_bw));
end

Cllr_LAMBA = cllr(LAMBDA_test_so(:), LAMBDA_test_do(:));
Cllr_min_LAMBA = min_cllr(LAMBDA_test_so(:), LAMBDA_test_do(:));





num_so_train = W;
num_do_train = W^2-W;


e_ms_direct = NaN(num_samples,1);
e_ms_similarity_only = e_ms_direct;
e_ms_similarity_typicality = e_ms_direct;
e_ms_anchored = e_ms_direct;
e_ms_match_non_match = NaN(num_samples,n_threshold);

lambda_direct_all = NaN(Q,K,num_samples);
lambda_similarity_only_all = lambda_direct_all;
lambda_similarity_typicality_all = lambda_direct_all;
lambda_anchored_all = lambda_direct_all;
lambda_match_all = NaN(n_threshold,num_samples);
lambda_non_match_all = lambda_match_all;
lambda_match_non_match_plot = lambda_direct_all;

Cllr_direct = NaN(num_samples,1);
Cllr_min_direct = NaN(num_samples,1);
Cllr_similarity_only = NaN(num_samples,1);
Cllr_min_similarity_only = NaN(num_samples,1);
Cllr_similarity_typicality = NaN(num_samples,1);
Cllr_min_similarity_typicality = NaN(num_samples,1);
Cllr_anchored = NaN(num_samples,1);
Cllr_min_anchored = NaN(num_samples,1);
Cllr_match_non_match = NaN(num_samples,n_threshold);
Cllr_min_match_non_match = NaN(num_samples,n_threshold);


progress_bar = TimedProgressBar(num_samples, 100, [],[],[]);
clc
parfor I_sample = 1:num_samples
    
    % relevant population
    mu_w = normrnd(mu_b, sigma_b, W, 1);
    x_wr = NaN(R,W);
    x_wr_prime = NaN(1,W);
    for w = 1:W
        x_wr(:,w) = normrnd(mu_w(w), sigma_w, R, 1);
        x_wr_prime(w) = normrnd(mu_w(w), sigma_w); % extra sample
    end
    
    mu_b_sample = mean(x_wr(:));
    sigma_bw_sample = std(x_wr(:));
    mu_w_sample = mean(x_wr);
    sigma_pooled = sqrt(sum(var(x_wr))*(R-1)/((R-1)*W));
    
    % known sources extra sample
    x_k_prime_r = NaN(R,K);
    for k = 1:K
        x_k_prime_r(:,k) = normrnd(mu_k(k), sigma_pooled, R, 1);
    end
    
    
    % direct LR calculation
    lambda_direct = NaN(Q, K);
    for k = 1:K
        lambda_direct(:,k) = log10(normpdf(x_q(:,k), mu_k(k), sigma_pooled)) - log10(normpdf(x_q(:,k), mu_b_sample, sigma_bw_sample));
    end
    e_squared = (LAMBDA - lambda_direct).^2;
    e_squared(I_mu_k, :) = []; % delete the spike value
    e_ms_direct(I_sample) = mean(e_squared(:));
    
    
    lambda_direct_test_so = NaN(n_test, K);
    lambda_direct_test_do = NaN(n_test, K);
    for k = 1:K
        lambda_direct_test_so(:,k) = log(normpdf(x_test(:,k), mu_k(k), sigma_w)) - log(normpdf(x_test(:,k), mu_b_sample, sigma_bw_sample));
        k_cross = 3-k;
        lambda_direct_test_do(:,k) = log(normpdf(x_test(:,k_cross), mu_k(k), sigma_w)) - log(normpdf(x_test(:,k_cross), mu_b_sample, sigma_bw_sample));
    end

    Cllr_direct(I_sample) = cllr(lambda_direct_test_so(:), lambda_direct_test_do(:));
    Cllr_min_direct(I_sample) = min_cllr(lambda_direct_test_so(:), lambda_direct_test_do(:));
    
    
    % similarity only scores (non-anchored)
    s_similarity_only = NaN(W,W);
    for w = 1:W
        s_similarity_only(:,w) = log10(normpdf(x_wr_prime, mu_w_sample(w), sigma_pooled));
    end
    s_similarity_only_so = diag(s_similarity_only);
    
    II_diag = diag(ones(W,1));
    s_similarity_only_no_diag = s_similarity_only(:);
    s_similarity_only_do = s_similarity_only_no_diag;
    s_similarity_only_do(logical(II_diag(:))) = []; % paper version 2016-07-16 may have wrong number for number of s_do
    
    s_qk_similarity_only = NaN(Q,K);
    for k = 1:K
       s_qk_similarity_only(:,k) = log10(normpdf(x_q(:,k), mu_k(k), sigma_pooled));
    end
    lambda_similarity_only = pav_model(s_qk_similarity_only, s_similarity_only_so, s_similarity_only_do);
    e_squared = (LAMBDA - lambda_similarity_only).^2;
    e_squared(I_mu_k, :) = []; % delete the spike value
    e_ms_similarity_only(I_sample) = mean(e_squared(:));
    
    s_similarity_only_test_so = NaN(n_test,K);
    s_similarity_only_test_do = NaN(n_test,K);
    for k = 1:K
        s_similarity_only_test_so(:,k) = log10(normpdf(x_test(:,k), mu_k(k), sigma_pooled)) ;
        k_cross = 3-k;
        s_similarity_only_test_do(:,k) = log10(normpdf(x_test(:,k_cross), mu_k(k), sigma_pooled)) ;
    end
    lambda_similarity_only_test_so = pav_model(s_similarity_only_test_so, s_similarity_only_so, s_similarity_only_do);
    lambda_similarity_only_test_do = pav_model(s_similarity_only_test_do, s_similarity_only_so, s_similarity_only_do);
    Cllr_similarity_only(I_sample) = cllr(lambda_similarity_only_test_so(:), lambda_similarity_only_test_do(:));
    Cllr_min_similarity_only(I_sample) = min_cllr(lambda_similarity_only_test_so(:), lambda_similarity_only_test_do(:));
    
    
    % similarity & typicality scores (non-anchored)
    s_similarity_typicality = NaN(W,W);
    for w = 1:W
        s_similarity_typicality(:,w) = log10(normpdf(x_wr_prime, mu_w_sample(w), sigma_pooled)) - log10(normpdf(x_wr_prime, mu_b_sample, sigma_bw_sample));
    end
    s_similarity_typicality_so = diag(s_similarity_typicality);
    
    II_diag = diag(ones(W,1));
    s_similarity_typicality_no_diag = s_similarity_typicality(:);
    s_similarity_typicality_do = s_similarity_typicality_no_diag;
    s_similarity_typicality_do(logical(II_diag(:))) = [];
    
    s_qk_similarity_typicality = lambda_direct;
    lambda_similarity_typicality = pav_model(s_qk_similarity_typicality, s_similarity_typicality_so, s_similarity_typicality_do);
    e_squared = (LAMBDA - lambda_similarity_typicality).^2;
    e_squared(I_mu_k, :) = []; % delete the spike value
    e_ms_similarity_typicality(I_sample) = mean(e_squared(:));
    
    
    s_similarity_typicality_test_so = lambda_direct_test_so / log(10);
    s_similarity_typicality_test_do = lambda_direct_test_do / log(10);
    lambda_similarity_typicality_test_so = pav_model(s_similarity_typicality_test_so, s_similarity_typicality_so, s_similarity_typicality_do);
    lambda_similarity_typicality_test_do = pav_model(s_similarity_typicality_test_do, s_similarity_typicality_so, s_similarity_typicality_do);
    Cllr_similarity_typicality(I_sample) = cllr(lambda_similarity_typicality_test_so(:), lambda_similarity_typicality_test_do(:));
    Cllr_min_similarity_typicality(I_sample) = min_cllr(lambda_similarity_typicality_test_so(:), lambda_similarity_typicality_test_do(:));
    
    
    % anchored scores
    lambda_anchored = NaN(Q,K);
    lambda_anchored_test_so = NaN(n_test,K);
    lambda_anchored_test_do = NaN(n_test,K);
    for k = 1:K
        s_anchored_so = log10(normpdf(x_k_prime_r(:,k), mu_k(k), sigma_pooled));
        for q = 1:Q
            s_anchored_do = NaN(W,1);
            for w = 1:W
                s_anchored_do(w) = log10(normpdf(x_q(q,k), mu_w_sample(w), sigma_pooled));
            end
            s_qk_anchored = log10(normpdf(x_q(q,k), mu_k(k), sigma_pooled));
            lambda_anchored(q,k) = pav_model(s_qk_anchored, s_anchored_so, s_anchored_do);
        end
        
        s_anchored_test_so = log10(normpdf(x_test(:,k), mu_k(k), sigma_pooled));
        k_cross = 3-k;
        s_anchored_test_do = log10(normpdf(x_test(:,k_cross), mu_k(k), sigma_pooled));
        for I_test = 1:n_test
            s_anchored_do = NaN(W,1);
            s_anchored_do_cross = NaN(W,1);
            for w = 1:W
                s_anchored_do(w) = log10(normpdf(x_test(I_test,k), mu_w_sample(w), sigma_pooled));
                s_anchored_do_cross(w) = log10(normpdf(x_test(I_test,k_cross), mu_w_sample(w), sigma_pooled));
            end
            lambda_anchored_test_so(I_test,k) = pav_model(s_anchored_test_so(I_test), s_anchored_so, s_anchored_do);
            lambda_anchored_test_do(I_test,k) = pav_model(s_anchored_test_do(I_test), s_anchored_so, s_anchored_do_cross);
        end
        
    end
    e_squared = (LAMBDA - lambda_anchored).^2;
    e_squared(I_mu_k, :) = []; % delete the spike value
    e_ms_anchored(I_sample) = mean(e_squared(:));
    
    Cllr_anchored(I_sample) = cllr(lambda_anchored_test_so(:), lambda_anchored_test_do(:));
    Cllr_min_anchored(I_sample) = min_cllr(lambda_anchored_test_so(:), lambda_anchored_test_do(:));
    
    
    % match/non-match
    for I_threshold = 1:n_threshold
        p_true_match = sum(s_similarity_only_so>s_threshold(I_threshold)) / num_so_train;
        p_false_match = sum(s_similarity_only_do>s_threshold(I_threshold)) / num_do_train;
        lambda_match = log10(p_true_match) - log10(p_false_match);
        lambda_non_match = log10(1-p_true_match) - log10(1-p_false_match);
        
        lambda_match_non_match = ones(Q,K)*lambda_match;
        if I_threshold<x_q_centre %<=x_q_centre-1
            length_non_match = x_q_centre-I_threshold;
            repmat_lambda_non_match = repmat(lambda_non_match, length_non_match, K);
            lambda_match_non_match(1:length_non_match, :) = repmat_lambda_non_match;
            lambda_match_non_match(end-length_non_match+1:end, :) = repmat_lambda_non_match;
        end
        e_squared = (LAMBDA - lambda_match_non_match).^2;
        e_squared(I_mu_k, :) = []; % delete the spike value (in this case because the denominator is sometimes zero for the narrowest threshold)
        e_ms_match_non_match(I_sample,I_threshold) = mean(e_squared(:));
        
        lambda_match_all(I_threshold,I_sample) = lambda_match;
        lambda_non_match_all(I_threshold,I_sample) = lambda_non_match;
        
        
        II_test_so = s_similarity_only_test_so(:,k) > s_threshold(I_threshold);
        lambda_match_non_match_test_so = ones(n_test,1)*lambda_non_match;
        lambda_match_non_match_test_so(II_test_so) = lambda_match;
        II_test_do = s_similarity_only_test_do(:,k) > s_threshold(I_threshold);
        lambda_match_non_match_test_do = ones(n_test,1)*lambda_non_match;
        lambda_match_non_match_test_do(II_test_do) = lambda_match;
        
        Cllr_match_non_match(I_sample,I_threshold) = cllr(lambda_match_non_match_test_so(:), lambda_match_non_match_test_do(:));
%         Cllr_min_match_non_match(I_sample,I_threshold) = min_cllr(lambda_match_non_match_test_so(:), lambda_match_non_match_test_do(:));
        
        
        if x_threshold(I_threshold) == 1 % save this one to plot later
            lambda_match_non_match_plot(:,:,I_sample) = lambda_match_non_match;
        end
    end
    
    lambda_direct_all(:,:,I_sample) = lambda_direct;
    lambda_similarity_only_all(:,:,I_sample) = lambda_similarity_only;
    lambda_similarity_typicality_all(:,:,I_sample) = lambda_similarity_typicality;
    lambda_anchored_all(:,:,I_sample) = lambda_anchored;
    
    progress_bar.progress; 
end
progress_bar.stop;


e_rms_direct = sqrt(e_ms_direct);
e_rms_similarity_only = sqrt(e_ms_similarity_only);
e_rms_similarity_typicality = sqrt(e_ms_similarity_typicality);
e_rms_anchored = sqrt(e_ms_anchored);
e_rms_match_non_match = sqrt(e_ms_match_non_match);


figure(6);
data_boxplot =[e_rms_direct, e_rms_similarity_only, e_rms_similarity_typicality, e_rms_anchored];
box_labels = {'direct', 'similarity only', 'similarity and typicality', 'anchored'};
boxplot(data_boxplot, 'notch', 'on', 'widths', 0.75, 'orientation', 'horizontal', 'factordirection', 'list', 'labels', box_labels, 'colors', 'k', 'symbol', '+k');
set(gca, 'FontSize', 12);
x_lim = get(gca, 'XLim');
hold on
y_lim = get(gca, 'YLim');
plot([0 0], y_lim, ':k');

figure(13);
box_labels = x_threshold;
boxplot(e_rms_match_non_match, 'notch', 'on', 'widths', 0.5, 'orientation', 'horizontal', 'factordirection', 'list', 'labels', box_labels, 'colors', 'k', 'symbol', '+k');
set(gca, 'XLim', x_lim);
hold on
y_lim = get(gca, 'YLim');
plot([0 0], y_lim, ':k');



I_sample_plot = 1;
plot_title = 'direct';
draw_xq_lambda(5, x_q, range_x_q, LAMBDA, lines_dashed, 'true');
draw_xq_lambda(5, x_q, range_x_q, lambda_direct_all(:,:,I_sample_plot), lines, 'false', mu_k, I_mu_k, plot_title);

plot_title = 'similarity only';
draw_xq_lambda(7, x_q, range_x_q, LAMBDA, lines_dashed, 'true');
draw_xq_lambda(7, x_q, range_x_q, lambda_similarity_only_all(:,:,I_sample_plot), lines, 'false', mu_k, I_mu_k, plot_title);

plot_title = 'similarity and typicality';
draw_xq_lambda(8, x_q, range_x_q, LAMBDA, lines_dashed, 'true');
draw_xq_lambda(8, x_q, range_x_q, lambda_similarity_typicality_all(:,:,I_sample_plot), lines, 'false', mu_k, I_mu_k, plot_title);

plot_title = 'anchored';
draw_xq_lambda(9, x_q, range_x_q, LAMBDA, lines_dashed, 'true');
draw_xq_lambda(9, x_q, range_x_q, lambda_anchored_all(:,:,I_sample_plot), lines, 'false', mu_k, I_mu_k, plot_title);

plot_title = 'match/non-match';
draw_xq_lambda(12, x_q, range_x_q, LAMBDA, lines_dashed, 'true');
draw_xq_lambda(12, x_q, range_x_q, lambda_match_non_match_plot(:,:,I_sample_plot), lines, 'false', mu_k, I_mu_k, plot_title);




plot_title = 'direct';
draw_percentiles(55, x_q, range_x_q, LAMBDA, lambda_direct_all, mu_k, I_mu_k, plot_title);

plot_title = 'similarity only';
draw_percentiles(77, x_q, range_x_q, LAMBDA, lambda_similarity_only_all, mu_k, I_mu_k, plot_title);

plot_title = 'similarity and typicality';
draw_percentiles(88, x_q, range_x_q, LAMBDA, lambda_similarity_typicality_all, mu_k, I_mu_k, plot_title);

plot_title = 'anchored';
draw_percentiles(99, x_q, range_x_q, LAMBDA, lambda_anchored_all, mu_k, I_mu_k, plot_title);

plot_title = 'match/non-match';
draw_percentiles(1212, x_q, range_x_q, LAMBDA, lambda_match_non_match_plot, mu_k, I_mu_k, plot_title);



%xlim([-2.5 4.5]); ylim([-.8 1]);


figure(14);
data_boxplot = [Cllr_direct, Cllr_similarity_only, Cllr_similarity_typicality, Cllr_anchored];
box_labels = {'direct', 'similarity only', 'similarity and typicality', 'anchored'};
boxplot(data_boxplot, 'notch', 'on', 'widths', 0.75, 'orientation', 'horizontal', 'factordirection', 'list', 'labels', box_labels, 'colors', 'k', 'symbol', '+k');
set(gca, 'FontSize', 12);
hold on
y_lim = get(gca, 'YLim');
plot([Cllr_LAMBA Cllr_LAMBA], y_lim, ':k');
x_lim = get(gca, 'XLim');

% figure(1414);
% boxplot([Cllr_min_direct, Cllr_min_similarity_only, Cllr_min_similarity_typicality, Cllr_min_anchored]);

figure(15);
box_labels = x_threshold;
boxplot(Cllr_match_non_match, 'notch', 'on', 'widths', 0.5, 'orientation', 'horizontal', 'factordirection', 'list', 'labels', box_labels, 'colors', 'k', 'symbol', '+k');
hold on
y_lim = get(gca, 'YLim');
plot([Cllr_LAMBA Cllr_LAMBA], y_lim, ':k');
new_x_lim = x_lim;
x_lim = get(gca, 'XLim');
new_x_lim(2) = x_lim(2);
set(gca, 'XLim', new_x_lim);

figure(14);
set(gca, 'XLim', new_x_lim);


rmpath('./cllr');
