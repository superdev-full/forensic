function message(texttodisplay, x, y, fntsize, audiofile, syn, lang_str, picfile, num_logical_monitors)
% 'texttodisplay' can either be a character array to be displayed,
%   a cell array of strings to be displayed, 
%   or a character array containing the path and filname of a text file with extension '.txt'

global nextb

% default inputs
if nargin==0
    texttodisplay='Press "Next" to continue';
end
if nargin<3
    x=-.05; y=.9;
end
if nargin<4
    fntsize=12;
end
if nargin<5
    audiofile=[];
end
if nargin<6
    syn='sync';
end
if nargin < 7 || isempty(lang_str)
    lang_str={'e' '' '' '' 'Next'};
end
if nargin < 8 || isempty(picfile)
    display_pic = false;
else
    display_pic = true;
end
if nargin < 9 || isempty(num_logical_monitors)
    num_logical_monitors = 1;
end


% read in text file
if ~iscell(texttodisplay) && strcmp(texttodisplay(end-3:end),'.txt')
    texttodisplay_file=texttodisplay;   clear texttodisplay;
    fid=fopen(texttodisplay_file,'r');
    texttodisplay=textscan(fid,'%s','delimiter','\n','whitespace','');
    fclose(fid);
end
% convert cell array of strings to character array
if iscell(texttodisplay)
    texttodisplay=char(texttodisplay{:});
end


for I_monitors = num_logical_monitors: -1 : 1 %counting backwards so that buttons will only go on the participant window
    % display text
    figure(I_monitors);

    text(x,y,texttodisplay,'Fontsize',fntsize, 'Units','normalized', 'HorizontalAlignment','left', 'VerticalAlignment','top');
    axis off

    % display picture
    if display_pic
        axes('Position',[.05 .05 .5 .5]);
        pic=imread(['.\graphics\',picfile]);
        hpic=image(pic);
        set(gca,'xtick',[],'ytick',[]);
    end
end
% play audio
if ~isempty(audiofile)
    pause(1);
    playsoundfile(audiofile,syn);
end

% Wait for button click
%   The computer buffers mouseclicks before the button is displayed, 
%   the following makes sure that any such clicks are ignored
nextb_ref=toc+.1;
nextb=0;
button_next(lang_str{5});

while nextb<=nextb_ref
    pause(0.1)
    %uiwait;
end
playsoundfile('./Instructions/Click.wav','async')
for I_monitors = 1:num_logical_monitors
    clf(I_monitors);
end

return