% SoundLabeller
% Release 2010-11-01
% © Geoffrey Stewart Morrison
% http://geoff-morrison.net
%
% see documentation in pdf



% initialise
clear all
global nextb
tic

hfullscreen = fullscreenfigure;
set(hfullscreen, 'Name', 'SoundLabeller', 'NumberTitle', 'off');


% load the default options
load_default_options

% get the user-selected options
gui_selections


%Get soundfile names
tdir=dir(fullfile(SoundDir,SoundFileName));
NumSounds=length(tdir);
[NameSounds{1:NumSounds}]=deal(tdir.name);
if review_only
    tdir_mat=dir(fullfile(SoundDir,[SoundFileName(1:end-4),'.mat']));
    NumMat=length(tdir_mat);
    [NameMat{1:NumMat}]=deal(tdir_mat.name);
    NameSounds_temp = cell(1,1);
    I_temp = 0;
    for soundI=1:NumSounds
        if sum(strcmp([NameSounds{soundI}(1:end-4),'.mat'],  NameMat)) > 0
            I_temp = I_temp + 1;
            NameSounds_temp{I_temp} = NameSounds{soundI};
        end
    end
    NameSounds = NameSounds_temp;
    NumSounds = length(NameSounds);
end
NumSoundsStr = num2str(NumSounds,'%1.0f');

% % PreCalculate Spectrograms (earlier versions held all sound data and spectrograms in memory - this used too much memory for large data sets)
% if precalc_specrograms
%     hwait=waitbar(0,'Calculating Spectrograms');
%     signal_length_sec = NaN(1,NumSounds);
%     for soundI=1:NumSounds
%         [Signal.yy, Signal.Fs] = wavread(fullfile(SoundDir,NameSounds{soundI}));
%         [Signal.time_axis, Signal.freq_axis, Signal.spectro] = get_spectrogram(Signal(soundI).yy, Signal(soundI).Fs, Fs_spec, premph, window_length_ms, window_shift_ms);
%         save([fullfile(SoundDir,NameSounds{soundI})(1:end-4), '_temp.mat', 'Signal');
%         waitbar(soundI/NumSounds);
%     end
%     delete(hwait)
% end
% total_signal_length_sec = sum(signal_length_sec);
% fprintf('\nTotal length of all sound files is: %0.0f seconds\n',  total_signal_length_sec);


% PreCalculate Spectrograms (earlier versions held all sound data and spectrograms in memory - this used too much memory for large data sets)
if precalc_specrograms
    hwait=waitbar(0,'Calculating Spectrograms');
else
    hwait=waitbar(0,'Preparing Sound Files');
end
mkdir(fullfile(SoundDir, 'temp'));
signal_length_sec = NaN(1,NumSounds);
for soundI=1:NumSounds
    [Signal.yy, Signal.Fs] = wavread(fullfile(SoundDir,NameSounds{soundI}));
    if precalc_specrograms
        [Signal.time_axis, Signal.freq_axis, Signal.spectro] = get_spectrogram(Signal.yy, Signal.Fs, Fs_spec, premph, window_length_ms, window_shift_ms);
        signal_length_sec(soundI) = Signal.time_axis(end);
    else
        signal_length_frames = length(Signal.yy);
        signal_length_sec(soundI) = signal_length_frames/Signal.Fs;
        Signal.time_axis = 0:window_shift_ms/1000:signal_length_sec(soundI); % BUG FIX 2012-07-23 was: Signal.time_axis = 0:window_shift_ms/1000:signal_length_sec;
        Signal.freq_axis = (0:floor(nyquist*.1))*10;
        Signal.spectro = NaN(length(Signal.freq_axis), length(Signal.time_axis));
    end
    save(fullfile(SoundDir, 'temp', [NameSounds{soundI}(1:end-4), '.mat']), 'Signal');
    waitbar(soundI/NumSounds);
end
delete(hwait)
total_signal_length_sec = sum(signal_length_sec);
fprintf('\nTotal length of all sound files is: %0.0f seconds\n',  total_signal_length_sec);


% Present sounds for labelling
button = 0;
soundI = 1;
while button~=27 %27=escape key

    % extract the data for this sound file
    signal_file_name = fullfile(SoundDir, 'temp', [NameSounds{soundI}(1:end-4), '.mat']);
    marker_file_name = fullfile(SoundDir, [NameSounds{soundI}(1:end-4), '.mat']);
    load(signal_file_name, 'Signal');
    yy = Signal.yy;
    Fs = Signal.Fs;
    invFs=1/Fs;
    time_axis = Signal.time_axis;
    freq_axis = Signal.freq_axis;
    spectro = Signal.spectro;
    length_freq_axis = freq_axis(end) - freq_axis(1);
    
    % initiate the temporary markers at the beginning and end of the file
    tempmark = [1 length(yy)];
    display_all = uint32(tempmark);
    display_section = display_all;

    % zero all the control variables
    wavedited = false;
    saved = false;
    undoable = false;
    del_file = false;
    
    % load any existing markers for this sound file
%     if ~isempty(dir([SoundDir,'\',NameSounds{soundI}(1:end-4),'*.mat'])) 
%         load([SoundDir,'\',NameSounds{soundI}(1:end-4),'.mat'],'mark_fs','mark_time','mark_text') 
    if ~isempty(dir(fullfile(SoundDir,[NameSounds{soundI}(1:end-4),'.mat']))) 
        load(fullfile(SoundDir,[NameSounds{soundI}(1:end-4),'.mat']),'mark_fs','mark_time','mark_text') 
        if ~iscell(mark_fs) % backwards compatible
            mark_fs_vector = mark_fs; mark_time_vector = mark_time; mark_text_vector = mark_text;
            mark_fs = cell(num_marker_rows,1); mark_time = cell(num_marker_rows,1); mark_text = cell(num_marker_rows,1);
            mark_fs{1} = mark_fs_vector; mark_time{1} = mark_time_vector; mark_text{1} = mark_text_vector;
        else % deal with different existing and specified numbers of rows
            num_marker_rows_existing = length(mark_fs);
            if num_marker_rows ~= num_marker_rows_existing
                num_rows_dlg = questdlg(sprintf('The number of rows in the exiting label file is %0.0f.\nThe number of rows you specified to use was %0.0f.\nDo you want to use the existing or the specified number of rows?\n(If you select the existing number of rows this will be used as the specified number of rows for all files processed from now on.)', num_marker_rows_existing, num_marker_rows), NameSounds{soundI}(1:end-4), num2str(num_marker_rows_existing, '%0.0f'), num2str(num_marker_rows, '%0.0f'), num2str(num_marker_rows, '%0.0f'));
                if isequal(num_rows_dlg, num2str(num_marker_rows, '%0.0f'))
                    mark_fs_old = mark_fs; mark_time_old = mark_time; mark_text_old = mark_text;
                    mark_fs = cell(num_marker_rows,1); mark_time = cell(num_marker_rows,1); mark_text = cell(num_marker_rows,1);
                    for I_marker_rows = 1:min([num_marker_rows, num_marker_rows_existing])
                        mark_fs(I_marker_rows) = mark_fs_old(I_marker_rows); 
                        mark_time(I_marker_rows) = mark_time_old(I_marker_rows); 
                        mark_text(I_marker_rows) = mark_text_old(I_marker_rows);
                    end
                else
                    num_marker_rows = num_marker_rows_existing;
                end
            end
        end
     else
        mark_fs = cell(num_marker_rows,1); mark_time = cell(num_marker_rows,1); mark_text = cell(num_marker_rows,1);
    end
    hmark = cell(num_marker_rows,1); htext = cell(num_marker_rows,1); hmark_num = cell(num_marker_rows,1); hmark_dur = cell(num_marker_rows,1);

    % plot the waveform and spectrogram
    clf
    h_subplot_spectrogrm = subplot('Position', [.1 .6 .8 .35]);
    plot_spectrogram
    h_subplot_wave = subplot('Position',[.1 .1 .8 .45]);
    plotwave

    % get and process the user's keyboard or mouse-click response
    button=0;
    while ~(button == 29 || button == 28) %rigth arrow | left arrow
        [x,y,button] = ginput(1); while isempty(button), [x,y,button] = ginput(1); end
        if button == 27, break, end % escape key
        if y < textline(1)
            text_area_response
        else
            wave_area_response
        end
    end

    % beep if the number of markers is not the set number
    if  requested_num_markers ~= 0 && length(mark_fs{1}) ~= requested_num_markers, beep, end
    
    hold off
    
    % delete files
    if del_file && saved
        delete(fullfile(SoundDir,NameSounds{soundI}));
        delete(signal_file_name);
        if ~isempty(dir(marker_file_name))
            delete(marker_file_name);
        end
        NameSounds(soundI) = [];
        NumSounds = NumSounds - 1;
        NumSoundsStr = num2str(NumSounds,'%1.0f');
    end

    % advance the counter
    switch button
        case 28 %left arrow
            if soundI > 1, soundI = soundI-1; end
        case 29 %right arrow
            if soundI < NumSounds && ~(del_file && saved), soundI = soundI+1; end
    end

        
end

% clean up
rmdir(fullfile(SoundDir, 'temp'), 's');
close(hfullscreen);
