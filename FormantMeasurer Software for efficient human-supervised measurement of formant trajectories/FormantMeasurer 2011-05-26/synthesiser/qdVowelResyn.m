%  Saved from C:\NeareyMLTools\SiganDevel\qdVowelResyn.m 2006/10/12 15:18

function y=qdVowelResyn(Fs,tax,ff,f0,fscale,taxSgm,ampSgm)
%   function y=qdVowelResyn(Fs,tax,ff,f0,fscale,taxSgm,ampSgm)
% For later developemnt taxSgm and ampSgm.. for matching amplitudes
% synthesis
% For use with checkOneVTrack
%This takes no time at all
% This fills out with neutral values to max of 300 Hz below nyquist
% based on fscale
if nargin==0
    tax=[0:200]';
    Fs=11025;
    f0=interp1([0,tax(end)]',[120,80]',tax);
    ff(:,1)=interp1([0,tax(end)]',[750,250]',tax);
    ff(:,2)=interp1([0,tax(end)]',[1200,2250]',tax);
    ff(:,3)=interp1([0,tax(end)]',[2500,2600]',tax);
    fscale=1;
    y=qdVowelResyn(Fs,tax,ff,f0,fscale);
    return

end

    if nargin<4|isempty(fscale)
        use=~isnan(ff(:,3));
        fscale=mean(ff(use,3))/3000;
        if fscale<.9
            fscale=.9;
        end
    end
    %      disp beforeglot
    glotsource=qdvoicesource(Fs,tax,f0);
    %     disp afterglot

    % Unpreemphasized....
    % Fill out to nyquist --- omit pole too close to nyq

    Fn=Fs/2;


    nft=floor(Fn/(1000*fscale));

    f1Base=500*fscale;
    fBase=f1Base*2*(1:nft)-f1Base;
    if fBase(end)>Fn-300;
        fBase(end)=[];
        nft=nft-1;
    end

    nt=size(ff,1);
    nff=size(ff,2);
    ff=[ff,repmat(fBase((nff+1):nft),nt,1)];
    fbw=max(70,.06*ff);
    pole=ones(1,max(nft,nff));
    deltms=2; % GSM changed from 5 to martch tracking delta
    fuji=1;
%     disp beforeCasc
ffstart=ff(1,:);
    y=cascfilter(Fs,glotsource,tax,ff,fbw,pole,deltms,fuji);
%     disp aftercasc
    y(isnan(y))=[];

    % soundsc(ysyn{i},Fs);
    if nargin==0
        soundsc(y,Fs);
    end
end
