function plot_LR_ranges(set_log_LR, log_LR_population, x_plot, new_xlim, x_suspect, new_ylim, title_text)

[num_test_suspects, ~, num_sample_sets] = size(set_log_LR);

I_05 = round(num_sample_sets*.05);
I_95 = round(num_sample_sets*.95);


sorted_set_log_LR = sort(set_log_LR, 3);
log_LR_sample_50 = median(sorted_set_log_LR, 3);
log_LR_sample_05 = sorted_set_log_LR(:,:,I_05);
log_LR_sample_95 = sorted_set_log_LR(:,:,I_95);

figure;
plot(x_plot', log_LR_population', ':');
hold on
plot(x_plot', log_LR_sample_50', '-');
plot(x_plot', log_LR_sample_05', '-');
plot(x_plot', log_LR_sample_95', '-');
xlim(new_xlim);
plot(new_xlim, [0 0], '-k');
ylim(new_ylim);
for I_suspect = 1:num_test_suspects
    II = find(x_plot(I_suspect, :) == x_suspect(I_suspect));
    plot([x_suspect(I_suspect) x_suspect(I_suspect)], [0 log_LR_sample_50(I_suspect, II)], '-k');
end
hold off
title(title_text);