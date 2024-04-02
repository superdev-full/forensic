%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/lagwin.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:lagwin.m 2002/11/6 19:5

function lw=lagwin(Fs,Beq,ntot,wtype,testing);
% lw=lw(Fs,Beq,ntot,wtype,testing);
% Y. Tohkura, F. Itakura and S. Hashimoto. Spectral smoothing
% technique in PARCOR Speech Analysis-Synthesis IEEE ASSP 26 1978 pp 587-596
%tnargin=nargin;
tnargin=nargin;
if tnargin==0, Fs=8000, Bs=80; Beq=Bs/sqrt(2/3), ntot=20, wtype='TRI', testing=1; tnargin=5; end
%if tnargin==0, Fs=8000, Bs=80; Beq=Bs*sqrt(2*log(2)), ntot=20, wtype='GAU', testing=1; tnargin=5; end

%Beq, Bs,F0=Bs/2, Fs
%pause
if tnargin<5|isempty(testing),testing=0; end
if tnargin<4|isempty(wtype),wtype='TRI'; end
wtype=upper(wtype);
if ~strcmp(wtype,'TRI') & ~strcmp(wtype,'GAU')
	warning('Only TRI and GAU wtype allowed: TRI being used');
	wtype='TRI';
end
% Y. Tohkura, F. Itakura and S. Hashimoto. Spectral smoothing
% technique in PARCOR Speech Analysis-Synthesis IEEE ASSP 26 1978 pp 587-596
nlagw=ntot; % length of lagwin including zero lag
tau=1/Fs;
	% Gaussian
t=[0:nlagw-1]'*tau;

if strcmp(wtype,'GAU')
	Bs=1/sqrt(2*log(2)) * Beq;
	omega=2*pi*Bs/2;
	lw=exp(-(omega*t).^2/2);
	if testing
		thetat=omega*t
		lwt=1-thetat.^2/2+1/8*thetat.^4;
	end
end

if strcmp(wtype,'TRI')

	Bs=sqrt(2/3)*Beq;
	omega=2*pi*Bs/2;
	sq=sqrt(3/2);
	lw=zeros(nlagw,1);
	lw(1)=1;
	kernal=sq*omega*t(2:end);

	lw(2:end)=(sin(kernal)./kernal).^2;
	if testing
		thetat=omega*t
		lwt=1-thetat.^2/2+1/10*thetat.^4;
	end

end

if testing

	nfft=512;
	fax=linspace(0,Fs,nfft)';
	nfold=nfft/2+1;
	npltft=min(find(fax>5*Beq));
	figure(37); clf
	subplot(2,1,1);
	plot(t,lw)
	dbs=20*log10(abs(fft(lw,nfft)));
	dbs=dbs-dbs(1); % normalize
	subplot(2,1,2);
	plot(fax(1:npltft),dbs(1:npltft)); hold on
	[jnk,ieq]=min(abs(fax-Beq/2))
	[jnk,is]=min(abs(fax-Bs/2))
	[jnk,ibt]=min(abs(dbs(1:npltft)+3))
	abs(dbs(1:npltft)+3)
	Bwt=2*fax(ibt);
	xx=[fax(1),fax(npltft)]; yy(1)=-3; yy(2)=yy(1);
	plot(xx,yy,'r');
	tstr=['DbDown Beq/2, Bs/2 , Bw/2 3Db', num2str([dbs(ieq),dbs(is),Bwt])];
	title(tstr);
	[x,y]=ginput;
	[x,y-dbs(1)]
	Beq
	Bs
	F0=Bs/2
	Fs
	tau
end
if testing
 [lw,lwt]
%Tohkura's table Very close here
% Series tests
delT=1/8000
f0=40
i=(0:8)'
omeg0tau=2*pi*f0*delT*i
theta=omeg0tau
tri=1-theta.^2/2+1/10*theta.^4;
gau=1-theta.^2/2+1/8*theta.^4;
[i,tri,gau,lwt(1:9),lw(1:9)]

thetastuff=[theta, thetat(1:9)]
end
