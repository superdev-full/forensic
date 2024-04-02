%  Saved from C:\Documents and Settings\Terrance M Nearey\Desktop\ronsdissertationdata\Matlab Acoustic Analysis\SoundMeasurer\highlightax.m 2006/10/12 15:18

function highlightax(ax,direction)
if nargin<2|isempty(direction)
     direction=1;
end
if direction==1
     set(ax,'xcolor','r','ycolor','r','LineWidth',4)
elseif direction==2|direction==-1
      set(ax,'xcolor','k','ycolor','k','LineWidth',.5)
else
     warning('Invalid direction  argument')
end


