figure;
for I_char = 0:300
    clf
    axis off
    text(.05,.5,num2str(I_char, '%X'),'FontName','Doulos SIL','FontSize',100)
    text(.6,.5,char(I_char),'FontName','Doulos SIL','FontSize',100)
    pause
end