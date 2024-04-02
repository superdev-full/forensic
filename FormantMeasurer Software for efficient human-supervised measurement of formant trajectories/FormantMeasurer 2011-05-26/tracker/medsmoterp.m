%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/medsmoterp.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:FTrackTools:medsmoterp.m 2002/11/6 19:5

function fsmo=medsmoterp(fc,medwid,idim);
%function fsmo=medsmoterp(fc,medwid,idim);
% median smooth and interpolate missings
% Call with medwidth of 1 for interpolation of missing values (NaN)
% Interpolation corrected 24 Apr 98
% Copyright 2000- 2001 T M Nearey
% handles matrices now
% This has very simple approach to endpoints... probably not a good one
% Copy on the first non-missing value and last non-missing value
% to alow interpolation/extensions
if nargin<3 |isempty(idim)
	idim=1;
end

if nargin==0
	medwid=3;
	nt=100;
	fc=repmat([1:nt]',1,2)+20*rand(nt,2);
	zipout=randperm(nt*2);
	fc(zipout(1:round(nt*2/3)))=NaN;
	clf
	plot(fc,'+'); hold on;
end
transpout=0;
if idim==2 | length(fc)==size(fc,2);
	transpout=1;
	fc=fc';
end

[nt,ncol]=size(fc);
ncop=(medwid+1)/2;
fsmo=repmat(NaN,nt,ncol);
for k=1:ncol
	fsm=repmat(NaN,nt,1);

	use=find(~isnan(fc(:,k)));
	nuse=length(use);
	if nuse<medwid
		warning('Not enough values to interpolate')
		nuse;medwid;
		fsm=fc(:,k);
		%return
	else
		if medwid>1 % if do smoothing
			fsm(use)=medfilt1(fc(use,k),medwid);
			fsm(use(1:ncop))=fsm(use(ncop+1));
			fsm(use(end-ncop+1:end))=fsm(use(end-ncop));
		else % degenerate case interpolation only
			fsm(use)=fc(use,k);
		end% end if dosmoothing

		%plot(fsm,'ro');
		% copy first and last non-missing values to the beg and end
		nomiss=find(~isnan(fsm));
		fsm=[fsm(nomiss(1));fsm;fsm(nomiss(end))];
		leftedge=find(~isnan(fsm(1:end-1)) & isnan(fsm(2:end)) );
		rightedge=find(isnan(fsm(1:end-1)) & ~isnan(fsm(2:end)) )+1;
		nl=length(rightedge);
		nr=length(leftedge);
		if nr~=nl, error('Should not happen PROG ERROR'); end
		for i=1:nr
			l=leftedge(i);
			r=rightedge(i);
			%  		tl=fsm(l)
			%  		tr=fsm(r)
			%  		tfil=linspace(fsm(l),fsm(r),r-l+1)
			%  		pause
			% l
			% r
			% leftedge
			% rightedge
			% fsmsize=size(fsm)
			% fsm(l),fsm(r),r-l+1
			if fsm(l)==fsm(r)
				fsm(l:r)=fsm(r);
			else
				fsm(l:r)=linspace(fsm(l),fsm(r),r-l+1);
			end
		end
		fsmo(:,k)=fsm((2):(end-1)); % statement was  wrongly placed out of loop

	end % have enough values


end % for k th col


if nargin==0; plot(fsmo); end;
	if transpout
		fsmo=fsmo';
	end
