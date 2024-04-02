%  Saved from /Users/nearey/NeareyMLTools/Sigantools/alpc2sgm.m 2004/6/2 14:20

function [X,fax]=alpc2sgm(alpc,gainsq,Fs,df,fast,stype)
%function [X,fax]=alpc2sgm(alpc,gainsq,Fs,df,fast,stype)
%function [X,fax]=alpc2sgm(alpc,gainsq,Fs,df,fast,stype)
% for use after (eg. sgm2alpcsel)
% assumes time axis of alpc and gain coeffs are known externally
% alpc is ntimeslice x (lpcord+1) matrix
% gainsq is ntimeslice x 1 vector
% stype is one of DB POW MAG AMP or INVPOW
% Copyright T.M. Nearey 1997-2001
% Scale conversion bug fix 22 Nov 2001
if nargin<5|isempty(fast)
	fast=1;
end
if nargin<6|isempty(stype)
	stype='DB';
else
	stype=upper(stype);
end
switch stype
case 'DB'
case 'POW'
case 'MAG', 'AMP'
case 'INVPOW'
otherwise
	error('Stype must be one of {DB,POW,MAG(AMP),INVPOW}')
end
nfft=2^nextpow2(ceil(Fs/df));
nfold=nfft/2+1;
fax=linspace(0,Fs/2,nfold)';
if fast
	X=abs(fft(alpc',nfft).^2); % note transpose
	X(nfold+1:end,:)=[];
else
	ncol=size(alpc,2);
	X=zeros(nfold,ncol);
	for i=1:ncol
		t=abs(fft(alpc(:,i),nfft).^2);
		X(:,i)=t(1:nfold);
	end
end
% sizex=size(X)
% sizegainsq=size(gainsq)
% nfold

switch stype
% note transposes of gainsq
case 'DB'
	X=-10*log10(X)+repmat(10*log10(gainsq'),nfold,1);
case 'POW'
	X=(1./X).*repmat(gainsq',nfold,1); % Bug fixed... this had log
case 'MAG', 'AMP'
	X=sqrt(1./X).*repmat(sqrt(gainsq)',nfold,1);
case 'INVPOW'
	X=X./repmat(gainsq',nfold,1);
otherwise
	error('Stype must be one of {DB,POW,MAG(AMP),INVPOW}')
end




