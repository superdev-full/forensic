%  Saved from C:\NeareyMLTools\matklatt80\bafilt.m 2006/10/12 15:18

function [b,a,A,B,C]=bafilt(Fs,f,fb,pole,casc);
%function [b,a,A,B,C]=bafilt(Fs,f,fb,pole,casc);
% calculate b and a coeffs for matlab filter function given
%INPUT
% Fs sampling frequency
% f(:), center frequencies (col vectors all)
% fb(:), bandwidth
% pole:. Should be scalar 1 pole 0 zero (if missing or empty, all poles assumed)
% if casc is 1, then cascaded polynomial is returned.
%OUTPUT
% b(k,nbcoefs) - numerator (FIR) coefficients for MATLAB filter function
% a(k,nacoefs)- denominator (IIR) coefficeints
% k corresponds to elements of input f,fb
% each row of output specifies a new set of filter function
% Note that poles and zeros cannot combined in one call
% Stacking of inputs useful for multiple formants, or variable time filters
% in synthesis (but not both). In former case casc=1 may be useful to build
% a big filter
% Copyright(c) 1999, 2003  Terrance M. Nearey
%  % version 1.0 Nijmegen S
% % version 1.1 force f=f(:), fb=fb(:) after size test
if nargin<4|isempty(pole);
	pole=1;
end
if ~isequal( size(fb),size(f))
error('size of arguments f and fb must match')
end;
f=f(:);
fb=fb(:);
if max(size(Fs))==1 % allow for bizzare possibilities
	Fs=Fs*ones(size(f));
end
if nargin<5|isempty(casc), casc=0; end;


f=abs(f); fb=abs(fb);
nf=length(f);
ONE=ones(nf,1);
PIT=pi./Fs;
R=exp(-PIT.*fb);
% Klatt 1980's ABC p 973-974 Jasa vol 67
C=-(R.^2);
B=2.*R.*cos(2*PIT.*f); % klatt's b
A=1.-B-C;
if pole
		a=[ONE,-B,-C];
		b=[A];
else
		AP=1.0 ./ A;
		BP=-AP.*B;
		CP=-AP.*C;
		b=[AP,BP,CP];
		a=ONE;
end
if casc
	[b,a]=cascade(b,a);
end

return


