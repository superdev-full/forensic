function fig = fullscreenfigure(ifig, blockbar)

if nargin < 2 || isempty(blockbar)
    blockbar = false;
end

set(0,'Units','pixels');
pos = get(0,'ScreenSize');

% adjust value have been optimised for the screen settings on my computers
% maximise a figure execute get(gcf, 'OuterPosition') and use the second value as the adjust
if ~blockbar
    adjust = 27;
    pos([2,4])=[adjust, pos(4)-adjust];
end

if nargin == 0 || isempty(ifig)
    fig=figure;
else
	fig=figure(ifig);
    clf
end

if blockbar
    set(fig,'OuterPosition',pos,'Toolbar','none','Menubar','none','Toolbar','none','Resize','off');
else
    set(fig,'OuterPosition',pos,'Toolbar','none','Menubar','none','Toolbar','none');
end
