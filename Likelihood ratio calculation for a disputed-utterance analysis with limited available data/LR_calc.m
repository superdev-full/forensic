% likelihood-ratio analysis of Swedish disputed-utterance data
% First and Second statistical analyses in:
%   Morrison, Lindh, Curran (2013)
%   Likelihood ratio calculation for a disputed-utterance analysis with limited available data
% known to run sucessfully on Matlab R2010a

clear all
close all

% options
deskew_2_var = false; % deskew using angle and shift (if set to false, only angle used)

plot_data = true;
draw_offender = true;
colour = {'>r' '<b' 'og'};

num_simulations = 10000;


%% LOAD AND TRANSFORM INITIAL DATA

% DATA
% Columns: I_Word VOT1 VOT2 VOT3 F0 F1 F2 F3 
%          1      2    3    4    5  6  7  8
% 
% I_Word 1=dom 2=Tim and 3=disputed
% VOT1,2,3 = 1st 2nd and 3rd VOT measurement of same token
% F3 measurements are not reliable, one is missing

load('data.txt');

var_labels = {'mean VOT' 'F1' 'F2'};
phoneme_labels = {'dom' 'Tim'};


% indices
II_known = NaN(size(data, 1), 2);
II_known_1 = data(:,1)==1; % dom
II_known_2 = data(:,1)==2; % Tim
II_disputed = find(data(:,1)==3); % disputed
num_known_data = [sum(II_known_1), sum(II_known_2)];

% formant data
formant_data = data(:, 6:7); % F1, F2


% transform VOT data
VOT_data = data(:, 2:4) * 1000; % convert to ms
mean_VOT_data = mean(VOT_data, 2); % mean of measurments for each token

mean_VOT_data_cell = {mean_VOT_data(II_known_1), mean_VOT_data(II_known_2)};
if deskew_2_var
    [transformed_VOT_data, angle, shift] = deskew2(mean_VOT_data_cell);
    fprintf('\nVOT transformation\nangle: %0.3f rad/ms\nshift: %0.3f ms\n', angle/pi, shift);
else
    [transformed_VOT_data, angle] = deskew1(mean_VOT_data_cell);
    fprintf('\nVOT transformation\nangle: %0.3f rad/ms\n', angle/pi);
end

skewness_ms = NaN(1,2);
skewness_transformed = NaN(1,2);
for I_phoneme = 1:2 
    skewness_ms(I_phoneme) = skewness(mean_VOT_data_cell{I_phoneme});
    skewness_transformed(I_phoneme) = skewness(transformed_VOT_data{I_phoneme});
end


% known data (VOT, F1, F2)
known_data = {[transformed_VOT_data{1}, formant_data(II_known_1, :)],...
              [transformed_VOT_data{2}, formant_data(II_known_2, :)]};

% disputed-utterance data (VOT, F1, F2)
disputed_data = [mean_VOT_data(II_disputed), formant_data(II_disputed, :)]; % only one data point
disputed_data_VOT_ms = disputed_data(1);
% transform VOT
if deskew_2_var
    disputed_data(1) = atan( angle * (disputed_data_VOT_ms + shift) );
else
    disputed_data(1) = atan( angle * disputed_data_VOT_ms );
end

% calculation of priors for Third statistical analysis - see R code
priors_mean = NaN(2,3);
priors_std = NaN(2,3);
priors_mean(:,2:3) = [604, 1043; 464, 2093]; % F1, F2 from Swedia database
priors_std(:,2:3) = [65, 124; 76, 569];
mean_VOT_prior_ms = [-45.37, 53.82]; % VOT from Lundborg et al (2012)
std_VOT_prior_ms = [56.33, 9.21]; 
ratio_VOT_priors = std_VOT_prior_ms ./ abs(mean_VOT_prior_ms);
if deskew_2_var
    priors_mean(1,1) = atan( angle * (mean_VOT_prior_ms(1) + shift) );
    priors_mean(2,1) = atan( angle * (mean_VOT_prior_ms(2) + shift) );
else
    priors_mean(1,1) = atan( angle * mean_VOT_prior_ms(1) );
    priors_mean(2,1) = atan( angle * mean_VOT_prior_ms(2) );
end
priors_std(:,1) = abs(priors_mean(:,1) .* ratio_VOT_priors(:));



%% DRAW DATA PLOTS

% plots
% 1D

if plot_data
    for I_var = 1:3
        figure(I_var);
        for I_phoneme = 1:2
    %         subplot(2,1,I_phoneme);
            subplot(2,1, 3-I_phoneme); % put "Tim" on top and "dom" on bottom
            hist(known_data{I_phoneme}(:, I_var));
            xlim_temp(I_phoneme,1:2) = get(gca, 'xlim');
            ylim_temp(I_phoneme,1:2) = get(gca, 'ylim');
        end
        if draw_offender
            xlim_min = min([xlim_temp(:,1); disputed_data(I_var)]);
            xlim_max = max([xlim_temp(:,2); disputed_data(I_var)]);
        else
            xlim_min = min(xlim_temp(:,1));
            xlim_max = max(xlim_temp(:,2));
        end
        ylim_max = max(ylim_temp(:,2)) +.5;
        for I_phoneme = 1:2
    %         subplot(2,1,I_phoneme);
            subplot(2,1, 3-I_phoneme); % put "Tim" on top and "dom" on bottom
            xlim([xlim_min, xlim_max]);
            ylim([0, ylim_max]);
            title(['phoneme: ', phoneme_labels{I_phoneme}, ', var: ', var_labels{I_var}]);
            if draw_offender
                hold on
                plot([disputed_data(I_var), disputed_data(I_var)], [0, ylim_max], 'r');
            end
        end
    end
    %2D
    figure(4);
    for I_phoneme = 1:2
            plot(known_data{I_phoneme}(:,2), known_data{I_phoneme}(:,3), colour{I_phoneme});
            hold on
    end
    if draw_offender
        plot(disputed_data(2), disputed_data(3), colour{3}, 'MarkerFaceColor', colour{3}(2));
    end
    hold off
    %3D
    figure(5);
%     stem_base = min(formant_data(:,2));
    for I_phoneme = 1:2
            plot3(known_data{I_phoneme}(:,1), known_data{I_phoneme}(:,2), known_data{I_phoneme}(:,3), colour{I_phoneme});
            
%             stem3(known_data{I_phoneme}(:,1), known_data{I_phoneme}(:,2), known_data{I_phoneme}(:,3), colour{I_phoneme}, 'BaseValue', stem_base);
            
%             dt = DelaunayTri(known_data{I_phoneme});
%             k = convexHull(dt);
%             trisurf(k, known_data{I_phoneme}(:,1), known_data{I_phoneme}(:,2), known_data{I_phoneme}(:,3), 'FaceColor', colour{I_phoneme}(2), 'EdgeColor', colour{I_phoneme}(2));
%             alpha(0.25);
            
            hold on
    end
    if draw_offender
        plot3(disputed_data(1), disputed_data(2), disputed_data(3), colour{3}, 'MarkerFaceColor', colour{3}(2));
%         stem3(disputed_data(1), disputed_data(2), disputed_data(3), colour{3}, 'MarkerFaceColor', colour{3}(2), 'BaseValue', stem_base);
    end
    hold off
    axis square, axis tight, grid on, box on
    
%     [az, el] = view;
%     axis vis3d
%     xx = get(gca, 'XTick'); yy = get(gca, 'YTick'); zz = get(gca, 'ZTick'); 
%     set(gca, 'XTick', xx, 'YTick', yy, 'ZTick', zz);
%     for I_az = 0:0.5:360
%         view(az + I_az, el);
%         drawnow;
%         pause(1/60);
%     end
    
end


%% CALCULATE INITIAL LR

% single-Gaussian distributions
[LR_disputed(1), model_mean, model_cov] = get_LR_Gaussian(known_data, disputed_data);

% Hotelling's T^2 distributions
LR_disputed(2) = get_LR_Hotelling(known_data, disputed_data);

fprintf('\nInitial likelihood ratios\nSingle Gaussian: %e\nHotelling''s: %e\n', 10^LR_disputed(1), 10^LR_disputed(2));



%% MONTE CARLO SIMULATIONS

% initiate the random number stream so we can get the same random sets each time we run this script (see "Managing the Default Stream" in help)
defaultStream = RandStream.getDefaultStream;
reset(defaultStream);

disputed_data_sim = disputed_data;
LR_sim = NaN(num_simulations, 2); % col 1: Gaussian. col 2: Hotelling

for I_sample = 1:num_simulations
    
    % generate simulated data
    sim_data = cell(1,2);
    sim_data_T = sim_data;
    for I_model = 1:2
        sim_data{I_model} = mvnrnd(model_mean{I_model}, model_cov{I_model}, num_known_data(I_model));
    end
    
    
%     figure(6);
%     for I_phoneme = 1:2
%             plot3(sim_data{I_phoneme}(:,1), sim_data{I_phoneme}(:,2), sim_data{I_phoneme}(:,3), colour{I_phoneme});
%             hold on
%     end
%     if draw_offender
%         plot3(disputed_data(1), disputed_data(2), disputed_data(3), colour{3}, 'MarkerFaceColor', colour{3}(2));
%     end
%     hold off
    
    
%     % transform VOT data
%     sim_VOT_data = {sim_data{1}(:,1), sim_data{2}(:,1)};
%     if deskew_2_var
%         sim_VOT_data_ms = skew2(sim_VOT_data, angle, shift);
%         [sim_VOT_data_transformed, sim_angle, sim_shift] = deskew2(sim_VOT_data_ms);
%         disputed_data_sim(1) = atan( sim_angle * (disputed_data_VOT_ms + sim_shift) );
%     else
%         sim_VOT_data_ms = skew1(sim_VOT_data, angle);
%         [sim_VOT_data_transformed, sim_angle] = deskew1robust(sim_VOT_data_ms);
%         disputed_data_sim(1) = atan( sim_angle * disputed_data_VOT_ms );
%     end
%     sim_data{1}(:,1) = sim_VOT_data_transformed{1};
%     sim_data{2}(:,1) = sim_VOT_data_transformed{2};

    % calculate likelihood ratios
    LR_sim(I_sample, 1) = get_LR_Gaussian(sim_data, disputed_data_sim);
    LR_sim(I_sample, 2) = get_LR_Hotelling(sim_data, disputed_data_sim);
    
    
%     figure(7);
%     for I_phoneme = 1:2
%             plot3(sim_VOT_data_ms{I_phoneme}, sim_data{I_phoneme}(:,2), sim_data{I_phoneme}(:,3), colour{I_phoneme});
%             hold on
%     end
%     if draw_offender
%         plot3(disputed_data_VOT_ms, disputed_data(2), disputed_data(3), colour{3}, 'MarkerFaceColor', colour{3}(2));
%     end
%     hold off
%     
%     figure(8);
%     for I_phoneme = 1:2
%             plot3(sim_data{I_phoneme}(:,1), sim_data{I_phoneme}(:,2), sim_data{I_phoneme}(:,3), colour{I_phoneme});
%             hold on
%     end
%     if draw_offender
%         plot3(disputed_data(1), disputed_data(2), disputed_data(3), colour{3}, 'MarkerFaceColor', colour{3}(2));
%     end
%     hold off
% %     pause
    
end

% get 1st and 5th percentiles
percentiles = NaN(2,2);
II = [floor(num_simulations*.01), floor(num_simulations*.05)];
for I_method = 1:2
    LRs_sorted = sort(LR_sim(:,I_method));
    percentiles(:,I_method) = LRs_sorted(II);
end
    


%plot histograms of results
title_method = {'Gaussian', 'Hotelling'};
x = {[1.5:3:316.5] [0.5:20.5]};
lim_x = {[0 320] [0 20]};
for I_method = 1:2
    figure;
    LR_sim_plot = LR_sim(:, I_method);
    II_Inf = LR_sim_plot == Inf;
    if sum(II_Inf) > 0;
        LR_sim_plot(II_Inf) = max(LR_sim_plot(~II_Inf)); % set Inf values a real number so hist will work
    end
    hist(LR_sim_plot, x{I_method});
    h = findobj(gca,'Type','patch');
    set(h, 'FaceColor', [0 1 1], 'EdgeColor', 'none');
    xlim(lim_x{I_method});
    title(title_method{I_method});
    
    hold on
    y_range = get(gca, 'YLim');
    plot([LR_disputed(I_method), LR_disputed(I_method)], y_range, '-r');
    plot([percentiles(1,I_method), percentiles(1,I_method)], y_range, '-g');
    plot([percentiles(2,I_method), percentiles(2,I_method)], y_range, '-b');
    
    hold off
end



fprintf('\n1st and 5th percentiles\nSingle Gaussian: %e\t%e\nHotelling''s: %e\t%e\n', 10^percentiles(1,1), 10^percentiles(2,1), 10^percentiles(1,2), 10^percentiles(2,2));

