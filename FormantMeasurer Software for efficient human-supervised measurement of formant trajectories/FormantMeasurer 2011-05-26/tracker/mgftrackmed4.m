%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/mgftrackmed.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:WorkingFall2k1:NeareyTracker4xApr2k1:mgftrackmed.m 2002/11/6 19:5

function [fsmo,bsmo,asmo]=mgftrackmed4(nf,fc,bw,ampdb,fcutoff,bwthresh,globDb,frameDb)
%[fsmo,bsmo,asmo]=mgftrack(nf,fc,bw,ampdb,fcutoff,bwthresh,globDb,frameDb)
%Markel and gray like initial sloting
% DOES 3 formants only [CHANGED TO 4 by GSM]
% But with wrinkle... fest is 5 pt MEDIAN SMOOTH of all the 'exactly 3 candidates'
%nf n candidates (per frame)
%fc  bw,ampdb-  raw FBA info
% fcutoff -- est of (F3+F4)/2
% bwthresh-- max bw for a real formant
% globDb,frameDb -- global and within frame dB thresholds compared to global or frame max
% Version 2.0 allows F1 down to 150 Hz
% also  back fills missing values to first frame
% i.e. first frame with exactly 3 peaks is used for initial estimate
% bw and amp of filled candidates will be zero on return
% Version 2.1 18 Dec 2000
% Version 2.11 4 Jan 2001 -- fixes initialization problem with only  2 peaks
% Copyright 1998-2001 (C) T M Nearey.
nframe=size(fc,1);
if size(nf)==[1 1],
	nf=ones(nframe,1)*nf;
end

% Bad formants may be rep'd by zeros or by NaNs or by things out of range
% Matlab's rules for comparison allow say NaN>x =>0

fsmo=zeros(nframe,4);
asmo=fsmo;
bsmo=fsmo;
festmed=NaN+fsmo; % initialize to bbad stuff
% Fcutoff assumed at expected (f3+f4)/2,
% 500(1000)1500(2000)2500(3000)3500(4000)
fspac=fcutoff/3;
prev=fspac/2+[0:3]*fspac;
if nargin<6
	bwthresh=750;
	globDb=70;
	frameDb=40;
end
% amplitudes must be within 40 db of maximum in frame
% and within 70 db of maximum in stream
% Fkm1=fspac/2+[0:2]*fspac; % new initialization
maxampGlob=max(max(ampdb));
maxampFrame=max(ampdb')';
thresh=max(maxampGlob-abs(globDb),maxampFrame-abs(frameDb));
% Three possible two point pairings
% candidate 1 assigned to peak 1, candidate 2 to peak 2 = 11 22
% pairs=  [1 1 2 2;...
%          1 1 2 3;...
%          1 2 2 3];

pairs = [1 1 2 2 3 3;...
         1 1 2 2 3 4;...
         1 1 2 3 3 4;...
         1 2 2 3 3 4];
     
pairs2 =[1 1 2 2;...
         1 1 2 3;...
         1 1 2 4;...
         1 2 2 3;...
         1 2 2 4;...
         1 3 2 4];

% look for first good frame
goodt= (fc>50 & fc<=fcutoff & bw<bwthresh & ampdb>repmat(thresh,1,size(fc,2)));
ngoodt=sum(goodt,2);
use=find(ngoodt==4);

% use=find(ngoodt>3);

if isempty(use)
    fsmo = [];
    bsmo = [];
    asmo = [];
    return
end

% festmed = zeros(nframe ,max(ngoodt));

for i=1:length(use);
	iu=use(i);
	festmed(iu,:)=fc(iu,goodt(iu,:));  % copy over the goodones
% 	festmed(iu, goodt(iu,:))=fc(iu, goodt(iu,:));  % copy over the goodones
end
% the bad frames in festmed are NaN, so medsmoterp will work well
festmed=medsmoterp(festmed,5);


% pause
dbg=0;
for k=1:nframe
	Fkm1=festmed(k,:); % Local continuity be damned.. use adjacency to
					 % more stable local estimate

	igood = find(fc(k,:)>50 & fc(k,:)<=fcutoff & bw(k,:)<bwthresh & ampdb(k,:)>thresh(k));
	Fkhat=fc(k,igood);
	Bkhat=bw(k,igood);
	Akhat=ampdb(k,igood);
	ngood=length(igood);
	if dbg
		Fkhat
	 	Fkm1
	 	pause
	end
	%%%%%%%%%%
    
% 	fsmo(k,:)=Fkm1; % initialize to previous
        Fkm1(Fkm1==0) = [];
        if isempty(Fkm1)
            Fkm1 = zeros(1, 4);
        end

	if ngood~=4
		% find best allignment to previous
		% 		Fkhat
		% 		Fkm1
		% 		repmat(Fkhat',1,3)
		% 		repmat(Fkm1,ngood,1)
		% 		%pause
		% rows are candidates
		% columns are prior est
		nu=abs(repmat(Fkhat',1,4)-repmat(Fkm1,ngood,1));

	end
	if ngood>=5
		% THIS CODE WAS IN ERROR
		%%%%[d, worst]=find(max(min(nu')));
		%% REPAIRED 18 Dec 2000 also generalized to handle more than 3 candidates
		[d,ibest]=sort(min(nu'));
		worst=ibest(5:end);
		%%%% Disp
		if dbg
			disp('case4> 3')
			fck=fc(k,:)
			igood
			Fkhat
			Fkm1
			nu
			pause
			worst
		end
		Fkhat(worst)=[];
		Bkhat(worst)=[];
		Akhat(worst)=[];
        
%         nu(worst, :) = [];
%         Fkm1=festmed(k,:);
%         Fkm1(worst) = [];
        
		ngood=4;
		%%%%%%
    end
    
    fsmo(k,:)=Fkm1; % initialize to previous

    
	if ngood==4
		%%%
		if dbg
			disp('case 3');
		end
		% 	Fkhat,Bkhat,Akhat
		fsmo(k,:)=Fkhat;
		bsmo(k,:)=Bkhat;
		asmo(k,:)=Akhat;

    else
		% Small enough to try all possible paths
		if ngood==1
			[dmin,imin]=min(nu(1,:));
			fsmo(k,imin)=Fkhat(1);
			if dbg
			 	disp('case 1')
				imin
			end
        end
        
        if ngood == 2
            d2pk = NaN(6,1);
			for i=1:6
				d2pk(i)=nu(pairs2(i,1),pairs2(i,2)) + nu(pairs2(i,3),pairs2(i,4));
			end
			[dmin,imin]=min(d2pk);
            
			sl1=pairs2(imin,2);
			sl2=pairs2(imin,4);
			can1=pairs2(imin,1);
			can2=pairs2(imin,3);
            
			fsmo(k,sl1)=Fkhat(can1);
			bsmo(k,sl1)=Bkhat(can1);
			asmo(k,sl1)=Akhat(can1);
            
			fsmo(k,sl2)=Fkhat(can2);
			bsmo(k,sl2)=Bkhat(can2);
			asmo(k,sl2)=Akhat(can2);
        end
        
		if ngood == 3
            d2pk = NaN(4,1);
			for i=1:4
				d2pk(i)=nu(pairs(i,1),pairs(i,2)) + nu(pairs(i,3),pairs(i,4)) + nu(pairs(i,5),pairs(i,6));
			end
			[dmin,imin]=min(d2pk);

			sl1=pairs(imin,2);
			sl2=pairs(imin,4);
            sl3=pairs(imin,6);
			can1=pairs(imin,1);
			can2=pairs(imin,3);
            can3=pairs(imin,5);

            fsmo(k,sl1)=Fkhat(can1);
			bsmo(k,sl1)=Bkhat(can1);
			asmo(k,sl1)=Akhat(can1);
            
			fsmo(k,sl2)=Fkhat(can2);
			bsmo(k,sl2)=Bkhat(can2);
			asmo(k,sl2)=Akhat(can2);

            fsmo(k,sl3)=Fkhat(can3);
			bsmo(k,sl3)=Bkhat(can3);
			asmo(k,sl3)=Akhat(can3);

		end
	end
	Fkm1=fsmo(k,:);
	if dbg
		newest=Fkm1
		pause
	end
end % for k frames


