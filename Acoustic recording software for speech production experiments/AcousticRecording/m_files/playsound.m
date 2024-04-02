function playsound(y,fs,syn,channel)
% function playsound(y,fs,syn,channel)
% same as waveplay plus:
% 1. channel can be selected to be 'right', 'left', or 'both'
% 2. default is a soft beep 

if nargin<4
    channel='both';
end
if nargin<3
    syn='sync';
end
if nargin<2
    fs=44100;
end
if nargin==0
    protobeep=cos(2*pi*500./fs*[0:fs/8])';
    envelope=sin(2*pi*4./fs*[0:fs/8])';
    y=protobeep.*envelope*.35;
end

switch channel
    case 'left'
        y=[y,zeros(size(y))];
    case {'right' 'rigth'}
        y=[zeros(size(y)),y];
    case 'both'
        y=[y,y];
end

wavplay(y,fs,syn);

return