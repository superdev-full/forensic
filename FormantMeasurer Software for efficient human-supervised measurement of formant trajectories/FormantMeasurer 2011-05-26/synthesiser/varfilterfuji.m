%  Saved from C:\NeareyMLTools\SiganDevel\varfilterfuji.m 2006/10/12 15:18

function y=varfilterfuji(x,tstart,tend,Fs,f,fb,pole,gain,dbg);
%function y=varfilterfuji(x,tstart,tend,Fs,f,fb,pole,gain,dbg);
% variable filter with Fujisaki and Azami memory correction
% at frame boudaries
% tstart sample starting each frame
% tend sample ending each frame
% f frequency column vector
% fb bandwidth
% gain- replace b(1) with specified value for  Klatt's % AGP=.007 in COEWAVE
% should ordinarily be empty or missing....
% REPAIR gain kludge added to last frame 20 Feb 2000
% Copyright 1999 2000 2001T.M. Nearey
%
if nargin<8, gain=[]; end
if nargin <9  | isempty(dbg)
	dbg=0;
end
if dbg
	sizef=size(f)
	sizefb=size(fb)
	figure(38); clf; plot([f,f+fb,f-fb])
	title(' F and BW in Varfilter')
	pause
end
%
% switch for pole or zero
n=length(x);
y=zeros(n,1);
nframe=size(tstart,1);
if length(Fs)==1
	Fs=repmat(Fs,nframe,1);
end
zFj=[0,0]; % initial conditions
if tend(end)<n,
	tend(end)=n;
end;
istart=tstart(1);
ft=f(1); bt=fb(1);
bprev=1;
%%%%%%%
if dbg %debug
	tstart1end=[tstart(1),tstart(end)]
	tend1end=[tend(1),tend(end)]
	figure(37); clf
	subplot(2,1,1);
	plot(x)
	title('X in varfilter')
	delfrms=find(diff(f)~=0|diff(fb)~=0)
	pause
end
anysyn=0;
for i=2:nframe;
	if f(i)==f(i-1)&fb(i)==fb(i-1)&Fs(i)==Fs(i-1)
		iend=tend(i); %extend the end of the 'fixed resonance' synthesis frame
	else
		iend=tend(i-1); % we've gone too far so synthesize
		%XSft,bt
		[b,a]=bafilt(Fs(i),ft,bt,pole);
		% Kludge for Klatt's fixed 32 for RGP
		if ~isempty(gain), b(1)=gain; end
		%a,b
		irng=[istart:iend];
		NONFINALstartEnd=[istart,iend];
		if  dbg
			ft,bt,pole,a,b
			NONFINALstartEnd=[istart,iend];
			pause
		end
		% The Fuji fix fujisaki Azami filter discontinuity adjust
		% this could go out of range in pathological cases LET IT
			% Pathological case... asking for change of parameters  after less
			% than two samples are processed
		if anysyn %
			fac=sqrt(b/bprev);
			idl=[istart-1,istart-2];
			yprev=y(idl)*fac;
			xprev=x(idl)*fac;%?
			% matlab uses direct form 2 structure .. see if we can fake same results
			zFj=filtic(b,a,yprev,xprev);
		end % if anysyn
		[y(irng),zFj]=filter(b,a,x(irng),zFj);
		bprev=b; % update for next time
		anysyn=1;
		istart=tstart(i); % update the starting frame
		ft=f(i);
		bt=fb(i);
	end
end
iend=tend(end);


[b,a]=bafilt(Fs(end),ft,bt,pole);
if ~isempty(gain), b(1)=gain; end
irng=[istart:iend];
if  dbg
	disp LastFilter
	n
	NONFINALstartEnd
	Fsend=Fs(end)
	ft,bt,pole,b,a
	anyfchange=any(diff(f))
	anybchange=any(diff(fb))
	anyFsChange=any(diff(Fs))
	sizex=size(x)
	sizey=size(y)
	startEnd=[istart,iend]

end
if anysyn % fujisaki Azami filter discontinuity adjust
	% 		% Calculate zFj from previous modified inputs and outputs
	fac=sqrt(b/bprev);
	idl=[istart-1,istart-2];
	yprev=y(idl)*fac;
	xprev=x(idl)*fac;%?
	% matlab uses direct form 2 structure .. see if we can fake same results
	zFj=filtic(b,a,yprev,xprev);
end
[y(irng),zFj]=filter(b,a,x(irng),zFj);

if dbg
	subplot(2,1,2)
	plot(y)
	title('Y in varfilter')
	pause
end
