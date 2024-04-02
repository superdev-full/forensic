%  Saved from /Users/nearey/NeareyMLTools/filetools/fig.m 2004/6/2 14:20

function fig(argstr);
% activate a figure
if nargin==0|isempty(argstr)
	figure(gcf)
	drawnow
elseif ischar(argstr)
	eval(['figure(',argstr,')']);
	drawnow
else
	figure(argstr)
	drawnow
end
