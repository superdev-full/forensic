% options_gui

Bgroup_data_file = uibuttongroup('Title','Data File',...
                        'FontSize',12,...
                        'Units','normalized',...
                        'Position',[.1 .6 .375 .25]);
    P_lang_label = uipanel(Bgroup_data_file, 'Title', 'File Name: "data_[text below].txt"', 'FontSize', 10, 'Position', [.05 .7 .9 .25], 'BorderType', 'none');
    B_lang_label = uicontrol('Style','Edit',...
                            'String',lang_label,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_lang_label);
    P_stimcols = uipanel(Bgroup_data_file, 'Title', 'Stimulus Columns', 'FontSize', 10, 'Position', [.05 .4 .9 .25], 'BorderType', 'none');
    B_stimcols = uicontrol('Style','Edit',...
                            'String',stimcols,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_stimcols);
    P_respcols = uipanel(Bgroup_data_file, 'Title', 'Response Columns', 'FontSize', 10, 'Position', [.05 .1 .9 .25], 'BorderType', 'none');
    B_respcols = uicontrol('Style','Edit',...
                            'String',respcols,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_respcols);
                        
Bgroup_models = uibuttongroup('Title','Models',...
                        'FontSize',12,...
                        'Units','normalized',...
                        'Position',[.1 .425 .375 .15]);
    P_models = uipanel(Bgroup_models, 'Title', 'Models', 'FontSize', 10, 'Position', [.05 .575 .9 .4], 'BorderType', 'none');
    B_models = uicontrol('Style','Edit',...
                            'String',models,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_models);
    P_default = uipanel(Bgroup_models, 'Title', 'Default Model', 'FontSize', 10, 'Position', [.05 .075 .9 .4], 'BorderType', 'none');
    B_default = uicontrol('Style','Edit',...
                            'String',default_model,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_default);

Bgroup_G2 = uibuttongroup('Title','Model Comparisons',...
                        'FontSize',12,...
                        'Units','normalized',...
                        'Position',[.1 .25 .375 .15]);
    P_compareG2 = uipanel(Bgroup_G2, 'Title', 'Perform deltaG2 Comparisons', 'FontSize', 10, 'Position', [.05 .575 .9 .4], 'BorderType', 'none');
    B_compareG2 = uicontrol('Style','Edit',...
                            'String',compareG2,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_compareG2);
    P_hyp_pairs = uipanel(Bgroup_G2, 'Title', 'Pairs of Hypotheses to Test', 'FontSize', 10, 'Position', [.05 .075 .9 .4], 'BorderType', 'none');
    B_hyp_pairs = uicontrol('Style','Edit',...
                            'String',hyp_pairs,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_hyp_pairs);

Bgroup_plot = uibuttongroup('Title','Probability Surface Plots',...
                        'FontSize',12,...
                        'Units','normalized',...
                        'Position',[.5 .55 .375 .3]);
    P_make_plots = uipanel(Bgroup_plot, 'Title', 'Make Plots of Default Model', 'FontSize', 10, 'Position', [.05 .775 .9 .2], 'BorderType', 'none');
    B_make_plots = uicontrol('Style','Edit',...
                            'String',make_plots,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_make_plots);
    P_colours = uipanel(Bgroup_plot, 'Title', 'Colours', 'FontSize', 10, 'Position', [.05 .55 .9 .2], 'BorderType', 'none');
    B_colours = uicontrol('Style','Edit',...
                            'String',colours,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_colours);
    P_orientation = uipanel(Bgroup_plot, 'Title', 'Orientation', 'FontSize', 10, 'Position', [.05 .325 .9 .2], 'BorderType', 'none');
    B_orientation = uicontrol('Style','Edit',...
                            'String',orientation,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_orientation);
    P_axis_labels = uipanel(Bgroup_plot, 'Title', 'Axis Labels', 'FontSize', 10, 'Position', [.05 .1 .9 .2], 'BorderType', 'none');
    B_axis_labels = uicontrol('Style','Edit',...
                            'String',axis_labels,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_axis_labels);

Bsave_coefs = uibuttongroup('Title','Save Coefficients',...
                        'FontSize',12,...
                        'Units','normalized',...
                        'Position',[.5 .425 .375 .1]);
    P_save_coefs = uipanel(Bsave_coefs, 'Title', 'Save Coefficients from Default Model', 'FontSize', 10, 'Position', [.05 .2 .9 .7], 'BorderType', 'none');
    B_save_coefs = uicontrol('Style','Edit',...
                            'String',save_coefs,...
                            'FontSize',10,...
                            'Units','normalized',...
                            'Position',[0 0 1 1],...
                            'Parent', P_save_coefs);

% next button
nextbutton = uicontrol('Style','pushbutton', ...
      'Units','normalized', ...
      'Position',[.6 .275 .2 .1], ...
      'FontSize',14, ...
      'String','Run Analysis');
    set(nextbutton,'Callback','uiresume;')
uiwait

% extract data
lang_label = get(B_lang_label, 'String');
stimcols = get(B_stimcols, 'String');
respcols = get(B_respcols, 'String');
models = get(B_models, 'String');
default_model = get(B_default, 'String');
compareG2 = get(B_compareG2, 'String');
hyp_pairs = get(B_hyp_pairs, 'String');
make_plots = get(B_make_plots, 'String');
colours = get(B_colours, 'String');
orientation = get(B_orientation, 'String');
axis_labels = get(B_axis_labels, 'String');
save_coefs = get(B_save_coefs, 'String');

% clean up
delete(Bgroup_data_file);
delete(Bgroup_models);
delete(Bgroup_G2);
delete(Bgroup_plot);
delete(Bsave_coefs);
delete(nextbutton);
