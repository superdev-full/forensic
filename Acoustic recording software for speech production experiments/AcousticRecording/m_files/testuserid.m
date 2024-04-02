%testuserid

% USER IDs: e.g., 001eedinf20 002slimam21 
%           digits  code
%           1:3     speaker id
%           4       e = English, s = Spanish
%           5:8     dialect code (4 digits) {edin edmo esse canb lima mexi madr}
%           9       male/female
%           10:11   age (2 digits)

% get legal languages
% num_legal_langs=length(languages_ini);
% legal_langs=cell(num_legal_langs,1);
% for I_legal_langs=1:num_legal_langs
%     legal_langs(I_legal_langs)=(languages_ini{I_legal_langs}(1,1));
% end
II_legal_langs=strcmp(userid(4),legal_langs);

% test userid
if ~isempty(userid) && length(userid)==11 && fix(str2num(userid(1:3)))==str2num(userid(1:3)) && fix(str2num(userid(10:11)))==str2num(userid(10:11)) && (logical(sum(II_legal_langs))) && (userid(9)=='f' || userid(9)=='m') 
    RecAnswerDir=[RecAnswerParentDir,userid,'\'];
  
    if NumAnswers > 0 && ~isempty(strmatch(userid,NameAnswers))
        pos_monitor_selected = get(gcf, 'OuterPosition');
        fullscreenfigure(3);
        axis off
        set(3, 'OuterPosition', pos_monitor_selected, 'Name', 'AcousticRecording', 'NumberTitle', 'off');
        texttodisplay=['The id "', userid, '" is already taken'];
        text(.35,.5,texttodisplay,'Fontsize',14);
        button_overwrite;
        button_differentid;
        button_append;
        uiwait;
        playsoundfile('./Instructions/Click.wav','async')
        switch append
            case -1 % overwrite
                delete([RecAnswerDir,'core\*.*']); 
                delete([RecAnswerDir,'extra\*.*']); 
                delete([RecAnswerDir,'practice\*.*']);
                close(3);
                uiresume;
            case 0 % choose different id
                close(3);
            case 1 % append
                delete([RecAnswerDir,'practice\*.*']);
                close(3);
                uiresume;
        end
    else
        mkdir(RecAnswerDir);
        mkdir([RecAnswerDir,'practice\']);
        mkdir([RecAnswerDir,'core\']);
        mkdir([RecAnswerDir,'extra\']);
        uiresume;
    end
end
