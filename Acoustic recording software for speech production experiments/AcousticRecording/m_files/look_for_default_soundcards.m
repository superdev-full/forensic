% look_for_default_soundcards
%load cell array col1: cardnames col2: peak amplitude scaling factor
fid=fopen('.\InitiationFiles\soundcard_ini.txt');
soundcard_ini=textscan(fid,'%s %f', 'delimiter','\t'); 
fclose(fid);
preferred_soundcards=soundcard_ini{:,1};
preferred_soundcard_scalers=soundcard_ini{:,2};

SoundCard=daqhwinfo('winsound');
board_names=SoundCard.BoardNames(:);

cardindex_default=[];
num_preferred_soundcards=length(preferred_soundcards);
I_preferred_soundcards=0;
while isempty(cardindex_default) && I_preferred_soundcards<num_preferred_soundcards
    I_preferred_soundcards=I_preferred_soundcards+1;
    cardindex_default=find(strcmp(board_names,preferred_soundcards{I_preferred_soundcards})==1);
end
if isempty(cardindex_default), cardindex_default=1; end 