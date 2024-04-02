%wave_area_response

switch button
    
    case mouse_tempmark_left  % mouse tempmark left (1)
        if x < tempmark(2)-2
            if x < display_all(1), x=display_all(1); end
            tempmark(1)=x;
            set(htempmark(1), 'XData',[tempmark(1) tempmark(1)])
            set(htempmark_num(1), 'Position',[tempmark(1),numpos_y], 'String',num2str(tempmark(1)/Fs-invFs,'%1.3f'));
            set(htempmark_dur, 'Position',[tempmark(1),durpos_y], 'String',num2str((tempmark(2)-tempmark(1))/Fs-invFs,'%1.3f'));
        end 
        
        
    case mouse_tempmark_right  % mouse tempmark right (3)
        if x > tempmark(1)+2
            if x > display_all(2), x=display_all(2); end
            tempmark(2) = x;
            set(htempmark(2),'XData',[tempmark(2) tempmark(2)])
            set(htempmark_num(2), 'Position',[tempmark(2),numpos_y], 'String',num2str(tempmark(2)/Fs-invFs,'%1.3f'));
            set(htempmark_dur, 'Position',[tempmark(1),durpos_y], 'String',num2str((tempmark(2)-tempmark(1))/Fs-invFs,'%1.3f'));
        end 
        
        
    case key_zero_crossing % move to nearest zero crossing (x)
        [C,I] = min(abs(tempmark-x));
        posI = 0; negI = 0;
        roundmark = round(tempmark(I));
        signyyval = sign(yy(roundmark));
        if signyyval ~= 0;
            while signyyval == sign(yy(roundmark+posI))
                posI = posI+1;
                if roundmark+posI == display_all(2)+1 %escape if there isn't a zero crossing before the end of the sound file
                    posI = 0;
                    break
                end
            end
            while signyyval == sign(yy(roundmark-negI))
                negI = negI+1;
                if roundmark-negI == 0 %escape if there isn't a zero crossing before the beginning of the sound file
                    neg = 0;
                    break
                end
            end
            if negI > posI
                tempmark(I) = roundmark+posI-.5;
            else
                tempmark(I) = roundmark-negI+.5;
            end
            set(htempmark(I), 'XData',[tempmark(I) tempmark(I)])
            set(htempmark_num(I), 'Position',[tempmark(I),numpos_y], 'String',num2str(tempmark(I)/Fs-invFs,'%1.3f'));
            set(htempmark_dur, 'Position',[tempmark(1),durpos_y], 'String',num2str((tempmark(2)-tempmark(1))/Fs-invFs,'%1.3f'));
        end 
        
        
    case key_zoom % zoom to selection (z)
        display_section = uint32(tempmark);
        hold off
        plot_spectrogram
        plotwave
        
        
    case key_all % display all (a)
        display_section = display_all;
        hold off
        plot_spectrogram
        plotwave
        
        
    case key_zoom_out % zoom out 150% (q)
        display_width25 = round((display_section(2) - display_section(1))*0.25);
        display_section(1) = display_section(1) - display_width25;
        if display_section(1) < 1, display_section(1) = 1; end
        display_section(2)=display_section(2)+display_width25;
        if display_section(2) > display_all(2), display_section(2) = display_all(2); end
        hold off
        plot_spectrogram
        plotwave
        
        
    case key_zoom_in % zoom in 50% (w)
        display_width25 = round((display_section(2) - display_section(1))*0.25);
        if display_width25>5 %how zoomed do you want!
            display_section(1) = display_section(1)+display_width25;
            display_section(2) = display_section(2)-display_width25;
        end 
        hold off
        plot_spectrogram
        plotwave
        
        
    case key_play % play section (spacebar)
        wavplaysc(yy(round(tempmark(1)):round(tempmark(2))),Fs,'async')
        
        
    case key_play_visible % play visible (p)
        wavplaysc(yy(display_section(1):display_section(2)),Fs,'async')
        
        
    case key_save % save (s)
        save_results
        
        
    case key_remove % remove (delete) selection (R)     % ADD A CHECK TO SEE IF TEMPMARKS ARE AT BEGINNING AND END - IF SO DELETE FILE
        undoable = true;
        wavedited = true;
        yy_old = yy;
        yy = [yy_old(1:round(tempmark(1)));yy_old(round(tempmark(2)):end)];
        
        cut_spec = round(tempmark./Fs*1000/2+1);
        time_axis_old = time_axis;
        spectro_old = spectro;
        time_axis = [time_axis_old(1:cut_spec(1)), time_axis_old(cut_spec(2):end)]; % 2009-12-01 BUG FIXED:was time_axis = [time_axis_old(1:cut_spec(1)); time_axis_old(cut_spec(2):end)];
        spectro = [spectro_old(:,1:cut_spec(1)), spectro_old(:,cut_spec(2):end)];
        
        display_all = uint32([1 length(yy)]);
        display_section = display_all;
        tempmark_old = tempmark;
        tempmark = double(display_section);
        
        mark_fs_old = mark_fs; mark_time_old = mark_time; mark_text_old = mark_text;
        mark_fs = cell(num_marker_rows,1); mark_time = cell(num_marker_rows,1); mark_text = cell(num_marker_rows,1);
        hold off
        
        if length(yy) == 2 % the whole file was selected for deletion
            del_file = true;
        end
        
        plot_spectrogram
        plotwave
        
    case key_zero % zero out selection (T)
        if ~isequal(tempmark,display_all) % do not zero out everything

            undoable = true;
            wavedited = true;

            yy_old = yy;
            yy(round(tempmark(1)) : round(tempmark(2))) = 0;

            cut_spec = round(tempmark./Fs*1000/2+1);
            spectro_old = spectro;
            spectro(:, cut_spec(1) : cut_spec(2)) = min(spectro(:));

            tempmark_old = tempmark;
            mark_fs_old = mark_fs; mark_time_old = mark_time; mark_text_old = mark_text;

            hold off
            plot_spectrogram
            plotwave
        end
        
        
    case key_undo % undo delete/zero out section (u)
        if undoable
            undoable = false;
            del_file = false;
            yy = yy_old;
            time_axis_old = time_axis;
            spectro = spectro_old;
            display_all = uint32([1 length(yy)]);
            display_section = display_all;
            tempmark = tempmark_old;
            hold off
            mark_fs = mark_fs_old; mark_time = mark_time_old; mark_text = mark_text_old;
            plot_spectrogram
            plotwave
        end
        
        
    case key_forward % move forwards in time 50% of window (f)
        display_width_50 = round((display_section(2) - display_section(1))*0.5);
        display_section_new = display_section + display_width_50;
        if display_section_new(2) <= display_all(2)
            display_section = display_section_new;
            hold off
            plot_spectrogram
            plotwave
        end
        
        
    case key_backward % move backwards in time 50% of window (d)
        display_width_50 = round((display_section(2) - display_section(1))*0.5);
        display_section_new = display_section - display_width_50;
        if display_section_new(1)>0
            display_section = display_section_new;
            hold off
            plot_spectrogram
            plotwave
        end 
        
        
    case key_continue % save and Continue to next soundfile (c)
        save_results
        button=29; % right arrow key
        
        
    case key_spectro_options % spectrogram Options (o)
        gui_spec_options
        plot_spectrogram
        subplot(h_subplot_wave);
        
    case key_spectro_options_default % spectrogram default Options (O)
        load_spectro_default_options
        gui_spec_options
        plot_spectrogram
        subplot(h_subplot_wave);
        
    case key_draw_spectrogram % draw spectroGram (g)
        [time_axis_part, freq_axis_part, spectro_part] = get_spectrogram(yy(display_section(1):display_section(2)), Fs, Fs_spec, premph, window_length_ms, window_shift_ms);
        length_spectro_part = size(spectro_part,2);
        spectro(:, display_spec(1):display_spec(1)+length_spectro_part-1) = spectro_part;
        Signal(soundI).spectro(:, display_spec(1):display_spec(1)+length_spectro_part-1)  = spectro_part;
        plot_spectrogram
        subplot(h_subplot_wave);
end 
