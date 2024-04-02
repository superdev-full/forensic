function h_button = button_next(button_label, button_position, font_size)

if nargin < 4 || isempty(font_size)
    font_size = 13;
end
if nargin < 3 || isempty(button_position)
    button_position = [.6 .05 .2 .1];
end
if nargin < 2 || isempty(button_label)
    button_label = 'Quit';
end

h_button = uicontrol('Style','pushbutton', ...
      'Units','normalized', ...
      'Position',button_position, ...
      'FontSize',font_size, ...
      'String',button_label);
    set(h_button,'Callback','global nextb quit_now; nextb=toc; quit_now=true;')
  
return



% quitbutton = uicontrol('Style','pushbutton', ...
%       'Units','normalized', ...
%       'Position',[.85 .05 .1 .1], ...
%       'FontSize',13, ...
%       'String','Quit');
%     set(quitbutton,'Callback','global nextb quit_now; nextb=toc; quit_now=true;')
  
