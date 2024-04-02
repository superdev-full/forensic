%plot_f0

figure(pitchplot);
clf

f0minplot = min(f0_min);
f0maxplot = max(f0_max);

% best f0
[f0_best_min, I_f0_best_min] = max(f0_score);
[f0_best_max, I_f0_best_max] = max(f0_best_min);
f0_best_min = f0_best_min(I_f0_best_max);
I_f0_best_min = I_f0_best_min(I_f0_best_max);

best_f0 = f0{I_f0_best_min, I_f0_best_max};

% positions of subplots
min_range = .05;
max_range = .975;
num_boxes = 4;
gap = 0.01;
subplot_width = (max_range - min_range)/num_boxes - gap + gap/num_boxes;
subplot_origins = min_range : subplot_width + gap : max_range;

h_pitch_subplot = NaN(16, 3);
I_h_pitch_subplot = 0;
for I_f0_min = 1:num_f0_min
    for I_f0_max = 1:num_f0_max
        current_subplot = subplot(num_f0_min, num_f0_max, (16 - I_f0_min * 4) + I_f0_max);
        set(current_subplot, 'Position', [subplot_origins(I_f0_max), subplot_origins(I_f0_min), subplot_width, subplot_width]);
        
        plot(taxsg, f0{I_f0_min, I_f0_max}, 'b-');
        hold on
        plot([taxsg(1)+fromedge_ms, taxsg(1)+fromedge_ms], [f0maxplot, f0minplot],'k-');
        plot([taxsg(end)-fromedge_ms, taxsg(end)-fromedge_ms], [f0maxplot, f0minplot],'k-');
        plot([taxsg(1), taxsg(end)], [f0_min(I_f0_min), f0_min(I_f0_min)],'g-');
        plot([taxsg(1), taxsg(end)], [f0_max(I_f0_max), f0_max(I_f0_max)],'g-');
        text((taxsg(end)-fromedge_ms)*.05, f0maxplot*.98, num2str(f0_score(I_f0_min, I_f0_max), '%0.4f'), 'VerticalAlignment', 'top');
        hold off
        xlim([taxsg(1), taxsg(end)]);
        ylim([f0minplot, f0maxplot]);
        
        % put axis labels on bottom and leftmost plots only
        if I_f0_min~=1
            set(current_subplot, 'XTickLabel', []);
%         else
%             xlabel(['max f0 = ', num2str(f0_max(I_f0_max), '%1.0f'), ' Hz']);
        end
        if I_f0_max~=1
            set(current_subplot, 'YTickLabel', []);
%         else
%             ylabel(['min f0 = ', num2str(f0_min(I_f0_min), '%1.0f'), ' Hz']);
%             set(get(current_subplot, 'YLabel'), 'Rotation', 90);
        end
        
        % highlight best plot
        if I_f0_min == I_f0_best_min && I_f0_max == I_f0_best_max
            set(gca, 'xcolor','r','ycolor','r','LineWidth', 3);
            last_best_pitch_subplot = gca;
        else
            set(gca, 'xcolor','k','ycolor','k','LineWidth',.5);
        end
        
        I_h_pitch_subplot = I_h_pitch_subplot + 1;
        h_pitch_subplot(I_h_pitch_subplot, :) = [I_f0_min, I_f0_max, current_subplot];
    end
end