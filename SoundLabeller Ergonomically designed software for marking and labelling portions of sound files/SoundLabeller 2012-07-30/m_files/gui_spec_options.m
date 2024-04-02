% gui_spec_options

nyquist_old = nyquist;
premph_old = premph;
window_length_ms_old = window_length_ms;
window_shift_ms_old = window_shift_ms;
colour_compression_old = colour_compression;
spectro_colormap_index_old = spectro_colormap_index;

% string (numeric) inputs
spectrogram_options = inputdlg({'Nyquist frequency (Hz):', 'Pre-emphasis:', 'Window length (ms):', 'Window shift (ms):', 'Amplitude display floor (proportion):'}, 'Spectogram Settings', 1, {nyquist_str, premph_str, window_length_ms_str, window_shift_ms_str, colour_compression_str});
if ~isempty(spectrogram_options)

    nyquist = round(abs(str2double(spectrogram_options{1})));
    if isnan(nyquist)
        nyquist = nyquist_old;
    else
        nyquist_str = num2str(nyquist);
        Fs_spec = nyquist*2;
    end

    premph = real(str2double(spectrogram_options{2}));
    if isnan(premph)
        premph = premph_old;
    else
        premph_str = num2str(premph);
    end

    window_length_ms = abs(str2double(spectrogram_options{3}));
    if isnan(window_length_ms)
        window_length_ms = window_length_ms_old;
    else
        window_length_ms_str = num2str(window_length_ms);
    end

    window_shift_ms = abs(str2double(spectrogram_options{4}));
    if isnan(window_shift_ms) || window_shift_ms > window_length_ms - 1000/Fs_spec
        window_length_ms = window_length_ms_old;
    else
        window_shift_ms_str = num2str(window_shift_ms);
    end

    colour_compression = abs(str2double(spectrogram_options{5}));
    if isnan(colour_compression) || colour_compression <= 0 || colour_compression >= 1
        colour_compression = colour_compression_old;
    else
        colour_compression_str = num2str(colour_compression);
    end
    
    % smoothing option
    if smooth_spectrograms
        smooth_spectrograms_str = 'Yes';
    else
        smooth_spectrograms_str = 'No';
    end
    smooth_spectrograms_str = questdlg('Smooth Spectrograms?', 'Spectrogram Settings', 'Yes', 'No', smooth_spectrograms_str);
    if isequal(smooth_spectrograms_str, 'Yes')
        smooth_spectrograms = true;
    else
        smooth_spectrograms = false;
    end

    % dropdown list input for colormap
    [spectro_colormap_index, ok_button] = listdlg('ListString',colormap_options(:,1), 'SelectionMode','single', 'InitialValue',spectro_colormap_index, 'ListSize',[200 200], 'Name','Spectogram Colour Setting');

    if ok_button
        spectro_colormap = eval(colormap_options{spectro_colormap_index,2});

        % spectral analysis
        signal_length_frames = length(yy);
        signal_length_sec = signal_length_frames/Fs;
        time_axis = 0:window_shift_ms/1000:signal_length_sec;
        Signal.time_axis = time_axis;
        freq_axis = (0:floor(nyquist*.1))*10;
        Signal.freq_axis = freq_axis;
        spectro = NaN(length(freq_axis), length(time_axis));
        Signal.spectro = spectro;

        [time_axis_part, freq_axis_part, spectro_part] = get_spectrogram(yy(display_section(1):display_section(2)), Fs, Fs_spec, premph, window_length_ms, window_shift_ms);

        display_section_sec = double(display_section)./Fs;
        [junk, display_spec(1)] = min(abs(time_axis-display_section_sec(1)));
        [junk, display_spec(2)] = min(abs(time_axis-display_section_sec(2)));

        length_spectro_part = size(spectro_part,2);

        spectro(:, display_spec(1):display_spec(1)+length_spectro_part-1) = spectro_part;
        Signal.spectro(:, display_spec(1):display_spec(1)+length_spectro_part-1)  = spectro_part;
    else
        spectro_colormap_index = spectro_colormap_index_old;
    end
    
end

save(signal_file_name, 'Signal');