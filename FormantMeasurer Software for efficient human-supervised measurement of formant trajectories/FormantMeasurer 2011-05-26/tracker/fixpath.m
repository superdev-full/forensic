%  Saved from /Users/nearey/NeareyMLTools/filetools/fixpath.m 2004/6/2 14:20

function newname=fixpath(fname,csys)
% newname=fixpath(fname)
%warning('fixpath has not been tested much');
%function newname=fixpath(fname <,csys>)
% Try to adjust pathname to computer
% csys is computer system MAC2, PCWIN, LNX86 or synonyms
% If not given (forced), it is read via 'COMPUTER' function
% Copyright 1999- 2002 TM Nearey.
% Forces filesep to end if name is recognized as directory
if nargin<2,
	csystem=computer;
	fsep=filesep;
else
	csys=upper(csys);
	switch csys
	case {'PC', 'PCWIN', 'WIN', 'WIN'}
	 csystem='PCWIN';
	 fsep='\';
 	case {'MAC2', 'MAC'}
	 csystem='MAC2';
	 fsep=':';
 	case {'LNX86', 'LINUX', 'UNIX'}
		csystem='LNX86';
 	otherwise
		warning('csys not recognized')
		disp('Recognized {PC PCWIN WIN}, {MAC, MAC2},{LNX86,LINUX<UNIX}')
		csystem=computer;
		fsep=filesep;
 	end
end



fname=fliplr(deblank(fliplr(fname)));
fname=deblank(fname);

newname=fname; % by default keep it the same

if strcmp(csystem,'MAC2')
		newname=strrep(newname,'\',':');
		newname=strrep(newname,'/',':');
		newname=strrep(newname,'::',':');
		if newname(1)==':', newname(1)=[]; end
elseif strcmp(csystem,'PCWIN')
		newname=strrep(newname,':','\');
		newname=strrep(newname,'/','\');
	    if newname(1)=='\',newname(1)=[]; end
		t1=findstr(newname,'\');
		if ~isempty(t1),
			t1=t1(1);
			newname=[newname(1:t1-1),':',newname(t1:end)];
		end
		newname=strrep(newname,'\\','\');
elseif strcmp(csystem,'LNX86')
		newname=strrep(newname,':','/');
		newname=strrep(newname,'\','/');
		newname=strrep(newname,'//','/');
		if newname(1)~='/', newname=['/',newname]; end

end
if exist(newname)==7% if it's a directory,,, add the filesep to it
	if newname(end)~=fsep,
		newname=[newname,fsep];
	end
end
return
