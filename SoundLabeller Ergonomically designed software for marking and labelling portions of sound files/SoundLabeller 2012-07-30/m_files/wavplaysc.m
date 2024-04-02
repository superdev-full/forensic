function wavplaysc(yy,Fs,mode)

maxyy=max(abs(yy));
yysc=yy/maxyy;
wavplay(yysc,Fs,mode)

return