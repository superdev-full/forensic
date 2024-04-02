%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/fcasc.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:speechsynth:fcasc.m 2002/11/6 19:5

function  [xfrmag, fharm]=fcasc(Fs,f0,oamag,ffrq,bw,genharm,fcutoff,hpcbas,grval,dbrng,killrk2)
%  [xfrmag, fharm]=fcasc(Fs,f0,oamag,ffrq,bw,genharm,fcutoff,hpcbas,grval,dbrng)
%                         1  2   3    4     5  6         7     8     9    10
% OS/8 conversion with a few arg changes DEBUGGING CODE
% Modified for continuous grval... if 1 or zero works like fcasc
% if real, acts serves as denominator in glottal correction
% INPUT %
%	f0- input "f0" value (for full fft spectrum
% 		should=Fs/(2.*float(nbins-1))
% 		if it is a  vector of same rowlength as ffrq,
%       and genharm is set to 1 then harmonics are generated
%       otherwise if it is a  vector, the specified frequencies are used for all frames
%		if f0 is a matrix (harmno, timeslice), then generate at only given frequencies (NaN's are skipped)
% 		fharm comes out the obvious way
%  	oamag % overall amplitude (magitude (rms) value)
%	ffrq - formant frequencies (ntimeslice x nft) will return spectrogram like array xfrmag(freq,time)
%  bw - bandwitdhs
%  genharm - generate harmonics at different f0 frequencies per time slice (size of f0 and ffrq must match)
%  fcutoff- target for high frequency cutoff
%  hpcbas- higher pole correction  base f1:
%     	use 500 hz for 17.5 cm slvt.
%      	use <=0 for no hpc
%  grval- glottal source/radiation flag if 1, then correction
%  dbrng- db range from max to floor
% 	 if.le.0, then no flooring is done
%      for source, radiation is done (not modified) %
%  calculations are done in power domain
%  and square rooting at end
% OUTPUT
%  xfrmag- returned array of magnitude spectrum amps of freqs above fcutoff are zero'd out
% fharm frequency of harmonics at each time slice
% version 2.0 Better higher pole correction
% (U. Laine 1988 Higher pole correction in vocal tract models and terminal analogs Speech Commmunication (7) p 21-40
% Version 2.1 grval replaces igr. Works the same as before if 0/1 (0 = no glottal correctoin)
% 	(1 = default) correction. Scalar value now possible default 1= scalar 100Hz in correction term
% Copyright T.M. Nearey 2001, 2002;
tnargin=nargin;

if tnargin==0
	Fs=10000; ffrq=[1 3 5 7 9]*500; bw=50+0*ffrq;
	hpcbas=500;grval=0; dbrng=0;
	f0=100; fcutoff=5000;
	tnargin=9;
	genharm=1;
	oamag=100;
	figure(1)
	clf
	[xfrmag, fharm]=fcasc(Fs,f0,oamag,ffrq,bw,genharm,fcutoff,hpcbas,grval,dbrng);
	plot(fharm,xfrmag);
	hold on;
	[xfrmag, fharm]=fcasc(Fs,f0,oamag,ffrq,bw,genharm,fcutoff,hpcbas,grval,dbrng,1);
	plot(fharm,xfrmag,'r');
	% no hpc
	[xfrmag, fharm]=fcasc(Fs,f0,oamag,ffrq,bw,genharm,fcutoff,0,grval,dbrng,1);
	plot(fharm,xfrmag,'g');
	hold on;


	return
end

% 5 genharm,fcutoff,hpcbas,grval,dbrng
if tnargin<6 |isempty(genharm)
	genaharm=1;
end
if tnargin<7 |isempty(fcutoff),
	fcutoff=Fs/2;
end
if tnargin<8 |isempty(hpcbas),
	hpcbas=500;
end
if tnargin<9 |isempty(grval)
	grval=1;
end
if tnargin<10 |isempty(dbrng)
	dbrng=-1;
end
if tnargin<11 | isempty(killrk2)
	killrk2=0;
end

if size(ffrq,2)==1, ffrq=ffrq'; bw=bw';end


onefsamp=0;
nslice=size(ffrq,1);
if max(size(oamag))==1; oamag=repmat(oamag,nslice,1);end;

	if max(size(f0))==1,
		nbins=floor(fcutoff/f0)+1;
		fhi=f0*(nbins-1);
		fharm=(0:f0:fhi)';
		onefsamp=1;
	elseif min(size(f0))==1 & genharm;
		f0=f0(:)';  % time dimension
		if length(f0)~=nslice
			error(' Length of F0 must match row dim of ffrq')
		end
		minf0=min(f0);
		f0t=f0(:)';
		nbins=ceil(fcutoff/minf0);
		fharm=repmat(f0t,nbins,1).*repmat((1:nbins)',1,nslice);
	elseif  min(size(f0))==1
		fharm=f0(:);
		nbins=length(f0);
		onefsamp=1;
	else % must be a martrix
		fharm=f0;
		nbins=size(f0,1);
	end


	nft=size(ffrq,2);
	xfrmag=zeros(nbins,nslice);
	for islice=1:nslice;
		if onefsamp, it=1; else it=islice; end
		f0t=fharm(:,it);
		ft=ffrq(islice,:);
		bt=bw(islice,:);
		ffold=Fs/2.;
		c2=(bt/2).^2;
		fnum=(ft.^2+c2).^2;
		% cddif=c2-c2A
		% fnumdif=fnum-fnumA
		% pause
		pole=(repmat(f0t,1,nft)-repmat(ft,nbins,1)).^2+repmat(c2,nbins,1);
		pconj=(repmat(f0t,1,nft)+repmat(ft,nbins,1)).^2+repmat(c2,nbins,1);
		% figure(37); clf
		% subplot(2,1,1); plot(f0t,tpole);subplot(2,1,2); plot(f0t,pole); pause
		% figure(37); clf
		% subplot(2,1,1); plot(f0t,tconj);subplot(2,1,2); plot(f0t,pconj); pause
		xfrmag(:,islice)=sqrt(prod(repmat(fnum,nbins,1)./(pole.*pconj),2));
		%plot(f0t, [xfrmagA,xfrmag+.05*max(xfrmagA)])


		if hpcbas>0
			%%% HPC Vectorized
			%  first order higher pole correction flanagan p 218 eq 6.14
			%  calc constant rk see also Olive p 662

			rk= pi*pi./8-sum(1./(2*(1:nft)-1).^2);
			% Fant 1959 as reported  in Laine 88 second order correcton
			if ~killrk2
				rk2=.5*((pi.^4)./96 - sum(1./(2*(1:nft)-1).^4));
			else
				rk2=0;
			end

			xfrmag(:,islice)=xfrmag(:,islice).*exp(rk*(f0t./hpcbas).^2+rk2*(f0t./hpcbas).^4);
		end
		%figure(37) ; plot(f0t,xfrmag); pause
		%  source plus glottal radiation
		%  olive jasa (1971) 50:662 equation 4
		if(grval==1) %
			xfrmag(:,islice)=xfrmag(:,islice).*(f0t./100)./(1+f0t.^2/10000);
		elseif grval >0
			xfrmag(:,islice)=xfrmag(:,islice).*(f0t./grval)./(1+f0t.^2/grval^2);
		end

		if any(f0t>fcutoff)
			xfrmag(find(f0t>fcutoff),islice)=xfrmag(find(f0t>fcutoff),islice).*0;
		end
		xfrmag(:,islice)=xfrmag(:,islice)*oamag(islice);
		%figure(37) ; plot(f0t,[xfrmagC,xfrmag+.05*max(xfrmagC)]); pause
		if dbrng>0 & dbrng<inf
			xdiv=exp(dbrng/8.68);
			amin=max(xfrmag(:,islice))/xdiv;
			xfrmag(:,islice)=max(xfrmag(:,islice),amin);
		end
		%figure(37) ; plot(f0t,[xfrmagD,xfrmag+.05*max(xfrmagD)]); pause
	end % slice loop
