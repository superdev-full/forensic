%  Saved from /Users/nearey/NeareyMLTools/SiganDevel/watchlevel.m 2004/6/2 14:20

function theWatchLevel=watchlevel(setwatchlevel);
persistent watchlev
if isempty(watchlev)
   watchlev=0;
end

if nargin>0 & ~isempty(setwatchlevel)
   watchlev=setwatchlevel;
end
theWatchLevel=watchlev;
return
