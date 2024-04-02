%save_results

if cellfun(@isempty, mark_fs) % 2012-07-20 this should stop saving of empty mat files
    if ~isempty(dir(marker_file_name)) % make sure they are gone
        delete(marker_file_name);
    end
else
    save(marker_file_name,'mark_fs','mark_time','mark_text');
end

if wavedited
    wavwrite(yy,Fs,fullfile(SoundDir,NameSounds{soundI}))

    Signal.yy = yy;
    Signal.time_axis = time_axis;
    Signal.freq_axis = freq_axis;
    Signal.spectro = spectro;
    save(signal_file_name, 'Signal');
end

saved = true;