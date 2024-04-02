function [y,glotsource,Fs,f0,oa_dB,ff,fscale,bw,maxft]=qdVowelSyn(Fs,tax,f0,oa_dB,ff,fscale,bw,maxft,minPhaseSource)
% function [y,glotsource,Fs,f0,oa_dB,ff,fscale,bw,maxft]=qdVowelSyn(Fs,tax,f0,oa_dB,ff,fscale,bw,maxft,minPhaseSource)
% Alterate % function
% [y,glotsource,Fs,f0,oa_dB,ff,fscale,bw,maxft]=qdVowelSyn(Fs,tax,sourceVectorSamples,'SourceGiven',ff,fscale,bw,maxft)
% Quick and dirty vowel synthesis. Formulaic bandwidths unless added at end
% % fscale is a scale factor to fill nyquist space with neutral formants
% 1.0 yields 500 hz base f1
% INPUT (if none, an [aI] is generated)
% 1) Fs - sample rate
% 2) tax - time axis [ntime x 1]
% 3) f0  - f0 [ntime x 1]
%        OR  (Version 2.1) a vector of source parameters to
%               filter if oa_dB is the string 'SourceGiven' It should be
%               approximately ms2samp(tax(end)-tax(1), Fs) samples long.
%               Voiced source components should be the preemphasized glottal
%               volume flow, as from qdVoiceSource.
%               Undifferentiated Gaussian noise should be right for whisper-source
% 4) oa_dB -overall db [ntime x 1]
%                OR (version 2.1) the string 'SourceGiven'
% 5) ff -formant frequncies [ntime x nft];
%% fscale scale factor relative to male = 1.0 (500 Hz base f1) This is used
%%      only to fill nyquist band with formants
% 6) bw - bandwidths
% 7) maxft - maximum number of formants. default what within Fs/2 given
%         uniform spacing.
%         Numerically things get bad otherwise
% 8) minPhaseSource - passed through to qdVoice source for Klatt 80 voice
%       source  1 for Klatt 80 source, 0 for maximum phase version
% OUTPUT
% y synthesized signal
% glotsource - source signal
% Fs,f0,oa_dB,ff,fscale,bw,maxft -- values actually used in synthesis
%  these will be filled in across time and ff and bw will be expanded
%   to fill Fs/2 band by simple rules
% Fs- copy of sampling rate (useful if called with no input args);
% Version 1.2 20 May 2006
% Version 1.3 14 may 2007 extra output args mainly for checking fill ins
% Version 2.1 15 March 2008... if oa_dB is the string 'SourceGiven', then f0
% Version 2.5 4 Feb 2009 extra argument minPhaseSource -- use Klatt 80 standard
% Version 2.6 Bandwidht fixed 27 May 2010
% -- 
%  phase  glottal pusles
% fileter
% is source to filter (returned in glotsource).
% See also qdvoicesource scaleQdVowelSyn

if nargin<2
    if nargout>0
        [y,glotsource,Fs]=testqdVowelSyn;
    else
        testqdVowelSyn;
    end;
    return
end
if nargin<3|isempty(f0), f0=120;end
if nargin<4|isempty(oa_dB),oa_dB=60;end
if nargin<5|isempty(ff),ff=[500 1500 2500] ;end

if nargin<6|isempty(fscale)
    nft=size(ff,2);
    use=~isnan(ff(:,nft));
    fexpected= (2*(nft-1)+1)*500;
    fscale=mean(ff(use,nft))/fexpected;
    if fscale<.9
        fscale=.9;
        warning('fscale truncated to 0.0 for formant fill')
    end
end
if nargin<7 | isempty(bw);
    bw=max(70,.06*ff); % fixed min changed to max 28 May 2010
end
if nargin<8|isempty(maxft)
    maxft=10;
    % we get glitches otherwise
end
if nargin<9 | isempty (minPhaseSource)
   minPhaseSource=0;
end
shouldSynGlotSource=~upequal(oa_dB,'SOURCEGIVEN');

ntime=length(tax);
onz=ones(ntime,1);

ff=filltime(ff,onz);
bw=filltime(bw,onz);
if shouldSynGlotSource
    f0=filltime(f0,onz);
    oa_dB=filltime(oa_dB,onz);
    %function [g,bwSource,extra]= qdvoicesource(Fs,tf0, f0,
    %ta0,a0dB,bwSourceIn,minPhaseSource,testme)
    glotsource=qdvoicesource(Fs,tax,f0,tax,oa_dB,[],minPhaseSource);
else
    if isvector(f0)
        glotsource=f0(:);
        durSource=samp2ms(length(glotsource),Fs);
        durTax=tax(end)-tax(1);
        if abs(durSource-durTax)>1
            warning(sprintf(' Dur of input source (%d ms) is differnt from duration requested in tax (%d ms)',durSource,durTax));
        end
    else
        error(' If "oa_dB" is string "SourceGiven", then f0 should be a vector')
    end
end % if shouldSynGlotSource


%     disp afterglot

% Unpreemphasized....
% Fill out to nyquist --- omit pole too close to nyq

Fn=Fs/2;


nft=floor(Fn/(1000*fscale));
nft=min(nft,maxft);
f1Base=500*fscale;

fBase=f1Base*2*(1:nft)-f1Base;

done=0;
% Get rid of any bad inserts
while ~done
    if fBase(end)>Fn-300;
        fBase(end)=[];
        nft=nft-1;
    else
        done=1;
    end
end % while

nt=size(ff,1);
nff=size(ff,2);
% Find first base > max +ff + 300
fbw=bw;
nffxtra=min(find(fBase>300+max(ff(:,end))));
if ~isempty(nffxtra);
    nffxtra= max(nffxtra,nff+1);
    ff=[ff,repmat(fBase((nffxtra):nft),nt,1)];
    fbw=[fbw,.06*repmat(fBase((nffxtra):nft),nt,1)];
end


if 0
    figure(39)
    plot(ff)
    %     pausemsg('showing formants');
end




pole=ones(1,max(nft,nff));
deltms=min(min(abs(diff(tax))),5);
% deltms=5;
% Let's see what happens here
fuji=1;
%     disp beforeCasc
% ffstart=ff(1,:)
% Fs
% keyboard
y=cascfilter(Fs,glotsource,tax,ff,fbw,pole,deltms,fuji);
%     disp aftercasc
y(isnan(y))=[];

% soundsc(ysyn{i},Fs);
function x=filltime(x,onz)
if size(x,1)==1
    x=x(onz,:);
end
return

function [y,glotsource,Fs]=testqdVowelSyn
dbstop if error
tax=[0:200]';
Fs=11025
oa_dB=interp1([0,tax(end)]',[60,50]',tax);
f0=interp1([0,tax(end)]',[120,80]',tax);
ff(:,1)=interp1([0,tax(end)]',[750,250]',tax);
ff(:,2)=interp1([0,tax(end)]',[1200,2250]',tax);
ff(:,3)=interp1([0,tax(end)]',[2500,2600]',tax);
fscale=1;
% 
% function [y,glotsource,Fs,f0,oa_dB,ff,fscale,bw,maxft]=
% qdVowelSyn(Fs,tax,f0,oa_dB,ff,fscale,bw,maxft,minPhaseSource)
[y,glotsource]=qdVowelSyn(Fs,tax,f0,oa_dB,ff,fscale,[],[],1);
playscpad(y,Fs);
noiseSource=randn(size(y));
% Not necessary to differentiate here.
% See Klatt and Klatt 1990
[yNoise]=qdVowelSyn(Fs,tax,noiseSource,'SourceGiven',ff,fscale);
pause(.3)
playscpad(yNoise,Fs);




return