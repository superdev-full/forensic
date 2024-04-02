function h_button = button_playing(button_label, button_position, font_size)

global freeze_play

%dispstr=lang_strings{7}; % {'Stop Playing' 'Grabar' ...}
if nargin < 4 || isempty(font_size)
    font_size = 13;
end
if nargin < 3 || isempty(button_position)
    button_position = [.6 .05 .2 .1];
end
if nargin < 2 || isempty(button_label)
    button_label = 'Stop Playing';
end

h_button = uicontrol('Style','pushbutton', ...
      'Units','normalized', ...
      'Position',button_position, ...
      'FontSize',font_size, ...
      'ForegroundColor','r', ...
      'String',button_label);
    set(h_button,'Callback','global freeze_play; freeze_play=0;');
  
return