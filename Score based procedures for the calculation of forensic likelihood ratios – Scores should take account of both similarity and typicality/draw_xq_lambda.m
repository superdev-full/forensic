function h_fig = draw_xq_lambda(h_fig, x_q, range_x_q, lambda, lines, first_drawn, mu_k, I_mu_k, plot_title)

if isempty(h_fig)
    h_fig = figure;
else
    figure(h_fig);
end

if first_drawn
    plot([range_x_q(1)-.5, range_x_q(2)+.5], [0, 0], '-k');
    hold on
end

for k = 1:2
    if nargin > 6
        plot([mu_k(k), mu_k(k)], [0, lambda(I_mu_k(k),k)], '-k');
        title(plot_title);
        hold on
    end
    plot(x_q(:,k), lambda(:,k), lines{k});
    hold on
end
