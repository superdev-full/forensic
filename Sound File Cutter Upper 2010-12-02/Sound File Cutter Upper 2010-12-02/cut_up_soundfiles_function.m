function cut_up_soundfiles_function
% cut_up_soundfiles_function.m
%
% by Geoffrey Stewart Morrison http://geoff-morrison.net/
%
% version of 2010-10-28
%
% 2010-10-28 min_duration_ms stplit into min_duration_above_ms and min_duration_below_ms
% 2010-10-16 adds handling of periods of absolute silence which generate -Inf amplitude
% 2010-04-14 version should have lower memory requirements than the previous version
%
% Before running this script, cut up the soundfiles by task and channel,
% i.e, input should be a single channel of about 10 minutes duration.


clear all

% default values (best values probabaly depend on soundfile being processed)
padding_ms = 100; % padding to add to extracted audio

min_duration_above_ms = 100; % ignore audio-between-silence less than this duration
min_duration_below_ms = 50; % ignore silence-between-audio less than this duration


threshold_proportion = 1/3; % threshold expressed a proportion of way from min amp to max amp

window_duration_ms = 100; % ms
window_type = 'HAMMING';

read_in_size_s = 15; %s
read_in_size_s = read_in_size_s + (window_duration_ms - rem(read_in_size_s*1000, window_duration_ms))/1000; % increase to nearest multiple of window_duration_ms

SoundFileDir_input = '..\Sound Files\';
FileFilter = [SoundFileDir_input, '*.wav'];


h_fig = fullscreenfigure;
text(0.5, 0.8, 'Sound File Cutter Upper', 'FontSize', 14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
axis off;
drawnow

% get file to cut up and create directory for storing the cut up portions
SoundFile_input = 0;
while SoundFile_input == 0;
    [SoundFile_input,SoundFileDir_input,FilterIndex] = uigetfile(FileFilter,'Select the sound file to cut up');
end
SoundFileDir_output = [SoundFileDir_input, SoundFile_input(1:end-4), '\'];
dir_existed = rmdir(SoundFileDir_output, 's'); % before creating the directory, if it alredy exists delete the directory and its contents
mkdir(SoundFileDir_output);

figure(h_fig);
text(0.5, 0.7, 'Loading Sound File and Calculating Amplitude', 'FontSize', 14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.5, 0.6, 'Please Wait', 'FontSize', 14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
drawnow

% read in info about the sound file
size_Fs = wavread([SoundFileDir_input, SoundFile_input],'size');
size_Fs = size_Fs(1);
[junk, Fs, nbits] = wavread([SoundFileDir_input, SoundFile_input], 1);

% calculate chunks of file to read in (overlap by 2 window lengths)
read_in_size_Fs = floor(read_in_size_s * Fs);
window_duration_Fs = floor(window_duration_ms / 1000 * Fs);

N_end = read_in_size_Fs : read_in_size_Fs : size_Fs;
if N_end(end) < size_Fs, N_end = [N_end, size_Fs]; end
N_start = [1, N_end(1:end-1) - window_duration_Fs*2];
N_length = length(N_end);

% read in chunks of soundfile and calculate their RMS_amp
RMS_amp = NaN(size_Fs, 1);
not_silence = false(size_Fs, 1);
h_wait = waitbar(0, 'Processing');
for I_N = 1:N_length
    % read in chunk of soundfile
    clear audio RMS_amp_temp audio_not_silent
    audio = wavread([SoundFileDir_input, SoundFile_input], [N_start(I_N), N_end(I_N)]);
    % find absolute silent sections (two consecutive zeros are counted as silence)
    audio_not_zero = audio ~= 0;
    audio_not_zero_shift = audio_not_zero(2:end);
    audio_not_silent = audio_not_zero(1:end-1) | audio_not_zero_shift;
    audio_not_silent = [audio_not_silent; audio_not_silent(end)];
    % get RMS amplitude
    RMS_amp_temp = rmsdb(audio, Fs, window_duration_ms, window_type);
    if I_N == 1
        RMS_amp(N_start(I_N) : N_end(I_N)) = RMS_amp_temp;
        not_silence(N_start(I_N) : N_end(I_N)) = audio_not_silent;
    else % start from beginning of second overlapping window (avoids discontinuities)
        RMS_amp(N_start(I_N)+window_duration_Fs-1 : N_end(I_N)) = RMS_amp_temp(window_duration_Fs : end);
        not_silence(N_start(I_N)+window_duration_Fs-1 : N_end(I_N)) = audio_not_silent(window_duration_Fs : end);
    end
    waitbar(I_N/N_length);
end
delete(h_wait);
clear audio RMS_amp_temp


% threshold on basis of RMS amplitude (ignoring absolute silent portions)
RMS_amp_not_silent = RMS_amp(not_silence);
max_RMS_amp = max(RMS_amp_not_silent(window_duration_Fs:end-window_duration_Fs));
min_RMS_amp = min_not_Inf(RMS_amp_not_silent(window_duration_Fs:end-window_duration_Fs));
RMS_amp(isinf(RMS_amp)) = min_RMS_amp;
RMS_amp(~not_silence) = min_RMS_amp;
threshold_RMS_amp = (max_RMS_amp - min_RMS_amp) * threshold_proportion + min_RMS_amp;

padding = floor(Fs*padding_ms/1000); % padding to add to extracted audio
min_duration_above = floor(Fs*min_duration_above_ms/1000); % ignore audio-between-silence less than this duration
min_duration_below = floor(Fs*min_duration_below_ms/1000); % ignore silence-between-audio less than this duration


% downsample data for plotting
clf(h_fig);
axis on;
set(gca, 'Units', 'pixels');
pixels_plot = get(gca, 'Position');
set(gca, 'Units', 'normalized');
length_RMS_amp = length(RMS_amp);
RMS_amp_plot = interp1(RMS_amp, 1 : length_RMS_amp/pixels_plot(3) : length_RMS_amp);
x_RMS_amp = (1:pixels_plot(3)) / pixels_plot(3) * length_RMS_amp / Fs;

% plot
plot(x_RMS_amp, RMS_amp_plot);
xlabel('seconds');
ylabel('dB');
hold on
h_thresh = plot([x_RMS_amp(1), x_RMS_amp(end)], [threshold_RMS_amp, threshold_RMS_amp], '-r', 'Erasemode', 'xor');
title('Primary Mouse Button: adjust threshold        Secondary Mouse Button: continue');
axis tight
hold off
drawnow
play_sound(3);

% get (adjusted threshold value)
button = 0;
while button ~= 3
    [junk, temp_thresh, button] = ginput(1);
    if button == 1
        threshold_RMS_amp = temp_thresh;
        set(h_thresh, 'YData', [threshold_RMS_amp, threshold_RMS_amp]);
    end
end
clf(h_fig);
clear x_RMS_amp RMS_amp_plot

% find and save non-silent portions of soundfile
text(0.5, 0.8, 'Sound File Cutter Upper', 'FontSize', 14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.5, 0.7, 'Finding and Saving Non-Silent Portions of Sound File', 'FontSize', 14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(0.5, 0.6, 'Please Wait', 'FontSize', 14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
axis off;
drawnow

h_wait = waitbar(0, 'Processing');
end_Fs = 0;
start_Fs_temp = find(RMS_amp > threshold_RMS_amp & not_silence, 1, 'first');
while ~isempty(start_Fs_temp)
    start_Fs = end_Fs + start_Fs_temp;
    end_Fs_temp = find(RMS_amp(start_Fs:end) < threshold_RMS_amp | ~not_silence(start_Fs:end), 1, 'first');
    if isempty(end_Fs_temp), break, end
    
    end_Fs = start_Fs + end_Fs_temp;
    
    % jump over silence-between-audio less than min_duration_below
    start_Fs_temp = find(RMS_amp(end_Fs:end) > threshold_RMS_amp & not_silence(end_Fs:end), 1, 'first');
    while ~isempty(start_Fs_temp) && start_Fs_temp < min_duration_below
        end_Fs_temp = find(RMS_amp(end_Fs + min_duration_below : end) < threshold_RMS_amp | ~not_silence(end_Fs + min_duration_below : end), 1, 'first');
        if isempty(end_Fs_temp), break, end
        end_Fs = end_Fs + min_duration_below + end_Fs_temp;
        start_Fs_temp = find(RMS_amp(end_Fs:end) > threshold_RMS_amp & not_silence(end_Fs:end), 1, 'first');
    end
    if isempty(end_Fs_temp), break, end
    
    % jump over audio-between-silence less than min_duration_above
    if end_Fs - start_Fs < min_duration_above, continue, end

    % extract portion of audio (add padding but do not pad across absolute silence)
    start_Fs_padded = start_Fs - padding;
    
    if start_Fs_padded < 1
        start_Fs_padded = 1;
    else
        silence_in_padding = find(~not_silence(start_Fs_padded : start_Fs), 1, 'last');
        if ~isempty(silence_in_padding)
            start_Fs_padded = start_Fs_padded + silence_in_padding - 1;
        end
    end
    
    end_Fs_padded = min([end_Fs + padding, size_Fs]);

    silence_in_padding = find(~not_silence(end_Fs : end_Fs_padded), 1, 'first');
    if ~isempty(silence_in_padding)
        end_Fs_padded = end_Fs + silence_in_padding - 1;
    end
    
    utterance = wavread([SoundFileDir_input, SoundFile_input], [start_Fs_padded, end_Fs_padded], 'native');

    % save
    SoundFile_output = [mm_ss(start_Fs_padded / Fs), '_', mm_ss(end_Fs_padded / Fs), '.wav'];
    %wavwrite(utterance, Fs, [SoundFileDir_output, SoundFile_output]);
    wavwrite(utterance, Fs, nbits, [SoundFileDir_output, SoundFile_output]);
    
%     figure
%     plot(utterance);
%     drawnow
%     wavplay(utterance, Fs);
%     pause
    
    waitbar(end_Fs/size_Fs);
    clear utterance
end
delete(h_wait);
close(h_fig);
play_sound(3);

return