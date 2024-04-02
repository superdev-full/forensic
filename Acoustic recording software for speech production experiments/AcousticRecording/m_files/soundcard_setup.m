%soundcard setup
% global ao

soundcard_cleanup

% some soundcardsoutput less than the ±1 range
% scale input to account for this
% need to have run look_for_default_soundcards and buttons_radio first

preferred_soundcard_index=find(strcmp(preferred_soundcards,cardname_in)==1);
if ~isempty(preferred_soundcard_index)
    wav_scaler=1.01/preferred_soundcard_scalers(preferred_soundcard_index);
else
    wav_scaler=1;
end


fsRec=44100;
%bitrate=16;


%Pick soundcard
SoundCard=daqhwinfo('winsound');
cardindex_in=find(strcmp(SoundCard.BoardNames(:),cardname_in)==1)-1;

ai=analoginput('winsound',cardindex_in);

addchannel(ai,1);
% set(ai,'BitsPerSample',bitrate);
set(ai,'SampleRate',fsRec);
set(ai,'SamplesPerTrigger',fsRec*20); %maximum 20 seconds of recording

