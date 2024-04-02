% plot_spectrogram

subplot(h_subplot_spectrogrm);

% adjust the colour range for the spectrum amplitude (based on whole file not selected portion)
spectro_max = max(spectro(~isinf(spectro(:))));
spectro_min = min(spectro(~isinf(spectro(:))));
spectro_range = spectro_max-spectro_min;
if isnan(spectro_range) || spectro_range == 0 || del_file %2012-07-20 added: spectro_range == 0
    spectro_exists = false;
    colour_limits = [1 2];
else
    spectro_exists = true;
    colour_limits = [spectro_min+spectro_range*colour_compression, spectro_max]; 
end
colormap(spectro_colormap)

% find the spectrogram time frames which are closest to the waveform time frames
display_section_sec = double(display_section)./Fs;
[junk, display_spec(1)] = min(abs(time_axis - display_section_sec(1)));
[junk, display_spec(2)] = min(abs(time_axis - display_section_sec(2)));

spectro_display = spectro(:, display_spec(1):display_spec(2));
time_axis_display = time_axis(display_spec(1):display_spec(2));

% cubic interpolation of values over pixels
if smooth_spectrograms && spectro_exists
    set(h_subplot_spectrogrm, 'Units', 'pixels');
    pixels_spectrogrm = get(h_subplot_spectrogrm, 'Position');
    set(h_subplot_spectrogrm, 'Units', 'normalized');

    length_time_axis = time_axis_display(end) - time_axis_display(1);
    length_time_pixels = pixels_spectrogrm(3);
    time_interp=[time_axis_display(1):length_time_axis/length_time_pixels:time_axis_display(end)];
    if length(time_interp) == length_time_pixels - 1, time_interp = [time_interp; time_interp(end)]; end %occasionally get rounding errors
    if length(time_interp) == length_time_pixels + 1, time_interp(end) = []; end

    length_freq_pixels = round(pixels_spectrogrm(4));
    freq_interp=[freq_axis(1):length_freq_axis/length_freq_pixels:freq_axis(end)]';
    if length(freq_interp) == length_freq_pixels - 1, freq_interp = [freq_interp; freq_interp(end)]; end %occasionally get rounding errors - note: using step size length_original/(length_new+1) results in rounding errors in other direction
    if length(freq_interp) == length_freq_pixels + 1, freq_interp(end) = []; end

    [time_mesh, freq_mesh] = meshgrid(time_axis_display, freq_axis);
    [time_mesh_pixels, freq_mesh_pixels] = meshgrid(time_interp, freq_interp);
    try
        spectro_display_pixels = interp2(time_mesh, freq_mesh, spectro_display, time_mesh_pixels, freq_mesh_pixels, 'cubic');
        % plot the spectrogram
        imagesc(time_axis_display, freq_interp, spectro_display_pixels, colour_limits);
    catch
        imagesc(time_axis, freq_axis, spectro_display, colour_limits);
    end

else
    % plot the spectrogram
    imagesc(time_axis, freq_axis, spectro_display, colour_limits);
end

axis xy
set(gca,'XTick',[])
xlabel([])
title([num2str(soundI,'%1.0f'),' of ',NumSoundsStr,'  ',NameSounds{soundI}], 'Interpreter', 'none')
