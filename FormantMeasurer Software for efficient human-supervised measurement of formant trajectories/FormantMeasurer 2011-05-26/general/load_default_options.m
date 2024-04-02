% load_default_options

[var_name var_value] = textread('FormantMeasurer.ini','%s\t%s', 'whitespace', '\t');
for Ivar = 1:length(var_name)
    assignin('caller', var_name{Ivar}, var_value{Ivar}); % assign strings to vars
    % note: have to use 'caller' rather than 'base' when nested within function for compiled version
end

% convert strings to logicals
process_dir = str2logical(process_dir);
use_saved_tracks = str2logical(use_saved_tracks);
use_fixed_num_trackmarks = str2logical(use_fixed_num_trackmarks);

% convert strings to numbers
label_row_to_use = str2double(label_row_to_use);
hopMs = str2double(hopMs);
MaxNumCandPerFrame = str2double(MaxNumCandPerFrame);
tol = str2double(tol);

