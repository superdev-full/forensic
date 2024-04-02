warning off MATLAB:iofun:UnsupportedEncoding;
fid = fopen('unicode_text.txt', 'r', 'l', 'UTF16-LE');
fseek(fid, 2, 0);
str = fscanf(fid, '%s')
abs(str)
fclose(fid);

text(.5,.5,str,'FontName','Times New Roman')
