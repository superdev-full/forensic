%  Saved from C:\NeareyMLTools\tnguitools\getstringdlg.m 2006/10/12 15:18

function [str, dialog_cancelled]=getstringdlg_2(promptstr,default,titlestr)
% function [str]=getstringdlg(promptstr,default)
% Input a string via dialog box
% Copyrignt TM Nearey 2003-2005
if nargin<1||isempty(promptstr)
    promptstr='Enter string';
end
if nargin<2||isempty(default)
    default='No Default';
end
if nargin<3||isempty(titlestr)
    titlestr='Enter string';
end
str='';
a=inputdlg(promptstr,titlestr,1,default);
if ~isempty(a) %~isempty(a{1}) && ~isempty(a{2})
    str=a;
    dialog_cancelled = false;
else
    str=default;
    dialog_cancelled = true;
end
