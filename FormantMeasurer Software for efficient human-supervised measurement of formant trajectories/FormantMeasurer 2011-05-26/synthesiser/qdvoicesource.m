function [g,bwSource,extra]= qdvoicesource(Fs,tf0, f0, ta0,a0dB,bwSourceIn,minPhaseSource,legacyBwSource,testme)
%function [g,bwSource,extra]= qdvoicesource(Fs,tf0, f0, ta0,a0dB,bwSourceIn,minPhaseSource,legacySource, testme)
% INPUT  - note major revision in default BwSource May 27 2010
% 1) Fs -sampling rate
% 2)  tf0 [ntf0 x 1] times  (ms) at which f0 is specified
% 3) f0  [ntf0 x 1] frequencies Hz of f0
% 4) ta0 [nta0 x 1] times at which a0dB is specified- if empty, then tf0 is
%  copied. {See older notes on length matching... csre conventions used}
% 5) a0dB [nta0 x 1] amplitude of source in db -- if scalar, then copied to
%                 length of ta0
% 6) bwSourceIn - bandwidth of pole at origin to produce -6 db/Oct tilt if
%       missing specified as Poq=.5;% average OQ of 50% of F0 proportionate Opening Quotient
%       bwSource=Fs/(T0SampAv*Poq) ;; where FsUpsam is upsampled sampling
%       rate and T0SampAv is T0SampAv=FsUpsam/F0Av; F0av is aveage of non
%       zero f0
%       returned as bwSource
% 7) minPhaseSource
% 8) legacyBwSource ... use old (incorrect) legacy bandwidth source default
%     calculation.
% 9) testme --boolean test (moved from arg 7 in ver 2.5)
%(Fs,tax,f0,oa_dB,ff,fscale,bw,maxft,minPhaseSource)
% Note this does NOT differentiate. Source AND radiation rolloff effects
% should be handled by source genertors (It is done automatically by
% default qdvoicesource.m, b
%------------------------------------
% OUTPUT
% g -glottal soruce waveforem
% bwSource -- copy of bwSourceIn if specified, othewise what is calculted
%   by default
% extra. record with following fields
%   FsUpsam -- upsampled sample rate
%   gUpsam -- upsampled version (4*Fs) of glottal source
%   pulseTrainUpsam -- pulsetrain underlying gUpsam;
%   cosUpsam -- upsampled FM cosine  
%   f0Instant -- instantaneous f0 at each sample point
%   taxF0Instant -- time axis (in ms) for instantaneous f0;
% --------------------
% Version 1.1  bad initial F0
% Version 2.1 March 15 2008.. default arguments changed, more output
% available. Adjusted location of first pulse. Fixed OQ
%    relaed bandwidthSource calcs
% This is an attempt to implement klatt88 impulsive voicing source in an
% 'anticausal' approximation filtering a time-reversed  impulsive source.
%  It uses an FM cosine to determine impulses times (glottal closing
%  instants).
% The underlying pulsetrain is timeshifted t by half a glottal period of the first non-zero f0 (a better
% appoximation might be to shift back by OQ * T0.
% The result is again gime reveresed and the padding is clipped
%     off the end of output glottal source and upsampled glottal source)
% This means we the 'opening phase is taken to begin that many samples
% before the nominal time specification of the current f0.
% Version 2.5 Feb 4 2010
%    minPhaseSource boolean if 1, then bypass time reversal producing Klatt
%    80 like source.
% Important revision ---------
% % Version 2.6  27 May 2010....  BwSource computation corrected  documentation changes only
% --------
% Older notes ::
% tf0- time in ms for f0 knots
% f0- f0 knots Hz
% Fs - sampling rate Hz
% ta0 time knots for amplitude of f0
% a0dB - overall amplitude knots in dB translated to pulse height (10^(dB/20))
% A modified version of Kiefte's thesis Klatt80 source
% Modifications... higher sample rate, downsampled (a la klatt88)
% Variable F0. Use peakpicking on fm sinewave
% backwards IIR sampling to give more glottal like waveshape
% pads begining by 1/f0(1) sec and trims that off the end...
%
% Uses F0 average for the filter to determine the glottal shaping parameter
% Also... differentiates
% ta0 and a0dB are optional arguments for an amplitude contour
% It is interpolated linearly to samples and applied to pulse train.
% it may have a different time line than
% The shorter one on either end is extended before interpolations
testedOnce=0;
extra=[];

if nargin==0
    testqdvoicesource
    return
else
    error(nargchk(3, 9, nargin))
end
if nargin<8
    legacyBwSource=0;
end
if nargin<9||isempty(testme)
    testme=0;
end
if nargin<7|| isempty(minPhaseSource)
    minPhaseSource=0;
end
if nargin<6
    bwSourceIn=[];
end
tf0=tf0(:);
f0=f0(:);
if nargin<4
    ta0=tf0;
    a0dB=ones(size(ta0));
end
if isempty(ta0);
    ta0=tf0;
end
% if nargin==4  % shift over
% 	a0dB=ta0(:);
% 	ta0=tf0;
% end
if nargin==5 && isempty(ta0)
    a0dB=a0dB(:);
    ta0=tf0;
end
a0dB=a0dB(:);
ta0=ta0(:);

if length(a0dB)~=length(ta0)
    if length(a0dB)==1
        a0dB=a0dB(ones(length(ta0),1));
    else
        error('  vector a0dB does not match number of time knots in ta0 (or tf0)')
    end
end

% Copy on values if one time axis is longer than another
tmin=min(min(ta0),min(tf0));

if tmin<min(ta0);
    ta0=[tmin;ta0];
    a0dB=[a0dB(1);a0dB];
end
if tmin<min(tf0);
    tf0=[tmin;tf0];
    f0=[f0(1);f0];
end
tmax=max(max(ta0),max(tf0));
if tmax>max(ta0);
    ta0=[ta0;tmax];
    a0dB=[a0dB;a0dB(end)];
end
if tmax>max(tf0);
    tf0=[tf0;tmax];
    f0=[f0;f0(end)];
end
% nframe=length(tf0);
% Upsample FS by integer least 40 Khz.
nupsam=ceil(40000/Fs);

FsUpsam=nupsam*Fs;
tau=1/FsUpsam;

dursec=(tmax-tmin)/1000;
tt=[0:tau:dursec]';

ft=interp1((tf0-tmin)/1000,f0(:),tt);

at=interp1((ta0-tmin)/1000,a0dB(:),tt);
% NB Dbized here.
at=10.^(at./20);

% Find first non-zero f0 % Version 2.1 March 15 2008..
% Determinse how far to shift first glottal pulse CLOSING point over.
% This is set at 1/half the period of the first non-zero f0 specificaton.
% We will pad with this many zeros before entier sequence
% That way, after we reverse the time sequence after filtering,
% we'll have opening ariflow for a single pulse before that ( note
% this implies open glottis before hand
% Use of cosine insures impulse closing point is at the first sample



iFirstF0=find(f0>0, 1);
if ~isempty(iFirstF0)
    f0Base=f0(iFirstF0);
end
% avoid bad initial f0;
if isempty(f0Base)|isnan(f0Base)
    f0Base=100;
end



    npad=round(1/f0Base*FsUpsam/2); % Divide by 2 for OQ of .5 (default) smarter system would adjust this to OQ

    % Version 2.5 ...  pad on a single 0 if minPhaseSource
    if minPhaseSource
        npadHead=1;
        npadTail=npad-1;
    else
        npadHead=npad;
        npadTail=0;
    end
% Generate an FM cosine sequence. Cosine with padding will give us a  peak
% at first sample +npad if f0(1) is not zero...
% What implicatins does this have for exact location of glottal pulses
% otherwise?
g=cos(2*pi*tau*cumsum(ft));

% Pad with npad zeros... glottal pulse delayed?
g=[zeros(npadHead,1);g;zeros(npadTail,1)];

if nargout>2
    % copy on the first f0
    extra.f0Instant=[ft(ones(npad,1));ft];
    extra.taxF0Instant=(0:length(g)-1)'/FsUpsam*1000;
    extra.cosUpsam=g;
end
at=[zeros(npadHead,1);at;zeros(npadTail,1)];
if testme
    figure
    plot(tt*1000,ft);
    title('f0 interpolated')
    drawnow
   figinput(' f0 interpolated')
    figure
    plot(g)
    title('freqmodsinusoid')
   figinput(' freqmodsinusoid click to continue')
    
end

g(2:end-1)=g(1:end-2)<g(2:end-1)&g(3:end)<=g(2:end-1);
g(1)=0;
g=g-mean(g);
g(end)=0;
% size(g)
% size(at)
g=g.*at; % modulate by amplitude
if nargout>2
    extra.pulseTrainUpsam=g;
    extra.FsUpsam=FsUpsam;
end
    g=diff([g;0]);

    if testme
        figure
        plot(g)
        soundsc(g,FsUpsam);
        title('Pulse train')
      figinput( 'pulse train ')
    end


    F0Av=mean(f0(f0>0));
    T0SampAv=FsUpsam/F0Av;
    Poq=.5;% average OQ of 50% of F0 proportionate Opening Quotient

    % FsUpsam
    % F0AV
    tstart=1;
    tend=length(g); % sample points
    % y=varfilterfuji( x,     tstart,tend,Fs,f,   fb,     pole,gain,dbg);
    if ~minPhaseSource % version 2.5
    g=flipud(g);
    end
    if nargin<6||isempty(bwSourceIn)
        %%% Check against Klatt MS
         % Klatt's formula (sensimetrics distribution of klatt88 lab manual
      %Klatts original formulation F0 = f0 *10. (integer  f0 control )
      % T0 = ceil(Fs*10/F0) = ceil(Fs/f0); (3.11)
      % But later he says use the upsampled value
      % BWimp= Fs/(T0*OQ/100)  (3.19)

      % Earlier Version.. probalby worng
%         bwSource=10000*F0AV/(FsUpsam*Poq) ;
% BWimp= Fs/(T0*OQ/100) 
     
   if legacyBwSource
        bwSource=Fs/(T0SampAv*Poq) ; 
        % I think this should be FsUpsam
   else % Reparied 27 May 2010
        bwSource=FsUpsam/(T0SampAv*Poq) ; 
   end
   
    else
        bwSource=bwSourceIn;
    end
%
    g=-varfilterfuji(g,tstart,tend,FsUpsam,0,bwSource,1);

    % adjust gain % Gives near constant gain near 300 Hz regardless of OQ
% 3.20 Aimp=Aimp*[1.0(.00833*T0*OQ/100).^2] % Makes gain at 200 Hz nearely
% constanat
   % g=g*(1.0+(.00833)*FsUpsam/F0AV*Poq).^2);
g=g.*(1.0+(0.00833.*T0SampAv*Poq).^2);

    if testme
        figure
        plot(g)
        title(' after filter, before downsample')
        soundsc(g,FsUpsam)
        figinput('after filter, before downsample')
    end
if ~minPhaseSource
    g=flipud(g);
end
    g((end-npad+1):end)=[];

    if nargout>2
        extra.gUpsam=g;
    end

    % hi freq should be pretty weak...just moving average rect window and downsample;
    b=1/nupsam*ones(1,nupsam);
    g=filter(b,1.0,g);
    g=g(1:nupsam:length(g));
    if any(isnan(g))
        [ta0,a0dB]
        [tf0,f0]
        figure
        plot(tt,at)
        title('tt,at')
        figure
        plot(tt,ft)
        title('tt,ft')
        more off
        if ~testedOnce
            qdvoicesource(Fs,tf0, f0, ta0,a0dB,1)
            testedOnce=1;
        end

    end
    return

    function testqdvoicesource
   closefigs
            Fs=10000;
        for ipass=1:2
            for jMin=[0,1]
                if ipass==1
                    t=[0,100]
                    f0=[100,100]
                    ta0=[0 100];
                    a0dB=[60,60]
                else
    a0dB=[50 65 65 10];
    t= [0,50,100 150 200,300 ]
    f0=[100,125,0 0  200,120];

    ta0=[25 100 150 300];
    a0dB=[50 65 65 10];
                end
    %function [g,bwSource,extra]= qdvoicesource(Fs,tf0, f0,
    %ta0,a0dB,bwSourceIn,minPhaseSource,testme)
 showvars(f0,a0dB,jMin)
 
    g = qdvoicesource(Fs,t, f0,ta0,a0dB,[],jMin,1);
    figure;
    plotsig([],g,Fs);

    soundsc(g,Fs)

    figure
    p=20*log10(abs(fft(g)));
    nspec=floor(length(p)/2+1);
    fax=linspace(0,Fs/2,nspec)';
    minp=min(find(fax>50));
    p((nspec+1):end)=[];
    p(1:(minp-1))=[];
    fax(1:(minp-1))=[];
    fax=log(fax)/log(2);
    plot(fax,p);
    xlabel('Octaves above 50 Hz')
    ylabel('dB')
    grid on;
    xx=fax(1); yy=p(1);
    xxl=xx; yyl=yy;
    while 1
        [xx,yy]=ginput(1);
        if isempty(xx)
            break
        end
        dbPerOct=(yyl-yy)/(xxl-xx);
        xxl=xx; yyl=yy;
        title([ ' Db/Oct = ' num2str(dbPerOct)]);
    end

figinput(' Click to continue')
    qdsgm(g,Fs)
    colorbar
                end
            end
    return
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 