%edit_pitch

mult=1;
add2F0=0;

donef0dlg=0;
while ~donef0dlg
    
    [str, dialog_cancelled] = getstringdlg_2({'Min Mimimum F0','Max Mimimum F0','Min Maximum F0','Max Maximum F0','multiply by','add','VoicingThreshold','SilenceThreshold','OctaveJumpCost','VoicedUnvoicedCost','OctaveCost'},...
        {num2str(min_minf0,'%0.0f'),num2str(max_minf0,'%0.0f'),num2str(min_maxf0,'%0.0f'),num2str(max_maxf0,'%0.0f'),num2str(mult,'%0.0f'),num2str(add2F0,'%0.0f'),num2str(VoicingThreshold,'%0.2f'),num2str(SilenceThreshold,'%0.2f'),num2str(OctaveJumpCost,'%0.2f'),num2str(VoicedUnvoicedCost,'%0.2f'),num2str(OctaveCost,'%0.2f')}, 'f0 parameters');
    
    if dialog_cancelled, break, end
    
    min_minf0=str2double(str{1}); if isempty(min_minf0) || min_minf0==0, min_minf0=25; end
    max_minf0=str2double(str{2}); if isempty(max_minf0) || max_minf0==0, max_minf0=100; end
    min_maxf0=str2double(str{3}); if isempty(min_maxf0) || min_maxf0==0, min_maxf0=150; end
    max_maxf0=str2double(str{4}); if isempty(max_maxf0) || max_maxf0==0, max_maxf0=300; end
    mult=str2double(str{5}); if isempty(mult) || mult==0, mult=1; end
    add2F0=str2double(str{6}); if isempty(add2F0) || add2F0>500, add2F0=0; end
    VoicingThreshold=str2double(str{7}); if isempty(VoicingThreshold) || VoicingThreshold<0, VoicingThreshold=0; end; if VoicingThreshold>1, VoicingThreshold=1; end
    SilenceThreshold=str2double(str{8}); if isempty(SilenceThreshold) || SilenceThreshold<0, SilenceThreshold=0; end; if SilenceThreshold>1, SilenceThreshold=1; end
    OctaveJumpCost=str2double(str{9}); if isempty(OctaveJumpCost) || OctaveJumpCost<0, OctaveJumpCost=0; end; if OctaveJumpCost>1, OctaveJumpCost=1; end
    VoicedUnvoicedCost=str2double(str{10}); if isempty(VoicedUnvoicedCost) || VoicedUnvoicedCost<0, VoicedUnvoicedCost=0; end; if VoicedUnvoicedCost>1, VoicedUnvoicedCost=1; end
    OctaveCost=str2double(str{11}); if isempty(OctaveCost) || OctaveCost<0, OctaveCost=0; end; if OctaveCost>1, OctaveCost=1; end
    
    % test values
    invalid_input = false;
    err_str = '';
    test_f0_values
    if invalid_input
        beep
        h_warn = warndlg(sprintf(err_str), 'Invalid options', 'modal');
        uiwait(h_warn);
    else
        donef0dlg=1;
    end
end

if ~dialog_cancelled
    get_f0
    f0 = cellfun(@(x) x*mult+add2F0, f0, 'UniformOutput', false);
    plot_f0
end
