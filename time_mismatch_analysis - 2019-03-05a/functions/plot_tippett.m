function plot_tippett(LR_s, II_s_groups, LR_d, II_d_groups, figure_title, new_fig, line_type, zero_line, dont_sort, symbol_type)
% plot_tippett(likelihood_ratio_same_speaker, IIsame_speaker_compared, likelihood_ratio_different_speaker, IIdifferent_speaker_compared, figure_title, new_fig, line_type, zero_line, dont_sort, symbol_type)
%
% by Geoffrey Stewart Morrison  http://geoff-morrison.net
% Version date: 2017-04-09
% sucessfully tested using Matlab R2015b running under Windows XP x64
% Change since version 2016-02-27: 2nd and 4th arguments, IIsame_speaker_groups and IIdifferent_speaker_groups, now specify groups for dumbell plots
% all members of the same group are plotted at the same y value, ordered according to the mid point of the group's range
% Version date: 2016-02-27
% sucessfully tested using Matlab R2015b running under Windows XP x64
% Change since version 2009-11-18: added option to plot a symbol at each point (for backward compatibility this the last (10th) argument)
% Version date: 2009-11-18
% sucessfully tested using Matlab R2009b running under Windows XP x64
% Change since version 2009-11-13: addedd "don't sort" option, useful for drawing credible intervals
%
%
% Function which draws Tippett plots
%   Red line: proportion of different-speaker comparisons with log10 likelihood ratio equal to or less than value indicated on x-axis
%   Blue line: proportion of same-speaker comparisons with log10 likelihood ratio equal to or greater than value indicated on x-axis
%
% REQUIRED INPUTS:
%   LR_s            vector of likelihood ratios from same-speaker comparisons
%   LR_d            vector of likelihood ratios from same-different comparisons
%   2nd and 4th argument spaces must be filled, call function as follows: plot_tippett(LR_s, [], LR_d, []);
%
% OPTIONAL INPUTS:
%   II_s_groups     indices indicating groups of same-speaker LRs, e.g., multiple pairs of recordings but all recordings from the same one speaker
%   II_d_groups     as above but multiple pairs of recordings all from the same two speakers
%                   if both the above are supplied, a grouped plot is drawn 
%                   if both are empty, e.g., plot_tippett(LR_s, [], LR_d, []), a normal plot is drawn
%   figure_title    title for Tippet plot (optional)
%   new_fig         logical true to plot on a new figure [defualt] , false to plot on an existing figure
%   line_type       '-' solid [default], '--' dashed, ':' dotted, '-.' dashed-dotted, 'none' no line
%   zero_line       logical true to daw vertical line at log10LR = 0 [defualt] , false to not plot line
%   symbol_type     see symbol option under LineSpec [default 'none' for normal plots and '.' for grouped plots]

if nargin == 0      % make a plot using sample data
    LR_ss = [.8 1 5 3 9 10 25 6 20 18 .9 .7 11];
    LR_ds = [.002 .01 .3 .5 .9 1.2 .6 .05 .006 1.3 .4 .2 .03 1.1 2 .0005];
    plot_tippett(LR_ss, [], LR_ds, []);
    return
end

if nargin < 5, figure_title = 'Tippett Plot'; end   % default figure title, enter [] for no title
if nargin < 6 || isempty(new_fig), new_fig = true; end   % default plot figure in new window
if nargin < 7 || isempty(line_type), line_type = '-'; end   % default solid line
if nargin < 8 || isempty(zero_line), zero_line = true; end   % default vertical line at zero
if nargin < 9 || isempty(dont_sort), dont_sort = false; end   % default sort input [grouped plots are always sorted]

% make a new figure and draw zero line if requested
if new_fig, figure; else hold on, end
if zero_line
    plot([0 0], [0 1], '-k');
    hold on
end

% make sure LR data is in form of column vectors and calculate log10LRs
LR_s = LR_s(:);
LR_d = LR_d(:);
log_LR_s = log10(LR_s);
log_LR_d = log10(LR_d);


if isempty(II_s_groups) && isempty(II_d_groups) % normal plot
    if nargin < 10 || isempty(symbol_type), symbol_type = 'none'; end   % default no symbol
    
    % make sure LR data is in form of column vectors
    % sort LR data
    % calculate log10 of LR data
    % calculate cumulative proportions
    if dont_sort
        log_LR_s_sorted = log_LR_s;
        log_LR_d_sorted = log_LR_d;
    else
        log_LR_s_sorted = sort(log_LR_s);
        log_LR_d_sorted = sort(log_LR_d, 'descend');
    end
    num_s = length(log_LR_s);
    cumulative_proportion_s = (1:num_s)/num_s;
    num_d = length(log_LR_d);
    cumulative_proportion_d = (1:num_d)/num_d;

    % plot cumulative proportions against log10 LR values
    plot(log_LR_d_sorted, cumulative_proportion_d, 'Color', 'r', 'LineStyle', line_type, 'Marker', symbol_type, 'LineWidth', 1);
    hold on
    plot(log_LR_s_sorted, cumulative_proportion_s, 'Color', 'b', 'LineStyle', line_type, 'Marker', symbol_type, 'LineWidth', 1);
    hold off
    
    
else % grouped plot
    if nargin < 10 || isempty(symbol_type), symbol_type = '.'; end   % default '.' symbol
    
    unique_II_s = unique(II_s_groups);
    unique_II_d = unique(II_d_groups);
    
    num_s = length(unique_II_s);
    num_d = length(unique_II_d);
    
    cumulative_proportion_s = (1:num_s)/num_s;
    cumulative_proportion_d = (1:num_d)/num_d;
    
    log_LR_d_group = cell(num_d,1);
    log_LR_group_d_order = NaN(num_d,1);
    for I_d = 1:num_d
        log_LR_d_group{I_d} = log_LR_d(II_d_groups == unique_II_d(I_d));
        log_LR_group_d_order(I_d) = max(log_LR_d_group{I_d});% (max(log_LR_d_group{I_d}) + min(log_LR_d_group{I_d})) / 2;
    end
    [~, II_d_sorted] = sort(log_LR_group_d_order, 'descend');
    for I_d = 1:num_d
        log_LR_current_group = log_LR_d_group{II_d_sorted(I_d)};
        log_LR_current_group = sort(log_LR_current_group);
        num_current_group = length(log_LR_current_group);
        
        cumulative_proportion_plot = repmat(cumulative_proportion_d(I_d), num_current_group, 1);
        
        plot(log_LR_current_group, cumulative_proportion_plot, 'Color', 'r', 'LineStyle', line_type, 'Marker', symbol_type, 'LineWidth', 1);
        hold on
    end
    
    log_LR_s_group = cell(num_s,1);
    log_LR_group_s_order = NaN(num_s,1);
    for I_s = 1:num_s
        log_LR_s_group{I_s} = log_LR_s(II_s_groups == unique_II_s(I_s));
        log_LR_group_s_order(I_s) = min(log_LR_s_group{I_s});% (max(log_LR_s_group{I_s}) + min(log_LR_s_group{I_s})) / 2;
    end
    [~, II_s_sorted] = sort(log_LR_group_s_order);
    for I_s = 1:num_s
        log_LR_current_group = log_LR_s_group{II_s_sorted(I_s)};
        log_LR_current_group = sort(log_LR_current_group);
        num_current_group = length(log_LR_current_group);
        
        cumulative_proportion_plot = repmat(cumulative_proportion_s(I_s), num_current_group, 1);
        
        plot(log_LR_current_group, cumulative_proportion_plot, 'Color', 'b', 'LineStyle', line_type, 'Marker', symbol_type, 'LineWidth', 1);
    end
    hold off
    
end

% add labels
title(figure_title)
xlabel('Log10 Likelihood Ratio')
ylabel('Cumulative Proportion')
grid on;
return

