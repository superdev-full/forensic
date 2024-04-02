%set_up_screen

for I_monitors = 1:num_logical_monitors
    figure(I_monitors);

    % Word display axes
    hword_axes(I_monitors) = axes('OuterPosition',[0 0 1 1]);
    axis off
    drawnow
    
    % htext0: large messages
    htext0(I_monitors)=text(.5,.7,'','FontName',font_orthographic,'Fontsize',font_size, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'EraseMode','xor');

    if left_to_right
        % htext1,2,3: sentence for participant to read. htext6: optional IPA for participant
        htext1(I_monitors)=text(margin_shift,.7,'','FontName',font_orthographic,'Fontsize',font_size, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'EraseMode','xor');%, 'Color',[0 0 .75]);
        htext2(I_monitors)=text(.5,.7,'','FontName',font_orthographic,'Fontsize',font_size, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'EraseMode','xor');
        htext3(I_monitors)=text(.6,.7,'','FontName',font_orthographic,'Fontsize',font_size, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'EraseMode','xor');
        htext6(I_monitors)=text(.7,.6,'','FontName',font_IPA,'Fontsize',font_size, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'EraseMode','xor', 'Color',[0 .75 0]);
    else
        htext1(I_monitors)=text(1-margin_shift,.7,'','FontName',font_orthographic,'Fontsize',font_size, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'EraseMode','xor');%, 'Color',[0 0 .75]);
        htext2(I_monitors)=text(.5,.7,'','FontName',font_orthographic,'Fontsize',font_size, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'EraseMode','xor');
        htext3(I_monitors)=text(.4,.7,'','FontName',font_orthographic,'Fontsize',font_size, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'EraseMode','xor');
        htext6(I_monitors)=text(.3,.6,'','FontName',font_IPA,'Fontsize',font_size, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'EraseMode','xor', 'Color',[0 .75 0]);
    end
end

% htext4,5,7,9 counters etc. for researcher
htext9=text(.1,.08,'','Fontsize',14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'EraseMode','xor');
htext4=text(.1,.05,'','Fontsize',14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'EraseMode','xor');
htext5=text(.1,.02,'','Fontsize',14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'EraseMode','xor');
htext7=text(.6,.1,'','FontName',font_IPA,'Fontsize',30, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'EraseMode','xor', 'Color',[0 0 0]);


%waveform display axes
hwave_axis=axes('OuterPosition',[.67 0 .33 .25], 'Position',[.69 .03 .3 .22]);
plot(0,0,'w');
set(hwave_axis,'XTickLabel',[], 'YLim',[-1 +1]);
