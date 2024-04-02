%  Saved from C:\NeareyMLTools\SiganDevel\qdvoicesource.m 2006/10/12 15:18

function [g,BWSource]= qdvoicesource(Fs,tf0, f0, ta0,a0db,BWSourceIn,testme)
%function g = qdvoicesource(Fs,tf0, f0, [[ta0],a0db])
% tf0- time in ms for f0 knots
% f0- f0 knots Hz
% Fs - sampling rate Hz
% ta0 time knots for amplitude of f0
% a0db - overall amplitude knots in dB translated to pulse height (10^(dB/20))
% A modified version of Kiefte's thesis Klatt80 source
% Modifications... higher sample rate, downsampled (a la klatt88)
% Variable F0. Use peakpicking on fm sinewave
% backwards IIR sampling to give more glottal like waveshape
% pads begining by 1/f0(1) sec and trims that off the end...
%
% Uses F0 average for the filter to determine the glottal shaping parameter
% Also... differentiates
% ta0 and a0db are optional arguments for an amplitude contour
% It is interpolated linearly to samples and applied to pulse train.
% it may have a different time line than
% The shorter one on either end is extended before interpolations
% INPUT
% Fs -sampling rate
% tf0 [ntf0 x 1] times  (ms) at which f0 is specified
% f0  pntf0 x 1] frequencies Hz of f0
% ta0 [nta0 x 1] times at which a0db is specified
% a0db [nta0 x 1] amplitude of source in db
% BwSourceIn - bandwidth of pole at origin to produce -6 db/Oct tilt if
%       missing specified as Poq=.5;% average OQ of 50% of F0 proportionate Opening Quotient
%       BWSource=10000*F0AV/(Fs_upsample*Poq) ; where Fs_upsample is upsampled sampling rate
%       returned as BwSourceOut
%
% Version 1.1  bad initial F0
testedOnce=0;
if nargin==0
	testqdvoicesource
	return
else
	error(nargchk(3, 5, nargin))
end
if nargin<7|isempty(testme)
	testme=0;
end
if nargin<6
    BwSourceIn=[];
end
tf0=tf0(:);
f0=f0(:);
if nargin<4
	ta0=tf0;
	a0db=ones(size(ta0));
end
if nargin==4  % shift over
	a0db=ta0(:);
	ta0=tf0;
end
if nargin==5 & isempty(ta0)
	a0db=a0db(:);
	ta0=tf0;
end
a0db=a0db(:);
ta0=ta0(:);


if length(a0db)~=length(ta0)
	error(' a0db does not match number of time knots in ta0 (or tf0)')
end

% Copy on values if one time axis is longer than another
tmin=min(min(ta0),min(tf0));

if tmin<min(ta0);
	ta0=[tmin;ta0];
	a0db=[a0db(1);a0db];
end
if tmin<min(tf0);
	tf0=[tmin;tf0];
	f0=[f0(1);f0];
end
tmax=max(max(ta0),max(tf0));
if tmax>max(ta0);
	ta0=[ta0;tmax];
	a0db=[a0db;a0db(end)];
end
if tmax>max(tf0);
	tf0=[tf0;tmax];
	f0=[f0;f0(end)];
end
nframe=length(tf0);
% Upsample FS by integer least 40 Khz.
nupsam=ceil(40000/Fs);

Fs_upsample=nupsam*Fs;
tau=1/Fs_upsample;

dursec=(tmax-tmin)/1000;
tt=[0:tau:dursec]';
ft=interp1((tf0-tmin)/1000,f0(:),tt);
at=interp1((ta0-tmin)/1000,a0db(:),tt);
% NB Dbized here.
at=10.^(at./20);
f0Base=f0(1);
% avoid bad initial f0;
if isempty(f0Base)|isnan(f0Base)
    f0Base=100;
end
if f0Base==0
    npad=0;
else
npad=round(1/f0Base*Fs_upsample);
end
g=cos(2*pi*tau*cumsum(ft));
g=[zeros(npad,1);g];
at=[zeros(npad,1);at];
if testme
	figure
	plot(tt*1000,ft);
	title('f0 interpolated')
	drawnow
	pause
	figure
	plot(g)
	title('freqmodsinusoid')
	soundsc(g,Fs_upsample)
	pause
end

g(2:end-1)=g(1:end-2)<g(2:end-1)&g(3:end)<=g(2:end-1);
g(1)=0;
g=g-mean(g);
g(end)=0;
% size(g)
% size(at)
g=g.*at; % modulate by amplitude
g=diff([g;0]);



if testme
	figure
	plot(g)
	soundsc(g,Fs_upsample);
	title('Pulse train')
	pause
end


F0AV=mean(f0);
% Fs_upsample
% F0AV
tstart=1;
tend=length(g); % sample points
% y=varfilterfuji( x,     tstart,tend,Fs,f,   fb,     pole,gain,dbg);

g=flipud(g);
if nargin<6|isempty(BWSourceIn)
%%% Check against Klatt MS
Poq=.5;% average OQ of 50% of F0 proportionate Opening Quotient
BWSource=10000*F0AV/(Fs_upsample*Poq) ;
else
    BWSource=BwSourceIn;
end

g=-varfilterfuji(g,tstart,tend,Fs_upsample,0,BWSource,1);

% adjust gain % Gives near constant gain near 300 Hz regardless of OQ

g=g*(1.0+(.00833)*Fs_upsample/F0AV*Poq).^2;

 if testme
	 figure
	 plot(g)
	 title(' after filter, before downsample')
	 soundsc(g,Fs_upsample)
	 pause
 end

g=flipud(g);
g((end-npad+1):end)=[];
% hi freq should be pretty weak...just moving average rect window and downsample;
b=1/nupsam*ones(1,nupsam);
g=filter(b,1.0,g);
g=g(1:nupsam:length(g));
if any(isnan(g))


	[ta0,a0db]
	[tf0,f0]
	figure
	plot(tt,at)
	title('tt,at')
	figure
	plot(tt,ft)
	title('tt,ft')
	more off
	if ~testedOnce
		qdvoicesource(Fs,tf0, f0, ta0,a0db,1)
		testedOnce=1;
	end

end
return

function testqdvoicesource
t=[0,50,200,250]
f0=[100,125,200,120];
Fs=11025;
ta0=[25 100 150 300];
a0db=[-60 50 80 10];
%

g = qdvoicesource(Fs,t, f0,ta0,a0db);
figure;
plotsig([],g,Fs);

soundsc(g,Fs)

figure
p=20*log10(abs(fft(g)));
nspec=floor(length(p)/2+1);
fax=linspace(0,Fs/2,nspec)';
minp=min(find(fax>50));
p((nspec+1):end)=[];
p(1:(minp-1))=[];
fax(1:(minp-1))=[];
fax=log(fax)/log(2);
plot(fax,p);
xlabel('Octaves above 50 Hz')
ylabel('dB')
grid on;
xx=fax(1); yy=p(1);
xxl=xx; yyl=yy;
while 1
	[xx,yy]=ginput(1);
	if isempty(xx)
		break
	end
	dbPerOct=(yyl-yy)/(xxl-xx);
	xxl=xx; yyl=yy;
	title([ ' Db/Oct = ' num2str(dbPerOct)]);
end

pausemsg
qdsgm(g,Fs)
colorbar
return
