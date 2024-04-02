%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/pausemsg.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:filetools:pausemsg.m 2002/11/6 19:5

function pausemsg(msg,varargin)
% function pausemsg(msg,varargin)
% function to do menu based pause which we hope viewers can see
% the reserved special messages in msg
% PAUSE ON, PAUSE OFF , {PAUSE ON DEBUG}, DEBUG
% set the PERSISTENT LOCAL pause flag
%'pause on' (case insensitive)
%'pause off'
% varargin.. variable numbers of.strings or scalars to add to menu -- a debugging tool
% if empty, a single OK button is  added
% copyright (c) 2001 TM Nearey
% in  Nearey's tnguitools
if nargin<2
	varargin={};
end
if nargin<1
	msg='OK';
end
persistent shouldpausemsg allowabort

if isempty(shouldpausemsg)
	shouldpausemsg=1;
end
chkmsg=deblank(upper(msg));
switch chkmsg
case 'PAUSE ON'
	shouldpausemsg=1;
 	msg='Pause is now on';
	allowabort=0;
case 'PAUSE OFF'
	shouldpausemsg=0;
	allowabort=0;
case {'PAUSE ON DEBUG', 'DEBUG'}
	msg='Pause is now on -- and abort allowed for traceback';
	shouldpausemessage=1
	allowabort=1;
end

if ~shouldpausemsg
	return
end
chkmsg=deblank(upper(msg));
switch chkmsg
case 'PAUSE ON'
	shouldpausemsg=1;
 	msg='Pause is now on';
case 'PAUSE OFF'
	shouldpausemsg=0;
	return
end
ttl='PAUSE MSG: Click a button to continue';
tcell{1}=msg;
for i=1:length(varargin)
	t=varargin{i}
	if ~isempty(t)
		switch class(t)
		case 'char'
			if size(t,1)>1,
				t=t(1,:), t=[t,'<line 1 of arg ', num2str(i+1)]

			end
		case 'double'
			tp=prod(size(t))>1;
			t=t(1);
			t=num2str(t);
			if tp
				[t,' <el 1 of arg ', num2str(i+1)]

			end
		otherwise
			disp UNKNOWN_ARGTYPE_IN_PAUSEMSG
			t
			typet=class(t)
			t='????'
		end
		tcell{i+1}=t;
	end
end
if allowabort,
	tcell{end+1}='QUIT NOW';
end
jnk=menu(ttl,tcell);
if allowabort & jnk==length(tcell)
	error('Traceback called by user')
end
