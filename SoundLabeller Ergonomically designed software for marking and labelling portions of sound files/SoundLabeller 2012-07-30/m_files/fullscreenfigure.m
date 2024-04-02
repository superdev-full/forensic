%fullscreenfigure
function fig=fullscreenfigure(ifig, inc_toolbar, block_bottom_bar)

if nargin <3
    block_bottom_bar=false;
end
if nargin <2 || isempty(inc_toolbar)
    inc_toolbar=false;
end
if nargin==0 || isempty(ifig)
    fig=figure;
else
	fig=figure(ifig);
    clf
end

set(0,'Units','pixels');
pos=get(0,'ScreenSize');
if pos(2)<0
    pos=[1 255 1024 768]; % works for TABLET LANDSCAPE
else
    if block_bottom_bar
        adjust = 24;
    else
        adjust = 36;
    end
    if inc_toolbar
        pos([2,4])=[adjust,pos(4)-adjust*3];
    else
        pos([2,4])=[adjust,pos(4)-adjust*1.5];
    end
end


if inc_toolbar
    inc_tool = 'figure';
else
    inc_tool = 'none';
end

if block_bottom_bar
    set(fig,'Toolbar',inc_tool,'Menubar',inc_tool,'Position',pos,'Resize','off');
else
    set(fig,'Toolbar',inc_tool,'Menubar',inc_tool,'Position',pos);
end
