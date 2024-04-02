function playsoundfile(File,syn)

    if nargin<2
        syn='sync';
    end
    
    [y,fs] = wavread(File);  
    playsound(y,fs,syn);   %more robust version of wavplay in case there are problems with sound device
return