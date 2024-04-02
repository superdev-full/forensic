function plot_LR(log_LR, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, title_text)

[num_test_suspects, ~] = size(log_LR);


figure;
plot(x_plot', log_LR_population', ':');
hold on
plot(x_plot', log_LR', '-');
xlim(new_xlim);
plot(new_xlim, [0 0], '-k');
if ~isempty(new_ylim);
    ylim(new_ylim);
end
for I_suspect = 1:num_test_suspects
    II = find(x_plot(I_suspect, :) == x_suspect(I_suspect));
    plot([x_suspect(I_suspect) x_suspect(I_suspect)], [0 log_LR(I_suspect, II)], '-k');
end
hold off
title(title_text);