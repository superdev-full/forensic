%function button_stop

%stopbtn nextb must be global

dispstr=lang_strings{8}; % {'Stop' 'Parar' ...}


bnst = uicontrol('Style','pushbutton', ...
      'Units','normalized', ...
      'Position',[.2 .05 .2 .1], ...
      'FontSize',13, ...
      'String',dispstr); %used to say "stop"
  set(bnst,'Callback','global stopbtn; stopbtn=1; %clear stopbtn');
  
%return