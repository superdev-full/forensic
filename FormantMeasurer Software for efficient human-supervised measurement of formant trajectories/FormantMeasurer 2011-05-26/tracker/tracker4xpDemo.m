%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/tracker4xpDemo.m 2004/6/2 14:20

function tracker4xpDemo(wavfile)
% Demonstrate tracker4xpOnefile....
% This implementation is too slow on most machines for practical
% interactive use.
% Note it is really only designed for mostly voiced speech
% It will track through moderate voiceless periods, but it was not designed
% to.
%  In production use, tracker4xp is used with a driver program that
% runs through a whole list of files and saves the returned arguments in
% orher files. These are then screened by a trained observer using
% ad-hoc graphics routines. and the 'good' measurements are saved for
% further study. If you have enough storage, this means you can batch up
% hundreds of files for later rapid interactive screening. Gives your computer
% something to do at night.
% Thie file HelloEh22050.wav I tried packaged with this file should
% provides a reasonable test case. F3 and F4 are farily close,  and they
% wobble around a bit.  Analysis 2 is preferred, though it appears to
% cut F3 a little short. Analysis 3 that puts the cutoff right at about
% average F4 clearly does the best job by my eyeballing. It probably
% didn't do as well because of the analysis by synthesis component of the
% figure of merit.. which would probably not like the extra energy at the
% top of the spectrum.
% This illustrates why several cutoffs need to be explored for even a
% single voice. It also illustrates why I want to explore other cutoff
% criteria. Cases where no single f3 f4 cutoff for a single utterance is
% satisfactory are not hard to come by.
thisdir=parsepath(which('tracker4XpDemo'));

if nargin==0
     try
          %wavfile=[thisdir,'HelloEh22050.wav'];
          wavfile=['C:\Documents and Settings\Geoff\My Documents\Desensitisation Hypothesis\Desensitisation Production Sound Files\Spanish bit-bid\SP06 bid 4.wav'];
     catch
          disp(['Sorry can''t find the test file: ',wavfile])
          disp('Call tracker4xpDemo(<WaveFileName>) where <WaveFileName> is a full path  name to a .wav file')
          return
     end
end
% f34 cutoffs are a list of expected cutoff frequencies above f3 but below
% f4. It is approximately  an upper bound for f3.
% Rule of thumb 3000 * sf where sf is scale factor for a voice relative to
% P&B standard male value. So 1.15 *3000  to 1.25 would be a good female range
%  and 2.0*3000 would be good for one-year old.
wavfile
[x,Fs]=wavread(wavfile);
num_f34cutoffs=6; %default was 6
max_f34cutoffs=4000; %default was 5000
f34cutoffs=round(exp(linspace(log(2000),log(max_f34cutoffs),num_f34cutoffs)));

watchlevel=0;
[bestRec,allTrialsRec,scorecompslabels,XsmoDb,faxsmo]=tracker4xpOneFile(x,Fs,f34cutoffs,wavfile,watchlevel);

figure(1)
clf
taxsg= bestRec.taxsg;
plotsgm(taxsg,faxsmo,XsmoDb);
hold on;
colorstr='bgr';
plot(taxsg,bestRec.savefest,'w','LineWidth',2) % white background
plot(taxsg,bestRec.savefest);
title(' Formant estimates with best figure of merit')


figure(2);
clf
subplotrc('tight')
% Plot all 6 alternatives with f34 cutoffs
nc=3; mr=2;
itry=0;
for ir=1:mr
     for ic=1:nc
          itry=itry+1;
          subplotrc(mr,nc,ir,ic);
          plotsgm(taxsg,faxsmo,XsmoDb);
          hold on;
          % Plot the f3 cutoff
          plot([taxsg(1),taxsg(end)],[f34cutoffs(itry),f34cutoffs(itry)],'w-.')
          plot(taxsg,allTrialsRec.fest{itry,1},'w','LineWidth',2) % white background
          plot(taxsg,allTrialsRec.fest{itry,1});
          tstr=sprintf('itry=%d, FoM=%6.4f,f34cut=%4d',itry,allTrialsRec.scorecomps(itry,1),f34cutoffs(itry));
          text(taxsg(1),faxsmo(end),tstr,'VerticalAlignment', 'top', 'HorizontalAlignment','left','Color','k','FontWeight','demi')
     end
end
