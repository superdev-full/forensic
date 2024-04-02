% test_f0_values

if isnan(min_minf0) || isnan(min_maxf0) || isnan(max_minf0) || isnan(max_maxf0) || min_minf0 >= max_minf0 || min_maxf0 >= max_maxf0 || max_minf0 >= min_maxf0
    err_str = [err_str, 'Invalid minimum or maximum F0 specification.\nReverting to defaults.\n'];
    [min_minf0, max_minf0, min_maxf0, max_maxf0] = deal(f0defaults{1:4});
    invalid_input = true;
end
if isnan(VoicingThreshold) || VoicingThreshold < 0 || VoicingThreshold > 1
    err_str = [err_str, 'Invalid voice threshold specification.\nReverting to defaults.\n'];
    [VoicingThreshold] = deal(f0defaults{5});
    invalid_input = true;
end
if isnan(SilenceThreshold) || SilenceThreshold < 0 || SilenceThreshold > 1
    err_str = [err_str, 'Invalid silence threshold specification.\nReverting to defaults.\n'];
    [SilenceThreshold] = deal(f0defaults{6});
    invalid_input = true;
end
if isnan(VoicedUnvoicedCost) || VoicedUnvoicedCost < 0 || VoicedUnvoicedCost > 1
    err_str = [err_str, 'Invalid voiced-voiceless cost specification.\nReverting to defaults.\n'];
    [VoicedUnvoicedCost] = deal(f0defaults{8});
    invalid_input = true;
end
if isnan(OctaveJumpCost) || OctaveJumpCost < 0 || OctaveJumpCost > 1
    err_str = [err_str, 'Invalid octave jump cost specification.\nReverting to defaults.\n'];
    [OctaveJumpCost] = deal(f0defaults{7});
    invalid_input = true;
end
if isnan(OctaveCost) || OctaveCost < 0 || OctaveCost > 1
    err_str = [err_str, 'Invalid octave cost specification.\nReverting to defaults.\n'];
    [OctaveCost] = deal(f0defaults{9});
    invalid_input = true;
end
