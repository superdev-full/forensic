% select_pitch

figure(pitchplot);

pitch_selected = false;
while ~pitch_selected
    [xxx,yyy,button]=ginput(1);
    if isempty(button), continue, end
    
    I_selected_subplot = find(h_pitch_subplot(:, 3) == gca);
    selected_pitch_subplot = h_pitch_subplot(I_selected_subplot, 3);
    
    switch button % add change f0 options
        case 1 % primary mouse
            set(last_best_pitch_subplot, 'xcolor','k','ycolor','k','LineWidth',.5);
            set(selected_pitch_subplot, 'xcolor','r','ycolor','r','LineWidth', 3);
            last_best_pitch_subplot = selected_pitch_subplot;

            I_f0_best_min = h_pitch_subplot(I_selected_subplot, 1);
            I_f0_best_max = h_pitch_subplot(I_selected_subplot, 2);

            best_f0 = f0{I_f0_best_min, I_f0_best_max};
            
        case 3 % secondary mouse
            pitch_selected = true;
            
        case {key_play, key_play_alt} % play original and synthesised version [spacebar, p]
            soundsc(ysound,Fs_10)
            pause(.3)
            synsound = play_synthetic(Fs_10, taxsg, bestRec.savefest, best_f0, fscales(Isubplot));
            display_synthetic
            figure(pitchplot);
            
        case key_f0_options % change f0 properties [f]
            edit_pitch

        case key_f0_options_default % default f0 properties [d]
            [min_minf0, max_minf0, min_maxf0, max_maxf0, VoicingThreshold, SilenceThreshold, OctaveJumpCost, VoicedUnvoicedCost, OctaveCost] = deal(f0defaults{:});
            edit_pitch
              
        case key_delete % Do not save and Remove (delete) any existing trackset for this vowel [R]
            do_not_save = true;
            doneExploring = true;
            doneThisOne = true;
            doneEdit = true;
            pitch_selected = true;

        case key_go_back % return to previous vowel [back arrow]
            go_back = true;
            doneExploring = true;
            doneThisOne = true;
            doneEdit = true;
            pitch_selected = true;

        case key_go_forward % go to next vowel without saving a best trackset [forward arrow]
            go_forward = true;
            doneExploring = true;
            doneThisOne = true;
            doneEdit = true;
            pitch_selected = true;

        case key_quit % Quit [ESC]
            quit_tracker = true;
            doneExploring = true;
            doneThisOne = true;
            doneEdit = true;
            pitch_selected = true;
    end
    
end

