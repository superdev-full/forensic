%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/r2lpc.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:r2lpc.m 2002/11/6 19:5

function [a,gainsq,rc]=r2lpc(r,m);
%function [a,gainsq,rc]=r2lpc(r,m);
% autocorrelation lpc of order m
% returns rowvectors (like levinson in signal)
% length of r on input is m+1 where m max lags = lpcorder
% gainsq is squared gain= M&G alpha in auto
% from Hermansky 1989 JASA
 error(nargchk(1,2,nargin))
 if nargin < 2, m = length(r)-1; end
  if r(1)<=0
 	a=[1,zeros(1,m)];% no signal;
	gainsq=0;
  	return
 end

    if length(r)<(m+1), error('Correlation vector too short.'), end

	a=zeros(1,m+1);
	rc=zeros(1,m+1);
	alp=zeros(1,m+1);
	a(1)=1.0;
	alp(1)=r(1);
	rc(1)=-r(2)/r(1);
	a(2)=rc(1);
	alp(2)=r(1)+r(2)*rc(1);
	for mct=2:m
		s=0;
		mct2=mct+2;
		alpmin=alp(mct);
		for ip=1:mct
			idx=mct2-ip;
			s=s+r(idx)*a(ip);
		end % for ip (60)
		rcmct=-s/alpmin;
		mh=mct/2+1;
		for ip=2:mh
			ib=mct2-ip;
			aip=a(ip);
			aib=a(ib);
			a(ip)=aip+rcmct*aib;
			a(ib)=aib+rcmct*aip;;
		end % for ip (70)
		a(mct+1)=rcmct;
		alp(mct+1)=alpmin-alpmin*rcmct*rcmct;
		rc(mct)=rcmct;
	end% for mct (50);
	gainsq=alp(m+1);

	% a agrees with levinson(r)

