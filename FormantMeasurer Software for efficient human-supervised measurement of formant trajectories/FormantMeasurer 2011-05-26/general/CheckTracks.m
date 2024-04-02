%CheckTracks

taxsg= bestRec.taxsg;

haveF0=1;

plotName = fliplr(strtok(fliplr(saveNames{soundI}), '\')); 
plotName = [plotName(5:end-4), ' - vowel ', num2str(soundI, '%0.0f'), ' of ', num2str(num_sounds, '%0.0f')];
set(multitrackplot, 'Name', ['Track Select: ', plotName], 'NumberTitle', 'off');
set(edittrackplot, 'Name', ['Track Edit: ', plotName], 'NumberTitle', 'off');
set(pitchplot, 'Name', ['Fundamental Frequency: ', plotName], 'NumberTitle', 'off');
set(synthplot, 'Name', ['Original and Synthesised Waveform: ', plotName], 'NumberTitle', 'off');


figure(multitrackplot);
clf

BestPlotOriginal = 0;


%Plot all alternatives with f34 cutoffs (nc*mr must equal num_f34cutoffs)
nc=4; mr=2;
itry=0;
for ir=1:mr
    for ic=1:nc
        itry=itry+1;
        ax(ic,ir)=subplotrc(mr,nc,ir,ic);
        plotsgm(taxsg,faxsmo,XsmoDb);
        hold on;
        %Plot the f3 cutoff
        plot([taxsg(1),taxsg(end)],[f34cutoffs(itry),f34cutoffs(itry)],'w-')
        %Plot vowel beginning & end
        plot([taxsg(1)+fromedge_ms,taxsg(1)+fromedge_ms],[faxsmo(1),faxsmo(end)],'w-')
        plot([taxsg(end)-fromedge_ms,taxsg(end)-fromedge_ms],[faxsmo(1),faxsmo(end)],'w-')

        if ~isempty(allTrialsRec.fest4{itry})
            plot(taxsg,allTrialsRec.fest4{itry},':k', 'EraseMode','xor','LineWidth',1);
        end
       
        plot(taxsg,allTrialsRec.fest{itry,1},'-k', 'EraseMode','xor','LineWidth',1);
        
        %plot(taxsg,allTrialsRec.fest{itry,1});
        %tstr=sprintf('itry=%d, FoM=%6.4f,f34cut=%4d',itry,allTrialsRec.scorecomps(itry,1),f34cutoffs(itry));
        tstr=sprintf('%6.4f', allTrialsRec.scorecomps(itry,1));
        text(taxsg(1),faxsmo(end),tstr,'VerticalAlignment', 'top', 'HorizontalAlignment','left','Color','w','FontWeight','demi')
        
        if ir~=2, set(ax(ic,ir),'XTickLabel',[]); end
        if ic~=1, set(ax(ic,ir),'YTickLabel',[]); end
        
        if allTrialsRec.scorecomps(itry,1)==bestRec.scorecompsbest(1)
            BestPlot=itry;
            if BestPlotOriginal == 0;
                BestPlotOriginal = BestPlot;
            end
        end
    end
end
drawnow
axes_handles = flipud(get(multitrackplot,'Children'));

% Manually confirm BEST trackset or select other trackset to use as BEST

ntax=length(taxsg);
fscales=(f34cutoffs./3.5)/500;
if ~haveF0
    get_f0
end
plot_f0

handle_origin = 5;
lastChosenAx =[];
doneThisOne = false;
go_back = false;
go_forward = false;
do_not_save = false;
first_time = true;
while ~doneThisOne
    ffhand=nan(ntax,3); % Reset this always here
    figure(multitrackplot)
    % Get f0 and fscales for resynthesis

    Isubplot=[];
    donePick=0;
    subplotrc(2,4,2,4)
    doneEdit = false;
    if ~isempty(lastChosenAx), highlightax(lastChosenAx,-1); end
    lastChosenAx=ax(BestPlotOriginal);
    highlightax(lastChosenAx);
    axes(lastChosenAx)
    doneExploring = false;
    Isubplot=BestPlot;
    
    % reset any previously selected tracks
    if ~first_time
        for Itrack = 1:3
            set(selectedFhandle(Itrack),'LineWidth',1); 
        end
    end
    selectedFhandle = NaN(1,3);
    
    % set best tracks from Terry's heuristics
    [max_score_track, II_score_track] = max(score_track);
    for Itrack = 1:3
        temp_handles = get(axes_handles(II_score_track(Itrack)),'Children');
        selectedFhandle(Itrack) = temp_handles(handle_origin - Itrack);
        set(selectedFhandle(Itrack),'LineWidth',3);
        bestRec.savefest(:,Itrack) = allTrialsRec.fest{II_score_track(Itrack),1}(:,Itrack);
    end
    F3cutoffI = II_score_track(3);
    best_track_disp = [1 1 1];
    
    if first_time
        soundsc(ysound,Fs_10)
        pause(.3)
        synsound = play_synthetic(Fs_10, taxsg, bestRec.savefest, best_f0, fscales(Isubplot));
        display_synthetic
        figure(multitrackplot);
        first_time = false;
    end

    hard_select = false;
    while ~doneExploring
        [xxx,yyy,button]=ginput(1);
        if isempty(button), continue, end
        
        switch button
            case {1, 3}   % Any mouse button will switch axis
                highlightax(lastChosenAx,-1)
                theSubplot=gca; % Get current axis
                lastChosenAx=theSubplot;
                highlightax(lastChosenAx);
                Isubplot=find(theSubplot==ax(:)); % Isubplot shows which choice was made

                if button == key_select_track  % select F1, F2, or F3 [primary mouse button]
                    [Time_diff,Time_closest] = min(abs(xxx-taxsg));
                    [Freq_diff,Formant_closest] = min(abs(yyy-allTrialsRec.fest{Isubplot,1}(Time_closest,:)));
                    if hard_select % If the immediatedly previous keypress was key {1, 2, 3}, make the nearest track {F1, F2, F3}
                        if ~isempty(allTrialsRec.fest4{Isubplot})
                            [Freq_diff4,Formant_closest4] = min(abs(yyy-allTrialsRec.fest4{Isubplot}(Time_closest,:)));
                        else
                            Freq_diff4 = Inf;
                        end
                        if Freq_diff4 < Freq_diff
                            bestRec.savefest(:,hard_track) = allTrialsRec.fest4{Isubplot}(:,Formant_closest4);
                        else
                            bestRec.savefest(:,hard_track) = allTrialsRec.fest{Isubplot,1}(:,Formant_closest);
                        end
                        if hard_track == 3;
                            F3cutoffI = Isubplot;
                        end
                        % make previously selected track thin
                        if ~isnan(selectedFhandle(hard_track))
                            set(selectedFhandle(hard_track),'LineWidth',1); 
                        end
                        % make selected track fat
                        temp_handles = get(theSubplot,'Children');
                        if Freq_diff4 < Freq_diff
                            selectedFhandle(hard_track) = temp_handles(handle_origin - Formant_closest4 + 4);
                        else
                            selectedFhandle(hard_track) = temp_handles(handle_origin - Formant_closest);
                        end
                    else
                        bestRec.savefest(:,Formant_closest) = allTrialsRec.fest{Isubplot,1}(:,Formant_closest);
                        if Formant_closest == 3;
                            F3cutoffI = Isubplot;
                        end
                        % make previously selected track thin
                        if ~isnan(selectedFhandle(Formant_closest))
                            set(selectedFhandle(Formant_closest),'LineWidth',1); 
                        end
                        % make selected track fat
                        temp_handles = get(theSubplot,'Children');
                        selectedFhandle(Formant_closest) = temp_handles(handle_origin-Formant_closest);
                    end

                    for Itrack = 1:3
                        set(selectedFhandle(Itrack),'LineWidth',3); 
                    end

                    plot_selected
                    figure(multitrackplot);

                elseif button == key_accept % edit in large window [secondary mouse button]
                    doneEdit = false;
                    doneExploring = true;
                end

            case {key_play, key_play_alt} % play original and synthesised version [spacebar, p]
                soundsc(ysound,Fs_10)
                pause(.3)
                synsound = play_synthetic(Fs_10, taxsg, bestRec.savefest, best_f0, fscales(Isubplot));
                display_synthetic
                figure(multitrackplot);

            case key_f0_select % select f0 track [s]
                select_pitch
                figure(multitrackplot)

            case key_go_back % return to previous vowel [back arrow]
                go_back = true;
                doneExploring = true;

            case key_go_forward % go to next vowel without saving a best trackset [forward arrow]
                go_forward = true;
                doneExploring = true;

            case key_delete % Do not save and Remove (delete) any existing trackset for this vowel [R]
                do_not_save = true;
                doneExploring = true;

            case key_quit % Quit [ESC]
                quit_tracker = true;
                doneExploring = true;

            case {key_next_best_F1, key_next_best_F2, key_next_best_F3} % keys [q], [w], [e] (immediately under [1], [2], [3]) - pick second, third, etc. best track instead of first best track - this was the previous behaviour of keys 1, 2, 3
                switch button
                    case key_next_best_F1
                        Itrack = 1;
                    case key_next_best_F2
                        Itrack = 2;
                    case key_next_best_F3
                        Itrack = 3;
                end
                best_track_disp(Itrack) = best_track_disp(Itrack) + 1;
                if best_track_disp(Itrack) > num_f34cutoffs, best_track_disp(Itrack) = 1; end
                [best_track_score, best_track_order] = sort(score_track(:, Itrack), 'descend');

                set(selectedFhandle(Itrack),'LineWidth',1);
                temp_handles = get(axes_handles(best_track_order(best_track_disp(Itrack))),'Children');
                selectedFhandle(Itrack) = temp_handles(handle_origin - Itrack);
                set(selectedFhandle(Itrack),'LineWidth',3); 

                if Itrack == 3, F3cutoffI = best_track_order(best_track_disp(Itrack)); end

                bestRec.savefest(:,Itrack) = allTrialsRec.fest{best_track_order(best_track_disp(Itrack)),1}(:,Itrack);
        end
        
        switch button % key [1], [2], [3], hard select F1, F2, F3. If the immediatedly following keypress is primary mouse button, make the nearest track {F1, F2, F3}
            case key_hard_select_F1
                hard_track = 1;
                hard_select = true;
            case key_hard_select_F2
                hard_track = 2;
                hard_select = true;
            case key_hard_select_F3
                hard_track = 3;
                hard_select = true;
            otherwise
                hard_select = false;
        end
        
    end % while not done exploring
    
    % sort the tracks in case hard selecting has put F1 higher than F2 etc.
    mean_track_values = mean(bestRec.savefest, 1);
    [junk, I_sort_tracks] = sort(mean_track_values);
    bestRec.savefest = bestRec.savefest(:,I_sort_tracks);
    
    
    if go_back || go_forward || do_not_save || quit_tracker
        if go_back
            if soundI > 1, soundI = soundI - 2; else soundI = 0; end
        end
        clf
        break
    end
    
    % move selected formant tracks to bestRec % this is actually only for the best set, not for individual tracks
    bestRec.scorecompsbest=allTrialsRec.scorecomps(Isubplot,1);
    bestRec.f34cutoffbest=allTrialsRec.f34cutoffs(Isubplot);
    BestPlot=Isubplot;

    % plot selected
    if ~doneEdit
        plot_selected
    end
    
    % Edit tracks, move onto next vowel, or return to multitrack plot
    bestRec.savefest_old=bestRec.savefest;
    while ~doneEdit
        [xxx,yyy,button]=ginput(1);
        if button == key_select_track % select track [primary mouse button]
            % Identify the formant
            [Time_diff,Time_closest]=min(abs(xxx-taxsg));
            [Freq_diff,Formant_closest]=min(abs(yyy-bestRec.savefest(Time_closest,:)));
            ffhand(Time_closest,Formant_closest)=yyy;
            while button == key_select_track; % Add more knot points on same track till something else is clicked [primary mouse button]
                [xxx,yyy,button]=ginput(1);
                if button == key_select_track
                    bestRec.savefest_old=bestRec.savefest;
                    [Time_diff,Time_closest]=min(abs(xxx-taxsg));
                    ffhand(Time_closest,Formant_closest)=yyy;
                    knotPoints=find(~isnan(ffhand(:,Formant_closest)));
                    nknots=length(knotPoints);
                    if nknots==1
                        bestRec.savefest(Time_closest,Formant_closest)=yyy;
                    elseif nknots>1
                        ifirst=knotPoints(1);
                        ilast=knotPoints(nknots);
                        bestRec.savefest(ifirst:ilast,Formant_closest)=interp1(taxsg(knotPoints),ffhand(knotPoints,Formant_closest),taxsg(ifirst:ilast));
                        set(hFormants(Formant_closest),'YData',bestRec.savefest(:,Formant_closest));
                        drawnow
                    end
                end
            end
            
            knotPoints=find(~isnan(ffhand(:,Formant_closest)));
            nknots=length(knotPoints);
            if nknots==1
                bestRec.savefest(Time_closest,Formant_closest)=yyy;
            elseif nknots>1
                ifirst=knotPoints(1);
                ilast=knotPoints(nknots);
                bestRec.savefest(ifirst:ilast,Formant_closest)=interp1(taxsg(knotPoints),ffhand(knotPoints,Formant_closest),taxsg(ifirst:ilast));
            end

            set(hFormants(Formant_closest),'YData',bestRec.savefest(:,Formant_closest))
            drawnow
            
            if button == key_accept %if save option is selected immediately after a manual edit, check if the user really wants to save
                save_manual_edits = questdlg('Save with the last manual edits?', 'Warning', 'Yes', 'No', 'No');
                switch save_manual_edits 
                    case 'No'
                        button = key_undo;
                end
            end
            
        end
        
        switch button
            case key_accept % save and move on to next vowel [secondary mouse button]
                doneThisOne = true;
                doneEdit = true;

            case key_undo %undo last trackedit [z]
                bestRec.savefest=bestRec.savefest_old;
                for IhFormants=1:3
                    set(hFormants(IhFormants),'YData',bestRec.savefest(:,IhFormants))
                end
                drawnow

            case key_f0_select % select f0 track [s]
                select_pitch
                figure(edittrackplot)

            case key_change_trackset % return to multitrack window to change selected trackset [c]
                doneEdit = true;

            case {key_play, key_play_alt}; % play original and synthesised version [spacebar, p]
                soundsc(ysound,Fs_10);
                pause(.3)
                synsound = play_synthetic(Fs_10, taxsg, bestRec.savefest, best_f0, fscales(Isubplot));
                ffhand=nan(ntax,3); % delete all knot points

            case key_switch_track % switch track to edit [x]
                ffhand=nan(ntax,3); % delete all knot points

            case key_delete % Do not save and Remove (delete) any existing trackset for this vowel [R]
                do_not_save = true;
                doneThisOne = true;
                doneEdit = true;

            case key_go_back % return to previous vowel [back arrow]
                go_back = true;
                if soundI > 1, soundI = soundI - 2; else soundI = 0; end
                doneThisOne = true;
                doneEdit = true;

            case key_go_forward % go to next vowel without saving a best trackset [forward arrow]
                go_forward = true;
                doneThisOne = true;
                doneEdit = true;

            case key_quit % Quit [ESC]
                quit_tracker = true;
                doneThisOne = true;
                doneEdit = true;
        end % switch button

    end % while not doneEdit
    clf

end % While Not Done this one

if quit_tracker, break, end

% saving and navegation
if ~(go_back || go_forward)
    saveNamesBest = regexprep(saveNames{soundI}, '\\tmp_', '\\formants_');
    if do_not_save
        if ~isempty(dir(saveNamesBest)), delete(saveNamesBest); end
        soundI = soundI - 1;
    else
        % interpolate yIntensity
        amp_db = interpolate1(yIntensity, length(taxsg));
        % complie and save    
        f_measures=[bestRec.taxsg, best_f0, bestRec.savefest, amp_db]; %columns are [time, f0, F1, F2, F3, amp_db]
        v_duration=vowel_duration;
        save(saveNamesBest,'f_measures','v_duration');
    end
end
    