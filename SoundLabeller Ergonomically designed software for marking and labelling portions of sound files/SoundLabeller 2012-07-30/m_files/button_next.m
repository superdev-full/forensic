%button_next

nextb_ref=toc+.1; nextb=0; 
nextbutton = uicontrol('Style','pushbutton', ...
      'Units','normalized', ...
      'Position',[.7 .05 .2 .1], ...
      'FontSize',14, ...
      'String','Next');
    set(nextbutton,'Callback','global nextb; nextb=toc; uiresume; %clear nextb')
  
