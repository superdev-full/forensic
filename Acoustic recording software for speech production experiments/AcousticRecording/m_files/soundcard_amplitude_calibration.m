% soundcard_amplitude_calibration

disp_lang=0;

SoundCard=daqhwinfo('winsound');
board_names=SoundCard.BoardNames(:);

nextb_ref=toc+.2;
nextb=0;
for I_monitors = 1:num_logical_monitors
    figure(I_monitors);

    SoundCardBgroup=uibuttongroup('Title','Sound Card',...
                            'FontSize',14,...
                            'Units','normalized',...
                            'Position',[.2 .7 .25 .2]);
    SoundCardB(I_monitors)=uicontrol('Style','Listbox',...
                            'String',board_names,...
                            'Value',1,...
                            'Min',1,'Max',1,...
                            'Units','normalized',...
                            'Position',[.1 .2 .8 .6],...
                            'Parent',SoundCardBgroup);
button_next;
end
while nextb<nextb_ref
    pause(.1)
end
monitor_selected = gcf;
cardindex=get(SoundCardB(monitor_selected),'Value');
cardname_in=board_names{cardindex};

for I_monitors = 1:num_logical_monitors
    clf(I_monitors);
end

preferred_soundcards={'none'};
soundcard_setup

reclength=get(ai,'SamplesPerTrigger');
set(ai,'SamplesPerTrigger',inf);

vdursec=.1;
vudur=fsRec*vdursec;
vuwindowsize=3;
vuwindow=vudur*vuwindowsize;
    
for I_monitors = 1:num_logical_monitors
    figure(I_monitors);

    subplot(2,1,2);
    text(0,1.3,['Soundcard: ',SoundCard.BoardNames{cardindex_in+1}(1,:)],'Fontsize',10, 'HorizontalAlignment', 'left');
    text(.5,1.1,'Soundcard Amplitude Calibration','Fontsize',30, 'HorizontalAlignment', 'center');
    text(.5,.8,'Turn the microphone gain to maximum','Fontsize',14, 'HorizontalAlignment', 'center');
    text(.5,.7,'Speak loudly or whistle until you get clipping.','Fontsize',14, 'HorizontalAlignment', 'center');
    text(.5,.6,'The maximum absolute peak amplitude will be saved to:','Fontsize',14, 'HorizontalAlignment', 'center');
    text(.5,.5,'soundcard\_amplitude\_calibration.txt','Fontsize',12, 'HorizontalAlignment', 'center');

    htext(I_monitors) = text(.5,.25,'','FontName','Times','Fontsize',14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'EraseMode','xor');

    axis off

    subplot(2,1,1);
    vuPlot(I_monitors) = plot(zeros(vuwindow,1),'EraseMode','xor');
    grid on
    ylim([-1 1]); 
    set(gca,'YTick',[-1:.25:1],'XTickLabel',[]);
    axis tight
    hold on
    maxPlot(I_monitors) = plot([0,vuwindow],[0,0],'r','EraseMode','xor');
    minPlot(I_monitors) = plot([0,vuwindow],[0,0],'r','EraseMode','xor');
    text(vuwindow/2,1.2,'Sound Test','Fontsize',15,'HorizontalAlignment', 'center');
end

clipping_level=0;

if strcmp(get(ai,'Running'),'Off')
    start(ai);
end

pause(vdursec*vuwindowsize)

for I_monitors = 1:num_logical_monitors
    figure(I_monitors);
    stopbtn=0;
    button_stop;
    freeze_play=0;
    button_freeze_play;
end

while ~stopbtn && strcmp(get(ai,'Running'),'On')
    pause(vdursec)
    vudata=peekdata(ai,vuwindow)*wav_scaler;
    maxdata=max(vudata);
    mindata=min(vudata);
    old_clipping=clipping_level;
    clipping_level=max([maxdata,-mindata,clipping_level]);
    if clipping_level>old_clipping
        set(htext,'String',num2str(clipping_level,'%0.3f'));
    end
    for I_monitors = 1:num_logical_monitors
        set(vuPlot(I_monitors),'YData',vudata);
        set(maxPlot(I_monitors),'YData',[maxdata,maxdata]);
        set(minPlot(I_monitors),'YData',[mindata,mindata]);
    end
    if freeze_play
        sampavail=get(ai,'SamplesAvailable');
        audio=getdata(ai,sampavail);
        if sampavail<fsRec*1.5 % play 1.5 second if available
            audiotoplay=sampavail*wav_scaler;
        else
            audiotoplay=audio(end-fsRec*1.5:end)*wav_scaler;
        end
        flushdata(ai)
        maxdata=max(audiotoplay);
        mindata=min(audiotoplay);
        old_clipping=clipping_level;
        clipping_level=max([maxdata,-mindata,clipping_level]);
        wintoplay=length(audiotoplay);
        for I_monitors = 1:num_logical_monitors
            figure(I_monitors);
            subplot(2,1,1);
            hold off
            vuPlot(I_monitors) = plot(audiotoplay);
            grid on
            ylim([-1 1]);
            set(gca,'YTick',[-1:.25:1],'XTickLabel',[]);
            if clipping_level>old_clipping
                set(htext(I_monitors),'String',num2str(clipping_level,'%0.3f'));
            end
            hold on
            maxPlot=plot([0,wintoplay],[maxdata,maxdata],'r');
            minPlot=plot([0,wintoplay],[mindata,mindata],'r');
            h_playingbutton(I_monitors) = button_playing(lang_strings{7});
            xlim([0 wintoplay]);
            drawnow
            hold off
        end
        while freeze_play
            playsound(audiotoplay,fsRec,'sync','left');
            pause(.1)
        end
        for I_monitors = 1:num_logical_monitors
            figure(I_monitors);
            delete(h_playingbutton(I_monitors));
            vuPlot(I_monitors)=plot(zeros(vuwindow,1),'EraseMode','xor');
            grid on
            ylim([-1 1]);
            set(gca,'YTick',[-1:.25:1],'XTickLabel',[]);
            axis tight
            hold on
            maxPlot(I_monitors) = plot([0,vuwindow],[0,0],'r','EraseMode','xor');
            minPlot(I_monitors) = plot([0,vuwindow],[0,0],'r','EraseMode','xor');
        end
    end
end

hold off

stop(ai)
flushdata(ai)

fid=fopen('.\InitiationFiles\soundcard_amplitude_calibration.txt','w');
    fprintf(fid,'%s\t%0.17f',cardname_in,clipping_level);
fclose(fid);

soundcard_cleanup
