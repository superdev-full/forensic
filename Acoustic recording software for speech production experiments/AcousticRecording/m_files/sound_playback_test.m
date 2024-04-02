% sound_playback_test

[playback_test_left,Fs,bits]=wavread('.\Instructions\playback_test_left.wav');
[playback_test_right,Fs,bits]=wavread('.\Instructions\playback_test_right.wav');
[playback_test_both,Fs,bits]=wavread('.\Instructions\playback_test_both.wav');
tic
nextb=0;
quit_now=0;

for I_monitors = 1:num_logical_monitors
    figure(I_monitors);
    axis off
    htext(I_monitors) = text(.5,.5,'','FontName','Times','Fontsize',14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'EraseMode','xor');
    button_quit;
    drawnow
end
while ~quit_now
    for I_monitors = 1:num_logical_monitors
        set(htext(I_monitors),'String','I am speaking on channel 1, the left channel. Only the researcher should be able to hear me.')
        drawnow
    end
    playsound(playback_test_left,Fs,'sync','left')
    pause(0.1)
    if quit_now, break, end
    for I_monitors = 1:num_logical_monitors
        set(htext(I_monitors),'String','I am speaking on channel 2, the right channel. Only the participant should be able to hear me.')
        drawnow
    end
    playsound(playback_test_right,Fs,'sync','right')
    pause(0.1)
    if quit_now, break, end
    for I_monitors = 1:num_logical_monitors
        set(htext(I_monitors),'String','We are speaking on both channels. Both the researcher and the participant should be able to hear us.')
        drawnow
    end
    playsound(playback_test_both,Fs,'sync','both')
    pause(0.1)
end
for I_monitors = 1:num_logical_monitors
    clf(I_monitors);
end

