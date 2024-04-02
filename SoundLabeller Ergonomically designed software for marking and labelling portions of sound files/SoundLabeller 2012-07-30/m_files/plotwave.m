% plotwave

% calculate and set the height of the wave plotbox and positioning of text area
subplot(h_subplot_wave);
plot(yy)
minamp = min(yy(display_section(1):display_section(2)))*1.01;
maxamp = max(yy(display_section(1):display_section(2)))*1.01;
range_amp = maxamp - minamp;
text_area_size = range_amp * .25; % <<controls what proportion of the wave plotbox is used for text labels
display_amp = [minamp - text_area_size, maxamp];
display_amp_range = display_amp(2) - display_amp(1);
try
    ylim(display_amp)
end

% calculate locations for time display above and below wave plotbox
numpos_y = display_amp(2) + display_amp_range * .041;
durpos_y = display_amp(2) + display_amp_range * .082;
fixnumpos_y = display_amp(1) - display_amp_range * .041;
fixdurpos_y = display_amp(1) - display_amp_range * .082;

% set the width of the wave plotbox
xlim(display_section)
display_ticks = [display_section(1):(display_section(2)-display_section(1))/11:display_section(2)];
display_times = str2num(num2str(display_ticks./Fs-invFs,'%1.3f'));
set(gca, 'xtick',display_ticks, 'XTickLabel',display_times);
hold on

% calculate and the locations for the lines and text for the text area, draw the lines
textline = NaN(num_marker_rows,1);
textpos_y = NaN(num_marker_rows,1);
for rowI = 1:num_marker_rows
    textline(rowI) = minamp - text_area_size*(rowI-1)/num_marker_rows;
    textpos_y(rowI) = textline(rowI) - text_area_size/num_marker_rows/2;
    plot(display_section,[textline(rowI) textline(rowI)],'g')
end
textline(rowI+1) = display_amp(1);

% plot the temporary markers
for markI=1:2
    htempmark(markI) = plot([tempmark(markI) tempmark(markI)],display_amp,'r');
    set(htempmark(markI),'EraseMode','xor');
    htempmark_num(markI) = text(tempmark(markI),numpos_y,num2str(tempmark(markI)/Fs-invFs,'%1.3f'));
    set(htempmark_num(markI),'Color','r','EraseMode','xor')
end 
htempmark_dur = text(tempmark(1),durpos_y,num2str((tempmark(2)-tempmark(1))/Fs-invFs,'%1.3f'));
set(htempmark_dur,'Color','r','EraseMode','xor')

% plot the permanent markers
for rowI = 1:num_marker_rows
    length_mark_fs_rowI = length(mark_fs{rowI});
    for markI=1:length_mark_fs_rowI
        % hmark{rowI}(markI) = plot([mark_fs{rowI}(markI) mark_fs{rowI}(markI)],display_amp,'g');
        hmark{rowI}(markI,1) = plot([mark_fs{rowI}(markI) mark_fs{rowI}(markI)], [minamp, maxamp], 'g'); % line over wave area
        hmark{rowI}(markI,2) = plot([mark_fs{rowI}(markI) mark_fs{rowI}(markI)], [textline(rowI+1), textline(rowI)], 'g'); % line over selected label row
        switch rem(rowI,3)
            case 1, line_style = '-';
            case 2, line_style = '--';
            case 0, line_style = ':';
        end
        set(hmark{rowI}(markI,1),'EraseMode','xor', 'LineStyle',line_style); % otherwise if there are an even number of xor lines in the same place they cancel each other out
        set(hmark{rowI}(markI,2),'EraseMode','xor'); 
        htext{rowI}(markI) = text(mark_fs{rowI}(markI), textpos_y(rowI), mark_text{rowI}{markI});
        set(htext{rowI}(markI),'EraseMode','xor');
        hmark_num{rowI}(markI) = text(mark_fs{rowI}(markI), fixnumpos_y, num2str(mark_time{rowI}(markI),'%1.3f'));
        set(hmark_num{rowI}(markI),'Color','g','EraseMode','xor')
    end  
    for markI = 1:length_mark_fs_rowI-1
        hmark_dur{rowI}(markI) = text(mark_fs{rowI}(markI), fixdurpos_y, num2str(mark_time{rowI}(markI+1)-mark_time{rowI}(markI),'%1.3f'));
        set(hmark_dur{rowI}(markI),'Color','g','EraseMode','xor')
    end 
    if ~isempty(hmark_dur{rowI}) && ~isempty(mark_fs{rowI})
        hmark_dur{rowI}(length_mark_fs_rowI)=text(mark_fs{rowI}(end),fixdurpos_y,'');
        set(hmark_dur{rowI}(length_mark_fs_rowI),'Color','g','EraseMode','xor')
    end 
end 