% dual_monitor_setup
close all

fullscreenfigure(1);
set(1, 'Name', 'Participant Window', 'NumberTitle', 'off');
axis off
text(.5, .6, sprintf('Size and Position this window on the the Participant''s monitor.\nPress next when both windows have been positioned.'), 'HorizontalAlignment', 'center', 'FontSize', 24)

nextb_ref=toc+.2; nextb=0;
button_next;

fullscreenfigure(2);
set(2, 'Name', 'Researcher Window', 'NumberTitle', 'off');
axis off
text(.5, .6, sprintf('Size and Position this window on the the Researcher''s monitor.\nPress next when both windows have been positioned.'), 'HorizontalAlignment', 'center', 'FontSize', 24)

button_next;
while nextb<=nextb_ref
    pause(0.1)
end
playsoundfile('./Instructions/Click.wav','async')

pos_window(1,1:4) = get(1, 'OuterPosition');
close(1);
pos_window(2,1:4) = get(2, 'OuterPosition');
close(2);

save('./InitiationFiles/WindowPositions_ini.mat', 'pos_window');
