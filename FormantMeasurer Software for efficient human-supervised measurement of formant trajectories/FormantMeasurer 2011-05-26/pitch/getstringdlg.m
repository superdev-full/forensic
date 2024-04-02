%  Saved from C:\NeareyMLTools\tnguitools\getstringdlg.m 2006/10/12 15:18

function [str]=getstringdlg(promptstr,default)
% function [str]=getstringdlg(promptstr,default)
% Input a string via dialog box
% Copyrignt TM Nearey 2003-2005
if nargin<1|isempty(promptstr)
    promptstr='Enter string';
end
if nargin<2|isempty(default)
    default='No Default';
end
str='';
a=inputdlg({promptstr}, 'Inputstring',1,{default});
if ~isempty(a)
str=a{1};
end
