function [time_axis, freq_axis, spectro] = get_spectrogram(signal, Fs_original, Fs_spec, premph, window_length_ms, window_shift_ms)

% resample
if nargin < 3 || isempty(Fs_spec)
    Fs_spec = 10000;
end
yy=resample(signal,Fs_spec,Fs_original);

% spectral tilt
if nargin < 4 || isempty(premph)
    premph = .95;
end
yy=filter([1,-premph],1,yy);

% window
if nargin < 5 || isempty(window_length_ms) || window_length_ms <= 0
    window_length_ms = 20;
end
if nargin < 6 || isempty(window_shift_ms) || window_shift_ms <= 0 || window_shift_ms > window_length_ms-1
    window_shift_ms = 2;
end
window_length_frames = floor(Fs_spec*window_length_ms/1000);
window_overlap_proportion = 1-window_shift_ms/window_length_ms;
window_overlap_frames = floor(window_length_frames*window_overlap_proportion);
cos4window =(.5 - .5*cos(2*pi*(0:window_length_frames-1)'/(window_length_frames-1))).^4;

% pad edges
padding = zeros(floor(window_length_frames/2),1);
yy = [padding; yy; padding];

% FFT length
nfft = floor(Fs_spec*.1);

% calculate spectrogram
[S, F, T, P] = spectrogram(yy, cos4window, window_overlap_frames, nfft, Fs_spec);

% for use with imagesc
time_axis = T-window_length_ms/2000;
freq_axis = F;
spectro = 10*log10(abs(P));

% for use with surf
% time_axis = T-window_length_ms/2000;
% freq_axis = flipud(F);
% spectro = 10*log10(abs(P.'));

return