%more robust version of wavplay in case there are problems with sound device (adapted from Terry's plascpad (Copyright T. Nearey 2001))

%daq version of playsound

function playsound(y,fs,syn,channel)
global ao
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
        y=protobeep.*envelope;
    end
    
    played=0;
    ntry=0;
    delay=.1;
    
    switch channel
    case 'left'
        y=[y,zeros(size(y))];
    case 'right'
        y=[zeros(size(y)),y];
    case 'both'
        y=[y,y];
    end
    
    while ~played
%     	try
            putdata(ao,y);
            start(ao);
            switch syn
                case 'syn'
                    waittilstop(ao,30);
            end
    		played=1;
%     	catch
%     		ntry=ntry+1;
%     		delay=size(y,1)/fs;
%             delay=delay*ntry;
%             pause(delay);
%     		if ntry>5
%     			warning('Cannot play after 5 tries... giving up')
% 			return
% 		end
	end
return