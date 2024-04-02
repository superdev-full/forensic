%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/fbaRoot.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:fbaRoot.m 2002/11/6 19:5

function [fc,bw,ampdb]=fbaRoot(a,gainsq,Fs);
% function [fc,bw,ampdb]=fbaRoot(a,gainsq,Fs);
% Gainsq is "alpha" of Markel and Grey routines
% find the roots of the predictor polynomial
%% This does not take a multiframe argument... just one alpc vector
% use fbaRoot2 for multiframe
% Copyright TM Nearey 1998-2001
% REQUIRES CHECKING... pole at folding frequency
if nargin~=3, error('fbaRoot requires 3 args');end;
if all(a(2:end)==0)
	fc=[];bw=[];ampdb=[];
	return
end
r=roots(a);
% frequencies and bandwidths of complex conjugate roots
if nargin<3;
		Fs=1;
end

fct=angle(r)*Fs/(2*pi);
bwct=log(abs(r))*Fs/pi;
fc=fct(find(imag(r)~=0 & fct>0));  % non-zero roots, pos freq
bw=abs(bwct(find(imag(r)~=0 & fct>0)));
[fc,ix]=sort(fc);    % sort into order of ascending freq
bw=bw(ix);           % and bandwidths
	if nargin<2
		gainsq=1;
	end

if nargout==3
	% evaluate amplitude at formant frequencies
	ampdb=zeros(size(fc));
	for k=1:length(fc);
		f=fc(k);
		ampdb(k)=abs(polyval(a,exp(2*i*pi*f/Fs)));
		ampdb(k)=-20*log10(ampdb(k))+10*log10(gainsq);
	end
end


