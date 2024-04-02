%function button_stop

%stopbtn nextb must be global

dispstr=lang_strings{6}; % {'Play' 'Escuchar' ...}

bnfp = uicontrol('Style','pushbutton', ...
      'Units','normalized', ...
      'Position',[.6 .05 .2 .1], ...
      'FontSize',13, ...
      'String',dispstr); %used to say "stop"
  set(bnfp,'Callback','global freeze_play; freeze_play=1; %clear freeze_play');
  
%return