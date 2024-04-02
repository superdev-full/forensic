function TG=readTextGrid(TextGridFile);

[fidTextgrid,messageTextGrid]=fopen(TextGridFile,'rt');
if fidTextgrid==-1
     disp(['Sorry can''t find the file: ',TextGridFile])
     disp(messageTextGrid)
     return
end
TextGrid=fread(fidTextgrid);
fclose(fidTextgrid);
TextGrid=char(TextGrid)';

newline=10;
lineindex=findstr(newline,TextGrid);

textlab='text = "';
xminlab='xmin = ';
xmaxlab='xmax = ';

textlabindex=findstr(textlab,TextGrid);

item=0;
for ilabsearch=1:length(textlabindex)
    currentlineend=find(lineindex>textlabindex(ilabsearch));
    currenttext=TextGrid(textlabindex(ilabsearch)+8:lineindex(currentlineend(1))-3);
    if ~isempty(currenttext)
        item=item+1;
        TG(item).text=currenttext;
        searchstring=TextGrid(lineindex(currentlineend(1)-3)+1:lineindex(currentlineend(1)-2)-2);
        TG(item).xmin=str2num(searchstring(findstr('=',searchstring)+2:end));
        searchstring=TextGrid(lineindex(currentlineend(1)-2)+1:lineindex(currentlineend(1)-1)-2);
        TG(item).xmax=str2num(searchstring(findstr('=',searchstring)+2:end));
    end
end
return