%GetTracks

[bestRec,allTrialsRec,scorecompslabels,XsmoDb,faxsmo,score_track]=tracker4xpOneFile(ysound,Fs_10,f34cutoffs,NameSounds{soundI},watchlevel);

bestRec.taxsg=bestRec.taxsg-fromedge_ms;