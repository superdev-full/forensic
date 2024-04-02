%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/tsfftsgm.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:tsfftsgm.m 2002/11/6 19:5

function [X2,tax,fax,nfft]=tsfftsgm(t1,t2,x,Fs,win,dt,df,premph,fast,rowistime,wantcomplex);
%function [X2,tax,fax,nfft]=tsfftsgm(t1,t2,x,Fs,win,dt,df,premph,fast,rowistime,wantcomplex);
%                                     1  2 3  4  5   6  7   8     9     10        11
% 30 Dec 1998 Copyright T. Nearey.
% T)ime S)election FFT (all times in ms)
% Returns magsq (power) spectrum (by default)
% t1,t2 first and last times see below
% x- signal vector
% Fs- sample rate, Hz
% win-window vector
% dt - hop duration
% df - frequency resolution (desired spacing of FFT bins);
% if empty or 0,then set on basis of window length (nextpower of two)
% premph filter by 1+premph*z^-1; default 0
% fast Use toolbox FFT spectrogram default =1 (this argument is now ignored.. try/catch used instead
% rowistime (see below)
% wantcomplex - default 0, if 1 X2 is complex (unfolded spectrum)
% Centers first window on t1 (pads left with zero if necessary)
% Centers last window on earliest hop >=t2 (pads right if necessary)
% Set t1, t2 to 0 Inf or [], [], for whole signal.
% By default returns FREQ as the rows and TIME as cols to be consistent with specgram
% and Slaney aud toolbox
% Rowistime tilts this
nx=length(x);
if ischar(win),error('win must be a numeric vector'); end
if isempty(t1), t1=0; t1=0;end
if isempty(df)|df==0, dfgiven=0; else dfgiven=1; end
if isempty(t2)|t2<=0|t2==inf, t2=ceil(nx/Fs*1000); end
if nargin<11, wantcomplex=0; end
if nargin<9|isempty(fast) fast=1; end
if exist('specgram')==0, fast=0; end % see if toolbox is avaialble
if nargin<10|isempty(rowistime);
	rowistime=0;
end
	hopms=dt;
	nhop=round(Fs*hopms/1000);
	nwin=length(win);
	nfftwin=2^ceil(log(nwin)/log(2));
	if dfgiven
		nfft=2^ceil(log(Fs/df)/log(2));
		if nfftwin>nfft, nfft=nfftwin; end;
	else
		nfft=nfftwin;
		df=Fs/nfft;
	end



	if nwin<nfft
			 npad=nfft-nwin;
			 padzer=zeros(npad,1);
	else
			padzer=[];
	end

	novlp=nwin-nhop;
%nwin,nhop,novlp
	if novlp<0, fast=0; end % specgram won't take neg overlaps
% 	pause
% Use same strategy as specgram for number of time slices, but first pad with a half window of
% zeros so leftmost frame is centered on both sides of signal
if size(x,2)~=1;x=x(:);end
first=round(t1/1000*Fs)+1 - ceil(nwin/2);
% the last time must be at or after time requested
%
last=round(t2/1000*Fs)+1 + ceil(nwin/2); % +nhop-1; don't stretch
%first, last
padleft=[];
if first<1, padleft=zeros(-first+1,1); first=1; end
padright=[];
if last>nx, padright=zeros(last-nx,1); last=nx; end


x=[padleft;x(first:last);padright];
	if premph>0
		x=filter([1,-premph],1,x); %preemphasize the whole buffer
	end
nx=length(x);
ncol = fix((nx-novlp)/(nwin-novlp));
% ncol
% pause
colindex = 1 + (0:(ncol-1))*(nwin-novlp);
tax=(colindex-1)'/Fs *1000+t1;
nfold=nfft/2+1;
fax = ((1:nfold)'-1)*Fs/nfft; % frequency axis for whole range
try
	%B = SPECGRAM(A,NFFT,Fs,WINDOW,NOVERLAP)
	X2 = specgram(x,nfft,Fs,win,novlp);
	if ~wantcomplex
		X2=abs(X2(1:nfold,1:length(tax))).^2;
	end
catch% the slow, mem conserving way
	if length(x)<(nwin+colindex(ncol)-1)
 	   x(nwin+colindex(ncol)-1) = 0;   % zero-pad x
   end
   %sizex=size(x)
   if wantcomplex
	   X2=zeros(nfft,ncol);
 	else
		X2=zeros(nfold,ncol);
	end
	for icol=1:ncol
		ci=colindex(icol);
		ce=ci+nwin-1;
		%sizewin=size(win)
		%xsecsize=size(x(ci:ce))
		xp=[win.*x(ci:ce);padzer];
		if ~wantcomplex
			R=abs(fft(xp)).^2; % here's your POWER
	% 	size(R(1:nfold))
	% 	size(X(icol,:))
			X2(:,icol)=R(1:nfold);
		else
			X2(:,icol)=fft(xp);
		end

	end % for icol
end
if rowistime, X2=X2';end


