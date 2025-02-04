%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/tracker4xpOneFile.m 2004/6/2 14:20

function [bestRec,allTrialsRec,scorecompslabels,Xsmodb,faxsmo,score_track]=tracker4xpOneFile(x,Fs,f34cutoffs,fname,watchlevel)
% Tracker 4xp Beta0p4 (zero point 4).
% Copyright T.M Nearey 2004
% This is minimally modified (to return Xsmodb and faxsmo) version of
% of the versin of tracker4XP installed in Peter's lab at UTD. This version
% is known to work 'off campus' , ie. not in my lab.
% The algorithm implemented is the one described at Cancun ASA meeting.
%  see tracker4xpDemo for example call
%INPUT:
% x -- signal to track (assumed to be a single vocalic chunk'
% Fs --  sampling rate (Hz)
% f34cutoffs -- (ntry x 1)  a vector of 'trial'  cutoff frequencies
%        These should be guesses of  cutoffs of frequencies that will likely
%          be above f3 but below f4.  It is suggested that user try a range of
%        values bracketing the expected upper frequency range of F3 roughly
%        halfway between 'average' f3 and average f4 for the voices to be
%        tracked. A very large range can be tried, but this will slow
%        things down. To coarse a sampling can result in not finding a good
%        cutoff that splits f3 and f4. (I.e. including too many or too few
%        candidates in the range)
%  	fname -- name of file analyzed (optional)
% 	 watchlevel-- (what to show and pause for everything above zero is for debugging in NeareyLab).
%        0 - pure batch,
% 	    1 - show best only and pause
% 	    2 - show everything pause judiciously
% 	    3 - debug pause all over the place
% OUTPUT:
%bestRec record with Fields:
%	'taxsg' - (nframe x 1) time axis vector (milliseconds) length(taxsg)=nframe;
%	'savefest'- (nframe x 3 ) array of formant estimates f1 to f3
%      so that plot(taxsg,savefest) will plot formant tracks.
%	'scorecompsbest'  score components
% 	'f34cutoffbest' best f3/4 cutoff frequency
% 	'fname' - passed from input, if given
%
% allTrialsRec record with fields:
%   'taxsg'-  as above
%   'fest' - {ntry x 2} cellarray of (nframe x 3) formant estimates where ntry is length(f34cutoffs)
%      so that for i=1:ntry, for j=1:2 plot(taxsg,fest{i,j})
%      will plot all the formant tracks investigated. Only fest{:,1} are possible candidates for fbest
%      fest{:,2) are used in the 'scorecomp' rfstable
%   'scorecomps'--{ntry x 9} evaluation score of the tracks in fest{:,1}
%    i.e. scorecomps(itry,j) is the score for fest(itry,1)
%     scorecomps(itry,1) is the composite 'figure of merit' for each trial
%     trackset. If iargmax is determined by [xmx,iargmax]=max(scorecomps(:,1))
%     allTrialsRec.fest{iargmax,1} corresponds to bestRec.savefest
%
%   'f34cutoffs' -- copy of input cutoffs
%   'fname' copy of input file
%   'dBPerOct' - dB/Octave adjustment used in analysis by synthesis regression (may be useable in future evaluation)
% Xsmodb - an lpc smoothed spectrogram (it may show some harmonic breaking)
%          on which other analyses are ultimately based (X_smo_db)
%
% faxsmo - the frequency axis of XsmoDb. plotsgm(taxsg,faxsmo,XsmoDb) will
%     plot the target spectrogram over which the smoothed formant tracks
%     can be plotted
% Fuzzy MGTrack with stability check
% multiple tries of MG track at different  selective lpc fhi cutoffs
% with a 'stability check' for extra formant in range
% (If you add one extra coefficient and things really change, this is not a good cutoff)
% with ABS verification of spectrum levels
% A baroque formant tracker
% Version 4.. using MGMedian tracker 5 Jan 2000 and extra median smooth
%   Also... selective LPC goes for 5 formant analysis
% This is on basis of Markel and Grey example p 159 5 extra coefs above F5
% But only lowest 3 are modeled subsequently
% Also.. 0.9 premphasis used
% Also... Spectrum of Target (large scale) LPC is used
% Also .. Number of coefficients in large scale LPC is made more conservative
% clear all;

% close all;
% fclose all;
% Version 4.1
% Bandwidth expectation corrected 60 Hz or .06 *Formant frequency
% Version 4.1a dB/octave slope returned  from  anbysynchk3 (v1.1) and saved in mtx files
% Version 4.1b 'noload' arg added to getNextPfaKid for continuation of runs (no name checking)
theNargsIn=nargin;

if nargin==0
	pausemsg('Testing... Go find a wave file')
	fname=uigetpath('*.wav');
	[x,Fs]=wavread(fname);
	watchlevel=1;
	f34cutoffs=round(exp(linspace(log(3000),log(5000),6)));
	[bestRec,allTrialsRec,scorecompslabels]=tracker4xpOneFile(x,Fs,f34cutoffs,fname,watchlevel);
	figure(1);
	clf
	plot(bestRec.taxsg,bestRec.savefest);
	title('Best track guess')
	kmenu=menu('Make text archive', 'Y', 'N')
	if kmenu==1
		inmemarchive({'Nearey','Working'},'tracker4xpOneFileAr.txt',0)
	end

	return

end

MEGABATCHDEBUG=0;
RANDOMSELECTION=0;


batchrun=watchlevel==0;


if batchrun
	warning off
	pausemsg('pause off')
	% show the best one
	% show alternate (extra coefficient) candidate analyses ( 2*NFT+1 and 2*NFT+2 coefs)
	% show all the candidate analysis
else
	warning on
	pausemsg('pause on Debug')
	% show alternate (extra coefficient) candidate analyses ( 2*NFT+1 and 2*NFT+2 coefs)
	% show all the candidate analysis

end

% if batchrun % figure out total number of elements to process
% 	possave=ftell(ffnl);
% 	eof=0;
% 	nSigsTot=0;
% 	while ~eof
% 		[t,eof]=fgetline(ffnl,1);
% 		if ~eof,
% 			nSigsTot=nSigsTot+1;
% 		end
% 	end
% 	fseek(ffnl,possave,-1);
% end


% figure out
% showbest=1
% watch=1
% pause on
% NEMPH=1;
% emphset=linspace(.7,.95,NEMPH);

%hitargset=3000*exp(linspace(log(1.0),log(1.4),NHITARG)); % Corrected for consistency.. max is 1.5 male
clear checkhalt
hitargset=f34cutoffs;
NHITARG=length(f34cutoffs);
%ntry=NEMPH*NHITARG;
% We're only doing one emph....
ntry=NHITARG;
%==============================
% Schafer and Rabiner male ranges
% JASA 47 no 2 1970 p 634-648
Fmn(1)=200;Fmx(1)=900;
Fmn(2)=550;Fmx(2)=2700; % fig 9 p 640
Fmn(3)=1100;Fmx(3)=2950;
% My own guess: F4mi
Fmn(4)=2700; Fmx(4)=3950;
%==============================


% Let's set an absolute upper target for the smoothed spectrogram
% plenty of coefficients for lowest frequency voice

FsmoHi=4/3*max(f34cutoffs)+100;% =6000 %  four formants for highest voice
%


%VSELECT=[2 3 6 8]
VSELECT=[1:12];
calcdist=0;

tic

inext=0;


if batchrun
	% progressmonitor(0)
end
scorecompslabels=cellstr(parse('score,presence,bwreason,ampreason,contreason,distreason,rabs,rangereason,rfstable',','));

processingcomplete=0;
lastfileprocessed='';

if watchlevel>0
	close all
end


tmin=0;
tmax=length(x)/Fs*1000;
if ~batchrun
	try
		playsc(x,Fs)
	end
end

% INITIAL SPECTROGRAM
% Window setup
win=getwin(100,'COS4', Fs); % 100 ms cosine 4 window
% get approx bw of window... Half bw here.
% to know how to widen formant bws
winSpec=10*log10(abs(fft(win)));
dfwin=Fs/length(winSpec);
imin=min(find(winSpec<(winSpec(1)-3)));
bwwin=2*interp1(winSpec(1:imin),linspace(0,dfwin,imin)',winSpec(1)-3);
premph=.95; % version 3.and later
FloTarg=0;
dt=2;
df=10;
fast=1;

[X2sg,taxsg,faxsg]=tsfftsgm(tmin,tmax,x,Fs,win,dt,df,premph,fast);%,rowistime,wantcomplex)
if watchlevel>3
	figure(1)
	clf
	plotsgm(taxsg,faxsg,10*log10(X2sg));
	colorbar
	title(['NarrowSGM', fname])
	pausemsg('NarrowSGM')
end % if watch
%=================================
%% Target smoothed spectrogram (to check against abs
%=================================
%TargetSpectrumType='CEP'
TargetSpectrumType='LPC';
%=================================

switch TargetSpectrumType
% 	case 'CEP'
% 		%Schaefer and Rabiner window
% 		cwin=10;
% 		sgmonly=1;
% 		tau=[0:1./Fs:3.6/1000]'; % non zero delays
% 		den=36/10000; %10 Khz in original pformula 1.3 of Olive
% 		i1=find(tau<=2/1000);
% 		i2=find(tau>2/1000&tau<3.6/1000);
% 		cwin=zeros(size(tau));
% 		tau1=2/1000;
% 		deltau=1.6/1000;
% 		cwin(i1)=1;
% 		cwin(i2)=.5*(1+cos(pi*(tau(i2)-tau1)/deltau)); % Schaefer and Rabiner JASA 47 p 638 (1970)
% 		if 0
% 			figure(37)
% 			plot(tau*1000,cwin)
% 			title('Cepstral window (lifter)')
% 			pausemsg
% 		end
% 		[rcepc,Xsmodb]=fastsgm2rceps(X2sg,cwin);%,nfftXdb)
% 		maxsgbin=max(find(faxsg<=FsmoHi));
% 		faxsmo=faxsg(1:maxsgbin);
% 		FsmoHi=faxsmo(end);
% 		Xsmodb=Xsmodb(1:maxsgbin,:);
% 		if watch
% 			figure(1);
% 			plotsgm(taxsg,faxsmo,Xsmodb);
%
% 			colorbar
% 			title('Cepstrogram  for target');
% 			pausemsg
% 		end
case 'LPC'
	% but this coul
	% we need to keep this in the same frequency range as the cepstrum would have
	% been.. he cepstrum is in the original freq scale.
	%emph(itry)=premph; % for later reporting
	% alpc needs to be a cell... varying sizes
	% gainsq could be a 2d  array... but easier to handle as cell
	% fhi is fine as a vector (one value for each try)
	Beq=125;
	FloTarg=0;
	lpcord=2*round(FsmoHi/(450*2))+5; %  Only a few extra... previous example had 2x as many
	% This might start resolving harmonics.
	[alpcsmo,gainsqsmo,Floact,FsmoHi]=sgm2alpcsel(X2sg,Fs,FloTarg,FsmoHi,lpcord,Beq);
	% could do a test here for too many (>6) narrow band formants and reduce
	% till they disappear We are hoping that BEQ will fix it
	df=faxsg(2); % same resolution as original spectrogram
	stype='dB';
	[Xsmodb,faxsmo]=alpc2sgm(alpcsmo,gainsqsmo,FsmoHi*2,df,fast,stype);
	X2smo=10.^(Xsmodb/10); % Power spectrum version 4 so smaller selections can be derived
	if watchlevel>1
		figure(1)
		plotsgm(taxsg,faxsmo,Xsmodb)
		colorbar
		title('LPCogram for target');
		pause
	end
end % smoothing case

nfaxsg=length(faxsg);
nfft=(nfaxsg-1)*2;
% The deemphasis function ... which will be linearly interpolated later
demph=20*log10(abs(fft([1,-premph]',nfft)));
demph=-demph(1:nfaxsg);
if watchlevel>3
	figure(37)
	plot(faxsg,demph);
	grid on
	title(' Deemphasis')
	pausemsg
end

FloTarg=0;
lpcord=7; % try for 3 fmnts EXACTLY

% Fuzzy trapezpoidal functions
bwtrpx= [0 .5  1  2  3  5  10 20 5000]; % trapeziodal function x bandwidth (as ratio to expected bw)
bwtrpy= [0 .25 1 .8 .5 .2 .1   0   0];

contx=[0 100 200 300 400 5000];
conty=[1  .5 .1   .05 0   0];

fdistx=[0 100 300 500 1200 2000 4000 Fs];
fdisty=[0 .1  .5   .9   1   .9  .5   0 ];

% As fraction of expected range
frngx=[-20000 -.2  -.05   0      1 1.05  1.2 10000];
frngy=[0        0     .5   1     1 .5      0    0 ];

amptrpx=[-1000 -50 -30 -20 -10 0]; % amp rel to max in db
amptrpy=[0      0  .3   .8 .9  1];


% maybe this isn't right the pre-emphais should be undone
% before the check by resynth
% add a deemph which is  -fft(1, -preemph)
score=-inf; % bad  score;
scorecomps=zeros(ntry,9);
fest={};
bwest={};
itry=0;
% We are doing only one preemphasis here

score_track = NaN(ntry, 3); % GSM this is a per track score

% %WAITBAR
% hwait=waitbar(0,['Running cutoffs for sound file: ', fname]);

dBPerOct=zeros(ntry,1); % preemphis required by anbysynchk3
for iFhiTarg=1:NHITARG

%     %WAITBAR
%     waitbar(iFhiTarg/NHITARG)
    
	itry=itry+1;
	Beq=125;
	FhiTarg{itry}=hitargset(iFhiTarg);
	% The high target is expected at (F3+F4)/2.. compare that to the 'base male' viz 3000
	estscale=FhiTarg{itry}/3000;
	ftrngmin=Fmn*estscale;
	ftrngmax=Fmx*estscale;

	emph(itry)=premph; % for later reporting
	% alpc needs to be a cell... varying sizes
	% gainsq could be a 2d  array... but easier to handle as cell
	% fhi is fine as a vector (one value for each try)

	% Alpc{itry,1} will be the 'opt fit (rignt number of coefs for the range'
	% Alpc{itry,2) will be the 'extra formant one to check that we aren't including another formant
	% 3 extra coefficients
	% The theory here is that a good cutoff won't change much if a few extra coefs are added
	% % One could be cleverer here with a strategic choice of an expected 3 ft
	% % and an expected 4 ft range...with the 4 ft range of one hyp cutoff analysis
	% % serving as the 3 ft range of another higher cutoff.. but
	% % But choice of grid points would be tricky to say the least.
	% % This just posits one 'extra formant guard analysis' for each cutoff
	% we have added lpc coefficients and scaled up the FhiTarg
	%	[alpc{itry,1},gainsq{itry,1},flo,fhi(itry)]=sgm2alpcsel(X2sg,Fs,FloTarg,FhiTarg{itry}*4/3,lpcord+2,Beq);
	% try with only 1 extra
	%	[alpc{itry,2},gainsq{itry,2},flo,fhi(itry)]=sgm2alpcsel(X2sg,Fs,FloTarg,FhiTarg{itry}*4/3,lpcord+1,Beq);

	% Version 4 This is done on smoothed spectrum instead... We have to trick sgm2alpcsel to think we have
	% an fft spectrum (N/2+1);
	% If faxsmo is even length, we'll skip the last element
	if rem(length(faxsmo),2)==0 % even case.. shorten
		nuse=length(faxsmo)-1;
	else
		nuse=length(faxsmo);
	end
	FsSmo=faxsmo(nuse)*2;
	% we're actually trying 4 formants
	SizX2smo=size(X2smo);
	nuse;FsSmo;FloTarg;FiTargT=FhiTarg{itry}*4/3;lpcord2=lpcord+2;Beq;

	[alpc{itry,1},gainsq{itry,1},flo,fhi(itry)]=sgm2alpcsel(X2smo(1:nuse,:),FsSmo,FloTarg,FhiTarg{itry}*4/3,lpcord+2,Beq);
	% try with only 1 extra
	[alpc{itry,2},gainsq{itry,2},flo,fhi(itry)]=sgm2alpcsel(X2smo(1:nuse,:),FsSmo,FloTarg,FhiTarg{itry}*4/3,lpcord+3,Beq);





	for ixt=1:2
		nt=size(alpc{itry,1},1);
		maxft=floor(lpcord/2)+1; % allow for 1 extra formant
		fc{itry,ixt}=repmat(NaN,nt,maxft);
		bw{itry,ixt}=fc{itry,ixt};
		ampdb{itry,ixt}=fc{itry,ixt};

		for it=1:size(alpc{itry},1);
			[fct,bwt,ampt]=	fbaRoot(alpc{itry,ixt}(it,:),gainsq{itry,ixt}(it),2*fhi(itry));
			npk=length(fct);
			fc{itry,ixt}(it,1:npk)=fct;
			bw{itry,ixt}(it,1:npk)=bwt;
			ampdb{itry,ixt}(it,1:npk)=ampt;
		end
		fast=1; stype='DB';
		globDb=70; frameDb=70;
		fcutoff=fhi(itry)*3/4;  % scale down the frequency
		bwthresh=2000; % try anything

		%	fest
		% this version uses mgftrackmed
		[fest{itry,ixt},bwest{itry,ixt},ampest{itry,ixt}]=mgftrackmed(3,fc{itry,ixt},bw{itry,ixt},ampdb{itry,ixt},fcutoff,bwthresh,globDb,frameDb);
		fest{itry,ixt}=medsmoterp(fest{itry,ixt},5);  %% extra med smoothing of frequencies
        
        % Try mgftrackmed4 to find four formants
% 		[fest4{itry,ixt},bwest4{itry,ixt},ampest4{itry,ixt}]=mgftrackmed4(4,fc{itry,ixt},bw{itry,ixt},ampdb{itry,ixt},fcutoff,bwthresh,globDb,frameDb);
% 		fest4{itry,ixt}=medsmoterp(fest4{itry,ixt},5);  %% extra med smoothing of frequencies
%         if ixt == 2 % only run with the higher number of coefs
%             [fest4{itry,ixt},bwest4{itry,ixt},ampest4{itry,ixt}] = mgftrackmed4(4,fc{itry,ixt},bw{itry,ixt},ampdb{itry,ixt},fcutoff,bwthresh,globDb,frameDb);
%             fest4{itry,ixt}=medsmoterp(fest4{itry,ixt},5);  %% extra med smoothing of frequencies
%         end
        if ixt == 2 % only run with one set of coefs
            [fest4{itry},bwest4{itry},ampest4{itry}] = mgftrackmed4(4,fc{itry,ixt},bw{itry,ixt},ampdb{itry,ixt},fcutoff,bwthresh,globDb,frameDb);
            fest4{itry}=medsmoterp(fest4{itry},5);  %% extra med smoothing of frequencies
        end
        
		%	fest
		% See what the tracker is doing
		if watchlevel>2
			figure(38+ixt)
			clf
			nct=size(fest{itry,ixt},2);
			fbaplot(taxsg,nct,fest{itry,ixt},bwest{itry,ixt},ampest{itry,ixt},fhi(itry),'tri')
			plot(taxsg,fc{itry,ixt},'*')
			title(['Analysis ', num2str(ixt)]);
			pausemsg
		end % if watch
	end % for ixt

	%
	% A pseudo correlation figure of merit for the concordance of the two coefficeint density tracs
	ff1=fest{itry,1};
	ff2=fest{itry,2};
	rfstable=1-sqrt(mean((ff1(:)-ff2(:)).^2))./std(ff1(:));



	% Fuzzy figure of merit... as
	% As missing is low (presence is high)
	% As continuity is high, as bw is reasonable , as amplitude it reasonable
% 	presence=1;
% 	bwreason=1;
% 	ampreason=1;
% 	contreason=1;
% 	distreason=1;
% 	rangereason=1;

    % GSM adapted to give per track scores
    presence = ones(1,3);
    bwreason = ones(1,3);
    ampreason = ones(1,3);
    contreason = ones(1,3);
    distreason = ones(1,3);
    rangereason = ones(1,3);
    
	for ift=1:3
        rfstable_this_track = 1-sqrt(mean((ff1(:,ift)-ff2(:,ift)).^2))./std(ff1(:,ift));
        
		there=find(bwest{itry,1}(:,ift)>0);
		if length(there)==0
			presence=0;
		else
			%presence=presence* length(there)/nt;
            presence(ift) = length(there)/nt;
		end
		if isnan(presence)
			disp NANPRESENCE
			% pausemsg
		end
		maxamp=max(ampest{itry,1}(there,ift));
		if presence==0
			ampreason=0; bwreason=0; contreason=0;
			score(itry)=0;
			break
		end
		if ift>1 & calcdist
			tthere=find(bwest{itry,1}(:,ift)>0 & bwest{itry,1}(:,ift-1)>0);
			fdist=abs(fest{itry,1}(tthere,ift)-fest{itry,1}(tthere,ift-1));
            %distreason=mean(interp1(fdistx,fdisty,fdist));
			distreason(ift) = mean(interp1(fdistx,fdisty,fdist));
		end
		%Current formants position within expected range
		festreltorange=(fest{itry,1}(there,ift)-ftrngmin(ift) )./(ftrngmax(ift)-ftrngmin(ift));
		%rangereason=rangereason*mean(interp1(frngx,frngy,festreltorange));
        rangereason(ift) = mean(interp1(frngx,frngy,festreltorange));
		
        % amp reason.. average peak amp should't be too far below the peak amplitude
		%ampreason=ampreason*mean(interp1(amptrpx,amptrpy,ampest{itry,1}(there,ift)-maxamp));
        ampreason(ift) = mean(interp1(amptrpx,amptrpy,ampest{itry,1}(there,ift)-maxamp));
        
		% reasonable badwidths  % CODE CORRECTED 60 hz or 6 percent of the frequency
		bwt=bwest{itry,1}(there,ift);
		bwexp=(bwt./max(60,0.06*fest{itry,1}(there,ift))); % expected bandwidths
        %bwreason=bwreason*mean(interp1(bwtrpx,bwtrpy,bwexp));
		bwreason(ift) = mean(interp1(bwtrpx,bwtrpy,bwexp));
        
		ft=fest{itry,1}(there,ift);
		cont=abs(diff(ft));
		%contreason=contreason*mean(interp1(contx,conty,cont));
        contreason(ift) = mean(interp1(contx,conty,cont));
        
        score_track(itry, ift) = rfstable_this_track * presence(ift) * bwreason(ift) * ampreason(ift) * contreason(ift);
        
	end % for ift
    presence = prod(presence);
    bwreason = prod(bwreason);
    ampreason = prod(ampreason);
    contreason = prod(contreason);
    distreason = prod(distreason);
    rangereason = prod(rangereason);

    %[Xlpc,faxlpc]=alpc2sgm(alpc{itry},gainsq{itry},fhi(itry)*2,df,fast,stype);
	% Target spectrum X
	%Xlpc+repmat(interp1(faxsg,demph,faxlpc),1,size(Xlpc,2)); %


	% The target spectrum at this curoff frequency to match.....(dont match above fcutoff);
	% Interpolate the emphasis function in the frequency range of range of Xtarg
	% The axis choice must be a subset of the smoothed axis, in case it is different
	% from the original spectrogram (sg) axis
	% note that fcutoff is lower 3/4 than fhi(itry)

	imaxtarg=max(find(faxsmo<=fcutoff));
	faxtarg=faxsmo(1:imaxtarg);
	Xtarg=Xsmodb(1:imaxtarg,:);
	Xdemph=repmat(interp1(faxsg,demph,faxtarg),1,size(Xtarg,2));
	EMPHCORRECT=0;
	if EMPHCORRECT
		Xtarg=Xtarg+Xdemph; % Re-define the target
		igr=1;
	else
		igr=0;
	end
	% suppose we
	[rabs,dbPred,dbRes,dBPerOct(itry)]=anbysynchk3(faxtarg,Xtarg,fest{itry,1},bwwin, igr);
	%	xFuzzyMGtrackPt2
	%%%%% SHOULD FILTER OUT NANs in scores....
	%% And should limit ranges to zeros

	score(itry)=rabs*presence*bwreason*ampreason*contreason*distreason*rangereason*rfstable;



	[maxscore,ibest]=max(score(1:itry));
	if ibest==itry
		dbPredSave=dbPred;
		XtargSave=Xtarg;
		faxtargSave=faxtarg;
	end
	scorecomps(itry,:)=[ score(itry), presence,bwreason,ampreason,contreason,distreason,rabs,rangereason,rfstable];

	%showbsettracks
	if watchlevel>=1
		dbgtracker4xshowtracks % invoke script
		pausemsg
		iFhiTarg
	end

end % for iFhiTarg hicutoff

% %WAITBAR
% close(hwait)

allTrialsRec.taxsg =taxsg;
allTrialsRec.fest =fest;
allTrialsRec.scorecomps =scorecomps;
allTrialsRec.f34cutoffs =f34cutoffs;
allTrialsRec.fname =fname;
allTrialsRec.dBPerOct =dBPerOct;
% if savealltrials
% 	save(fsaveTrialsName,'taxsg','fest','scorecomps', 'f34cutoffs','fname', 'dBPerOct');
% end
savefest=fest{ibest,1};
scorecompsbest=scorecomps(ibest,:);
f34cutoffbest=f34cutoffs(ibest);
bestRec.taxsg =taxsg;
bestRec.savefest =savefest;
bestRec.scorecompsbest =scorecompsbest;
bestRec.f34cutoffbest =f34cutoffbest;
bestRec.fname =fname;

allTrialsRec.fest4 = fest4;


%save(fsaveName,'taxsg','savefest','scorecompsbest', 'f34cutoffbest','fname');

return







