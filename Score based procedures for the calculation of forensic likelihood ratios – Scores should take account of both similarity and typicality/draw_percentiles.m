function draw_percentiles(h_fig, x_q, range_x_q, LAMBDA, lambda, mu_k, I_mu_k, plot_title)

[Q, K, num_samples] = size(lambda);

lambda_sorted = NaN(Q, K, num_samples);
for k = 1:K
    for q = 1:Q
        lambda_sorted(q,k,:) = sort(lambda(q,k,:));
    end
end

I_05 = round(num_samples*.05);
I_50 = round(num_samples*.50);
I_95 = round(num_samples*.95);

lambda_05 = lambda_sorted(:,:,I_05);
lambda_50 = lambda_sorted(:,:,I_50);
lambda_95 = lambda_sorted(:,:,I_95);

lines = {'-b', '-g'};
lines_dashed = {'--b', '--g'};

draw_xq_lambda(h_fig, x_q, range_x_q, LAMBDA, lines_dashed, 'true');
draw_xq_lambda(h_fig, x_q, range_x_q, lambda_05, lines, 'false');
draw_xq_lambda(h_fig, x_q, range_x_q, lambda_50, lines, 'false', mu_k, I_mu_k, plot_title);
draw_xq_lambda(h_fig, x_q, range_x_q, lambda_95, lines, 'false');
