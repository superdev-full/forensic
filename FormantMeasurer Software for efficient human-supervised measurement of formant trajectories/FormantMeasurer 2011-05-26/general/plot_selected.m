% plot_selected
figure(edittrackplot);
clf
% Plot upto f3 cuttoff
iif34cutoff=find(faxsmo>f34cutoffs(F3cutoffI));
iif34cutoff=iif34cutoff(1);
plotsgm(taxsg,faxsmo(1:iif34cutoff),XsmoDb(1:iif34cutoff,:));
hold on;
% Plot vowel beginning & end
plot([taxsg(1)+fromedge_ms,taxsg(1)+fromedge_ms],[faxsmo(1),faxsmo(end)],'w-')
plot([taxsg(end)-fromedge_ms,taxsg(end)-fromedge_ms],[faxsmo(1),faxsmo(end)],'w-')
%Plot formant tracks
hFormants=plot(taxsg,bestRec.savefest,'Marker','.','MarkerSize',15,'EraseMode','xor');

set(gca, 'Position', [.05 .05 .9 .9]);