% Acoustic Recording Software for Speech Production Experiments
% © 2007, 2008 Geoffrey Stewart Morrison
% Release 2008-12-23
%
% Use the following audio setup:
%
% Windows audio settings:
%       Sound Playback Defaut Devices:             EDIROL UA-25     EDIROL FA-101 Out 1
%
% Physical hookups:
%   Soundcard: EDIROL FA-101
%       participant's microphone input:            input 1/L        input 1
%       researcher's microphone input (intercom):  input 2/R        input 2
%       output to researcher only (left):          output L         output 1
%       output to participant only (right):        output R         output 2
%   switches:
%           mono:                                  out              out
%           soft control:                                           out
%           mon. sw:                               light on, and adjust volume
%           sample rate:                           44100            44100
%           limiter:                               off
%           advance:                               off


% USER IDs: e.g., 001eedinf20 002slimam21 
%           digits  code
%           1:3     speaker id
%           4       e = English, s = Spanish
%           5:8     dialect code (4 digits) {edin edmo esse canb lima mexi madr}
%           9       male/female
%           10:11   age (2 digits)

% INSTRUCTIONS:
%
%   PROMPT DISPLAY WINDOW:
%       spacebar:   stop recording
%   WAVEFORM WINDOW:
%       p:          play recording (only experimenter will hear this)
%       a:          accept recording
%       x:          reject recording
%       spacebar:   accept recording (reject if clipped or timed-out)
%       Q:          quit (a prompt for this option does not appear in the
%                   window, must be a capital Q)

close all
clear all
global goodrecording nextb button_id cont userid idget legal_langs II_legal_langs stopbtn append freeze_play replay quit_now RecAnswerParentDir RecAnswerDir NumAnswers NameAnswers lang_strings %I_monitors num_logical_monitors ao 


tic
% disp_lang=0;
RecAnswerParentDir='.\RecAnswers\';
prompt_audio_Dir='.\PromptSounds\';
instructions_Dir='.\Instructions\';

quit_now=0;

%default label to display on buttons
lang_strings={'e' '' '' '' 'Next' 'Play' 'Stop Playing' 'Stop'};


% set up windows
if ~isempty(dir('./InitiationFiles/WindowPositions_ini.mat'))
    dual_monitors = true;
    num_logical_monitors = 2;
    load('./InitiationFiles/WindowPositions_ini.mat', 'pos_window');
    fullscreenfigure(1);
    set(1, 'OuterPosition', pos_window(1,:), 'Name', 'AcousticRecording (Participant)', 'NumberTitle', 'off');
    fullscreenfigure(2);
    set(2, 'OuterPosition', pos_window(2,:), 'Name', 'AcousticRecording (Researcher)', 'NumberTitle', 'off');
else
    dual_monitors = false;
    num_logical_monitors = 1;
    fullscreenfigure(1);
    set(1, 'Name', 'AcousticRecording', 'NumberTitle', 'off');
end


% introduction screen
for I_monitors = 1:num_logical_monitors
    figure(I_monitors);
    
    text(.5,.9,'Acoustic Recording Software ','Fontsize',30, 'Units','normalized', 'HorizontalAlignment','center', 'VerticalAlignment','top');
    text(.5,.8,'for Speech Production Experiments','Fontsize',30, 'Units','normalized', 'HorizontalAlignment','center', 'VerticalAlignment','top');
    text(.5,.7,'Release 2008-12-23','Fontsize',12, 'Units','normalized', 'HorizontalAlignment','center', 'VerticalAlignment','top');
    text(0,.1,'© 2007, 2008 Geoffrey Stewart Morrison','Fontsize',12, 'Units','normalized', 'HorizontalAlignment','left', 'VerticalAlignment','top');
    axis off
    ApplicationChoiceGroup=uibuttongroup('Units','normalized',...
                            'Position',[.0 .0 .2 .125]);
    ApplicationExperiment(I_monitors)=uicontrol('Style','Radio',...
                            'String','Experiment',...
                            'Value',1,...
                            'Min',0,'Max',1,...
                            'Units','normalized',...
                            'Position',[.05 .7 .9 .2],...
                            'Parent',ApplicationChoiceGroup);
    ApplicationPlayback(I_monitors)=uicontrol('Style','Radio',...
                            'String','Sound Playback Test',...
                            'Value',0,...
                            'Min',0,'Max',1,...
                            'Units','normalized',...
                            'Position',[.05 .5 .9 .2],...
                            'Parent',ApplicationChoiceGroup);
    ApplicationCalibrate(I_monitors)=uicontrol('Style','Radio',...
                            'String','Soundcard Amplitude Calibration',...
                            'Value',0,...
                            'Min',0,'Max',1,...
                            'Units','normalized',...
                            'Position',[.05 .3 .9 .2],...
                            'Parent',ApplicationChoiceGroup);
    ApplicationMonitors(I_monitors)=uicontrol('Style','Radio',...
                            'String','Setup Dual Monitors',...
                            'Value',false,...
                            'Units','normalized',...
                            'Position',[.05 .1 .9 .2],...
                            'Parent',ApplicationChoiceGroup);

    nextb_ref=toc+.1; nextb=0; nextbutton(I_monitors) = button_next(lang_strings{5});
end
while nextb<=nextb_ref
    pause(0.1)
end
playsoundfile('./Instructions/Click.wav','async')

monitor_selected = gcf; % on which monitor was the next button pressed

run_playback = get(ApplicationPlayback(monitor_selected),'Value');
run_calibrate = get(ApplicationCalibrate(monitor_selected),'Value');
run_monitors = get(ApplicationMonitors(monitor_selected),'Value');
for I_monitors = 1:num_logical_monitors
    clf(I_monitors);
end

if run_playback
    sound_playback_test
elseif run_calibrate
    soundcard_amplitude_calibration
elseif run_monitors
    dual_monitor_setup
else
    % run experiment
    % load languages ini file
    fid=fopen('.\InitiationFiles\languages_ini.txt');
    languages_ini_lines=textscan(fid,'%s', 'delimiter','\n');
    fclose(fid);
    languages_ini_first_line=textscan(char(languages_ini_lines{1}(1)),'%s', 'delimiter','\t');
    legal_langs=languages_ini_first_line{1};
    num_legal_langs=length(legal_langs);
    scanstr=repmat('%s',1,num_legal_langs);
    fid=fopen('.\InitiationFiles\languages_ini.txt');
    languages_ini=textscan(fid,scanstr, 'delimiter','\t');
    fclose(fid);
    
    getuserid
    
    lang_strings=languages_ini{II_legal_langs};
    filelang=['_',lang_strings{1}];
    link_words=lang_strings(2:4);
    font_orthographic=lang_strings{9};
    font_size=str2num(lang_strings{10});
    margin_shift=str2num(lang_strings{11});
    font_IPA=lang_strings{12};
    switch lang_strings{13}, case 'L', left_to_right=true; case 'R', left_to_right=false; end

    
    look_for_default_soundcards
    buttons_radio %GUI for experiment options
  
    soundcard_setup
    SoundTest

    fsRec_tol=fsRec*.25; %silence stripper tolerance
    cutamp_tol=.05;

    instructions_start_time=now;
    if ~skipInstructions
        instructions;
    end

    set_up_screen


    % core stimuli
    stimuli=get_stimuli(['Prompts\stimuli_core',filelang,'.txt']);
    core_str='core\';
    NumProdRounds=num_rounds_core_stimulus_set;
    tic; start_time=now;
    recording_cycle
    
    % time information
    end_time=now;     elapsed_time=toc;    minutes_elapsed=floor(elapsed_time/60);    seconds_elapsed=rem(elapsed_time,60);
    fid_time=fopen([RecAnswerDir,'timing_info.txt'],'at');
        fprintf(fid_time,'\nSession start time: \t%s\n',datestr(instructions_start_time));
        fprintf(fid_time,'\nCore Prompts');
        fprintf(fid_time,'\nstart time: \t%s',datestr(start_time));
        fprintf(fid_time,'\nend time: \t%s',datestr(end_time));
        fprintf(fid_time,'\nduration: \t%02.0f:%02.f',minutes_elapsed,seconds_elapsed);
        fprintf(fid_time,'\nNumber of recordings at start: \t%03.0f',NumCountStart);
        fprintf(fid_time,'\nNumber of at end/quit (cumulative): \t%s\n',counterstr);
    fclose(fid_time);

    % extra stimuli
    if ~quit_now && num_rounds_extra_stimulus_set>0
        set(htext0,'String',SoundTestSentences{7}); %Please take a rest before the next round.
        nextb_ref=toc+.1;
        nextb=0;
        button_next(lang_strings{5});
        button_quit;
        while nextb<nextb_ref
            pause(.1)
        end
        delete(nextbutton, quitbutton);
        set(htext0,'String',[]);
        if ~quit_now
            stimuli=get_stimuli(['Prompts\stimuli_extra',filelang,'.txt']);
            core_str='extra\';
            NumProdRounds=num_rounds_extra_stimulus_set;
            tic; start_time=now;
            recording_cycle
        end
        % time information
        end_time=now;     elapsed_time=toc;    minutes_elapsed=floor(elapsed_time/60);    seconds_elapsed=rem(elapsed_time,60);
        fid_time=fopen([RecAnswerDir,'timing_info.txt'],'at');
            fprintf(fid_time,'\nExtra Prompts');
            fprintf(fid_time,'\nstart time: \t%s',datestr(start_time));
            fprintf(fid_time,'\nend time: \t%s',datestr(end_time));
            fprintf(fid_time,'\nduration: \t%02.0f:%02.f',minutes_elapsed,seconds_elapsed);
            fprintf(fid_time,'\nNumber of recordings at start: \t%03.0f',NumCountStart);
            fprintf(fid_time,'\nNumber of at end/quit (cumulative): \t%s\n',counterstr);
        fclose(fid_time);
    end

    for I_monitors = 1:num_logical_monitors
        clf(I_monitors);
    end

    if ~quit_now
        mes=[instructions_Dir,'end_message',filelang];
    else
        mes=[instructions_Dir,'quit_message',filelang];
    end
    message([mes,'.txt'],0,.9,14,[],[],lang_strings, [], num_logical_monitors);
end

close all
soundcard_cleanup