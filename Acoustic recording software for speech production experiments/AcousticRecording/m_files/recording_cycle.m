numwords=size(stimuli,1);
lastword=0;
j=0;

RecAnswerDirCore=[RecAnswerDir,core_str];

% initiate counter including check for any files already recorded
counter=zeros(numwords,1);
tdir=dir(RecAnswerDirCore);
NumAlreadyAnswered=length(tdir); %included count of present and parent folders
if NumAlreadyAnswered>2
    for itdir=3:NumAlreadyAnswered
        for iwords=1:numwords
            if strcmp(stimuli(iwords,1),tdir(itdir).name(1:4))
                counter(iwords)=counter(iwords)+1;
            end
        end
    end
end
NumCountStart=NumAlreadyAnswered-2;
NumRoundsStart=min(counter(:))+1;
if NumRoundsStart==max(counter(:)), NumRoundsStart=NumRoundsStart+1; end


counterstr=num2str(sum(counter(:)),'%03.0f');
set(htext4,'String',counterstr);

% RECORDING
for Iround=NumRoundsStart:NumProdRounds
    set(figure(num_logical_monitors), 'WindowStyle', 'modal') % Researcher window will capture all keyboard and mouse input
    
    set(htext9,'String',num2str(Iround,'%0.0f'));
    
    % Click on the Researcher window to begin
    set(htext0(num_logical_monitors),'String',SoundTestSentences{6}); 
    window_click=0;
    while window_click~=1;
        pause(0.1);
        [xx,yy,window_click]=ginput(1);
    end
    set(htext0,'String',[]);
    pause(0.5)
    
    while min(counter)<Iround
        wordnumsthisround=find(counter<Iround);
        numwordsthisround=length(wordnumsthisround);

        j=randperm(numwordsthisround);
        while wordnumsthisround(j(1))==lastword && numwordsthisround>1
            j=randperm(numwordsthisround);
        end

        lastword=wordnumsthisround(j(end));
        for iword=1:numwordsthisround
            counterstr=num2str(sum(counter(:))+1,'%03.0f');
            set(htext4,'String',counterstr);
            timenow=toc;
            minutesnow=floor(timenow/60);
            secondsnow=rem(timenow,60);
            timestr=([num2str(minutesnow,'%02.0f'),':',num2str(secondsnow,'%02.0f')]);
            set(htext5,'String',timestr);


            sounds_like_word=stimuli{wordnumsthisround(j(iword)),3};
            no_rhyme=str2double(stimuli{wordnumsthisround(j(iword)),4});
            target_word=stimuli{wordnumsthisround(j(iword)),2};
            target_word_IPA=['[',stimuli{wordnumsthisround(j(iword)),6},']'];
            playsound
            
            if left_to_right
                set(htext1,'String',[link_words{1},' ',sounds_like_word,' ',link_words{2},' ']);
                for I_monitors = 1:num_logical_monitors
                    prompt_pos=get(htext1(I_monitors),'Extent');
                    if no_rhyme
                        set(htext2(I_monitors),'String',target_word,'Color',[.75 0 0],'Position',[prompt_pos(1)+prompt_pos(3), prompt_pos(2)]);
                    else
                        set(htext2(I_monitors),'String',target_word,'Color',[0 0 .75],'Position',[prompt_pos(1)+prompt_pos(3), prompt_pos(2)]);
                    end
                    prompt_pos=get(htext2(I_monitors),'Extent');
                    set(htext3(I_monitors),'String',[' ',link_words{3}],'Position',[prompt_pos(1)+prompt_pos(3), prompt_pos(2)]);
                end
            else %right_to_left
                set(htext1,'String',[' ',link_words{2},' ',sounds_like_word,' ',link_words{1}]);
                for I_monitors = 1:num_logical_monitors
                    prompt_pos=get(htext1(I_monitors),'Extent');
                    if no_rhyme
                        set(htext2(I_monitors),'String',target_word,'Color',[.75 0 0],'Position',[prompt_pos(1), prompt_pos(2)]);
                    else
                        set(htext2(I_monitors),'String',target_word,'Color',[0 0 .75],'Position',[prompt_pos(1), prompt_pos(2)]);
                    end
                    prompt_pos=get(htext2(I_monitors),'Extent');
                    set(htext3(I_monitors),'String',[' ',link_words{3}],'Position',[prompt_pos(1), prompt_pos(2)]);
                end
            end
            
            if display_IPA
                for I_monitors = 1:num_logical_monitors
                    set(htext6(I_monitors),'String',target_word_IPA);
                end
            end
            set(htext7,'String',target_word_IPA);
            drawnow

%             if spoken_prompt
%                 spoken_prompt_file=[prompt_audio_Dir,stimuli{wordnumsthisround(j(iword)),1},'_01.wav'];
%                 [prompt_audio Fs]=wavread(spoken_prompt_file);
%                 playsound(prompt_audio,Fs,'sync','both')
%             end %if spoken_prompt

            start(ai);
            %button_corner;
            %uiwait;
            waitforbuttonpress;
            timed_out=strcmp(get(ai,'Running'),'Off');
            stop(ai);
            %delete(cornerbutton)
            
            for I_monitors = 1:num_logical_monitors
                set(htext1(I_monitors),'String',[]); 
                set(htext2(I_monitors),'String',[]); 
                set(htext3(I_monitors),'String',[]); 
                if display_IPA, set(htext6(I_monitors),'String',[]); end
            end

            recorded=getdata(ai,ai.SamplesAvailable);
            flushdata(ai)

            % delete silence from beginning & end of recording
            lengrec=length(recorded);
            cutamp=max(abs(recorded))*cutamp_tol;
            cutind=find(recorded>cutamp);
            if ~isempty(cutind)
                cutto=cutind(1)-fsRec_tol;
                cutfrom=cutind(end)+fsRec_tol;
                if cutto<1, cutto=1; end
                if cutfrom>lengrec, cutfrom=lengrec; end
                recorded=recorded(cutto:cutfrom)*wav_scaler;
            end
            length_recorded=length(recorded);

%             if max(abs(recorded))>=1    %clipped recording
%                 %goodrecording=0;
%                 figure(hclipped);
%                 hh=hclipped;
%                 clipped=1;
%             else
%                 figure(hwaveform);
%                 hh=hwaveform;
%                 clipped=0;
%             end
            if max(abs(recorded))>=1    %clipped recording
                clipped=1;
            else
                clipped=0;
            end
            
            plot(recorded);
            set(hwave_axis,'XTickLabel',[], 'YLim',[-1 +1], 'XLim',[1 length_recorded]);
%             ylim([-1 1])
%             xlim([1 length_recorded])
%             set(hwave_axis,'XTickLabel',[])
            grid on

            if clipped || timed_out
                htext8=text(0.01,-1.01,'Accept: a     Play: p     Reject: spacebar     Quit: Q','FontName','Helvetica','Fontsize',10, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
                if clipped
                    text(length_recorded/2,0.5,'Clipped','FontName','Times','Fontsize',20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
                end
                if timed_out
                    text(length_recorded/2,-0.5,'Timed Out','FontName','Times','Fontsize',20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
                end
            else
                htext8=text(0.01,-1.01,'Accept: spacebar     Play: p     Reject: x     Quit: Q','FontName','Helvetica','Fontsize',10, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
            end
            drawnow
            cont=0;

            while ~cont
                wfbp=waitforbuttonpress;
                if wfbp
                    responsekey=get(gcf,'CurrentCharacter');
                    switch responsekey
                        case 'p'
                            playsound(recorded,fsRec,'sync','left');
                            cont=0;
                        case 'x'
                            goodrecording=0;
                            cont=1;
                        case 'a'
                            goodrecording=1;
                            cont=1;
                        case ' '
                            if clipped, goodrecording=0; else goodrecording=1; end
                            cont=1;
                        case 'Q'
                            goodrecording=0;
                            cont=1;
                            quit_now=1;
                    end
                end
            end

            if goodrecording
%                 lastwarn('');
                temp_count=counter(wordnumsthisround(j(iword)))+1;
                RecAnswerFile=[RecAnswerDirCore,stimuli{wordnumsthisround(j(iword)),1},'_',num2str(temp_count,'%02.0f'),'.wav'];
                wavwrite(recorded,fsRec,RecAnswerFile);
    % Note this if_else is commented out because we are allowing clipped recordings to be saved in this version
    %             if ~isempty(lastwarn)  
    %                 delete(RecAnswerFile);
    %             else
    %                 counter(wordnumsthisround(j(iword)))=temp_count;
    %             end
                counter(wordnumsthisround(j(iword)))=temp_count;
            end
            
            delete(htext8);
            plot(0,0,'w');
            set(hwave_axis,'XTickLabel',[], 'YLim',[-1 +1]);

            set(htext7,'String',[]);
            pause(.5)
            if quit_now, set(figure(num_logical_monitors), 'WindowStyle', 'normal'); break, end
        end %for iword=1:numwordsthisround
        if quit_now, set(figure(num_logical_monitors), 'WindowStyle', 'normal'); break, end
    end %while min(counter)<Iround
    
    set(figure(num_logical_monitors), 'WindowStyle', 'normal'); % allow input from either window
    
    if quit_now, break, end

    % take a rest between rounds
    if Iround<NumProdRounds
        for I_monitors = 1:num_logical_monitors
            set(htext0(I_monitors),'String',SoundTestSentences{7}); %Please take a rest before the next round.
        end
        nextb_ref=toc+.1;
        nextb=0;
        figure(1); % Particiapnt window
        h_button_next = button_next(lang_strings{5});
        figure(num_logical_monitors); % Researcher window
        h_button_quit = button_quit;
        while nextb<nextb_ref
            pause(.1)
        end
        delete(h_button_next, h_button_quit);
        for I_monitors = 1:num_logical_monitors
            set(htext0(I_monitors),'String',[]);
        end
        if quit_now, break, end
    end
end %for Iround=1:NumProdRounds

