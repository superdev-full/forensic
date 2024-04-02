%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/anbysynchk3.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:WorkingFall2k1:NeareyTracker4xApr2k1:anbysynchk3.m 2002/11/6 19:5


function [rabs,dbPred,dbRes,dBPerOct]=anbysynchk3(fax,dbTarg,fest,bwwin, igr,hpcbas);
%function [rabs,dbPred]=anbysynchk3(fax,dbTarg,fest,bwwin, igr,<hpcbas>)
% analysis by synthesis checking
% return a normalized rms error (dB)
% and the dB predicted spectrum
% bwwin is bandwidth of window for inflating formant bw estimates
% Assume that fax is a spectrum with cutoff assumed to be half way between
% F3 and F4.. so high pole correction characteristics can be estimates
% Alternately, hpcbas can be specified with explicit neutral F1
%  if igr is 1, then glottal/radiation function is added
% 	to spectrum.. this should be applied to NON-PREEMPHASIZED
% 	or to DE-PREEMPHASIZED spectra
% Version 1.1 July 5 2002. Also returns the global db/Oct slope
oamag=1;
genharm=1;
nt=size(dbTarg,2);
f0syn=repmat(fax,1,nt);
fabs=fest(:,1:3);
fcutoff=max(fax);

Fs=fcutoff*2; % Don't need real Fs here
%bwabs= bsmo{ii}(:,1:3);
% use apriori bandwidths
bwabs=max(.07*fabs,70)+bwwin; % 7 pct of 70 hz + the window smear
%igr=1;
if nargin<6
	hpcbas=500*fax(end)/3000; %  fax(end) is assumed F3.5 frequency
end

hpcbas;

dbrng=[];
[xfrmag, fharm]=fcasc(Fs,f0syn,oamag,fabs,bwabs,genharm,fcutoff,hpcbas,igr,dbrng);
xfrmag(1,:)=xfrmag(2,:); % fix dc just incase

% let;s gain normalize... mag squared
Ppred=sum(xfrmag.^2);
[nf,nt]=size(xfrmag);

Ptarg=sum(10.^(dbTarg./10)); % total energy per time frame
%Ptarg./Ppred

dbPred= 20*log10(xfrmag)+repmat(10*log10(Ptarg./Ppred),nf,1); % gain match the frames

sizedbPred=size(dbPred);
sizedbTarg=size(dbTarg);

%dbPred=dbPred;


%  assumed to be preemphasized if igr is  so just peak normalize
%				plotsgm(taxSG,fax,dbN-dbPred);

% rabs=1-std(dbRes(:))/std(dbTarg(:)); % Hmmm this has overall gain in it as well

% db per octave above 200 Hz.. no correction below 200 hx
% discount everything below 50 Hz
% perhaps we should just truncate this a la olive... 500 hz above f3.
% We may have unnaturally high cutoffs.
%
ilo=min(find(fax>=50));
irng=[ilo:length(fax)]';

 dbRes=dbTarg(irng,:)-dbPred(irng,:);
% rabs=1-std(dbRes(:))./std(vec(dbTarg(irng,:))); This is bloody lousy... not sure why

% rr=corrcoef(vec(dbTarg(irng,:)),vec(dbPred(irng,:)))
%
% rabs=max(rr(1,2),0).^2

octabove=max(log(fax(irng))/log(2),0);
w=1;
[p,yhat,res] =  wtregA([vec(dbPred(irng,:)),vec(repmat(octabove,1,nt)),ones(length(irng)*nt,1)],vec(dbTarg(irng,:)),1);
dBPerOct=p(end-1);
rabs=1-std(res)./std(vec(dbTarg(irng,:)));
% Could also impose a 'db/oct tax';
% p


%rabs=1./std(dbRes(:));
% more flexible fit...
% in each slice y= x + a*oct+c
