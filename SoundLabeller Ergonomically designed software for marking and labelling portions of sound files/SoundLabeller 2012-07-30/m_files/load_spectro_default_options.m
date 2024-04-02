% load_spectro_default_options
[var_name var_value] = textread('SoundLabeller.ini','%s\t%s', 'whitespace', '\t');
for Ivar = 7:length(var_name) % Spectrogram settings start at row 7
    assignin('caller', var_name{Ivar}, var_value{Ivar}); % assign strings to vars
end
spectro_colormap_index = str2double(spectro_colormap_index);
smooth_spectrograms = str2logical(smooth_spectrograms);
