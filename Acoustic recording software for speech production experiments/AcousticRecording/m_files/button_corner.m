%function button_next

%closes current figure

cornerbutton = uicontrol('Style','pushbutton', ...
      'Units','normalized', ...
      'Position',[.875 .00 .125 .05], ...
      'FontSize',12, ...
      'String','>');
    set(cornerbutton,'Callback','global goodrecording; goodrecording=0; uiresume; %clear goodrecording')
  
%return