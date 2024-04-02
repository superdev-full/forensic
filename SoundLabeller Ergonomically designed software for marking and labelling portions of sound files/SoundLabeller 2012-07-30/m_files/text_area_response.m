%text_area_response

% detect which labelling row the cursor is on
for rowI = num_marker_rows:-1:1
    if y < textline(rowI), break, end
end

% respond to according to the button which was pressed
switch button
    
    case mouse_set_mark %  fix nearest tempmark (primary mouse button)
        [C,I]=min(abs(tempmark-x));
        %if isempty(find(mark_fs{rowI} == tempmark(I), 1)) %if this point isn't already marked
        if ~any(mark_fs{rowI} == tempmark(I)) %if this point isn't already marked
            mark_fs{rowI} = [mark_fs{rowI}, tempmark(I)];
            mark_time{rowI} = [mark_time{rowI}, tempmark(I)./Fs-invFs];
            if isempty(mark_text{rowI}), mark_text{rowI}{1} = ''; else mark_text{rowI}{end+1}=''; end
            [mark_fs{rowI},XI] = sort(mark_fs{rowI});
            mark_time{rowI} = mark_time{rowI}(XI);
            mark_text{rowI} = mark_text{rowI}(XI);
            length_mark = length(mark_fs{rowI});
            % hmark{rowI}(length_mark) = plot([mark_fs{rowI}(XI(end)) mark_fs{rowI}(XI(end))],display_amp,'g');
            hmark{rowI}(length_mark,1) = plot([mark_fs{rowI}(XI(end)) mark_fs{rowI}(XI(end))], [minamp, maxamp], 'g');
            hmark{rowI}(length_mark,2) = plot([mark_fs{rowI}(XI(end)) mark_fs{rowI}(XI(end))], [textline(rowI+1), textline(rowI)], 'g');
            switch rem(rowI,3)
                case 1, line_style = '-';
                case 2, line_style = '--';
                case 0, line_style = ':';
            end
            set(hmark{rowI}(length_mark,1),'EraseMode','xor', 'LineStyle',line_style); % otherwise if there are an even number of xor lines in the same place they cancel each other out
            set(hmark{rowI}(length_mark,2),'EraseMode','xor');
            htext{rowI}(length_mark) = text(mark_fs{rowI}(XI(end)),textpos_y(rowI),mark_text{rowI}{XI(end)});
            set(htext{rowI}(length_mark),'EraseMode','xor');
            hmark_num{rowI}(length_mark) = text(mark_fs{rowI}(XI(end)),fixnumpos_y,'');
            set(hmark_num{rowI}(length_mark),'Color','g','EraseMode','xor')
            
            for markI = 1:length_mark
                set(hmark{rowI}(markI,1),'XData',[mark_fs{rowI}(markI) mark_fs{rowI}(markI)]);
                set(hmark{rowI}(markI,2),'XData',[mark_fs{rowI}(markI) mark_fs{rowI}(markI)]);
                set(htext{rowI}(markI),'Position',[mark_fs{rowI}(markI),textpos_y(rowI)],'String',mark_text{rowI}{markI});
                set(hmark_num{rowI}(markI),'Position',[mark_fs{rowI}(markI),fixnumpos_y],'String',num2str(mark_time{rowI}(markI),'%1.3f'));
            end
            
            if length_mark > 1,length_mark_adjusted = length_mark-1; else length_mark_adjusted = length_mark; end
            hmark_dur{rowI}(length_mark_adjusted) = text(mark_fs{rowI}(XI(end)),fixdurpos_y,'');
            set(hmark_dur{rowI}(length_mark_adjusted),'Color','g','EraseMode','xor')
            for markI = 1:length_mark-1
                set(hmark_dur{rowI}(markI),'Position',[mark_fs{rowI}(markI),fixdurpos_y],'String',num2str(mark_time{rowI}(markI+1)-mark_time{rowI}(markI),'%1.3f'))
            end %for markI=1:length(mark_fs)-1          
            
        end 
        
        
    case mouse_remove_mark % remove nearest fixedmark (secondary mouse button)
        if ~isempty(mark_fs{rowI})
            [C,I] = min(abs(mark_fs{rowI}-x));
            mark_fs{rowI}(I) = [];
            mark_time{rowI}(I) = [];
            mark_text{rowI}(I) = [];
            delete(hmark{rowI}(end,1)); %hmark{rowI}(end,1) = [];
            delete(hmark{rowI}(end,2)); %hmark{rowI}(end,2) = [];
            hmark{rowI}(end,:) = [];
            delete(htext{rowI}(end)); htext{rowI}(end) = [];
            delete(hmark_num{rowI}(end)); hmark_num{rowI}(end) = [];
            if ~isempty(hmark_dur{rowI}), delete(hmark_dur{rowI}(end)); hmark_dur{rowI}(end) = []; end
            length_mark=length(mark_fs{rowI});
            
            for markI = 1:length_mark
                set(hmark{rowI}(markI,1),'XData',[mark_fs{rowI}(markI) mark_fs{rowI}(markI)]);
                set(hmark{rowI}(markI,2),'XData',[mark_fs{rowI}(markI) mark_fs{rowI}(markI)]);
                set(htext{rowI}(markI),'Position',[mark_fs{rowI}(markI),textpos_y(rowI)],'String',mark_text{rowI}{markI});
                set(hmark_num{rowI}(markI),'Position',[mark_fs{rowI}(markI),fixnumpos_y],'String',num2str(mark_time{rowI}(markI),'%1.3f'));
            end

            if length_mark>2
                for markI = 1:length_mark-1
                    set(hmark_dur{rowI}(markI),'Position',[mark_fs{rowI}(markI),fixdurpos_y],'String',num2str(mark_time{rowI}(markI+1)-mark_time{rowI}(markI),'%1.3f'));
                end 
            end
        end
        
        
    case key_play % play section (spacebar)
        [C,I] = find(mark_fs{rowI}<x);
        if isempty(I), startplay = display_section(1); I = 0; else startplay = round(mark_fs{rowI}(I(end))); end
        if I(end)+1 > length(mark_fs{rowI}), endplay = display_section(2); else endplay = round(mark_fs{rowI}(I(end)+1)); end
        wavplaysc(yy(startplay:endplay),Fs,'async')
        
        
    case 8 % backspace [hard coded]
        [C,I] = find(mark_fs{rowI}<x);
        if ~isempty(C) && ~strcmp(mark_text{rowI}{I(end)},'') && ~isempty(mark_text{rowI}{I(end)})
            mark_text{rowI}{I(end)}(end)=[];
            set(htext{rowI}(I(end)),'String',mark_text{rowI}{I(end)});
        end
        
        
    otherwise %insert text
        if allow_textlabels
            [C,I] = find(mark_fs{rowI}<x);
            if ~isempty(I)
                mark_text{rowI}{I(end)} = [mark_text{rowI}{I(end)},char(button)];
                set(htext{rowI}(I(end)), 'String',mark_text{rowI}{I(end)});
            end 
        else
            beep
        end
        
end