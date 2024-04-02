%  Saved from /Users/nearey/NeareyMLTools/filetools/parsepath.m 2004/6/2 14:20

function [dirname,base,ext]=parsepath(fname,nofix)
%[dirname,base,ext]=parsepath(fname,nofix)
% parse a pathname into directory, filebasename and extension
% dirname if not empty will have : or \ or / attached
% ext if not empty will have . attached (only last . is parsed to ext);
% If fname is a cellarray of strings or string matrix, then
% outputs are cellarrays of strings of same dimension.
% Copyritght 2002-2004 T.M. Nearey

if nargin<2|isempty(nofix), nofix=0; end
if size(fname,1)>1 | iscellstr(fname);
     fname=cellstr(fname);
     nfname=length(fname);
     dirname=cell(1,nfname);
     base=dirname;
     ext=dirname;

     for i=1:length(fname);
          [dirname{i},base{i},ext{i}]=parsepath(fname{i},nofix);
     end
     return
end


fname=fliplr(deblank(fliplr(fname)));
fname=deblank(fname);
dirname=''; base=''; ext='';

maclike=0;pclike=0;unixlike=0;
numcol=length(findstr(fname,':'));
numbsl= length(findstr(fname,'\'));
numsl= length(findstr(fname,'/'));
if numcol>1|(numcol==1&numbsl==0)
	maclike=1;
elseif numbsl>0
	pclike=1;
elseif ~maclike & ~pclike & numsl>0
	unixlike=1;
end
 matches=sum(abs([maclike,unixlike,pclike]));
 if nargout==0
	 maclike
	 unixlike
	 pclike
	 matches
 end

if matches>1
	warning(['Cannot uniquely parse:' fname]);
	return
end
if matches==0
	per=findstr(fname,'.');
	if length(per)==0
		base=fname;
		return
	end
	iper=per(end);
	if iper>1
		base=fname(1:iper-1);
	end
	ext=fname(iper:end);
	return
end

if maclike % ds is directory separator
	ds=':';
elseif pclike
	ds='\';
elseif unixlike
	ds='/';
end
	ids=findstr(fname,ds);
	lastds=0;
	if length(ids)>0
		lastds=ids(end);
		dirname=fname(1:lastds);
	end
	nfname=length(fname);
	per=findstr(fname,'.');
	lastper=nfname+1;
	if length(per)>0
		lastper=per(end);
	end
	if nargout==0
		lastds
		lastper
	end
	baserange=lastds+1:lastper-1;
	if ~isempty(baserange)
		base=fname(baserange);
	end
	dirrange=1:lastds;
	if ~isempty(dirrange)
		dir=fname(dirrange);
	end
		extrange=lastper:nfname;
	if ~isempty(dirrange)
		ext=fname(extrange);
	end
	if ~nofix
		dirname=fixpath(dirname);
	end
	if nargout==0
		dirname
		base
		ext
	end
return



