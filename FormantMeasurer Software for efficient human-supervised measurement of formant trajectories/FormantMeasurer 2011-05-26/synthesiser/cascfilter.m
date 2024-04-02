%  Saved from C:\NeareyMLTools\SiganDevel\cascfilter.m 2006/10/12 15:18

function y=cascfilter(fs,x,t,ff,fbw,pole,deltms,fuji)
%function y=cascfilter(fs,x,t,ff,[fbw,[pole,[deltms]]])
% use varfilter fuji to filter the input source x.
% fs sampling frequency Hz
% x input source (in samples)
% t time knots for all formants (ntime x 1)
% ff  should be ntime x nformant
% bw if not empty sould be same shape as ff
% if empty or missing set to max(60,6% of formant frequency);
% pole should be nformant x 1 vector
%     one for pole, zero for zero
%     default, all ones
%  deltms is frame rate in ms to which t is interpolated before call to varfilterfuji
% default is 1 ms
% version 1.1 Fuji arg added... default 1 (use varfilter if 0 varfilterfuji if 1)
% version 1.2 order of formant filtering reversed to reduce transients
%  Copyright T.M. Nearey 1999-2002


if nargin==0
	testcascfilter
	return
end
if nargin<8|isempty(fuji)
	fuji=1;
end
if nargin<7|isempty(deltms)|deltms<=0
	deltms=1;
end

[ntime,nft]=size(ff);
if nargin<6|isempty(pole)
	pole=ones(nft,1);
else
	pole=pole(:);
end
if nargin<5|isempty(fbw)
	fbw=max(.06*ff,60);
end
y=x;

t=t-t(1);% Starting time irrelevant
% add on one extra point, then delete it later
% do at least as frequently as called for
nframe=ceil(t(end)/deltms)+1;
tstartms=round(linspace(t(1),t(end),nframe))';

tstartsam=ms2samp(tstartms,fs);
tendsam=[tstartsam(2:end)-1;tstartsam(end)+ceil(deltms/1000*fs)];

% [tstartsam,tendsam]
% pause

% interpolate the targets at the ms points
x=x(:);
nx=length(x);
if nx<tendsam(end)
	x=[x; zeros(tendsam(end)-nx,1)];
end
y=x;

%[tstartsam,tendsam]
% keyboard
for i=nft:-1:1
	f=interp1(t,ff(:,i),tstartms);
	%
	% 	plot(tstartms,f,'-x')
	% 	hold on;
	fb=interp1(t,fbw(:,i),tstartms);
	tpole=pole(i);
  %%%%%%%%%%%%%%%%%%%%%%
  if 0

  mean(f),std(f)
  mean(fb),std(fb)
    keyboard
  end
  %%%%%%%%%%%
	if fuji
		y=varfilterfuji(y,tstartsam,tendsam,fs,f,fb,tpole);
	else
		y=varfilter(y,tstartsam,tendsam,fs,f,fb,tpole);
		%function y=varfilter(x,tstart,tend,Fs,f,fb,pole,gain,dbg);
    end

end
% GSM delete the extra point
y = y(1:tstartsam(end));


function testcascfilter
close all
fs=11025;
t=[0 75 100 150 220 300]'
ff=[470 800 2200 3500 4500
470 800 2200 3500 4500
250 2000 2500 3500 4500
470 800 2200 3500 4500
470 800 2200 3500 4500
500 1300 1600 3000 4500];
fbw=[];
pole=[];
deltms=5;
dofuji=1
f0= [100, 125, 125, 125, 125 80]';
source=qdvoicesource(fs,t,f0);
y=cascfilter(fs,source,t,ff,fbw,pole,deltms,dofuji);
soundsc(y,fs)
figure
qdsgm(y,fs);
figure
subplot(2,1,1)
plot(y)
subplot(2,1,2)
title(' input 2 points')
[xx,yy]=ginput(2)
while length(xx)==2
	xx=round(sort(xx));
	if xx(1)<1, xx(1)=1; end
	if xx(2)>length(y), xx(2)=length(y); end
	subplot(2,1,2)
	plot([xx(1):xx(2)]',y(xx(1):xx(2)));
	[xx,yy]=ginput(2)

end
