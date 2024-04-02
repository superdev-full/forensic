function [synsound, scaleAmp] = play_synthetic(Fs, taxsg, fest, f0, fscale)

if sum(f0)==0   % if f0 tracking failed this will prevent synthesiser from crashing
    f0=ones(size(f0))*50;
end

synsound= qdVowelResyn(Fs, taxsg, fest, f0, fscale);

soundsc(synsound,Fs);

return
