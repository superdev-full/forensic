% getuserid

% The function testuserid only appears in a callback. Manually add it to the compiler

figure(num_logical_monitors); % researcher window
axis off

clear tdir; NumAnswers=0; NameAnswers={};
if ~isdir(RecAnswerParentDir), mkdir(RecAnswerParentDir); end
tdir=dir(RecAnswerParentDir);
NumAnswers=length(tdir);
if NumAnswers > 0
    [NameAnswers{1:NumAnswers}]=deal(tdir.name);
    text(.1,.5,NameAnswers,'Fontsize',8);
end


if NumAnswers > 0
    text(.1,.5,NameAnswers,'Fontsize',8);
end

text(.5,.40, 'id should have the form:', 'Fontsize',14);
text(.55,.35, '001eedinf20, 002slimam21, etc.', 'Fontsize',12);


idmes = uicontrol('Style','text', ...
      'Units','normalized', ...
      'Position',[.4 .5 .2 .05], ...
      'FontSize',14, ...
      'String','Enter your id:');

idget = uicontrol('Style','edit', ...
      'Units','normalized', ...
      'Position',[.6 .5 .2 .05], ...
      'FontSize',14, ...
      'String','');
set(idget,'Callback','global userid idget legal_langs II_legal_langs RecAnswerParentDir RecAnswerDir NumAnswers NameAnswers; userid=get(idget,''String''); testuserid;');

uiwait;

clf(num_logical_monitors);

