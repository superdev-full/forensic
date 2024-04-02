% FormantMeasurer
quit_tracker = false;
num_f34cutoffs=8;

% get customisable command keys and mouse click
load_keyboard_and_mouse

% get user specified options
gui_selections

%Get labelfile names
tdir=dir([SoundDir, FileName]); %if a directory was selected FileName = '*.mat'
NumSounds=length(tdir);
NumSoundsStr=num2str(NumSounds,'%1.0f');
[NameSoundFiles{1:NumSounds}]=deal(tdir.name);

% check that there are wav files corresponding to the mat files
% check if each mat file has the right number of trackmarks
tdir_wav=dir([SoundDir,'*.wav']);
NumSoundsWav=length(tdir_wav);
[NameSoundsWav{1:NumSoundsWav}]=deal(tdir_wav.name);
error_in_files = false;
NameSoundLabels = cell(1,NumSounds);
for Icheck = 1:NumSounds
    NameSoundLabels{Icheck} = NameSoundFiles{Icheck}(1:end-4);
    test_string = [NameSoundLabels{Icheck},'.wav'];
    if ~sum(strcmp(test_string, NameSoundsWav))
        error_in_files = true;
        fprintf('Missing wav file corresponding to: %s\n', NameSoundFiles{Icheck});
    end
    if use_fixed_num_trackmarks
        load([SoundDir,NameSoundFiles{Icheck}],'mark_fs');
        if iscell(mark_fs), mark_fs = mark_fs{label_row_to_use}; end
        % THIS ERROR IS NOT BEING CAUGHT BELOW
%         if length(mark_fs) ~= num_trackmarks
%             error_in_files = true;
%             fprintf('Incorrect number of trackmarks in: %s\n', NameSoundFiles{Icheck});
%         end
    end
end

if ~error_in_files
    %make a dir to put FormantMeasurments
    if isempty(dir([SoundDir,'FormantMeasures']))
        mkdir([SoundDir,'FormantMeasures']);
    end

    %(analysis window is 10ms, window-shift is 2ms)
    Fs_10=10000;
    fromedge_ms=6;
    fromedge_10=fromedge_ms*Fs_10/1000;

    % F3-F4 cutoffs
    f34cutoffs=round(exp(linspace(log(min_f34cutoffs),log(max_f34cutoffs),num_f34cutoffs)));
    watchlevel=0;


    if ~use_saved_tracks
        % run slow formant tracking & pitch analysis in batch mode
        NameSounds = cell(NumSounds,1);
        saveNames = cell(0);
        hwaitbar1 = waitbar(0,'number of files processed');
%         pos_waitbar1 = get(hwaitbar1, 'Position'); set(hwaitbar1, 'Position', [pos_waitbar1(1) pos_waitbar1(2)*1.2 pos_waitbar1(3) pos_waitbar1(4)])
        for soundI=1:NumSounds
            load([SoundDir,NameSoundFiles{soundI}],'mark_fs','mark_time','mark_text') %load existing label file
            if iscell(mark_fs)
                mark_fs = mark_fs{label_row_to_use};
                mark_time = mark_time{label_row_to_use};
                mark_text = mark_text{label_row_to_use};
            end
            length_mark_fs = length(mark_fs);
            NameSounds{soundI}=[NameSoundLabels{soundI},'.wav'];
            [yyyy,Fs]=wavread([SoundDir,NameSounds{soundI}]);
            length_sound = length(yyyy);
            fromedge_Fs=round(fromedge_10/Fs_10*Fs);

            % get indices of sections to measure if using labels
            if ~use_fixed_num_trackmarks
                trackmarks_to_use_initial = [];
                for I_labels = 1:num_labels
                    trackmarks_to_use_initial = [trackmarks_to_use_initial; strmatch(labels_to_measure{I_labels}, mark_text, 'exact')];
                end
                trackmarks_to_use_final = trackmarks_to_use_initial+1;
                trackmarks_to_use = sort([trackmarks_to_use_initial; trackmarks_to_use_final]);
            end

            % extract and measure sections
            for Iselection = 1:2:length(trackmarks_to_use)
                % catch errors
                skip_this_one = false;
                skip_mark_fs_start_test = false;
                skip_mark_fs_end_test = false;
                % display error of the requested start marker doesn't exist
                if trackmarks_to_use(Iselection) > length_mark_fs
                    h_error = warndlg(sprintf('Requested start marker %0.0f in %s does not exist\nWill skip this section', trackmarks_to_use(Iselection), NameSoundFiles{soundI}));
                    beep;
                    uiwait(h_error);
                    skip_this_one = true;
                    skip_mark_fs_start_test = true;
                end
                % display error of the requested start marker doesn't exist / the last selection doesn't have an end marker
                if trackmarks_to_use(Iselection+1) > length_mark_fs
                    h_error = warndlg(sprintf('No end marker following marker %0.0f in %s\nWill skip this section', trackmarks_to_use(Iselection), NameSoundFiles{soundI}));
                    beep;
                    uiwait(h_error);
                    skip_this_one = true;
                    skip_mark_fs_end_test = true;
                end
                % display error of the first or last marker is too close to the edge of the file
                if ~skip_mark_fs_start_test
                    if mark_fs(trackmarks_to_use(Iselection)) <= fromedge_Fs
                        h_error = warndlg(sprintf('First marker for first section in %s is too close to the start\nWill skip this section', NameSoundFiles{soundI}));
                        beep;
                        uiwait(h_error);
                        skip_this_one = true;
                    end
                end
                if ~skip_mark_fs_end_test
                    if mark_fs(trackmarks_to_use(Iselection+1)) + fromedge_Fs >= length_sound;
                        h_error = warndlg(sprintf('Last marker for last section in %s is too close to the end\nWill skip this section', NameSoundFiles{soundI}));
                        beep;
                        uiwait(h_error);
                        skip_this_one = true;
                    end
                end
                if skip_this_one
                    continue
                end
                
                % find beggining and end of section
                mark_fs_working = mark_fs(trackmarks_to_use(Iselection:Iselection+1));
                mark_time_working = mark_time(trackmarks_to_use(Iselection:Iselection+1));
                mark_text_working = mark_text{trackmarks_to_use(Iselection)};
                vowel_duration=(mark_fs_working(2)-mark_fs_working(1))*1000/Fs;

                % isolate portion of file to measure (vowel plus padding) and resample to 10kHz
                yy=yyyy(ceil(mark_fs_working(1)-fromedge_Fs) : floor(mark_fs_working(2)+fromedge_Fs));
                ysound=resample(yy,Fs_10,Fs); 

                % get formant tracks
                GetTracks
                taxsg= bestRec.taxsg;

                % get intensity (amplitude)
                yyyydb=rmsdb(yyyy,Fs,window_length,'HAMMING',0);
                yIntensity=yyyydb(ceil(mark_fs_working(1)-fromedge_Fs) : floor(mark_fs_working(2)+fromedge_Fs));

                % get f0
                get_f0
                %if gender=='F' && mean(f0)<100, f0=f0*2; end  %correct possible octave eror (could be wrong if voice is creaky)

                % save using filename from wav file + Iselection + label
                if ~isempty(mark_text_working)
                    save_label = ['_', mark_text_working];
                else
                    save_label = [];
                end
                saveName = [SoundDir, 'FormantMeasures\tmp_', NameSoundLabels{soundI}, '_', num2str(trackmarks_to_use(Iselection),'%03.0f'), save_label, '.mat'];
                NameSoundLabel = NameSoundLabels{soundI};
                save(saveName,'bestRec','allTrialsRec','score_track','scorecompslabels','XsmoDb','faxsmo','f0','f0_score','ysound','yIntensity','vowel_duration','NameSoundLabel','mark_fs_working','mark_time_working','mark_text_working');
                saveNames = [saveNames,{saveName}];
            end
            waitbar(soundI/NumSounds, hwaitbar1);
        end %for soundI=1:NumSounds %1
        delete(hwaitbar1);
    else % read in existing track files
        tdir_existing = dir([SoundDir, 'FormantMeasures\tmp_*.mat']);
        num_existing = length(tdir_existing);
        [name_existing{1:num_existing}]=deal(tdir_existing.name);
        saveNames = cell(num_existing, 1);
        for I_existing = 1:num_existing
            saveNames{I_existing} = [SoundDir, 'FormantMeasures\', name_existing{I_existing}];
        end
        f0_min = min_minf0 : (max_minf0 - min_minf0)/3 : max_minf0;
        f0_max = min_maxf0 : (max_maxf0 - min_maxf0)/3 : max_maxf0;
        num_f0_min = 4;
        num_f0_max = 4;
    end %if ~use_saved_tracks

    delete(h_gui_selections);

    % check formant and pitch tracking results
    multitrackplot = figure; 
    clf
    subplotrc('tight')
    edittrackplot = figure;
    clf
    pitchplot = figure;
    clf
    synthplot = figure;
    clf
    if ~isempty(dir('WindowPositions.ini'))
        load('WindowPositions.ini', '-mat');
        set(multitrackplot, 'Position', multitrackplot_pos);
        set(edittrackplot, 'Position', edittrackplot_pos);
        set(pitchplot, 'Position', pitchplot_pos);
        set(synthplot, 'Position', synthplot_pos);
    end

    soundI = 0;
    num_sounds = length(saveNames);
    if num_sounds == 0, quit_tracker = true; end
    while ~quit_tracker 
        soundI = soundI + 1;
        load(saveNames{soundI},'bestRec','allTrialsRec','score_track','scorecompslabels','XsmoDb','faxsmo','f0','f0_score','ysound','yIntensity','vowel_duration','NameSoundLabel','mark_fs_working','mark_time_working','mark_text_working');
        CheckTracks
        if soundI >= num_sounds
            quit_dlg = questdlg(sprintf('That was the last vowel.\nDo you want to quit FormatMeasurer'),'Last Vowel','Yes','No','Yes');
            if isequal(quit_dlg, 'Yes')
                quit_tracker = true;
            else
                soundI = num_sounds - 1; 
            end 
        end
    end


    %Cleanup
    multitrackplot_pos = get(multitrackplot, 'Position');
    edittrackplot_pos = get(edittrackplot, 'Position');
    pitchplot_pos = get(pitchplot, 'Position');
    synthplot_pos = get(synthplot, 'Position');
    close all
    quit_options
    if del_all
        delete([SoundDir,'FormantMeasures\tmp_*.mat']);
    elseif del_processed
        tdir_processed = dir([SoundDir,'FormantMeasures\formants_*.mat']);
        num_files_processed = length(tdir_processed);
        [name_files_processed{1:num_files_processed}]=deal(tdir_processed.name);
        for I_files_processed = 1:num_files_processed
            delete([SoundDir,'FormantMeasures\tmp_', name_files_processed{I_files_processed}(10:end)]);
        end
    end
    if save_pos
        save('WindowPositions.ini', 'multitrackplot_pos', 'edittrackplot_pos', 'pitchplot_pos', 'synthplot_pos', '-mat');
    end

else
    beep
end
