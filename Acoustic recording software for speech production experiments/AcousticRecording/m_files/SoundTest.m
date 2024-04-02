% run_soundtest

reclength=get(ai,'SamplesPerTrigger');
set(ai,'SamplesPerTrigger',inf);

fid=fopen(['.\Instructions\SoundTestSentences',filelang,'.txt']);
SoundTestSentences=textscan(fid,'%s', 'delimiter','\t');
fclose(fid);
SoundTestSentences=SoundTestSentences{1};

vdursec=.1;
vudur=fsRec*vdursec;
vuwindowsize=3;
vuwindow=vudur*vuwindowsize;

for I_monitors = 1:num_logical_monitors
    figure(I_monitors);
    subplot(2,1,2);
    text(0,1.3,['Soundcard: ',SoundCard.BoardNames{cardindex_in+1}(1,:)],'Fontsize',10, 'HorizontalAlignment', 'left');
    text(.5,1.1,SoundTestSentences{1},'Fontsize',20, 'HorizontalAlignment', 'center');
    text(.5,.875,SoundTestSentences{2},'FontName','Times','Fontsize',25, 'HorizontalAlignment', 'center');
    text(.5,.7,SoundTestSentences{3},'FontName','Times','Fontsize',25, 'HorizontalAlignment', 'center');
    text(.5,.525,SoundTestSentences{4},'FontName','Times','Fontsize',25, 'HorizontalAlignment', 'center');
    text(.5,.35,SoundTestSentences{5},'FontName','Times','Fontsize',25, 'HorizontalAlignment', 'center');
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

if strcmp(get(ai,'Running'),'Off')
    start(ai);
end

pause(vdursec*vuwindowsize)

figure(num_logical_monitors); % buttons on researcher window only
stopbtn=0;
button_stop;
freeze_play=0;
button_freeze_play;

while ~stopbtn & strcmp(get(ai,'Running'),'On')
    pause(vdursec)
    vudata=peekdata(ai,vuwindow)*wav_scaler;
    maxdata=max(vudata);
    mindata=min(vudata);
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
%         old_clipping=clipping_level;
%         clipping_level=max([maxdata,-mindata,clipping_level]);
        wintoplay=length(audiotoplay);
        for I_monitors = 1:num_logical_monitors
            figure(I_monitors);
            subplot(2,1,1);
            hold off
            vuPlot(I_monitors) = plot(audiotoplay);
            grid on
            ylim([-1 1]);
            set(gca,'YTick',[-1:.25:1],'XTickLabel',[]);
%             if clipping_level>old_clipping
%                 set(htext(I_monitors),'String',num2str(clipping_level,'%0.3f'));
%             end
            hold on
            maxPlot=plot([0,wintoplay],[maxdata,maxdata],'r');
            minPlot=plot([0,wintoplay],[mindata,mindata],'r');
            xlim([0 wintoplay]);
            drawnow
            hold off
        end
        h_playingbutton = button_playing(lang_strings{7});
        while freeze_play
            playsound(audiotoplay,fsRec,'sync','left');
            pause(.1)
        end
        delete(h_playingbutton);
        for I_monitors = 1:num_logical_monitors
            figure(I_monitors);
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

set(ai,'SamplesPerTrigger',reclength);

for I_monitors = 1:num_logical_monitors
    clf(I_monitors);
end

