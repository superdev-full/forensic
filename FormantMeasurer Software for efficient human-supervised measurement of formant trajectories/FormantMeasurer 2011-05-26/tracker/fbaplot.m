%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/fbaplot.m 2004/6/2 14:20

function fbaplot(t,nc,f,b,a,fcutoff,style,tcol)
%fbaplot(t,nc,f,b,a,fcutoff,style,<tcolor>)
% Version 2.0 nt calculated 1 June 97
%function fbaplot(t,nc,f,b,a,fcutoff,style)
% assumes dB and Hz and that 0dB and 500 Hz are smallest/biggest
% portrayable amps/bws
% styles are 'tri' or 'num'
%warning('fbaplot')
% Modified to allow empty amplitudes
if nargin<7|isempty(style)
	style='TRI';
end

if nargin<8
	if strcmp(upper(style),'TRI')
		tcol='b';
	else
		tcol='k';
	end
end

nt=length(t);
if size(nc)==[1 1]
	nc=repmat(nc,nt,1);
end
% triangle style used for now
frange=1.05*fcutoff;
trange=t(nt)-t(1);
delt=trange/nt;
if isempty(a)
	a=zeros(size(f));
	amax=1;
else
	amax=max(max(a));
end

if amax==0
	amax=1; % in case no amp is given
end

bmax=max(max(b));
if bmax>500
	bmax=500;
end
afac=delt;
bfac=1;
%fcutoff
%[t(1),t(nt)+5,0,1.05*fcutoff]
axis([t(1),t(nt)+5,0,1.05*fcutoff]);
hold on
tri=0;
num=0;
if length(style)>=3
	if upper(style(1:3))=='TRI'
		tri=1;
	end
	if upper(style(1:3))=='NUM'
		num=1;
	end
end;
for i=1:nt
	for j=1:nc(i);
		%i,j,t(i),f(i,j),b(i,j),a(i,j)
		if tri
			bt=min(fcutoff/10,b(i,j));
			at=max(a(i,j),0);
			x(1)=t(i);
			y(1)=f(i,j)+bt/2;
			x(2)=t(i)+at/amax*afac;
			y(2)=f(i,j);
			x(3)=t(i);
			y(3)=f(i,j)-bt/2;
			x(4)=x(1);
			y(4)=y(1);
			if b(i,j)>fcutoff/10,
				st=':';
			else
				st='-';
			end
			plot(x,y,st,'Color',tcol);
		elseif num
			text(t(i),f(i,j),num2str(j),'Color',tcol)
		else
			text(t(i),f(i,j),style(1))
		end% if

	end;
end;
%drawnow;
