clear all

load_files = {'coefs_english.mat' 'coefs_russian.mat' 'coefs_spanish.mat'};
num_load_files = length(load_files);

lang_labels = {'English' 'Russian' 'Spanish'};
colours={'or' 'vg' '^b'};
text_colour = {[1 0 0] [0 1 0] [0 0 1]};

plot_labels = false;

for I_load_file = 1:num_load_files
    load(load_files{I_load_file}, 'coefs', 'listenersIDs');
    B{I_load_file} = coefs;
    listeners{I_load_file} = listenersIDs;
end

for I_load_file = 1:num_load_files
    B_plot = squeeze(B{I_load_file}(2:3, :))'; % assuming intercept plus 2 stimulua-tuned coefficients
    plot(B_plot(:,1), B_plot(:,2), colours{I_load_file});
    hold on
    if plot_labels
        for I_listener = 1:length(listeners{I_load_file});
            text(B_plot(I_listener,1), B_plot(I_listener,2), num2str(listeners{I_load_file}(I_listener), '%02.0f'), 'color', text_colour{I_load_file});
        end
    end
end
% axis equal
%grid on
legend(lang_labels);
xlabel('spectral properties');
ylabel('duration');
hold off