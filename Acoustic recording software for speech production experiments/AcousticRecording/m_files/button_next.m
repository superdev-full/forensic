function h_button = button_next(button_label, button_position, font_size)

global nextb

%dispstr=lang_strings{5}; % {'Next' 'Siguiente' ...}
if nargin < 3 || isempty(font_size)
    font_size = 13;
end
if nargin < 2 || isempty(button_position)
    button_position = [.6 .05 .2 .1];
end
if nargin < 1 || isempty(button_label)
    button_label = 'Next';
end

h_button = uicontrol('Style','pushbutton', ...
      'Units','normalized', ...
      'Position',button_position, ...
      'FontSize',font_size, ...
      'String',button_label);
    set(h_button,'Callback','global nextb; nextb=toc; uiresume;')
  
return