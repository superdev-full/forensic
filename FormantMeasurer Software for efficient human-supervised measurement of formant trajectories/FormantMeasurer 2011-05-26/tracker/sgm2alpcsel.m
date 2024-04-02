%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/sgm2alpcsel.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:sgm2alpcsel.m 2002/11/6 19:5

function [alpc,gainsq,flo,fhi]=sgm2alpcsel(X,Fs,FloTarg,FhiTarg,lpcord,Beq)
%function [alpc,gainsq,flo,fhi]=sgm2alpcsel(X,Fs,FloTarg,FhiTarg,lpcord,Beq)
% Produce the LPC ('a') coefficients of a (power) spectral section
% Should be non-folded  power spectrum (1:[nfft/2+1]) (as from tsfftsgm)
% Input can be a spectrogram (freq rows x time cols)
% 1 Jan 1998 Copyright T. Nearey
% alpc will have time-series vector form (rows=time, cols=coeffieient)
% gainsq will lso be a col vector (ntime  x 1)
% Beq is Tohkura's lagwindow (gaussian) smoothing (120 hz recommended)
% modified for zero Beq 22 nov 2001
%
% Version 1.2 forces FhiTarg and FloTarg into Nyquist band
% Copyright T.M Nearey 1998-2002

[nfold,nslice]=size(X);
delf=Fs/(2*(nfold-1));


nlag=lpcord;
%fax =  linspace(0,Fs,nfold)';
if FhiTarg>Fs/2
	warning('FhiTarg set to nyquist')
	FhiTarg=Fs/2;
end
if FloTarg<0
	warning('FloTarg set to zero')
	pause
end
klo=floor(FloTarg/delf)+1;
khi=ceil(FhiTarg/delf)+1;
% klo
% khi
% nfold
% nslice
% pause
flo=(klo-1)*delf; % actual frequency range of selection
fhi=(khi-1)*delf;
l=khi-klo;
L=2*l;
alpc=zeros(nslice,lpcord+1);
gainsq=zeros(nslice,1);
% force to even
sp2accmat=1/L*exp(-i*2*pi/L* [0:L-1]'*[0:nlag])	;

if Beq>0
	lagw=lagwin((fhi-flo)*2,Beq,lpcord+1,'GAU')'; % rt wants a row below
else
	lagw=1;
end

Xt=zeros(L,1);
for islice=1:nslice
	% zero delay is at size(rx,1)+1/2+1;
	Xt(1:(l+1))=X(klo:khi,islice);
	Xt((l+2):L)=flipud(Xt(2:l));
	rt=real(Xt'*sp2accmat);
	%sizert=size(rt)
	%sizelagw=size(lagw);
	[alpc(islice,:),gainsq(islice)]=r2lpc(rt.*lagw);
end
