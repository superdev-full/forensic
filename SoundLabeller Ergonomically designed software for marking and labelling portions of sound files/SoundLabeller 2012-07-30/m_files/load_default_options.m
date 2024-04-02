% load_default_options

% load options
[var_name var_value] = textread('SoundLabeller.ini','%s\t%s', 'whitespace', '\t');
for Ivar = 1:length(var_name)
    assignin('caller', var_name{Ivar}, var_value{Ivar}); % assign strings to vars
    % note: have to use 'caller' rather than 'base' when nested within function for compiled version
end

% convert strings to logicals
process_dir = str2logical(process_dir);
precalc_specrograms = str2logical(precalc_specrograms);
allow_textlabels = str2logical(allow_textlabels);
smooth_spectrograms = str2logical(smooth_spectrograms);
review_only = str2logical(review_only);

% load keyboard and mouse
clear var_name var_value
[var_name var_value] = textread('KeyboardMouse.ini','%s\t%s', 'whitespace', '\t');
for Ivar = 1:length(var_name)
    var_test = str2double(var_value{Ivar});
    if isnan(var_test)
        var_value{Ivar} = double(var_value{Ivar});
    else
        var_value{Ivar} = var_test;
    end
    assignin('caller', var_name{Ivar}, var_value{Ivar});
end


spectro_colormap_index = str2double(spectro_colormap_index);
colormap_options = {'Jet (blue-red)',       'jet';...
                    'Jet (red-blue)',       'flipud(jet)';...
                    'Gray (light-dark)',	'flipud(gray)';...
                    'Gray (dark-light)',	'gray';...
                    'Bone (light-dark)',	'flipud(bone)';...
                    'Bone (dark-light)',	'bone'};
