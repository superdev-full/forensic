function tracker4xpDemo_ar                                                                       
deMatArch('tracker4xpDemo_ar.m');                                                                
function deMatArch(farchname);                                                                   
%DeMatArch.m                                                                                     
% Dearchiver                                                                                     
% Dearchives self extracting files created by depfunArchive.m files                              
% Copyright(c) 2003 T.M. Nearey                                                                  
% Extract this from any textarchive and use it to dearchive the file                             
% Version 1.01 fixes filenames so there's no leading blank                                       
% Version 1.2 does not have blank line and works better with no graphics                         
% Searches for first %#-h-                                                                       
% strips away leading %# on any other line                                                       
% See neareyMLTools                                                                              
theFullName=which(farchname);                                                                    
[archDir,basename]=fileparts(theFullName);                                                       
if ~isequal(archDir(end),filesep)                                                                
     archDir(end+1)=filesep;                                                                     
end                                                                                              
newdir=[archDir,basename,'_dir'];                                                                
                                                                                                 
kmenu=2;                                                                                         
                                                                                                 
while kmenu==2                                                                                   
     kmenu=menu(['Creating de-archived files in: ',newdir],'OK','Try interactive','CANCEL');     
     if isequal(kmenu,2)                                                                         
          [fjnk,newdir]=uiputfile('*.*', 'Specify a dummy file in target  de-arched directory ');
     end                                                                                         
     if kmenu==3                                                                                 
          return                                                                                 
     end                                                                                         
end                                                                                              
                                                                                                 
                                                                                                 
if ~isequal(newdir(end),filesep)                                                                 
     newdir(end+1)=filesep;                                                                      
end                                                                                              
                                                                                                 
if ~isdir(newdir)                                                                                
     try % Makedir is stupid  parse parent and child if necessary                                
     fs=find(newdir==filesep);                                                                   
     if length(fs)<1                                                                             
          mkdir(newdir);                                                                         
     else                                                                                        
          ic=fs(end-1);                                                                          
          par=newdir(1:ic);                                                                      
          kid=newdir(ic+1:end);                                                                  
          mkdir(par,kid);                                                                        
     end                                                                                         
     disp(['Created ', newdir]);                                                                 
                                                                                                 
     catch                                                                                       
          error([ 'Cannot create ', newdir]);                                                    
     end                                                                                         
end                                                                                              
% pausemsg                                                                                       
[farch,errmsg]=fopen(theFullName);                                                               
if ~isempty(errmsg)                                                                              
     theFullName                                                                                 
     error(errmsg)                                                                               
end                                                                                              
                                                                                                 
fout=0;                                                                                          
done=0;                                                                                          
started=0;                                                                                       
while ~done                                                                                      
     tline=fgetl(farch);                                                                         
     if ~isstr(tline)                                                                            
          done=1;                                                                                
     end                                                                                         
                                                                                                 
     if ~done                                                                                    
          tline=deblank(tline);                                                                  
          [firstword,rest]=strtok(tline);                                                        
          if strcmp('%#-h-',firstword)                                                           
               started=1;                                                                        
               if fout~=0                                                                        
                    fclose(fout);                                                                
               end % if fout                                                                     
               % Trim edging blanks                                                              
               rest=fliplr(deblank(fliplr(deblank(rest))));                                      
               [tdir,file,ext]=fileparts(rest);                                                  
               fname=fullfile(newdir,[file,ext]);                                                
               disp(['Creating ' fname]);                                                        
               [fout,errmsg]=fopen(fname,'wt');                                                  
               if ~isempty(errmsg)                                                               
                    error(errmsg)                                                                
               end                                                                               
          elseif started                                                                         
               if length(tline)>=2 & isequal(tline(1:2),'%#')                                    
                    tline(1:2)=[];                                                               
               end                                                                               
               fprintf(fout,'%s\n', tline);                                                      
          end                                                                                    
     end % if ~done                                                                              
end %while not done                                                                              
try, fclose(fout); catch; end                                                                    
fclose(farch);                                                                                   
clear all                                                                                        
%showinmem('NeareyMLTools')                                                                      
% cut here--------------------------------------                                                 
% Unless otherwise noted, all programs and functions herien contained                            
% are copyright (C) 2004 by T.M. Nearey                                                          
% and are distributed under the GNU public licence below.                                        
% ******GNU PUBLIC LICENCE FOLLOWS******                                                         
% 		    GNU GENERAL PUBLIC LICENSE                                                               
% 		       Version 2, June 1991                                                                  
%                                                                                                
%  Copyright (C) 1989, 1991 Free Software Foundation, Inc.                                       
%                        59 Temple Place, Suite 330, Boston, MA  02111-1307  USA                 
%  Everyone is permitted to copy and distribute verbatim copies                                  
%  of this license document, but changing it is not allowed.                                     
%                                                                                                
% 			    Preamble                                                                                
%                                                                                                
%   The licenses for most software are designed to take away your                                
% freedom to share and change it.  By contrast, the GNU General Public                           
% License is intended to guarantee your freedom to share and change free                         
% software--to make sure the software is free for all its users.  This                           
% General Public License applies to most of the Free Software                                    
% Foundation's software and to any other program whose authors commit to                         
% using it.  (Some other Free Software Foundation software is covered by                         
% the GNU Library General Public License instead.)  You can apply it to                          
% your programs, too.                                                                            
%                                                                                                
%   When we speak of free software, we are referring to freedom, not                             
% price.  Our General Public Licenses are designed to make sure that you                         
% have the freedom to distribute copies of free software (and charge for                         
% this service if you wish), that you receive source code or can get it                          
% if you want it, that you can change the software or use pieces of it                           
% in new free programs; and that you know you can do these things.                               
%                                                                                                
%   To protect your rights, we need to make restrictions that forbid                             
% anyone to deny you these rights or to ask you to surrender the rights.                         
% These restrictions translate to certain responsibilities for you if you                        
% distribute copies of the software, or if you modify it.                                        
%                                                                                                
%   For example, if you distribute copies of such a program, whether                             
% gratis or for a fee, you must give the recipients all the rights that                          
% you have.  You must make sure that they, too, receive or can get the                           
% source code.  And you must show them these terms so they know their                            
% rights.                                                                                        
%                                                                                                
%   We protect your rights with two steps: (1) copyright the software, and                       
% (2) offer you this license which gives you legal permission to copy,                           
% distribute and/or modify the software.                                                         
%                                                                                                
%   Also, for each author's protection and ours, we want to make certain                         
% that everyone understands that there is no warranty for this free                              
% software.  If the software is modified by someone else and passed on, we                       
% want its recipients to know that what they have is not the original, so                        
% that any problems introduced by others will not reflect on the original                        
% authors' reputations.                                                                          
%                                                                                                
%   Finally, any free program is threatened constantly by software                               
% patents.  We wish to avoid the danger that redistributors of a free                            
% program will individually obtain patent licenses, in effect making the                         
% program proprietary.  To prevent this, we have made it clear that any                          
% patent must be licensed for everyone's free use or not licensed at all.                        
%                                                                                                
%   The precise terms and conditions for copying, distribution and                               
% modification follow.                                                                           
%                                                                                                
% 		    GNU GENERAL PUBLIC LICENSE                                                               
%    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION                             
%                                                                                                
%   0. This License applies to any program or other work which contains                          
% a notice placed by the copyright holder saying it may be distributed                           
% under the terms of this General Public License.  The "Program", below,                         
% refers to any such program or work, and a "work based on the Program"                          
% means either the Program or any derivative work under copyright law:                           
% that is to say, a work containing the Program or a portion of it,                              
% either verbatim or with modifications and/or translated into another                           
% language.  (Hereinafter, translation is included without limitation in                         
% the term "modification".)  Each licensee is addressed as "you".                                
%                                                                                                
% Activities other than copying, distribution and modification are not                           
% covered by this License; they are outside its scope.  The act of                               
% running the Program is not restricted, and the output from the Program                         
% is covered only if its contents constitute a work based on the                                 
% Program (independent of having been made by running the Program).                              
% Whether that is true depends on what the Program does.                                         
%                                                                                                
%   1. You may copy and distribute verbatim copies of the Program's                              
% source code as you receive it, in any medium, provided that you                                
% conspicuously and appropriately publish on each copy an appropriate                            
% copyright notice and disclaimer of warranty; keep intact all the                               
% notices that refer to this License and to the absence of any warranty;                         
% and give any other recipients of the Program a copy of this License                            
% along with the Program.                                                                        
%                                                                                                
% You may charge a fee for the physical act of transferring a copy, and                          
% you may at your option offer warranty protection in exchange for a fee.                        
%                                                                                                
%   2. You may modify your copy or copies of the Program or any portion                          
% of it, thus forming a work based on the Program, and copy and                                  
% distribute such modifications or work under the terms of Section 1                             
% above, provided that you also meet all of these conditions:                                    
%                                                                                                
%     a) You must cause the modified files to carry prominent notices                            
%     stating that you changed the files and the date of any change.                             
%                                                                                                
%     b) You must cause any work that you distribute or publish, that in                         
%     whole or in part contains or is derived from the Program or any                            
%     part thereof, to be licensed as a whole at no charge to all third                          
%     parties under the terms of this License.                                                   
%                                                                                                
%     c) If the modified program normally reads commands interactively                           
%     when run, you must cause it, when started running for such                                 
%     interactive use in the most ordinary way, to print or display an                           
%     announcement including an appropriate copyright notice and a                               
%     notice that there is no warranty (or else, saying that you provide                         
%     a warranty) and that users may redistribute the program under                              
%     these conditions, and telling the user how to view a copy of this                          
%     License.  (Exception: if the Program itself is interactive but                             
%     does not normally print such an announcement, your work based on                           
%     the Program is not required to print an announcement.)                                     
%                                                                                                
% These requirements apply to the modified work as a whole.  If                                  
% identifiable sections of that work are not derived from the Program,                           
% and can be reasonably considered independent and separate works in                             
% themselves, then this License, and its terms, do not apply to those                            
% sections when you distribute them as separate works.  But when you                             
% distribute the same sections as part of a whole which is a work based                          
% on the Program, the distribution of the whole must be on the terms of                          
% this License, whose permissions for other licensees extend to the                              
% entire whole, and thus to each and every part regardless of who wrote it.                      
%                                                                                                
% Thus, it is not the intent of this section to claim rights or contest                          
% your rights to work written entirely by you; rather, the intent is to                          
% exercise the right to control the distribution of derivative or                                
% collective works based on the Program.                                                         
%                                                                                                
% In addition, mere aggregation of another work not based on the Program                         
% with the Program (or with a work based on the Program) on a volume of                          
% a storage or distribution medium does not bring the other work under                           
% the scope of this License.                                                                     
%                                                                                                
%   3. You may copy and distribute the Program (or a work based on it,                           
% under Section 2) in object code or executable form under the terms of                          
% Sections 1 and 2 above provided that you also do one of the following:                         
%                                                                                                
%     a) Accompany it with the complete corresponding machine-readable                           
%     source code, which must be distributed under the terms of Sections                         
%     1 and 2 above on a medium customarily used for software interchange; or,                   
%                                                                                                
%     b) Accompany it with a written offer, valid for at least three                             
%     years, to give any third party, for a charge no more than your                             
%     cost of physically performing source distribution, a complete                              
%     machine-readable copy of the corresponding source code, to be                              
%     distributed under the terms of Sections 1 and 2 above on a medium                          
%     customarily used for software interchange; or,                                             
%                                                                                                
%     c) Accompany it with the information you received as to the offer                          
%     to distribute corresponding source code.  (This alternative is                             
%     allowed only for noncommercial distribution and only if you                                
%     received the program in object code or executable form with such                           
%     an offer, in accord with Subsection b above.)                                              
%                                                                                                
% The source code for a work means the preferred form of the work for                            
% making modifications to it.  For an executable work, complete source                           
% code means all the source code for all modules it contains, plus any                           
% associated interface definition files, plus the scripts used to                                
% control compilation and installation of the executable.  However, as a                         
% special exception, the source code distributed need not include                                
% anything that is normally distributed (in either source or binary                              
% form) with the major components (compiler, kernel, and so on) of the                           
% operating system on which the executable runs, unless that component                           
% itself accompanies the executable.                                                             
%                                                                                                
% If distribution of executable or object code is made by offering                               
% access to copy from a designated place, then offering equivalent                               
% access to copy the source code from the same place counts as                                   
% distribution of the source code, even though third parties are not                             
% compelled to copy the source along with the object code.                                       
%                                                                                                
%   4. You may not copy, modify, sublicense, or distribute the Program                           
% except as expressly provided under this License.  Any attempt                                  
% otherwise to copy, modify, sublicense or distribute the Program is                             
% void, and will automatically terminate your rights under this License.                         
% However, parties who have received copies, or rights, from you under                           
% this License will not have their licenses terminated so long as such                           
% parties remain in full compliance.                                                             
%                                                                                                
%   5. You are not required to accept this License, since you have not                           
% signed it.  However, nothing else grants you permission to modify or                           
% distribute the Program or its derivative works.  These actions are                             
% prohibited by law if you do not accept this License.  Therefore, by                            
% modifying or distributing the Program (or any work based on the                                
% Program), you indicate your acceptance of this License to do so, and                           
% all its terms and conditions for copying, distributing or modifying                            
% the Program or works based on it.                                                              
%                                                                                                
%   6. Each time you redistribute the Program (or any work based on the                          
% Program), the recipient automatically receives a license from the                              
% original licensor to copy, distribute or modify the Program subject to                         
% these terms and conditions.  You may not impose any further                                    
% restrictions on the recipients' exercise of the rights granted herein.                         
% You are not responsible for enforcing compliance by third parties to                           
% this License.                                                                                  
%                                                                                                
%   7. If, as a consequence of a court judgment or allegation of patent                          
% infringement or for any other reason (not limited to patent issues),                           
% conditions are imposed on you (whether by court order, agreement or                            
% otherwise) that contradict the conditions of this License, they do not                         
% excuse you from the conditions of this License.  If you cannot                                 
% distribute so as to satisfy simultaneously your obligations under this                         
% License and any other pertinent obligations, then as a consequence you                         
% may not distribute the Program at all.  For example, if a patent                               
% license would not permit royalty-free redistribution of the Program by                         
% all those who receive copies directly or indirectly through you, then                          
% the only way you could satisfy both it and this License would be to                            
% refrain entirely from distribution of the Program.                                             
%                                                                                                
% If any portion of this section is held invalid or unenforceable under                          
% any particular circumstance, the balance of the section is intended to                         
% apply and the section as a whole is intended to apply in other                                 
% circumstances.                                                                                 
%                                                                                                
% It is not the purpose of this section to induce you to infringe any                            
% patents or other property right claims or to contest validity of any                           
% such claims; this section has the sole purpose of protecting the                               
% integrity of the free software distribution system, which is                                   
% implemented by public license practices.  Many people have made                                
% generous contributions to the wide range of software distributed                               
% through that system in reliance on consistent application of that                              
% system; it is up to the author/donor to decide if he or she is willing                         
% to distribute software through any other system and a licensee cannot                          
% impose that choice.                                                                            
%                                                                                                
% This section is intended to make thoroughly clear what is believed to                          
% be a consequence of the rest of this License.                                                  
%                                                                                                
%   8. If the distribution and/or use of the Program is restricted in                            
% certain countries either by patents or by copyrighted interfaces, the                          
% original copyright holder who places the Program under this License                            
% may add an explicit geographical distribution limitation excluding                             
% those countries, so that distribution is permitted only in or among                            
% countries not thus excluded.  In such case, this License incorporates                          
% the limitation as if written in the body of this License.                                      
%                                                                                                
%   9. The Free Software Foundation may publish revised and/or new versions                      
% of the General Public License from time to time.  Such new versions will                       
% be similar in spirit to the present version, but may differ in detail to                       
% address new problems or concerns.                                                              
%                                                                                                
% Each version is given a distinguishing version number.  If the Program                         
% specifies a version number of this License which applies to it and "any                        
% later version", you have the option of following the terms and conditions                      
% either of that version or of any later version published by the Free                           
% Software Foundation.  If the Program does not specify a version number of                      
% this License, you may choose any version ever published by the Free Software                   
% Foundation.                                                                                    
%                                                                                                
%   10. If you wish to incorporate parts of the Program into other free                          
% programs whose distribution conditions are different, write to the author                      
% to ask for permission.  For software which is copyrighted by the Free                          
% Software Foundation, write to the Free Software Foundation; we sometimes                       
% make exceptions for this.  Our decision will be guided by the two goals                        
% of preserving the free status of all derivatives of our free software and                      
% of promoting the sharing and reuse of software generally.                                      
%                                                                                                
% 			    NO WARRANTY                                                                             
%                                                                                                
%   11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY                     
% FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN                       
% OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES                         
% PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED                     
% OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF                           
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS                      
% TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE                         
% PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,                       
% REPAIR OR CORRECTION.                                                                          
%                                                                                                
%   12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING                    
% WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR                            
% REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,                     
% INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING                    
% OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED                      
% TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY                       
% YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER                     
% PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE                          
% POSSIBILITY OF SUCH DAMAGES.                                                                   
%                                                                                                
% 		     END OF TERMS AND CONDITIONS                                                             
%#******END OF GNU PUBLIC LICENCE TEXT****                                                       
%#-h- filesArchived.txt                                                             
%#/Users/nearey/NeareyMLTools/FtrackTest/jnk.m                                      
%#/Users/nearey/NeareyMLTools/GraphTools/subplot_tight.m                            
%#/Users/nearey/NeareyMLTools/GraphTools/subplotrc.m                                
%#/Users/nearey/NeareyMLTools/SiganDevel/watchlevel.m                               
%#/Users/nearey/NeareyMLTools/Sigantools/alpc2sgm.m                                 
%#/Users/nearey/NeareyMLTools/filetools/fig.m                                       
%#/Users/nearey/NeareyMLTools/filetools/fixpath.m                                   
%#/Users/nearey/NeareyMLTools/filetools/parsepath.m                                 
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/anbysynchk3.m           
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/coswin.m                
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/dbgtracker4xshowtracks.m
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/fbaRoot.m               
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/fbaplot.m               
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/fcasc.m                 
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/getwin.m                
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/lagwin.m                
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/medsmoterp.m            
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/mgftrackmed.m           
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/parse.m                 
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/pausemsg.m              
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/playsc.m                
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/playsigsafe.m           
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/plotsgm.m               
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/r2lpc.m                 
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/sgm2alpcsel.m           
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/tracker4xpDemo.m        
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/tracker4xpOneFile.m     
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/tsfftsgm.m              
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/uigetpath.m             
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/vec.m                   
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/wavread.m               
%#/Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/wtregA.m                
%#-h- jnk.m                                                               
%  Saved from /Users/nearey/NeareyMLTools/FtrackTest/jnk.m 2004/6/2 14:20

%#zc=0:3000;                                                              
%#zcw=exp(-5*  ((zc-700)/1000).^4 );                                      
%#figure(37)                                                              
%#plot(zc,zcw);                                                           
%#                                                                        
%#-h- subplot_tight.m                                                                   
%  Saved from /Users/nearey/NeareyMLTools/GraphTools/subplot_tight.m 2004/6/2 14:20
    
%#function theAxis = subplot_tight(nrows, ncols, thisPlot, replace)                     
%#% Hacked version of subplot to reduce buffer size and NEVER kill siblings             
%#% Mainly use this through subplotrc.                                                  
%#% TMN                                                                                 
%#%SUBPLOT Create axes in tiled positions.                                              
%#%   H = SUBPLOT(m,n,p), or SUBPLOT(mnp), breaks the Figure window                     
%#%   into an m-by-n matrix of small axes, selects the p-th axes for                    
%#%   for the current plot, and returns the axis handle.  The axes                      
%#%   are counted along the top row of the Figure window, then the                      
%#%   second row, etc.  For example,                                                    
%#%                                                                                     
%#%       SUBPLOT(2,1,1), PLOT(income)                                                  
%#%       SUBPLOT(2,1,2), PLOT(outgo)                                                   
%#%                                                                                     
%#%   plots income on the top half of the window and outgo on the                       
%#%   bottom half.                                                                      
%#%                                                                                     
%#%   SUBPLOT(m,n,p), if the axis already exists, makes it current.                     
%#%   SUBPLOT(m,n,p,'replace'), if the axis already exists, deletes it and              
%#%   creates a new axis.                                                               
%#%   SUBPLOT(m,n,P), where P is a vector, specifies an axes position                   
%#%   that covers all the subplot positions listed in P.                                
%#%   SUBPLOT(H), where H is an axis handle, is another way of making                   
%#%   an axis current for subsequent plotting commands.                                 
%#%                                                                                     
%#%   SUBPLOT('position',[left bottom width height]) creates an                         
%#%   axis at the specified position in normalized coordinates (in                      
%#%   in the range from 0.0 to 1.0).                                                    
%#%                                                                                     
%#%   If a SUBPLOT specification causes a new axis to overlap an                        
%#%   existing axis, the existing axis is deleted - unless the position                 
%#%   of the new and existing axis are identical.  For example,                         
%#%   the statement SUBPLOT(1,2,1) deletes all existing axes overlapping                
%#%   the left side of the Figure window and creates a new axis on that                 
%#%   side - unless there is an axes there with a position that exactly                 
%#%   matches the position of the new axes (and 'replace' was not specified),           
%#%   in which case all other overlapping axes will be deleted and the                  
%#%   matching axes will become the current axes.                                       
%#%                                                                                     
%#%                                                                                     
%#%   SUBPLOT(111) is an exception to the rules above, and is not                       
%#%   identical in behavior to SUBPLOT(1,1,1).  For reasons of backwards                
%#%   compatibility, it is a special case of subplot which does not                     
%#%   immediately create an axes, but instead sets up the figure so that                
%#%   the next graphics command executes CLF RESET in the figure                        
%#%   (deleting all children of the figure), and creates a new axes in                  
%#%   the default position.  This syntax does not return a handle, so it                
%#%   is an error to specify a return argument.  The delayed CLF RESET                  
%#%   is accomplished by setting the figure's NextPlot to 'replace'.                    
%#                                                                                      
%#%   Copyright 1984-2002 The MathWorks, Inc.                                           
%#%   $Revision: 5.22 $  $Date: 2002/04/08 21:44:37 $                                   
%#                                                                                      
%#% we will kill all overlapping axes siblings if we encounter the mnp                  
%#% or m,n,p specifier (excluding '111').                                               
%#% But if we get the 'position' or H specifier, we won't check for and                 
%#% delete overlapping siblings:                                                        
%#%TMN HACK                                                                             
%#if nargin==0                                                                          
%#                                                                                      
%#    nr=3; nc=4;                                                                       
%#     for ii=1:nr*nc                                                                   
%#    subplot_tight(3,4,ii)                                                             
%#                                                                                      
%#    plot(1,1,'x')                                                                     
%#end                                                                                   
%#                                                                                      
%#fig                                                                                   
%#return                                                                                
%#end                                                                                   
%#SQUEEZE=4; % Factor by which to reduce the margins from original MATLAB choices       
%#ORIGINAL=0; % TMN ... if 1 then revert                                                
%#%END TMN HACK (Others below)                                                          
%#narg = nargin;                                                                        
%#kill_siblings = 0;                                                                    
%#create_axis = 1;                                                                      
%#delay_destroy = 0;                                                                    
%#tol = sqrt(eps);                                                                      
%#if narg == 0 % make compatible with 3.5, i.e. subplot == subplot(111)                 
%#    nrows = 111;                                                                      
%#    narg = 1;                                                                         
%#end                                                                                   
%#                                                                                      
%#%check for encoded format                                                             
%#handle = '';                                                                          
%#position = '';                                                                        
%#                                                                                      
%#if narg == 1                                                                          
%#    % The argument could be one of 3 things:                                          
%#    % 1) a 3-digit number 100 < num < 1000, of the format mnp                         
%#    % 2) a 3-character string containing a number as above                            
%#    % 3) an axis handle                                                               
%#    code = nrows;                                                                     
%#                                                                                      
%#    % turn string into a number:                                                      
%#    if(isstr(code))                                                                   
%#        code = str2double(code);                                                      
%#    end                                                                               
%#                                                                                      
%#    % number with a fractional part can only be an identifier:                        
%#    if(rem(code,1) > 0)                                                               
%#        handle = code;                                                                
%#        if ~strcmp(get(handle,'type'),'axes')                                         
%#            error('Requires valid axes handle for input.')                            
%#        end                                                                           
%#        create_axis = 0;                                                              
%#    % all other numbers will be converted to mnp format:                              
%#    else                                                                              
%#        thisPlot = rem(code, 10);                                                     
%#        ncols = rem( fix(code-thisPlot)/10,10);                                       
%#        nrows = fix(code/100);                                                        
%#        if nrows*ncols < thisPlot                                                     
%#            error('Index exceeds number of subplots.');                               
%#        end                                                                           
%# 	    kill_siblings = 1;                                                              
%#	    if(code == 111)                                                                  
%#	    create_axis   = 0;                                                               
%#	    delay_destroy = 1;                                                               
%#	    else                                                                             
%#	    create_axis   = 1;                                                               
%#	    delay_destroy = 0;                                                               
%#	    end                                                                              
%#    end                                                                               
%#                                                                                      
%#elseif narg == 2                                                                      
%#    % The arguments MUST be the string 'position' and a 4-element vector:             
%#    if(strcmp(lower(nrows), 'position'))                                              
%#        pos_size = size(ncols);                                                       
%#        if(pos_size(1) * pos_size(2) == 4)                                            
%#            position = ncols;                                                         
%#        else                                                                          
%#            error(['subplot(''position'',',...                                        
%#            ' [left bottom width height]) is what works'])                            
%#        end                                                                           
%#    else                                                                              
%#        error('Unknown command option')                                               
%#    end                                                                               
%#     kill_siblings = 1; % Kill overlaps here also.                                    
%#                                                                                      
%#elseif narg == 3                                                                      
%#    % passed in subplot(m,n,p) -- we should kill overlaps                             
%#    % here too:                                                                       
%#     kill_siblings = 1;                                                               
%#                                                                                      
%#elseif narg == 4                                                                      
%#    % passed in subplot(m,n,p,'replace') - probably                                   
%#    if strncmp(lower(replace),'replace',1)                                            
%#       kill_siblings = 2; % kill nomatter what                                        
%#    else                                                                              
%#        kill_siblings = 1; % kill if it overlaps stuff                                
%#    end                                                                               
%#end                                                                                   
%#                                                                                      
%#                                                                                      
%#                                                                                      
%#                                                                                      
%#% if we recovered an identifier earlier, use it:                                      
%#if(~isempty(handle))                                                                  
%#    set(get(0,'CurrentFigure'),'CurrentAxes',handle);                                 
%#% if we haven't recovered position yet, generate it from mnp info:                    
%#elseif(isempty(position))                                                             
%#    if (min(thisPlot) < 1)                                                            
%#        error('Illegal plot number.')                                                 
%#    elseif (max(thisPlot) > ncols*nrows)                                              
%#        error('Index exceeds number of subplots.')                                    
%#    else                                                                              
%#        % This is the percent offset from the subplot grid of the plotbox.            
%#                                                                                      
%#        if  ORIGINAL                                                                  
%#            PERC_OFFSET_L = 2*0.09;                                                   
%#        PERC_OFFSET_R = 2*0.045;                                                      
%#    else                                                                              
%#        PERC_OFFSET_L = 2*0.09/SQUEEZE;   % Just a guess tmn                          
%#        PERC_OFFSET_R = 2*0.045/SQUEEZE;                                              
%#    end                                                                               
%#                                                                                      
%#                                                                                      
%#        PERC_OFFSET_B = PERC_OFFSET_L;                                                
%#        PERC_OFFSET_T = PERC_OFFSET_R;                                                
%#        if nrows > 2                                                                  
%#            PERC_OFFSET_T = 0.9*PERC_OFFSET_T;                                        
%#            PERC_OFFSET_B = 0.9*PERC_OFFSET_B;                                        
%#        end                                                                           
%#        if ncols > 2                                                                  
%#            PERC_OFFSET_L = 0.9*PERC_OFFSET_L;                                        
%#            PERC_OFFSET_R = 0.9*PERC_OFFSET_R;                                        
%#        end                                                                           
%#                                                                                      
%#        row = (nrows-1) -fix((thisPlot-1)/ncols);                                     
%#        col = rem (thisPlot-1, ncols);                                                
%#                                                                                      
%#        % For this to work the default axes position must be in normalized coordinates
%#        if ~strcmp(get(gcf,'defaultaxesunits'),'normalized')                          
%#            warning('DefaultAxesUnits not normalized.')                               
%#            tmp = axes;                                                               
%#            set(axes,'units','normalized')                                            
%#            def_pos = get(tmp,'position');                                            
%#            delete(tmp)                                                               
%#        else                                                                          
%#            def_pos = get(gcf,'DefaultAxesPosition');                                 
%#        end                                                                           
%#                                                                                      
%#        % TMN GUESSING AGAIN                                                          
%#        % Take everything .6 of the way from where it is to max possible;             
%#        MAXPOS=[0 0 1 1];                                                             
%#        MAXDIST=abs(def_pos-MAXPOS);                                                  
%#        def_pos=.6* [-1 -1 1 1] .* MAXDIST + def_pos;                                 
%#        %%%%%%                                                                        
%#        col_offset = def_pos(3)*(PERC_OFFSET_L+PERC_OFFSET_R)/ ...                    
%#                                (ncols-PERC_OFFSET_L-PERC_OFFSET_R);                  
%#        row_offset = def_pos(4)*(PERC_OFFSET_B+PERC_OFFSET_T)/ ...                    
%#                                (nrows-PERC_OFFSET_B-PERC_OFFSET_T);                  
%#        totalwidth = def_pos(3) + col_offset;                                         
%#        totalheight = def_pos(4) + row_offset;                                        
%#        width = totalwidth/ncols*(max(col)-min(col)+1)-col_offset;                    
%#        height = totalheight/nrows*(max(row)-min(row)+1)-row_offset;                  
%#        position = [def_pos(1)+min(col)*totalwidth/ncols ...                          
%#                    def_pos(2)+min(row)*totalheight/nrows ...                         
%#                    width height];                                                    
%#        if width <= 0.5*totalwidth/ncols                                              
%#            position(1) = def_pos(1)+min(col)*(def_pos(3)/ncols);                     
%#            position(3) = 0.7*(def_pos(3)/ncols)*(max(col)-min(col)+1);               
%#        end                                                                           
%#        if height <= 0.5*totalheight/nrows                                            
%#            position(2) = def_pos(2)+min(row)*(def_pos(4)/nrows);                     
%#            position(4) = 0.7*(def_pos(4)/nrows)*(max(row)-min(row)+1);               
%#        end                                                                           
%#    end                                                                               
%#end                                                                                   
%#                                                                                      
%#% kill overlapping siblings if mnp specifier was used:                                
%#nextstate = get(gcf,'nextplot');                                                      
%#                                                                                      
%#if strncmp(nextstate,'replace',7)                                                     
%#    nextstate = 'add';                                                                
%#end                                                                                   
%#if(kill_siblings)                                                                     
%#    if delay_destroy                                                                  
%#        if nargout                                                                    
%#            error('Function called with too many output arguments')                   
%#        else                                                                          
%#            set(gcf,'NextPlot','replace');                                            
%#            return                                                                    
%#        end                                                                           
%#    end                                                                               
%#    sibs = datachildren(gcf);                                                         
%#    got_one = 0;                                                                      
%#    for i = 1:length(sibs)                                                            
%#        % Be aware that handles in this list might be destroyed before                
%#        % we get to them, because of other objects' DeleteFcn callbacks...            
%#        if(ishandle(sibs(i)) & strcmp(get(sibs(i),'Type'),'axes'))                    
%#            units = get(sibs(i),'Units');                                             
%#            set(sibs(i),'Units','normalized')                                         
%#            sibpos = get(sibs(i),'Position');                                         
%#            set(sibs(i),'Units',units);                                               
%#            intersect = 1;                                                            
%#            if((position(1) >= sibpos(1) + sibpos(3)-tol) | ...                       
%#                (sibpos(1) >= position(1) + position(3)-tol) | ...                    
%#                (position(2) >= sibpos(2) + sibpos(4)-tol) | ...                      
%#                (sibpos(2) >= position(2) + position(4)-tol))                         
%#                intersect = 0;                                                        
%#            end                                                                       
%#            if intersect                                                              
%#                % if already found the position match axis (got_one)                  
%#                % or if this intersecting axis doesn't have matching pos              
%#                % or if we know we want to make a new axes anyway (kill_siblings==2)  
%#                % delete it                                                           
%#                if got_one | ...                                                      
%#                        any(abs(sibpos - position) > tol) | ...                       
%#                        kill_siblings==2                                              
%#                    delete(sibs(i));                                                  
%#                    % otherwise, the intersecting sibs' pos matches subplot area      
%#                else                                                                  
%#                    got_one = 1;                                                      
%#                    set(gcf,'CurrentAxes',sibs(i));                                   
%#                    if strcmp(nextstate,'new')                                        
%#                        create_axis = 1;                                              
%#                    else                                                              
%#                        create_axis = 0;                                              
%#                    end                                                               
%#                end                                                                   
%#            end                                                                       
%#        end                                                                           
%#    end                                                                               
%#set(gcf,'NextPlot',nextstate);                                                        
%#end                                                                                   
%#                                                                                      
%#% create the axis:                                                                    
%#if create_axis                                                                        
%#    if strcmp(nextstate,'new')                                                        
%#        figure                                                                        
%#    end                                                                               
%#    ax = axes('units','normal','Position', position);                                 
%#    set(ax,'units',get(gcf,'defaultaxesunits'))                                       
%#else                                                                                  
%#    ax = gca;                                                                         
%#end                                                                                   
%#                                                                                      
%#% return identifier, if requested:                                                    
%#if(nargout > 0)                                                                       
%#    theAxis = ax;                                                                     
%#end                                                                                   
%#-h- subplotrc.m                                                                               
%  Saved from /Users/nearey/NeareyMLTools/GraphTools/subplotrc.m 2004/6/2 14:20
                
%#function h=subplotrc(mr,nc,r,c)                                                               
%#% function h=subplotrc(mr,nc,r,c)                                                             
%#% select the r-th row and c-th column of matlab subplot layout                                
%#% subplot(mr,nc)                                                                              
%#% Copyright 2003 TMN                                                                          
%#% If called with one argument == 'tight' (in any case), then tight mode is applied till turned
%#% off (Tight mode = narrow boarders)                                                          
%#% If tight, it calls the TMN hacked subroutint subplot_tight                                  
%#persistent mode                                                                               
%#if isempty(mode)                                                                              
%#    mode='REGULAR';                                                                           
%#end                                                                                           
%#if nargin==1                                                                                  
%#    if isequal(upper(mr),'TIGHT')                                                             
%#        mode='TIGHT';                                                                         
%#    else                                                                                      
%#        mode='REGULAR';                                                                       
%#    end                                                                                       
%#    return                                                                                    
%#end                                                                                           
%#                                                                                              
%#ith=c+nc*(r-1);                                                                               
%#if isequal(mode,'TIGHT')                                                                      
%#    th=subplot_tight(mr,nc,ith);                                                              
%#else                                                                                          
%#th=subplot(mr,nc,ith);                                                                        
%#end                                                                                           
%#if nargout>0                                                                                  
%#    h=th;                                                                                     
%#end                                                                                           
%#-h- watchlevel.m                                                               
%  Saved from /Users/nearey/NeareyMLTools/SiganDevel/watchlevel.m 2004/6/2 14:20

%#function theWatchLevel=watchlevel(setwatchlevel);                              
%#persistent watchlev                                                            
%#if isempty(watchlev)                                                           
%#   watchlev=0;                                                                 
%#end                                                                            
%#                                                                               
%#if nargin>0 & ~isempty(setwatchlevel)                                          
%#   watchlev=setwatchlevel;                                                     
%#end                                                                            
%#theWatchLevel=watchlev;                                                        
%#return                                                                         
%#-h- alpc2sgm.m                                                               
%  Saved from /Users/nearey/NeareyMLTools/Sigantools/alpc2sgm.m 2004/6/2 14:20

%#function [X,fax]=alpc2sgm(alpc,gainsq,Fs,df,fast,stype)                      
%#%function [X,fax]=alpc2sgm(alpc,gainsq,Fs,df,fast,stype)                     
%#%function [X,fax]=alpc2sgm(alpc,gainsq,Fs,df,fast,stype)                     
%#% for use after (eg. sgm2alpcsel)                                            
%#% assumes time axis of alpc and gain coeffs are known externally             
%#% alpc is ntimeslice x (lpcord+1) matrix                                     
%#% gainsq is ntimeslice x 1 vector                                            
%#% stype is one of DB POW MAG AMP or INVPOW                                   
%#% Copyright T.M. Nearey 1997-2001                                            
%#% Scale conversion bug fix 22 Nov 2001                                       
%#if nargin<5|isempty(fast)                                                    
%#	fast=1;                                                                     
%#end                                                                          
%#if nargin<6|isempty(stype)                                                   
%#	stype='DB';                                                                 
%#else                                                                         
%#	stype=upper(stype);                                                         
%#end                                                                          
%#switch stype                                                                 
%#case 'DB'                                                                    
%#case 'POW'                                                                   
%#case 'MAG', 'AMP'                                                            
%#case 'INVPOW'                                                                
%#otherwise                                                                    
%#	error('Stype must be one of {DB,POW,MAG(AMP),INVPOW}')                      
%#end                                                                          
%#nfft=2^nextpow2(ceil(Fs/df));                                                
%#nfold=nfft/2+1;                                                              
%#fax=linspace(0,Fs/2,nfold)';                                                 
%#if fast                                                                      
%#	X=abs(fft(alpc',nfft).^2); % note transpose                                 
%#	X(nfold+1:end,:)=[];                                                        
%#else                                                                         
%#	ncol=size(alpc,2);                                                          
%#	X=zeros(nfold,ncol);                                                        
%#	for i=1:ncol                                                                
%#		t=abs(fft(alpc(:,i),nfft).^2);                                             
%#		X(:,i)=t(1:nfold);                                                         
%#	end                                                                         
%#end                                                                          
%#% sizex=size(X)                                                              
%#% sizegainsq=size(gainsq)                                                    
%#% nfold                                                                      
%#                                                                             
%#switch stype                                                                 
%#% note transposes of gainsq                                                  
%#case 'DB'                                                                    
%#	X=-10*log10(X)+repmat(10*log10(gainsq'),nfold,1);                           
%#case 'POW'                                                                   
%#	X=(1./X).*repmat(gainsq',nfold,1); % Bug fixed... this had log              
%#case 'MAG', 'AMP'                                                            
%#	X=sqrt(1./X).*repmat(sqrt(gainsq)',nfold,1);                                
%#case 'INVPOW'                                                                
%#	X=X./repmat(gainsq',nfold,1);                                               
%#otherwise                                                                    
%#	error('Stype must be one of {DB,POW,MAG(AMP),INVPOW}')                      
%#end                                                                          
%#                                                                             
%#                                                                             
%#                                                                             
%#                                                                             
%#-h- fig.m                                                              
%  Saved from /Users/nearey/NeareyMLTools/filetools/fig.m 2004/6/2 14:20

%#function fig(argstr);                                                  
%#% activate a figure                                                    
%#if nargin==0|isempty(argstr)                                           
%#	figure(gcf)                                                           
%#	drawnow                                                               
%#elseif ischar(argstr)                                                  
%#	eval(['figure(',argstr,')']);                                         
%#	drawnow                                                               
%#else                                                                   
%#	figure(argstr)                                                        
%#	drawnow                                                               
%#end                                                                    
%#-h- fixpath.m                                                              
%  Saved from /Users/nearey/NeareyMLTools/filetools/fixpath.m 2004/6/2 14:20

%#function newname=fixpath(fname,csys)                                       
%#% newname=fixpath(fname)                                                   
%#%warning('fixpath has not been tested much');                              
%#%function newname=fixpath(fname <,csys>)                                   
%#% Try to adjust pathname to computer                                       
%#% csys is computer system MAC2, PCWIN, LNX86 or synonyms                   
%#% If not given (forced), it is read via 'COMPUTER' function                
%#% Copyright 1999- 2002 TM Nearey.                                          
%#% Forces filesep to end if name is recognized as directory                 
%#if nargin<2,                                                               
%#	csystem=computer;                                                         
%#	fsep=filesep;                                                             
%#else                                                                       
%#	csys=upper(csys);                                                         
%#	switch csys                                                               
%#	case {'PC', 'PCWIN', 'WIN', 'WIN'}                                        
%#	 csystem='PCWIN';                                                         
%#	 fsep='\';                                                                
%# 	case {'MAC2', 'MAC'}                                                     
%#	 csystem='MAC2';                                                          
%#	 fsep=':';                                                                
%# 	case {'LNX86', 'LINUX', 'UNIX'}                                          
%#		csystem='LNX86';                                                         
%# 	otherwise                                                                
%#		warning('csys not recognized')                                           
%#		disp('Recognized {PC PCWIN WIN}, {MAC, MAC2},{LNX86,LINUX<UNIX}')        
%#		csystem=computer;                                                        
%#		fsep=filesep;                                                            
%# 	end                                                                      
%#end                                                                        
%#                                                                           
%#                                                                           
%#                                                                           
%#fname=fliplr(deblank(fliplr(fname)));                                      
%#fname=deblank(fname);                                                      
%#                                                                           
%#newname=fname; % by default keep it the same                               
%#                                                                           
%#if strcmp(csystem,'MAC2')                                                  
%#		newname=strrep(newname,'\',':');                                         
%#		newname=strrep(newname,'/',':');                                         
%#		newname=strrep(newname,'::',':');                                        
%#		if newname(1)==':', newname(1)=[]; end                                   
%#elseif strcmp(csystem,'PCWIN')                                             
%#		newname=strrep(newname,':','\');                                         
%#		newname=strrep(newname,'/','\');                                         
%#	    if newname(1)=='\',newname(1)=[]; end                                 
%#		t1=findstr(newname,'\');                                                 
%#		if ~isempty(t1),                                                         
%#			t1=t1(1);                                                               
%#			newname=[newname(1:t1-1),':',newname(t1:end)];                          
%#		end                                                                      
%#		newname=strrep(newname,'\\','\');                                        
%#elseif strcmp(csystem,'LNX86')                                             
%#		newname=strrep(newname,':','/');                                         
%#		newname=strrep(newname,'\','/');                                         
%#		newname=strrep(newname,'//','/');                                        
%#		if newname(1)~='/', newname=['/',newname]; end                           
%#                                                                           
%#end                                                                        
%#if exist(newname)==7% if it's a directory,,, add the filesep to it         
%#	if newname(end)~=fsep,                                                    
%#		newname=[newname,fsep];                                                  
%#	end                                                                       
%#end                                                                        
%#return                                                                     
%#-h- parsepath.m                                                              
%  Saved from /Users/nearey/NeareyMLTools/filetools/parsepath.m 2004/6/2 14:20

%#function [dirname,base,ext]=parsepath(fname,nofix)                           
%#%[dirname,base,ext]=parsepath(fname,nofix)                                   
%#% parse a pathname into directory, filebasename and extension                
%#% dirname if not empty will have : or \ or / attached                        
%#% ext if not empty will have . attached (only last . is parsed to ext);      
%#% If fname is a cellarray of strings or string matrix, then                  
%#% outputs are cellarrays of strings of same dimension.                       
%#% Copyritght 2002-2004 T.M. Nearey                                           
%#                                                                             
%#if nargin<2|isempty(nofix), nofix=0; end                                     
%#if size(fname,1)>1 | iscellstr(fname);                                       
%#     fname=cellstr(fname);                                                   
%#     nfname=length(fname);                                                   
%#     dirname=cell(1,nfname);                                                 
%#     base=dirname;                                                           
%#     ext=dirname;                                                            
%#                                                                             
%#     for i=1:length(fname);                                                  
%#          [dirname{i},base{i},ext{i}]=parsepath(fname{i},nofix);             
%#     end                                                                     
%#     return                                                                  
%#end                                                                          
%#                                                                             
%#                                                                             
%#fname=fliplr(deblank(fliplr(fname)));                                        
%#fname=deblank(fname);                                                        
%#dirname=''; base=''; ext='';                                                 
%#                                                                             
%#maclike=0;pclike=0;unixlike=0;                                               
%#numcol=length(findstr(fname,':'));                                           
%#numbsl= length(findstr(fname,'\'));                                          
%#numsl= length(findstr(fname,'/'));                                           
%#if numcol>1|(numcol==1&numbsl==0)                                            
%#	maclike=1;                                                                  
%#elseif numbsl>0                                                              
%#	pclike=1;                                                                   
%#elseif ~maclike & ~pclike & numsl>0                                          
%#	unixlike=1;                                                                 
%#end                                                                          
%# matches=sum(abs([maclike,unixlike,pclike]));                                
%# if nargout==0                                                               
%#	 maclike                                                                    
%#	 unixlike                                                                   
%#	 pclike                                                                     
%#	 matches                                                                    
%# end                                                                         
%#                                                                             
%#if matches>1                                                                 
%#	warning(['Cannot uniquely parse:' fname]);                                  
%#	return                                                                      
%#end                                                                          
%#if matches==0                                                                
%#	per=findstr(fname,'.');                                                     
%#	if length(per)==0                                                           
%#		base=fname;                                                                
%#		return                                                                     
%#	end                                                                         
%#	iper=per(end);                                                              
%#	if iper>1                                                                   
%#		base=fname(1:iper-1);                                                      
%#	end                                                                         
%#	ext=fname(iper:end);                                                        
%#	return                                                                      
%#end                                                                          
%#                                                                             
%#if maclike % ds is directory separator                                       
%#	ds=':';                                                                     
%#elseif pclike                                                                
%#	ds='\';                                                                     
%#elseif unixlike                                                              
%#	ds='/';                                                                     
%#end                                                                          
%#	ids=findstr(fname,ds);                                                      
%#	lastds=0;                                                                   
%#	if length(ids)>0                                                            
%#		lastds=ids(end);                                                           
%#		dirname=fname(1:lastds);                                                   
%#	end                                                                         
%#	nfname=length(fname);                                                       
%#	per=findstr(fname,'.');                                                     
%#	lastper=nfname+1;                                                           
%#	if length(per)>0                                                            
%#		lastper=per(end);                                                          
%#	end                                                                         
%#	if nargout==0                                                               
%#		lastds                                                                     
%#		lastper                                                                    
%#	end                                                                         
%#	baserange=lastds+1:lastper-1;                                               
%#	if ~isempty(baserange)                                                      
%#		base=fname(baserange);                                                     
%#	end                                                                         
%#	dirrange=1:lastds;                                                          
%#	if ~isempty(dirrange)                                                       
%#		dir=fname(dirrange);                                                       
%#	end                                                                         
%#		extrange=lastper:nfname;                                                   
%#	if ~isempty(dirrange)                                                       
%#		ext=fname(extrange);                                                       
%#	end                                                                         
%#	if ~nofix                                                                   
%#		dirname=fixpath(dirname);                                                  
%#	end                                                                         
%#	if nargout==0                                                               
%#		dirname                                                                    
%#		base                                                                       
%#		ext                                                                        
%#	end                                                                         
%#return                                                                       
%#                                                                             
%#                                                                             
%#                                                                             
%#-h- anbysynchk3.m                                                                                                      
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/anbysynchk3.m 2004/6/2 14:20
                    
%#%  Saved from Eps1:Desktop Folder:WorkingFall2k1:NeareyTracker4xApr2k1:anbysynchk3.m 2002/11/6 19:5                    
%#                                                                                                                       
%#                                                                                                                       
%#function [rabs,dbPred,dbRes,dBPerOct]=anbysynchk3(fax,dbTarg,fest,bwwin, igr,hpcbas);                                  
%#%function [rabs,dbPred]=anbysynchk3(fax,dbTarg,fest,bwwin, igr,<hpcbas>)                                               
%#% analysis by synthesis checking                                                                                       
%#% return a normalized rms error (dB)                                                                                   
%#% and the dB predicted spectrum                                                                                        
%#% bwwin is bandwidth of window for inflating formant bw estimates                                                      
%#% Assume that fax is a spectrum with cutoff assumed to be half way between                                             
%#% F3 and F4.. so high pole correction characteristics can be estimates                                                 
%#% Alternately, hpcbas can be specified with explicit neutral F1                                                        
%#%  if igr is 1, then glottal/radiation function is added                                                               
%#% 	to spectrum.. this should be applied to NON-PREEMPHASIZED                                                           
%#% 	or to DE-PREEMPHASIZED spectra                                                                                      
%#% Version 1.1 July 5 2002. Also returns the global db/Oct slope                                                        
%#oamag=1;                                                                                                               
%#genharm=1;                                                                                                             
%#nt=size(dbTarg,2);                                                                                                     
%#f0syn=repmat(fax,1,nt);                                                                                                
%#fabs=fest(:,1:3);                                                                                                      
%#fcutoff=max(fax);                                                                                                      
%#                                                                                                                       
%#Fs=fcutoff*2; % Don't need real Fs here                                                                                
%#%bwabs= bsmo{ii}(:,1:3);                                                                                               
%#% use apriori bandwidths                                                                                               
%#bwabs=max(.07*fabs,70)+bwwin; % 7 pct of 70 hz + the window smear                                                      
%#%igr=1;                                                                                                                
%#if nargin<6                                                                                                            
%#	hpcbas=500*fax(end)/3000; %  fax(end) is assumed F3.5 frequency                                                       
%#end                                                                                                                    
%#                                                                                                                       
%#hpcbas;                                                                                                                
%#                                                                                                                       
%#dbrng=[];                                                                                                              
%#[xfrmag, fharm]=fcasc(Fs,f0syn,oamag,fabs,bwabs,genharm,fcutoff,hpcbas,igr,dbrng);                                     
%#xfrmag(1,:)=xfrmag(2,:); % fix dc just incase                                                                          
%#                                                                                                                       
%#% let;s gain normalize... mag squared                                                                                  
%#Ppred=sum(xfrmag.^2);                                                                                                  
%#[nf,nt]=size(xfrmag);                                                                                                  
%#                                                                                                                       
%#Ptarg=sum(10.^(dbTarg./10)); % total energy per time frame                                                             
%#%Ptarg./Ppred                                                                                                          
%#                                                                                                                       
%#dbPred= 20*log10(xfrmag)+repmat(10*log10(Ptarg./Ppred),nf,1); % gain match the frames                                  
%#                                                                                                                       
%#sizedbPred=size(dbPred);                                                                                               
%#sizedbTarg=size(dbTarg);                                                                                               
%#                                                                                                                       
%#%dbPred=dbPred;                                                                                                        
%#                                                                                                                       
%#                                                                                                                       
%#%  assumed to be preemphasized if igr is  so just peak normalize                                                       
%#%				plotsgm(taxSG,fax,dbN-dbPred);                                                                                    
%#                                                                                                                       
%#% rabs=1-std(dbRes(:))/std(dbTarg(:)); % Hmmm this has overall gain in it as well                                      
%#                                                                                                                       
%#% db per octave above 200 Hz.. no correction below 200 hx                                                              
%#% discount everything below 50 Hz                                                                                      
%#% perhaps we should just truncate this a la olive... 500 hz above f3.                                                  
%#% We may have unnaturally high cutoffs.                                                                                
%#%                                                                                                                      
%#ilo=min(find(fax>=50));                                                                                                
%#irng=[ilo:length(fax)]';                                                                                               
%#                                                                                                                       
%# dbRes=dbTarg(irng,:)-dbPred(irng,:);                                                                                  
%#% rabs=1-std(dbRes(:))./std(vec(dbTarg(irng,:))); This is bloody lousy... not sure why                                 
%#                                                                                                                       
%#% rr=corrcoef(vec(dbTarg(irng,:)),vec(dbPred(irng,:)))                                                                 
%#%                                                                                                                      
%#% rabs=max(rr(1,2),0).^2                                                                                               
%#                                                                                                                       
%#octabove=max(log(fax(irng))/log(2),0);                                                                                 
%#w=1;                                                                                                                   
%#[p,yhat,res] =  wtregA([vec(dbPred(irng,:)),vec(repmat(octabove,1,nt)),ones(length(irng)*nt,1)],vec(dbTarg(irng,:)),1);
%#dBPerOct=p(end-1);                                                                                                     
%#rabs=1-std(res)./std(vec(dbTarg(irng,:)));                                                                             
%#% Could also impose a 'db/oct tax';                                                                                    
%#% p                                                                                                                    
%#                                                                                                                       
%#                                                                                                                       
%#%rabs=1./std(dbRes(:));                                                                                                
%#% more flexible fit...                                                                                                 
%#% in each slice y= x + a*oct+c                                                                                         
%#-h- coswin.m                                                                                           
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/coswin.m 2004/6/2 14:20
         
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:coswin.m 2002/11/6 19:5
%#                                                                                                       
%#function win=coswin(nwin,p);                                                                           
%#%	win=coswin(nwin,p);                                                                                  
%#	win= (.5 - .5*cos(2*pi*(0:nwin-1)'/(nwin-1))).^p;                                                     
%#return                                                                                                 
%#-h- dbgtracker4xshowtracks.m                                                                                                                 
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/dbgtracker4xshowtracks.m 2004/6/2 14:20
                               
%#%  Saved from Eps1:Desktop Folder:WorkingFall2k1:NeareyTracker4xApr2k1:dbgtracker4xshowtracks.m 2002/11/6 19:5                               
%#                                                                                                                                             
%#% dbgtracker4xshowtracks - a debugging script called by tracker 4x to graph stuff                                                            
%#% A                                                                                                                                          
%#pausemsg('Watchlevel', watchlevel)                                                                                                           
%#showbest=watchlevel>0;                                                                                                                       
%#showall=watchlevel>1                                                                                                                         
%#pauseeverywhere=watchlevel>2                                                                                                                 
%#showfstable=watchlevel>1                                                                                                                     
%#showAnbysyn=watchlevel>1                                                                                                                     
%#if showbest & itry==ntry  % a second pass  to show best                                                                                      
%#	nplotpass=2;                                                                                                                                
%#	%pausemsg                                                                                                                                   
%#else                                                                                                                                         
%#	nplotpass=1;                                                                                                                                
%#	%showbest                                                                                                                                   
%#	itryisntry=itry==ntry;                                                                                                                      
%#	%                                                                                                                                           
%#end                                                                                                                                          
%#% nplotpass                                                                                                                                  
%#% itry                                                                                                                                       
%#% ntry                                                                                                                                       
%#% pausemsg                                                                                                                                   
%#for iplotpass=1:nplotpass                                                                                                                    
%#	shownow=watchlevel>0 & (showall| (showbest & iplotpass==2));                                                                                
%#	pausemsg('Shownow',shownow, 'showall', showall,'showbest', showbest, 'iplotpass',iplotpass)                                                 
%#	pausemsg('nplotpass', nplotpass,'itry', itry,'ntry',ntry)                                                                                   
%#	if  shownow                                                                                                                                 
%#		figure(47);                                                                                                                                
%#		% do the  sgms of the sub analyses and the fest plots.                                                                                     
%#		subplot(2,1,1);                                                                                                                            
%#		[Xlpcdb,faxlpc]=alpc2sgm(alpc{itry,1},gainsq{itry,1},fhi(itry)*2,df,fast,stype);                                                           
%#		plotsgm(taxsg,faxlpc,Xlpcdb)                                                                                                               
%#		hold on                                                                                                                                    
%#		colorbar                                                                                                                                   
%#		plot(taxsg,ff1,'w','linewidth',2); hold on                                                                                                 
%#		plot(taxsg,ff1);                                                                                                                           
%#                                                                                                                                             
%#		title('LPCogram for analysis 1');                                                                                                          
%#		subplot(2,1,2);                                                                                                                            
%#		[Xlpcdb,faxlpc]=alpc2sgm(alpc{itry,2},gainsq{itry,2},fhi(itry)*2,df,fast,stype);                                                           
%#		plotsgm(taxsg,faxlpc,Xlpcdb)                                                                                                               
%#		hold on                                                                                                                                    
%#		colorbar                                                                                                                                   
%#		plot(taxsg,ff1,'w','linewidth',2); hold on                                                                                                 
%#		plot(taxsg,ff1);                                                                                                                           
%#                                                                                                                                             
%#                                                                                                                                             
%#		title('LPCogram for analysis 12');                                                                                                         
%#		playsc(x,Fs)                                                                                                                               
%#		pausemsg                                                                                                                                   
%#		col='bgrc';                                                                                                                                
%#		if iplotpass==2                                                                                                                            
%#			ishow=ibest;                                                                                                                              
%#			dbPred=dbPredSave;                                                                                                                        
%#			Xtarg=XtargSave;                                                                                                                          
%#			faxtarg=faxtargSave;                                                                                                                      
%#		else                                                                                                                                       
%#			ishow=itry;                                                                                                                               
%#		end% if plotpass==2                                                                                                                        
%#		if showAnbysyn                                                                                                                             
%#			figure(2); clf                                                                                                                            
%#			if iplotpass==1;                                                                                                                          
%#				subplot(2,2,4);                                                                                                                          
%#				plot(taxsg,ff1,'-'); hold on;                                                                                                            
%#				plot(taxsg,ff2+30,':');                                                                                                                  
%#				set(gca,'Ylim',[0,max(faxtarg)]);                                                                                                        
%#			end %if iplotpass==1                                                                                                                      
%#                                                                                                                                             
%#			tstr=['premph-', num2str(emph(ishow)),'; fhi- ', num2str(fhi(ishow))];                                                                    
%#			if iplotpass==2                                                                                                                           
%#				tstr=['best ', tstr];                                                                                                                    
%#			end	% if plotpass=2                                                                                                                       
%#			% Xtarg does not look like it is on the faxtarg axis.                                                                                     
%#			%                                                                                                                                         
%#			showAnbysynSpect(taxsg,faxtarg, Xtarg,dbPred,tstr)                                                                                        
%#                                                                                                                                             
%#			[xx,yy]=ginput(1)                                                                                                                         
%#			while ~isempty(xx)                                                                                                                        
%#				xlabel(' Pick a spot for section')                                                                                                       
%#				[jnk,isect]=min(abs(xx-taxsg));                                                                                                          
%#				figure(38)                                                                                                                               
%#				plot(faxtarg,[Xtarg(:,isect),dbPred(:,isect)]);                                                                                          
%#				legend('Target','AnBySyn')                                                                                                               
%#				xlabel(['t ',num2str(xx), 'isect ', num2str(isect)]);                                                                                    
%#                                                                                                                                             
%#				pausemsg                                                                                                                                 
%#				figure(2)                                                                                                                                
%#				[xx,yy]=ginput(1)                                                                                                                        
%#                                                                                                                                             
%#                                                                                                                                             
%#			end	%while not empty                                                                                                                      
%#		end % if showanbysyn                                                                                                                       
%#		figure(1);                                                                                                                                 
%#		%clf                                                                                                                                       
%#		% 		[ax1,ax2]=splitfig2313;                                                                                                                
%#		% 		subplot(ax1);                                                                                                                          
%#                                                                                                                                             
%#		hold on;                                                                                                                                   
%#                                                                                                                                             
%#		%qdsgm(x,Fs);                                                                                                                              
%#		nft=3;                                                                                                                                     
%#		try                                                                                                                                        
%#			delete(lh1)                                                                                                                               
%#			delete(lh2)                                                                                                                               
%#			% 			delete(lh1K)                                                                                                                         
%#			% 			delete(lh2K)                                                                                                                         
%#		catch                                                                                                                                      
%#			lasterr                                                                                                                                   
%#		end %try                                                                                                                                   
%#		for j=1:nft                                                                                                                                
%#			try                                                                                                                                       
%#				ccc=[col(j),'-'];                                                                                                                        
%#				% 				cccK=[col(j),':'];                                                                                                                 
%#				lh1(j)=plot(taxsg,fest{ishow}(:,j),'w','linewidth',3);                                                                                   
%#				hold on;                                                                                                                                 
%#				lh2(j)=plot(taxsg,fest{ishow}(:,j),ccc,'linewidth',1);                                                                                   
%#				% 				lh1K(j)=plot(taxfK,festK(:,j),'y','linewidth',3);                                                                                  
%#				% 				lh2K(j)=plot(taxfK,festK(:,j),cccK,'linewidth',1);                                                                                 
%#			catch                                                                                                                                     
%#				lasterr                                                                                                                                  
%#				disp('plottFK problems')                                                                                                                 
%#			end % try catch                                                                                                                           
%#                                                                                                                                             
%#		end %  for j..nft                                                                                                                          
%#		pausemsg                                                                                                                                   
%#		figure(1)                                                                                                                                  
%#		tstr=sprintf('sc %6.4f; prs %5.3f; bw %5.3f;  amp %5.3f; cont %5.3f; dist %5.3f; rabs %5.3f ; rng %5.3f; rfs %5.3f', scorecomps(ishow,:)) ;
%#		if iplotpass==2,                                                                                                                           
%#			tstr=['Best ',tstr];                                                                                                                      
%#			title(tstr);                                                                                                                              
%#			scorecomps,                                                                                                                               
%#			% 					xstr=sprintf('%d ', round(frealfest));                                                                                             
%#			% 					xlabel(xstr)                                                                                                                       
%#			%	jnk=menu('Best pausemsg menu','y', num2str(ibest));                                                                                     
%#                                                                                                                                             
%#			drawnow                                                                                                                                   
%#			pausemsg                                                                                                                                  
%#		end %if plotpass==2                                                                                                                        
%#		title(tstr)                                                                                                                                
%#		% 	fest{ishow}                                                                                                                             
%#		% 	ampest{ishow}                                                                                                                           
%#		% 	bwest{ishow}                                                                                                                            
%#		SSCORE=100*score                                                                                                                           
%#		pausemsg                                                                                                                                   
%#	end % if shownow                                                                                                                            
%#end %iplotpass                                                                                                                               
%#if watchlevel>2                                                                                                                              
%#	pausemsg('Final pause in dbgtracker4xshowtracks')                                                                                           
%#end                                                                                                                                          
%#                                                                                                                                             
%#                                                                                                                                             
%#-h- fbaRoot.m                                                                                           
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/fbaRoot.m 2004/6/2 14:20
         
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:fbaRoot.m 2002/11/6 19:5
%#                                                                                                        
%#function [fc,bw,ampdb]=fbaRoot(a,gainsq,Fs);                                                            
%#% function [fc,bw,ampdb]=fbaRoot(a,gainsq,Fs);                                                          
%#% Gainsq is "alpha" of Markel and Grey routines                                                         
%#% find the roots of the predictor polynomial                                                            
%#%% This does not take a multiframe argument... just one alpc vector                                     
%#% use fbaRoot2 for multiframe                                                                           
%#% Copyright TM Nearey 1998-2001                                                                         
%#% REQUIRES CHECKING... pole at folding frequency                                                        
%#if nargin~=3, error('fbaRoot requires 3 args');end;                                                     
%#if all(a(2:end)==0)                                                                                     
%#	fc=[];bw=[];ampdb=[];                                                                                  
%#	return                                                                                                 
%#end                                                                                                     
%#r=roots(a);                                                                                             
%#% frequencies and bandwidths of complex conjugate roots                                                 
%#if nargin<3;                                                                                            
%#		Fs=1;                                                                                                 
%#end                                                                                                     
%#                                                                                                        
%#fct=angle(r)*Fs/(2*pi);                                                                                 
%#bwct=log(abs(r))*Fs/pi;                                                                                 
%#fc=fct(find(imag(r)~=0 & fct>0));  % non-zero roots, pos freq                                           
%#bw=abs(bwct(find(imag(r)~=0 & fct>0)));                                                                 
%#[fc,ix]=sort(fc);    % sort into order of ascending freq                                                
%#bw=bw(ix);           % and bandwidths                                                                   
%#	if nargin<2                                                                                            
%#		gainsq=1;                                                                                             
%#	end                                                                                                    
%#                                                                                                        
%#if nargout==3                                                                                           
%#	% evaluate amplitude at formant frequencies                                                            
%#	ampdb=zeros(size(fc));                                                                                 
%#	for k=1:length(fc);                                                                                    
%#		f=fc(k);                                                                                              
%#		ampdb(k)=abs(polyval(a,exp(2*i*pi*f/Fs)));                                                            
%#		ampdb(k)=-20*log10(ampdb(k))+10*log10(gainsq);                                                        
%#	end                                                                                                    
%#end                                                                                                     
%#                                                                                                        
%#                                                                                                        
%#-h- fbaplot.m                                                                                  
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/fbaplot.m 2004/6/2 14:20

%#function fbaplot(t,nc,f,b,a,fcutoff,style,tcol)                                                
%#%fbaplot(t,nc,f,b,a,fcutoff,style,<tcolor>)                                                    
%#% Version 2.0 nt calculated 1 June 97                                                          
%#%function fbaplot(t,nc,f,b,a,fcutoff,style)                                                    
%#% assumes dB and Hz and that 0dB and 500 Hz are smallest/biggest                               
%#% portrayable amps/bws                                                                         
%#% styles are 'tri' or 'num'                                                                    
%#%warning('fbaplot')                                                                            
%#% Modified to allow empty amplitudes                                                           
%#if nargin<7|isempty(style)                                                                     
%#	style='TRI';                                                                                  
%#end                                                                                            
%#                                                                                               
%#if nargin<8                                                                                    
%#	if strcmp(upper(style),'TRI')                                                                 
%#		tcol='b';                                                                                    
%#	else                                                                                          
%#		tcol='k';                                                                                    
%#	end                                                                                           
%#end                                                                                            
%#                                                                                               
%#nt=length(t);                                                                                  
%#if size(nc)==[1 1]                                                                             
%#	nc=repmat(nc,nt,1);                                                                           
%#end                                                                                            
%#% triangle style used for now                                                                  
%#frange=1.05*fcutoff;                                                                           
%#trange=t(nt)-t(1);                                                                             
%#delt=trange/nt;                                                                                
%#if isempty(a)                                                                                  
%#	a=zeros(size(f));                                                                             
%#	amax=1;                                                                                       
%#else                                                                                           
%#	amax=max(max(a));                                                                             
%#end                                                                                            
%#                                                                                               
%#if amax==0                                                                                     
%#	amax=1; % in case no amp is given                                                             
%#end                                                                                            
%#                                                                                               
%#bmax=max(max(b));                                                                              
%#if bmax>500                                                                                    
%#	bmax=500;                                                                                     
%#end                                                                                            
%#afac=delt;                                                                                     
%#bfac=1;                                                                                        
%#%fcutoff                                                                                       
%#%[t(1),t(nt)+5,0,1.05*fcutoff]                                                                 
%#axis([t(1),t(nt)+5,0,1.05*fcutoff]);                                                           
%#hold on                                                                                        
%#tri=0;                                                                                         
%#num=0;                                                                                         
%#if length(style)>=3                                                                            
%#	if upper(style(1:3))=='TRI'                                                                   
%#		tri=1;                                                                                       
%#	end                                                                                           
%#	if upper(style(1:3))=='NUM'                                                                   
%#		num=1;                                                                                       
%#	end                                                                                           
%#end;                                                                                           
%#for i=1:nt                                                                                     
%#	for j=1:nc(i);                                                                                
%#		%i,j,t(i),f(i,j),b(i,j),a(i,j)                                                               
%#		if tri                                                                                       
%#			bt=min(fcutoff/10,b(i,j));                                                                  
%#			at=max(a(i,j),0);                                                                           
%#			x(1)=t(i);                                                                                  
%#			y(1)=f(i,j)+bt/2;                                                                           
%#			x(2)=t(i)+at/amax*afac;                                                                     
%#			y(2)=f(i,j);                                                                                
%#			x(3)=t(i);                                                                                  
%#			y(3)=f(i,j)-bt/2;                                                                           
%#			x(4)=x(1);                                                                                  
%#			y(4)=y(1);                                                                                  
%#			if b(i,j)>fcutoff/10,                                                                       
%#				st=':';                                                                                    
%#			else                                                                                        
%#				st='-';                                                                                    
%#			end                                                                                         
%#			plot(x,y,st,'Color',tcol);                                                                  
%#		elseif num                                                                                   
%#			text(t(i),f(i,j),num2str(j),'Color',tcol)                                                   
%#		else                                                                                         
%#			text(t(i),f(i,j),style(1))                                                                  
%#		end% if                                                                                      
%#                                                                                               
%#	end;                                                                                          
%#end;                                                                                           
%#%drawnow;                                                                                      
%#-h- fcasc.m                                                                                                         
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/fcasc.m 2004/6/2 14:20
                       
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:speechsynth:fcasc.m 2002/11/6 19:5             
%#                                                                                                                    
%#function  [xfrmag, fharm]=fcasc(Fs,f0,oamag,ffrq,bw,genharm,fcutoff,hpcbas,grval,dbrng,killrk2)                     
%#%  [xfrmag, fharm]=fcasc(Fs,f0,oamag,ffrq,bw,genharm,fcutoff,hpcbas,grval,dbrng)                                    
%#%                         1  2   3    4     5  6         7     8     9    10                                        
%#% OS/8 conversion with a few arg changes DEBUGGING CODE                                                             
%#% Modified for continuous grval... if 1 or zero works like fcasc                                                    
%#% if real, acts serves as denominator in glottal correction                                                         
%#% INPUT %                                                                                                           
%#%	f0- input "f0" value (for full fft spectrum                                                                       
%#% 		should=Fs/(2.*float(nbins-1))                                                                                   
%#% 		if it is a  vector of same rowlength as ffrq,                                                                   
%#%       and genharm is set to 1 then harmonics are generated                                                        
%#%       otherwise if it is a  vector, the specified frequencies are used for all frames                             
%#%		if f0 is a matrix (harmno, timeslice), then generate at only given frequencies (NaN's are skipped)               
%#% 		fharm comes out the obvious way                                                                                 
%#%  	oamag % overall amplitude (magitude (rms) value)                                                                
%#%	ffrq - formant frequencies (ntimeslice x nft) will return spectrogram like array xfrmag(freq,time)                
%#%  bw - bandwitdhs                                                                                                  
%#%  genharm - generate harmonics at different f0 frequencies per time slice (size of f0 and ffrq must match)         
%#%  fcutoff- target for high frequency cutoff                                                                        
%#%  hpcbas- higher pole correction  base f1:                                                                         
%#%     	use 500 hz for 17.5 cm slvt.                                                                                 
%#%      	use <=0 for no hpc                                                                                          
%#%  grval- glottal source/radiation flag if 1, then correction                                                       
%#%  dbrng- db range from max to floor                                                                                
%#% 	 if.le.0, then no flooring is done                                                                               
%#%      for source, radiation is done (not modified) %                                                               
%#%  calculations are done in power domain                                                                            
%#%  and square rooting at end                                                                                        
%#% OUTPUT                                                                                                            
%#%  xfrmag- returned array of magnitude spectrum amps of freqs above fcutoff are zero'd out                          
%#% fharm frequency of harmonics at each time slice                                                                   
%#% version 2.0 Better higher pole correction                                                                         
%#% (U. Laine 1988 Higher pole correction in vocal tract models and terminal analogs Speech Commmunication (7) p 21-40
%#% Version 2.1 grval replaces igr. Works the same as before if 0/1 (0 = no glottal correctoin)                       
%#% 	(1 = default) correction. Scalar value now possible default 1= scalar 100Hz in correction term                   
%#% Copyright T.M. Nearey 2001, 2002;                                                                                 
%#tnargin=nargin;                                                                                                     
%#                                                                                                                    
%#if tnargin==0                                                                                                       
%#	Fs=10000; ffrq=[1 3 5 7 9]*500; bw=50+0*ffrq;                                                                      
%#	hpcbas=500;grval=0; dbrng=0;                                                                                       
%#	f0=100; fcutoff=5000;                                                                                              
%#	tnargin=9;                                                                                                         
%#	genharm=1;                                                                                                         
%#	oamag=100;                                                                                                         
%#	figure(1)                                                                                                          
%#	clf                                                                                                                
%#	[xfrmag, fharm]=fcasc(Fs,f0,oamag,ffrq,bw,genharm,fcutoff,hpcbas,grval,dbrng);                                     
%#	plot(fharm,xfrmag);                                                                                                
%#	hold on;                                                                                                           
%#	[xfrmag, fharm]=fcasc(Fs,f0,oamag,ffrq,bw,genharm,fcutoff,hpcbas,grval,dbrng,1);                                   
%#	plot(fharm,xfrmag,'r');                                                                                            
%#	% no hpc                                                                                                           
%#	[xfrmag, fharm]=fcasc(Fs,f0,oamag,ffrq,bw,genharm,fcutoff,0,grval,dbrng,1);                                        
%#	plot(fharm,xfrmag,'g');                                                                                            
%#	hold on;                                                                                                           
%#                                                                                                                    
%#                                                                                                                    
%#	return                                                                                                             
%#end                                                                                                                 
%#                                                                                                                    
%#% 5 genharm,fcutoff,hpcbas,grval,dbrng                                                                              
%#if tnargin<6 |isempty(genharm)                                                                                      
%#	genaharm=1;                                                                                                        
%#end                                                                                                                 
%#if tnargin<7 |isempty(fcutoff),                                                                                     
%#	fcutoff=Fs/2;                                                                                                      
%#end                                                                                                                 
%#if tnargin<8 |isempty(hpcbas),                                                                                      
%#	hpcbas=500;                                                                                                        
%#end                                                                                                                 
%#if tnargin<9 |isempty(grval)                                                                                        
%#	grval=1;                                                                                                           
%#end                                                                                                                 
%#if tnargin<10 |isempty(dbrng)                                                                                       
%#	dbrng=-1;                                                                                                          
%#end                                                                                                                 
%#if tnargin<11 | isempty(killrk2)                                                                                    
%#	killrk2=0;                                                                                                         
%#end                                                                                                                 
%#                                                                                                                    
%#if size(ffrq,2)==1, ffrq=ffrq'; bw=bw';end                                                                          
%#                                                                                                                    
%#                                                                                                                    
%#onefsamp=0;                                                                                                         
%#nslice=size(ffrq,1);                                                                                                
%#if max(size(oamag))==1; oamag=repmat(oamag,nslice,1);end;                                                           
%#                                                                                                                    
%#	if max(size(f0))==1,                                                                                               
%#		nbins=floor(fcutoff/f0)+1;                                                                                        
%#		fhi=f0*(nbins-1);                                                                                                 
%#		fharm=(0:f0:fhi)';                                                                                                
%#		onefsamp=1;                                                                                                       
%#	elseif min(size(f0))==1 & genharm;                                                                                 
%#		f0=f0(:)';  % time dimension                                                                                      
%#		if length(f0)~=nslice                                                                                             
%#			error(' Length of F0 must match row dim of ffrq')                                                                
%#		end                                                                                                               
%#		minf0=min(f0);                                                                                                    
%#		f0t=f0(:)';                                                                                                       
%#		nbins=ceil(fcutoff/minf0);                                                                                        
%#		fharm=repmat(f0t,nbins,1).*repmat((1:nbins)',1,nslice);                                                           
%#	elseif  min(size(f0))==1                                                                                           
%#		fharm=f0(:);                                                                                                      
%#		nbins=length(f0);                                                                                                 
%#		onefsamp=1;                                                                                                       
%#	else % must be a martrix                                                                                           
%#		fharm=f0;                                                                                                         
%#		nbins=size(f0,1);                                                                                                 
%#	end                                                                                                                
%#                                                                                                                    
%#                                                                                                                    
%#	nft=size(ffrq,2);                                                                                                  
%#	xfrmag=zeros(nbins,nslice);                                                                                        
%#	for islice=1:nslice;                                                                                               
%#		if onefsamp, it=1; else it=islice; end                                                                            
%#		f0t=fharm(:,it);                                                                                                  
%#		ft=ffrq(islice,:);                                                                                                
%#		bt=bw(islice,:);                                                                                                  
%#		ffold=Fs/2.;                                                                                                      
%#		c2=(bt/2).^2;                                                                                                     
%#		fnum=(ft.^2+c2).^2;                                                                                               
%#		% cddif=c2-c2A                                                                                                    
%#		% fnumdif=fnum-fnumA                                                                                              
%#		% pause                                                                                                           
%#		pole=(repmat(f0t,1,nft)-repmat(ft,nbins,1)).^2+repmat(c2,nbins,1);                                                
%#		pconj=(repmat(f0t,1,nft)+repmat(ft,nbins,1)).^2+repmat(c2,nbins,1);                                               
%#		% figure(37); clf                                                                                                 
%#		% subplot(2,1,1); plot(f0t,tpole);subplot(2,1,2); plot(f0t,pole); pause                                           
%#		% figure(37); clf                                                                                                 
%#		% subplot(2,1,1); plot(f0t,tconj);subplot(2,1,2); plot(f0t,pconj); pause                                          
%#		xfrmag(:,islice)=sqrt(prod(repmat(fnum,nbins,1)./(pole.*pconj),2));                                               
%#		%plot(f0t, [xfrmagA,xfrmag+.05*max(xfrmagA)])                                                                     
%#                                                                                                                    
%#                                                                                                                    
%#		if hpcbas>0                                                                                                       
%#			%%% HPC Vectorized                                                                                               
%#			%  first order higher pole correction flanagan p 218 eq 6.14                                                     
%#			%  calc constant rk see also Olive p 662                                                                         
%#                                                                                                                    
%#			rk= pi*pi./8-sum(1./(2*(1:nft)-1).^2);                                                                           
%#			% Fant 1959 as reported  in Laine 88 second order correcton                                                      
%#			if ~killrk2                                                                                                      
%#				rk2=.5*((pi.^4)./96 - sum(1./(2*(1:nft)-1).^4));                                                                
%#			else                                                                                                             
%#				rk2=0;                                                                                                          
%#			end                                                                                                              
%#                                                                                                                    
%#			xfrmag(:,islice)=xfrmag(:,islice).*exp(rk*(f0t./hpcbas).^2+rk2*(f0t./hpcbas).^4);                                
%#		end                                                                                                               
%#		%figure(37) ; plot(f0t,xfrmag); pause                                                                             
%#		%  source plus glottal radiation                                                                                  
%#		%  olive jasa (1971) 50:662 equation 4                                                                            
%#		if(grval==1) %                                                                                                    
%#			xfrmag(:,islice)=xfrmag(:,islice).*(f0t./100)./(1+f0t.^2/10000);                                                 
%#		elseif grval >0                                                                                                   
%#			xfrmag(:,islice)=xfrmag(:,islice).*(f0t./grval)./(1+f0t.^2/grval^2);                                             
%#		end                                                                                                               
%#                                                                                                                    
%#		if any(f0t>fcutoff)                                                                                               
%#			xfrmag(find(f0t>fcutoff),islice)=xfrmag(find(f0t>fcutoff),islice).*0;                                            
%#		end                                                                                                               
%#		xfrmag(:,islice)=xfrmag(:,islice)*oamag(islice);                                                                  
%#		%figure(37) ; plot(f0t,[xfrmagC,xfrmag+.05*max(xfrmagC)]); pause                                                  
%#		if dbrng>0 & dbrng<inf                                                                                            
%#			xdiv=exp(dbrng/8.68);                                                                                            
%#			amin=max(xfrmag(:,islice))/xdiv;                                                                                 
%#			xfrmag(:,islice)=max(xfrmag(:,islice),amin);                                                                     
%#		end                                                                                                               
%#		%figure(37) ; plot(f0t,[xfrmagD,xfrmag+.05*max(xfrmagD)]); pause                                                  
%#	end % slice loop                                                                                                   
%#-h- getwin.m                                                                                           
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/getwin.m 2004/6/2 14:20
         
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:getwin.m 2002/11/6 19:5
%#                                                                                                       
%#function [window]=getwin(nwin,wintype,Fs)                                                              
%#% function window=getwin(nwin,wintype)                                                                 
%#% or window=getwin(windurms,wintype,Fs)                                                                
%#% if there are three input arguments, nwin is taken to be                                              
%#% a duration in ms                                                                                     
%#% Windows implemented HAMMING, HANNING, COS4, GAUSS, RECT                                              
%#% Copyright 1997-2001 T.M. Nearey                                                                      
%#if nargin==3                                                                                           
%#	nwin=ceil(nwin/1000*Fs);                                                                              
%#end                                                                                                    
%#if nargin<2|isempty(wintype)                                                                           
%#	wintype='HAMMING';                                                                                    
%#end                                                                                                    
%#wintype=upper(wintype);                                                                                
%#switch wintype                                                                                         
%#case 'HAMMING'                                                                                         
%#	window = 0.54 - 0.46*cos(2*pi*(0:nwin-1)/nwin)';                                                      
%#	%disp('hamming');                                                                                     
%#case 'COS4'                                                                                            
%#	window=coswin(nwin,4);                                                                                
%#	%disp('Cos4');                                                                                        
%#case {'HANNING', 'HANN'}                                                                               
%#	window = .5*(1 - cos(2*pi*(1:nwin)'/(nwin+1)));                                                       
%#case {'GAU','GAUSS','GAUSSIAN'}                                                                        
%#	% P. Boersma IFA proceedinfgs(Institute of Phontics Sciences, University of Amsterdam                 
%#	% Proceeding 17 (1993)  17, 1993                                                                      
%#	% Accurate short-term analysis of the fundamental frequency                                           
%#	% and the harmonics-to-noise ratio                                                                    
%#	% of a sampled sound. pp 97-110                                                                       
%#	window=exp(-12*(([1:nwin]'-.5)/nwin-.5).^2)/(1-exp(-12));                                             
%#case {'RECT','RECTANGULAR'}                                                                            
%#	window=ones(nwin,1);                                                                                  
%#                                                                                                       
%#otherwise                                                                                              
%#	warning('Window not defined ... hamming substituted')                                                 
%#	legalwins='HAMMING, COS4, RECT, HANNING, GAUSS'                                                       
%#	window = 0.54 - 0.46*cos(2*pi*(0:nwin-1)/nwin)';                                                      
%#	pause                                                                                                 
%#end                                                                                                    
%#-h- lagwin.m                                                                                           
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/lagwin.m 2004/6/2 14:20
         
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:lagwin.m 2002/11/6 19:5
%#                                                                                                       
%#function lw=lagwin(Fs,Beq,ntot,wtype,testing);                                                         
%#% lw=lw(Fs,Beq,ntot,wtype,testing);                                                                    
%#% Y. Tohkura, F. Itakura and S. Hashimoto. Spectral smoothing                                          
%#% technique in PARCOR Speech Analysis-Synthesis IEEE ASSP 26 1978 pp 587-596                           
%#%tnargin=nargin;                                                                                       
%#tnargin=nargin;                                                                                        
%#if tnargin==0, Fs=8000, Bs=80; Beq=Bs/sqrt(2/3), ntot=20, wtype='TRI', testing=1; tnargin=5; end       
%#%if tnargin==0, Fs=8000, Bs=80; Beq=Bs*sqrt(2*log(2)), ntot=20, wtype='GAU', testing=1; tnargin=5; end 
%#                                                                                                       
%#%Beq, Bs,F0=Bs/2, Fs                                                                                   
%#%pause                                                                                                 
%#if tnargin<5|isempty(testing),testing=0; end                                                           
%#if tnargin<4|isempty(wtype),wtype='TRI'; end                                                           
%#wtype=upper(wtype);                                                                                    
%#if ~strcmp(wtype,'TRI') & ~strcmp(wtype,'GAU')                                                         
%#	warning('Only TRI and GAU wtype allowed: TRI being used');                                            
%#	wtype='TRI';                                                                                          
%#end                                                                                                    
%#% Y. Tohkura, F. Itakura and S. Hashimoto. Spectral smoothing                                          
%#% technique in PARCOR Speech Analysis-Synthesis IEEE ASSP 26 1978 pp 587-596                           
%#nlagw=ntot; % length of lagwin including zero lag                                                      
%#tau=1/Fs;                                                                                              
%#	% Gaussian                                                                                            
%#t=[0:nlagw-1]'*tau;                                                                                    
%#                                                                                                       
%#if strcmp(wtype,'GAU')                                                                                 
%#	Bs=1/sqrt(2*log(2)) * Beq;                                                                            
%#	omega=2*pi*Bs/2;                                                                                      
%#	lw=exp(-(omega*t).^2/2);                                                                              
%#	if testing                                                                                            
%#		thetat=omega*t                                                                                       
%#		lwt=1-thetat.^2/2+1/8*thetat.^4;                                                                     
%#	end                                                                                                   
%#end                                                                                                    
%#                                                                                                       
%#if strcmp(wtype,'TRI')                                                                                 
%#                                                                                                       
%#	Bs=sqrt(2/3)*Beq;                                                                                     
%#	omega=2*pi*Bs/2;                                                                                      
%#	sq=sqrt(3/2);                                                                                         
%#	lw=zeros(nlagw,1);                                                                                    
%#	lw(1)=1;                                                                                              
%#	kernal=sq*omega*t(2:end);                                                                             
%#                                                                                                       
%#	lw(2:end)=(sin(kernal)./kernal).^2;                                                                   
%#	if testing                                                                                            
%#		thetat=omega*t                                                                                       
%#		lwt=1-thetat.^2/2+1/10*thetat.^4;                                                                    
%#	end                                                                                                   
%#                                                                                                       
%#end                                                                                                    
%#                                                                                                       
%#if testing                                                                                             
%#                                                                                                       
%#	nfft=512;                                                                                             
%#	fax=linspace(0,Fs,nfft)';                                                                             
%#	nfold=nfft/2+1;                                                                                       
%#	npltft=min(find(fax>5*Beq));                                                                          
%#	figure(37); clf                                                                                       
%#	subplot(2,1,1);                                                                                       
%#	plot(t,lw)                                                                                            
%#	dbs=20*log10(abs(fft(lw,nfft)));                                                                      
%#	dbs=dbs-dbs(1); % normalize                                                                           
%#	subplot(2,1,2);                                                                                       
%#	plot(fax(1:npltft),dbs(1:npltft)); hold on                                                            
%#	[jnk,ieq]=min(abs(fax-Beq/2))                                                                         
%#	[jnk,is]=min(abs(fax-Bs/2))                                                                           
%#	[jnk,ibt]=min(abs(dbs(1:npltft)+3))                                                                   
%#	abs(dbs(1:npltft)+3)                                                                                  
%#	Bwt=2*fax(ibt);                                                                                       
%#	xx=[fax(1),fax(npltft)]; yy(1)=-3; yy(2)=yy(1);                                                       
%#	plot(xx,yy,'r');                                                                                      
%#	tstr=['DbDown Beq/2, Bs/2 , Bw/2 3Db', num2str([dbs(ieq),dbs(is),Bwt])];                              
%#	title(tstr);                                                                                          
%#	[x,y]=ginput;                                                                                         
%#	[x,y-dbs(1)]                                                                                          
%#	Beq                                                                                                   
%#	Bs                                                                                                    
%#	F0=Bs/2                                                                                               
%#	Fs                                                                                                    
%#	tau                                                                                                   
%#end                                                                                                    
%#if testing                                                                                             
%# [lw,lwt]                                                                                              
%#%Tohkura's table Very close here                                                                       
%#% Series tests                                                                                         
%#delT=1/8000                                                                                            
%#f0=40                                                                                                  
%#i=(0:8)'                                                                                               
%#omeg0tau=2*pi*f0*delT*i                                                                                
%#theta=omeg0tau                                                                                         
%#tri=1-theta.^2/2+1/10*theta.^4;                                                                        
%#gau=1-theta.^2/2+1/8*theta.^4;                                                                         
%#[i,tri,gau,lwt(1:9),lw(1:9)]                                                                           
%#                                                                                                       
%#thetastuff=[theta, thetat(1:9)]                                                                        
%#end                                                                                                    
%#-h- medsmoterp.m                                                                                            
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/medsmoterp.m 2004/6/2 14:20
          
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:FTrackTools:medsmoterp.m 2002/11/6 19:5
%#                                                                                                            
%#function fsmo=medsmoterp(fc,medwid,idim);                                                                   
%#%function fsmo=medsmoterp(fc,medwid,idim);                                                                  
%#% median smooth and interpolate missings                                                                    
%#% Call with medwidth of 1 for interpolation of missing values (NaN)                                         
%#% Interpolation corrected 24 Apr 98                                                                         
%#% Copyright 2000- 2001 T M Nearey                                                                           
%#% handles matrices now                                                                                      
%#% This has very simple approach to endpoints... probably not a good one                                     
%#% Copy on the first non-missing value and last non-missing value                                            
%#% to alow interpolation/extensions                                                                          
%#if nargin<3 |isempty(idim)                                                                                  
%#	idim=1;                                                                                                    
%#end                                                                                                         
%#                                                                                                            
%#if nargin==0                                                                                                
%#	medwid=3;                                                                                                  
%#	nt=100;                                                                                                    
%#	fc=repmat([1:nt]',1,2)+20*rand(nt,2);                                                                      
%#	zipout=randperm(nt*2);                                                                                     
%#	fc(zipout(1:round(nt*2/3)))=NaN;                                                                           
%#	clf                                                                                                        
%#	plot(fc,'+'); hold on;                                                                                     
%#end                                                                                                         
%#transpout=0;                                                                                                
%#if idim==2 | length(fc)==size(fc,2);                                                                        
%#	transpout=1;                                                                                               
%#	fc=fc';                                                                                                    
%#end                                                                                                         
%#                                                                                                            
%#[nt,ncol]=size(fc);                                                                                         
%#ncop=(medwid+1)/2;                                                                                          
%#fsmo=repmat(NaN,nt,ncol);                                                                                   
%#for k=1:ncol                                                                                                
%#	fsm=repmat(NaN,nt,1);                                                                                      
%#                                                                                                            
%#	use=find(~isnan(fc(:,k)));                                                                                 
%#	nuse=length(use);                                                                                          
%#	if nuse<medwid                                                                                             
%#		warning('Not enough values to interpolate')                                                               
%#		nuse;medwid;                                                                                              
%#		fsm=fc(:,k);                                                                                              
%#		%return                                                                                                   
%#	else                                                                                                       
%#		if medwid>1 % if do smoothing                                                                             
%#			fsm(use)=medfilt1(fc(use,k),medwid);                                                                     
%#			fsm(use(1:ncop))=fsm(use(ncop+1));                                                                       
%#			fsm(use(end-ncop+1:end))=fsm(use(end-ncop));                                                             
%#		else % degenerate case interpolation only                                                                 
%#			fsm(use)=fc(use,k);                                                                                      
%#		end% end if dosmoothing                                                                                   
%#                                                                                                            
%#		%plot(fsm,'ro');                                                                                          
%#		% copy first and last non-missing values to the beg and end                                               
%#		nomiss=find(~isnan(fsm));                                                                                 
%#		fsm=[fsm(nomiss(1));fsm;fsm(nomiss(end))];                                                                
%#		leftedge=find(~isnan(fsm(1:end-1)) & isnan(fsm(2:end)) );                                                 
%#		rightedge=find(isnan(fsm(1:end-1)) & ~isnan(fsm(2:end)) )+1;                                              
%#		nl=length(rightedge);                                                                                     
%#		nr=length(leftedge);                                                                                      
%#		if nr~=nl, error('Should not happen PROG ERROR'); end                                                     
%#		for i=1:nr                                                                                                
%#			l=leftedge(i);                                                                                           
%#			r=rightedge(i);                                                                                          
%#			%  		tl=fsm(l)                                                                                           
%#			%  		tr=fsm(r)                                                                                           
%#			%  		tfil=linspace(fsm(l),fsm(r),r-l+1)                                                                  
%#			%  		pause                                                                                               
%#			% l                                                                                                      
%#			% r                                                                                                      
%#			% leftedge                                                                                               
%#			% rightedge                                                                                              
%#			% fsmsize=size(fsm)                                                                                      
%#			% fsm(l),fsm(r),r-l+1                                                                                    
%#			if fsm(l)==fsm(r)                                                                                        
%#				fsm(l:r)=fsm(r);                                                                                        
%#			else                                                                                                     
%#				fsm(l:r)=linspace(fsm(l),fsm(r),r-l+1);                                                                 
%#			end                                                                                                      
%#		end                                                                                                       
%#		fsmo(:,k)=fsm((2):(end-1)); % statement was  wrongly placed out of loop                                   
%#                                                                                                            
%#	end % have enough values                                                                                   
%#                                                                                                            
%#                                                                                                            
%#end % for k th col                                                                                          
%#                                                                                                            
%#                                                                                                            
%#if nargin==0; plot(fsmo); end;                                                                              
%#	if transpout                                                                                               
%#		fsmo=fsmo';                                                                                               
%#	end                                                                                                        
%#-h- mgftrackmed.m                                                                                  
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/mgftrackmed.m 2004/6/2 14:20

%#%  Saved from Eps1:Desktop Folder:WorkingFall2k1:NeareyTracker4xApr2k1:mgftrackmed.m 2002/11/6 19:5
%#                                                                                                   
%#function [fsmo,bsmo,asmo]=mgftrackmed(nf,fc,bw,ampdb,fcutoff,bwthresh,globDb,frameDb)              
%#%[fsmo,bsmo,asmo]=mgftrack(nf,fc,bw,ampdb,fcutoff,bwthresh,globDb,frameDb)                         
%#%Markel and gray like initial sloting                                                              
%#% DOES 3 formants only                                                                             
%#% But with wrinkle... fest is 5 pt MEDIAN SMOOTH of all the 'exactly 3 candidates'                 
%#%nf n candidates (per frame)                                                                       
%#%fc  bw,ampdb-  raw FBA info                                                                       
%#% fcutoff -- est of (F3+F4)/2                                                                      
%#% bwthresh-- max bw for a real formant                                                             
%#% globDb,frameDb -- global and within frame dB thresholds compared to global or frame max          
%#% Version 2.0 allows F1 down to 150 Hz                                                             
%#% also  back fills missing values to first frame                                                   
%#% i.e. first frame with exactly 3 peaks is used for initial estimate                               
%#% bw and amp of filled candidates will be zero on return                                           
%#% Version 2.1 18 Dec 2000                                                                          
%#% Version 2.11 4 Jan 2001 -- fixes initialization problem with only  2 peaks                       
%#% Copyright 1998-2001 (C) T M Nearey.                                                              
%#nframe=size(fc,1);                                                                                 
%#if size(nf)==[1 1],                                                                                
%#	nf=ones(nframe,1)*nf;                                                                             
%#end                                                                                                
%#                                                                                                   
%#% Bad formants may be rep'd by zeros or by NaNs or by things out of range                          
%#% Matlab's rules for comparison allow say NaN>x =>0                                                
%#                                                                                                   
%#fsmo=zeros(nframe,3);                                                                              
%#asmo=fsmo;                                                                                         
%#bsmo=fsmo;                                                                                         
%#festmed=NaN+fsmo; % initialize to bbad stuff                                                       
%#% Fcutoff assumed at expected (f3+f4)/2,                                                           
%#% 500(1000)1500(2000)2500(3000)3500(4000)                                                          
%#fspac=fcutoff/3;                                                                                   
%#prev=fspac/2+[0:3]*fspac;                                                                          
%#if nargin<6                                                                                        
%#	bwthresh=750;                                                                                     
%#	globDb=70;                                                                                        
%#	frameDb=40;                                                                                       
%#end                                                                                                
%#% amplitudes must be within 40 db of maximum in frame                                              
%#% and within 70 db of maximum in stream                                                            
%#% Fkm1=fspac/2+[0:2]*fspac; % new initialization                                                   
%#maxampGlob=max(max(ampdb));                                                                        
%#maxampFrame=max(ampdb')';                                                                          
%#thresh=max(maxampGlob-abs(globDb),maxampFrame-abs(frameDb));                                       
%#% Three possible two point pairings                                                                
%#% candidate 1 assigned to peak 1, candidate 2 to peak 2 = 11 22                                    
%#pairs=[1 1 2 2; 1 1 2 3; 1 2 2 3];                                                                 
%#% look for first good frame                                                                        
%#goodt= (fc>150&fc<=fcutoff&bw<bwthresh & ampdb>repmat(thresh,1,size(fc,2)));                       
%#ngoodt=sum(goodt,2);                                                                               
%#use=find(ngoodt==3);                                                                               
%#for i=1:length(use);                                                                               
%#	iu=use(i);                                                                                        
%#	festmed(iu,:)=fc(iu,goodt(iu,:));  % copy over the goodones                                       
%#end                                                                                                
%#% the bad frames in festmed are NaN, so medsmoterp will work well                                  
%#festmed=medsmoterp(festmed,5);                                                                     
%#                                                                                                   
%#                                                                                                   
%#% pause                                                                                            
%#dbg=0;                                                                                             
%#for k=1:nframe                                                                                     
%#	Fkm1=festmed(k,:); % Local continuity be damned.. use adjacency to                                
%#					 % more stable local estimate                                                                 
%#                                                                                                   
%#	igood=find(fc(k,:)>150&fc(k,:)<=fcutoff&bw(k,:)<bwthresh & ampdb(k,:)>thresh(k));                 
%#	Fkhat=fc(k,igood);                                                                                
%#	Bkhat=bw(k,igood);                                                                                
%#	Akhat=ampdb(k,igood);                                                                             
%#	ngood=length(igood);                                                                              
%#	if dbg                                                                                            
%#		Fkhat                                                                                            
%#	 	Fkm1                                                                                            
%#	 	pause                                                                                           
%#	end                                                                                               
%#	%%%%%%%%%%                                                                                        
%#	fsmo(k,:)=Fkm1; % initialize to previous                                                          
%#	if ngood~=3                                                                                       
%#		% find best allignment to previous                                                               
%#		% 		Fkhat                                                                                        
%#		% 		Fkm1                                                                                         
%#		% 		repmat(Fkhat',1,3)                                                                           
%#		% 		repmat(Fkm1,ngood,1)                                                                         
%#		% 		%pause                                                                                       
%#		% rows are candidates                                                                            
%#		% columns are prior est                                                                          
%#		nu=abs(repmat(Fkhat',1,3)-repmat(Fkm1,ngood,1));                                                 
%#                                                                                                   
%#	end                                                                                               
%#	if ngood>=4                                                                                       
%#		% THIS CODE WAS IN ERROR                                                                         
%#		%%%%[d, worst]=find(max(min(nu')));                                                              
%#		%% REPAIRED 18 Dec 2000 also generalized to handle more than 3 candidates                        
%#		[d,ibest]=sort(min(nu'));                                                                        
%#		worst=ibest(4:end);                                                                              
%#		%%%% Disp                                                                                        
%#		if dbg                                                                                           
%#			disp('case4> 3')                                                                                
%#			fck=fc(k,:)                                                                                     
%#			igood                                                                                           
%#			Fkhat                                                                                           
%#			Fkm1                                                                                            
%#			nu                                                                                              
%#			pause                                                                                           
%#			worst                                                                                           
%#		end                                                                                              
%#		Fkhat(worst)=[];                                                                                 
%#		Bkhat(worst)=[];                                                                                 
%#		Akhat(worst)=[];                                                                                 
%#		ngood=3;                                                                                         
%#		%%%%%%                                                                                           
%#	end                                                                                               
%#	if ngood==3                                                                                       
%#		%%%                                                                                              
%#		if dbg                                                                                           
%#			disp('case 3');                                                                                 
%#		end                                                                                              
%#		% 	Fkhat,Bkhat,Akhat                                                                             
%#		fsmo(k,:)=Fkhat;                                                                                 
%#		bsmo(k,:)=Bkhat;                                                                                 
%#		asmo(k,:)=Akhat;                                                                                 
%#                                                                                                   
%#	else                                                                                              
%#                                                                                                   
%#		% Small enough to try all possible paths                                                         
%#		if ngood==1                                                                                      
%#			[dmin,imin]=min(nu(1,:));                                                                       
%#			fsmo(k,imin)=Fkhat(1);                                                                          
%#			if dbg                                                                                          
%#			 	disp('case 1')                                                                                
%#				imin                                                                                           
%#			end                                                                                             
%#		end                                                                                              
%#		if ngood==2                                                                                      
%#			for i=1:3                                                                                       
%#				d2pk(i)=nu(pairs(i,1),pairs(i,2))+nu(pairs(i,3),pairs(i,4));                                   
%#			end                                                                                             
%#			[dmin,imin]=min(d2pk);                                                                          
%#                                                                                                   
%#			try                                                                                             
%#			sl1=pairs(imin,2);                                                                              
%#			sl2=pairs(imin,4);                                                                              
%#			can1=pairs(imin,1);                                                                             
%#			can2=pairs(imin,3);                                                                             
%#		catch                                                                                            
%#			lasterr                                                                                         
%#			Fkhat                                                                                           
%#			d2pk                                                                                            
%#			imin                                                                                            
%#			pairs                                                                                           
%#			pause                                                                                           
%#			%%%                                                                                             
%#		end                                                                                              
%#			fsmo(k,sl1)=Fkhat(can1);                                                                        
%#			bsmo(k,sl1)=Bkhat(can1);                                                                        
%#			asmo(k,sl1)=Akhat(can1);                                                                        
%#			fsmo(k,sl2)=Fkhat(can2);                                                                        
%#			bsmo(k,sl2)=Bkhat(can2);                                                                        
%#			asmo(k,sl2)=Akhat(can2);                                                                        
%#                                                                                                   
%#		end                                                                                              
%#	end                                                                                               
%#	Fkm1=fsmo(k,:);                                                                                   
%#	if dbg                                                                                            
%#		newest=Fkm1                                                                                      
%#		pause                                                                                            
%#	end                                                                                               
%#end % for k frames                                                                                 
%#                                                                                                   
%#                                                                                                   
%#-h- parse.m                                                                                          
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/parse.m 2004/6/2 14:20
        
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:filetools:parse.m 2002/11/6 19:5
%#                                                                                                     
%#function p=parse(string,delimiters);                                                                 
%#%function p=parse(string,delimiters);                                                                
%#%  Parse STRING according to delimiters.  PARSE returns a string matrix in                           
%#%  which each row is a subsection of STRING bounded by delimiters.  By                               
%#%  default, DELIMTERS is any blankspace character.                                                   
%#% Vers 2.0 uses repeated calls to strtok and strvcat                                                 
%#% Vers 2.1 empty string handled                                                                      
%#error(nargchk(1,2,nargin));                                                                          
%#if isempty(string)                                                                                   
%#	p='';                                                                                               
%#	return                                                                                              
%#end                                                                                                  
%#if (min(size(string))~=1)|~isstr(string)                                                             
%#        error('STRING must be a vector string.');                                                    
%#end                                                                                                  
%#                                                                                                     
%#if nargin<2|isempty(delimiters);                                                                     
%#        delimiters=char([9:13,32]);                                                                  
%#end                                                                                                  
%#pt=[];                                                                                               
%#while ~isempty(string)                                                                               
%#	[ptt,string]=strtok(string,delimiters);                                                             
%#	pt=strvcat(pt,ptt);                                                                                 
%#end                                                                                                  
%#p=pt;                                                                                                
%#-h- pausemsg.m                                                                                          
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/pausemsg.m 2004/6/2 14:20
        
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:filetools:pausemsg.m 2002/11/6 19:5
%#                                                                                                        
%#function pausemsg(msg,varargin)                                                                         
%#% function pausemsg(msg,varargin)                                                                       
%#% function to do menu based pause which we hope viewers can see                                         
%#% the reserved special messages in msg                                                                  
%#% PAUSE ON, PAUSE OFF , {PAUSE ON DEBUG}, DEBUG                                                         
%#% set the PERSISTENT LOCAL pause flag                                                                   
%#%'pause on' (case insensitive)                                                                          
%#%'pause off'                                                                                            
%#% varargin.. variable numbers of.strings or scalars to add to menu -- a debugging tool                  
%#% if empty, a single OK button is  added                                                                
%#% copyright (c) 2001 TM Nearey                                                                          
%#% in  Nearey's tnguitools                                                                               
%#if nargin<2                                                                                             
%#	varargin={};                                                                                           
%#end                                                                                                     
%#if nargin<1                                                                                             
%#	msg='OK';                                                                                              
%#end                                                                                                     
%#persistent shouldpausemsg allowabort                                                                    
%#                                                                                                        
%#if isempty(shouldpausemsg)                                                                              
%#	shouldpausemsg=1;                                                                                      
%#end                                                                                                     
%#chkmsg=deblank(upper(msg));                                                                             
%#switch chkmsg                                                                                           
%#case 'PAUSE ON'                                                                                         
%#	shouldpausemsg=1;                                                                                      
%# 	msg='Pause is now on';                                                                                
%#	allowabort=0;                                                                                          
%#case 'PAUSE OFF'                                                                                        
%#	shouldpausemsg=0;                                                                                      
%#	allowabort=0;                                                                                          
%#case {'PAUSE ON DEBUG', 'DEBUG'}                                                                        
%#	msg='Pause is now on -- and abort allowed for traceback';                                              
%#	shouldpausemessage=1                                                                                   
%#	allowabort=1;                                                                                          
%#end                                                                                                     
%#                                                                                                        
%#if ~shouldpausemsg                                                                                      
%#	return                                                                                                 
%#end                                                                                                     
%#chkmsg=deblank(upper(msg));                                                                             
%#switch chkmsg                                                                                           
%#case 'PAUSE ON'                                                                                         
%#	shouldpausemsg=1;                                                                                      
%# 	msg='Pause is now on';                                                                                
%#case 'PAUSE OFF'                                                                                        
%#	shouldpausemsg=0;                                                                                      
%#	return                                                                                                 
%#end                                                                                                     
%#ttl='PAUSE MSG: Click a button to continue';                                                            
%#tcell{1}=msg;                                                                                           
%#for i=1:length(varargin)                                                                                
%#	t=varargin{i}                                                                                          
%#	if ~isempty(t)                                                                                         
%#		switch class(t)                                                                                       
%#		case 'char'                                                                                           
%#			if size(t,1)>1,                                                                                      
%#				t=t(1,:), t=[t,'<line 1 of arg ', num2str(i+1)]                                                     
%#                                                                                                        
%#			end                                                                                                  
%#		case 'double'                                                                                         
%#			tp=prod(size(t))>1;                                                                                  
%#			t=t(1);                                                                                              
%#			t=num2str(t);                                                                                        
%#			if tp                                                                                                
%#				[t,' <el 1 of arg ', num2str(i+1)]                                                                  
%#                                                                                                        
%#			end                                                                                                  
%#		otherwise                                                                                             
%#			disp UNKNOWN_ARGTYPE_IN_PAUSEMSG                                                                     
%#			t                                                                                                    
%#			typet=class(t)                                                                                       
%#			t='????'                                                                                             
%#		end                                                                                                   
%#		tcell{i+1}=t;                                                                                         
%#	end                                                                                                    
%#end                                                                                                     
%#if allowabort,                                                                                          
%#	tcell{end+1}='QUIT NOW';                                                                               
%#end                                                                                                     
%#jnk=menu(ttl,tcell);                                                                                    
%#if allowabort & jnk==length(tcell)                                                                      
%#	error('Traceback called by user')                                                                      
%#end                                                                                                     
%#-h- playsc.m                                                                                      
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/playsc.m 2004/6/2 14:20
    
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:SIGIO:playsc.m 2002/11/6 19:5
%#                                                                                                  
%#function playsc(varargin);                                                                        
%#% Caller to soundsc through playsigsafe                                                           
%#% version 2.0 Copyright T.M. Nearey 2002                                                          
%#% same args as soundsc                                                                            
%#playsigsafe(1,varargin);                                                                          
%#-h- playsigsafe.m                                                                                      
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/playsigsafe.m 2004/6/2 14:20
    
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:SIGIO:playsigsafe.m 2002/11/6 19:5
%#                                                                                                       
%#function playsigsafe(scale,otherargs);                                                                 
%#% Caller to soundsc or sound..safe version                                                             
%#% To avoid problems with overlapping playbacks                                                         
%#% WARNING safe feature will not work unless all calls to playback                                      
%#% go through this routine                                                                              
%#% used by playsc and playnosc, playpadsc, playnopadsc..                                                
%#% Checks for no errors on playback                                                                     
%#% checks last time something was played (throug playsc)                                                
%#% and delays till after it should be done                                                              
%#% version 2.0 Copyright T.M. Nearey 2002                                                               
%#% if scale is 1, then calls matlab soundsc, else calls sound                                           
%#% other arguments to soundsc or sound are passed along in otherargs                                    
%#persistent lastplayedtime lastplayeddur% keep track of when last thing started to play                 
%#if isempty(lastplayedtime)                                                                             
%#	lastplayedtime=cputime;                                                                               
%#	lastplayeddur=0;                                                                                      
%#end                                                                                                    
%#error(nargchk(2,2,nargin));                                                                            
%#varargin=deal(otherargs); %  peal them out to pass them on;                                            
%#nvararg=size(varargin);                                                                                
%#if nvararg<2 | scale & nvararg==2 & isequal( size(varargin{2}),[1,2])% special case for slim           
%#	fs=10000;                                                                                             
%#else                                                                                                   
%#	fs=varargin{2};                                                                                       
%#end                                                                                                    
%#delay=.1;                                                                                              
%#played=0;                                                                                              
%#ntry=0;                                                                                                
%#while ~played                                                                                          
%#	elapsed=cputime-lastplayedtime;                                                                       
%#	if elapsed>=lastplayeddur                                                                             
%#		try                                                                                                  
%#			if scale                                                                                            
%#				soundsc(varargin{:});                                                                              
%#			else                                                                                                
%#				sound(varargin{:});                                                                                
%#			end                                                                                                 
%#			lastplayedtime=cputime;                                                                             
%#			lastplayeddur=size(varargin{1},1)/fs;                                                               
%#			played=1;                                                                                           
%#		catch                                                                                                
%#			ntry=ntry+1;                                                                                        
%#			delay=max(delay,size(varargin{1},1)/fs);                                                            
%#			delay=delay*ntry;                                                                                   
%#			pause(delay);                                                                                       
%#			if ntry>5                                                                                           
%#				warning('Cannot play after 5 tries... giving up')                                                  
%#				return                                                                                             
%#			end                                                                                                 
%#		end                                                                                                  
%#	end                                                                                                   
%#end                                                                                                    
%#-h- plotsgm.m                                                                                           
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/plotsgm.m 2004/6/2 14:20
         
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:plotsgm.m 2002/11/6 19:5
%#                                                                                                        
%#function plotsgm(tax,fax,X,color,dbrng,beta);                                                           
%#%function plotsgm(tax,fax,X,color,dbrng,pow);                                                           
%#% plotsgm(color); --- change from default (jet) to inverse gray;                                        
%#if nargin<5,                                                                                            
%#	dbrng=100;                                                                                             
%#end                                                                                                     
%#if nargin<4|isempty(color)                                                                              
%#	color='jet';                                                                                           
%#end                                                                                                     
%#                                                                                                        
%#if (strcmp(upper(color),'GRAY'))|(strcmp(upper(color),'GREY'))                                          
%#	colormap(flipud('gray'));                                                                              
%#else                                                                                                    
%#	colormap('jet');                                                                                       
%#end                                                                                                     
%#if nargin==6 & ~isempty(beta)                                                                           
%#	brighten(beta);                                                                                        
%#end                                                                                                     
%#xmx=max(X(:));                                                                                          
%#xmn=xmx-dbrng;                                                                                          
%#imagesc(tax,fax,max(X,xmn));                                                                            
%#axis('xy');                                                                                             
%#                                                                                                        
%#                                                                                                        
%#                                                                                                        
%#                                                                                                        
%#-h- r2lpc.m                                                                                           
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/r2lpc.m 2004/6/2 14:20
         
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:r2lpc.m 2002/11/6 19:5
%#                                                                                                      
%#function [a,gainsq,rc]=r2lpc(r,m);                                                                    
%#%function [a,gainsq,rc]=r2lpc(r,m);                                                                   
%#% autocorrelation lpc of order m                                                                      
%#% returns rowvectors (like levinson in signal)                                                        
%#% length of r on input is m+1 where m max lags = lpcorder                                             
%#% gainsq is squared gain= M&G alpha in auto                                                           
%#% from Hermansky 1989 JASA                                                                            
%# error(nargchk(1,2,nargin))                                                                           
%# if nargin < 2, m = length(r)-1; end                                                                  
%#  if r(1)<=0                                                                                          
%# 	a=[1,zeros(1,m)];% no signal;                                                                       
%#	gainsq=0;                                                                                            
%#  	return                                                                                             
%# end                                                                                                  
%#                                                                                                      
%#    if length(r)<(m+1), error('Correlation vector too short.'), end                                   
%#                                                                                                      
%#	a=zeros(1,m+1);                                                                                      
%#	rc=zeros(1,m+1);                                                                                     
%#	alp=zeros(1,m+1);                                                                                    
%#	a(1)=1.0;                                                                                            
%#	alp(1)=r(1);                                                                                         
%#	rc(1)=-r(2)/r(1);                                                                                    
%#	a(2)=rc(1);                                                                                          
%#	alp(2)=r(1)+r(2)*rc(1);                                                                              
%#	for mct=2:m                                                                                          
%#		s=0;                                                                                                
%#		mct2=mct+2;                                                                                         
%#		alpmin=alp(mct);                                                                                    
%#		for ip=1:mct                                                                                        
%#			idx=mct2-ip;                                                                                       
%#			s=s+r(idx)*a(ip);                                                                                  
%#		end % for ip (60)                                                                                   
%#		rcmct=-s/alpmin;                                                                                    
%#		mh=mct/2+1;                                                                                         
%#		for ip=2:mh                                                                                         
%#			ib=mct2-ip;                                                                                        
%#			aip=a(ip);                                                                                         
%#			aib=a(ib);                                                                                         
%#			a(ip)=aip+rcmct*aib;                                                                               
%#			a(ib)=aib+rcmct*aip;;                                                                              
%#		end % for ip (70)                                                                                   
%#		a(mct+1)=rcmct;                                                                                     
%#		alp(mct+1)=alpmin-alpmin*rcmct*rcmct;                                                               
%#		rc(mct)=rcmct;                                                                                      
%#	end% for mct (50);                                                                                   
%#	gainsq=alp(m+1);                                                                                     
%#                                                                                                      
%#	% a agrees with levinson(r)                                                                          
%#                                                                                                      
%#-h- sgm2alpcsel.m                                                                                           
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/sgm2alpcsel.m 2004/6/2 14:20
         
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:sgm2alpcsel.m 2002/11/6 19:5
%#                                                                                                            
%#function [alpc,gainsq,flo,fhi]=sgm2alpcsel(X,Fs,FloTarg,FhiTarg,lpcord,Beq)                                 
%#%function [alpc,gainsq,flo,fhi]=sgm2alpcsel(X,Fs,FloTarg,FhiTarg,lpcord,Beq)                                
%#% Produce the LPC ('a') coefficients of a (power) spectral section                                          
%#% Should be non-folded  power spectrum (1:[nfft/2+1]) (as from tsfftsgm)                                    
%#% Input can be a spectrogram (freq rows x time cols)                                                        
%#% 1 Jan 1998 Copyright T. Nearey                                                                            
%#% alpc will have time-series vector form (rows=time, cols=coeffieient)                                      
%#% gainsq will lso be a col vector (ntime  x 1)                                                              
%#% Beq is Tohkura's lagwindow (gaussian) smoothing (120 hz recommended)                                      
%#% modified for zero Beq 22 nov 2001                                                                         
%#%                                                                                                           
%#% Version 1.2 forces FhiTarg and FloTarg into Nyquist band                                                  
%#% Copyright T.M Nearey 1998-2002                                                                            
%#                                                                                                            
%#[nfold,nslice]=size(X);                                                                                     
%#delf=Fs/(2*(nfold-1));                                                                                      
%#                                                                                                            
%#                                                                                                            
%#nlag=lpcord;                                                                                                
%#%fax =  linspace(0,Fs,nfold)';                                                                              
%#if FhiTarg>Fs/2                                                                                             
%#	warning('FhiTarg set to nyquist')                                                                          
%#	FhiTarg=Fs/2;                                                                                              
%#end                                                                                                         
%#if FloTarg<0                                                                                                
%#	warning('FloTarg set to zero')                                                                             
%#	pause                                                                                                      
%#end                                                                                                         
%#klo=floor(FloTarg/delf)+1;                                                                                  
%#khi=ceil(FhiTarg/delf)+1;                                                                                   
%#% klo                                                                                                       
%#% khi                                                                                                       
%#% nfold                                                                                                     
%#% nslice                                                                                                    
%#% pause                                                                                                     
%#flo=(klo-1)*delf; % actual frequency range of selection                                                     
%#fhi=(khi-1)*delf;                                                                                           
%#l=khi-klo;                                                                                                  
%#L=2*l;                                                                                                      
%#alpc=zeros(nslice,lpcord+1);                                                                                
%#gainsq=zeros(nslice,1);                                                                                     
%#% force to even                                                                                             
%#sp2accmat=1/L*exp(-i*2*pi/L* [0:L-1]'*[0:nlag])	;                                                           
%#                                                                                                            
%#if Beq>0                                                                                                    
%#	lagw=lagwin((fhi-flo)*2,Beq,lpcord+1,'GAU')'; % rt wants a row below                                       
%#else                                                                                                        
%#	lagw=1;                                                                                                    
%#end                                                                                                         
%#                                                                                                            
%#Xt=zeros(L,1);                                                                                              
%#for islice=1:nslice                                                                                         
%#	% zero delay is at size(rx,1)+1/2+1;                                                                       
%#	Xt(1:(l+1))=X(klo:khi,islice);                                                                             
%#	Xt((l+2):L)=flipud(Xt(2:l));                                                                               
%#	rt=real(Xt'*sp2accmat);                                                                                    
%#	%sizert=size(rt)                                                                                           
%#	%sizelagw=size(lagw);                                                                                      
%#	[alpc(islice,:),gainsq(islice)]=r2lpc(rt.*lagw);                                                           
%#end                                                                                                         
%#-h- tracker4xpDemo.m                                                                                                          
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/tracker4xpDemo.m 2004/6/2 14:20
                        
%#function tracker4xpDemo(wavfile)                                                                                              
%#% Demonstrate tracker4xpOnefile....                                                                                           
%#% This implementation is too slow on most machines for practical                                                              
%#% interactive use.                                                                                                            
%#% Note it is really only designed for mostly voiced speech                                                                    
%#% It will track through moderate voiceless periods, but it was not designed                                                   
%#% to.                                                                                                                         
%#%  In production use, tracker4xp is used with a driver program that                                                           
%#% runs through a whole list of files and saves the returned arguments in                                                      
%#% orher files. These are then screened by a trained observer using                                                            
%#% ad-hoc graphics routines. and the 'good' measurements are saved for                                                         
%#% further study. If you have enough storage, this means you can batch up                                                      
%#% hundreds of files for later rapid interactive screening. Gives your computer                                                
%#% something to do at night.                                                                                                   
%#% Thie file HelloEh22050.wav I tried packaged with this file should                                                           
%#% provides a reasonable test case. F3 and F4 are farily close,  and they                                                      
%#% wobble around a bit.  Analysis 2 is preferred, though it appears to                                                         
%#% cut F3 a little short. Analysis 3 that puts the cutoff right at about                                                       
%#% average F4 clearly does the best job by my eyeballing. It probably                                                          
%#% didn't do as well because of the analysis by synthesis component of the                                                     
%#% figure of merit.. which would probably not like the extra energy at the                                                     
%#% top of the spectrum.                                                                                                        
%#% This illustrates why several cutoffs need to be explored for even a                                                         
%#% single voice. It also illustrates why I want to explore other cutoff                                                        
%#% criteria. Cases where no single f3 f4 cutoff for a single utterance is                                                      
%#% satisfactory are not hard to come by.                                                                                       
%#thisdir=parsepath(which('tracker4XpDemo'));                                                                                   
%#                                                                                                                              
%#if nargin==0                                                                                                                  
%#     try                                                                                                                      
%#          wavfile=[thisdir,'HelloEh22050.wav'];                                                                               
%#     catch                                                                                                                    
%#          disp(['Sorry can''t find the test file: ',wavfile])                                                                 
%#          disp('Call tracker4xpDemo(<WaveFileName>) where <WaveFileName> is a full path  name to a .wav file')                
%#          return                                                                                                              
%#     end                                                                                                                      
%#end                                                                                                                           
%#% f34 cutoffs are a list of expected cutoff frequencies above f3 but below                                                    
%#% f4. It is approximately  an upper bound for f3.                                                                             
%#% Rule of thumb 3000 * sf where sf is scale factor for a voice relative to                                                    
%#% P&B standard male value. So 1.15 *3000  to 1.25 would be a good female range                                                
%#%  and 2.0*3000 would be good for one-year old.                                                                               
%#wavfile                                                                                                                       
%#[x,Fs]=wavread(wavfile);                                                                                                      
%#f34cutoffs=round(exp(linspace(log(2000),log(5000),6)));                                                                       
%#                                                                                                                              
%#watchlevel=0;                                                                                                                 
%#[bestRec,allTrialsRec,scorecompslabels,XsmoDb,faxsmo]=tracker4xpOneFile(x,Fs,f34cutoffs,wavfile,watchlevel);                  
%#                                                                                                                              
%#figure(1)                                                                                                                     
%#clf                                                                                                                           
%#taxsg= bestRec.taxsg;                                                                                                         
%#plotsgm(taxsg,faxsmo,XsmoDb);                                                                                                 
%#hold on;                                                                                                                      
%#colorstr='bgr'                                                                                                                
%#plot(taxsg,bestRec.savefest,'w','LineWidth',2) % white background                                                             
%#plot(taxsg,bestRec.savefest);                                                                                                 
%#title(' Formant estimates with best figure of merit')                                                                         
%#                                                                                                                              
%#                                                                                                                              
%#figure(2);                                                                                                                    
%#clf                                                                                                                           
%#subplotrc('tight')                                                                                                            
%#% Plot all 6 alternatives with f34 cutoffs                                                                                    
%#nc=3; mr=2                                                                                                                    
%#itry=0;                                                                                                                       
%#for ir=1:mr                                                                                                                   
%#     for ic=1:nc                                                                                                              
%#          itry=itry+1;                                                                                                        
%#          subplotrc(mr,nc,ir,ic);                                                                                             
%#          plotsgm(taxsg,faxsmo,XsmoDb);                                                                                       
%#          hold on;                                                                                                            
%#          % Plot the f3 cutoff                                                                                                
%#          plot([taxsg(1),taxsg(end)],[f34cutoffs(itry),f34cutoffs(itry)],'w-.')                                               
%#          plot(taxsg,allTrialsRec.fest{itry,1},'w','LineWidth',2) % white background                                          
%#          plot(taxsg,allTrialsRec.fest{itry,1});                                                                              
%#          tstr=sprintf('itry=%d, FoM=%6.4f,f34cut=%4d',itry,allTrialsRec.scorecomps(itry,1),f34cutoffs(itry));                
%#          text(taxsg(1),faxsmo(end),tstr,'VerticalAlignment', 'top', 'HorizontalAlignment','left','BackgroundColor',[1 .8 .8])
%#     end                                                                                                                      
%#end                                                                                                                           
%#-h- tracker4xpOneFile.m                                                                                                                      
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/tracker4xpOneFile.m 2004/6/2 14:20
                                    
%#function [bestRec,allTrialsRec,scorecompslabels,Xsmodb,faxsmo]=tracker4xpOneFile(x,Fs,f34cutoffs,fname,watchlevel)                           
%#% Tracker 4xp Beta0p4 (zero point 4).                                                                                                        
%#% Copyright T.M Nearey 2004                                                                                                                  
%#% This is minimally modified (to return Xsmodb and faxsmo) version of                                                                        
%#% of the versin of tracker4XP installed in Peter's lab at UTD. This version                                                                  
%#% is known to work 'off campus' , ie. not in my lab.                                                                                         
%#% The algorithm implemented is the one described at Cancun ASA meeting.                                                                      
%#%  see tracker4xpDemo for example call                                                                                                       
%#%INPUT:                                                                                                                                      
%#% x -- signal to track (assumed to be a single vocalic chunk'                                                                                
%#% Fs --  sampling rate (Hz)                                                                                                                  
%#% f34cutoffs -- (ntry x 1)  a vector of 'trial'  cutoff frequencies                                                                          
%#%        These should be guesses of  cutoffs of frequencies that will likely                                                                 
%#%          be above f3 but below f4.  It is suggested that user try a range of                                                               
%#%        values bracketing the expected upper frequency range of F3 roughly                                                                  
%#%        halfway between 'average' f3 and average f4 for the voices to be                                                                    
%#%        tracked. A very large range can be tried, but this will slow                                                                        
%#%        things down. To coarse a sampling can result in not finding a good                                                                  
%#%        cutoff that splits f3 and f4. (I.e. including too many or too few                                                                   
%#%        candidates in the range)                                                                                                            
%#%  	fname -- name of file analyzed (optional)                                                                                                
%#% 	 watchlevel-- (what to show and pause for everything above zero is for debugging in NeareyLab).                                           
%#%        0 - pure batch,                                                                                                                     
%#% 	    1 - show best only and pause                                                                                                          
%#% 	    2 - show everything pause judiciously                                                                                                 
%#% 	    3 - debug pause all over the place                                                                                                    
%#% OUTPUT:                                                                                                                                    
%#%bestRec record with Fields:                                                                                                                 
%#%	'taxsg' - (nframe x 1) time axis vector (milliseconds) length(taxsg)=nframe;                                                               
%#%	'savefest'- (nframe x 3 ) array of formant estimates f1 to f3                                                                              
%#%      so that plot(taxsg,savefest) will plot formant tracks.                                                                                
%#%	'scorecompsbest'  score components                                                                                                         
%#% 	'f34cutoffbest' best f3/4 cutoff frequency                                                                                                
%#% 	'fname' - passed from input, if given                                                                                                     
%#%                                                                                                                                            
%#% allTrialsRec record with fields:                                                                                                           
%#%   'taxsg'-  as above                                                                                                                       
%#%   'fest' - {ntry x 2} cellarray of (nframe x 3) formant estimates where ntry is length(f34cutoffs)                                         
%#%      so that for i=1:ntry, for j=1:2 plot(taxsg,fest{i,j})                                                                                 
%#%      will plot all the formant tracks investigated. Only fest{:,1} are possible candidates for fbest                                       
%#%      fest{:,2) are used in the 'scorecomp' rfstable                                                                                        
%#%   'scorecomps'--{ntry x 9} evaluation score of the tracks in fest{:,1}                                                                     
%#%    i.e. scorecomps(itry,j) is the score for fest(itry,1)                                                                                   
%#%     scorecomps(itry,1) is the composite 'figure of merit' for each trial                                                                   
%#%     trackset. If iargmax is determined by [xmx,iargmax]=max(scorecomps(:,1))                                                               
%#%     allTrialsRec.fest{iargmax,1} corresponds to bestRec.savefest                                                                           
%#%                                                                                                                                            
%#%   'f34cutoffs' -- copy of input cutoffs                                                                                                    
%#%   'fname' copy of input file                                                                                                               
%#%   'dBPerOct' - dB/Octave adjustment used in analysis by synthesis regression (may be useable in future evaluation)                         
%#% Xsmodb - an lpc smoothed spectrogram (it may show some harmonic breaking)                                                                  
%#%          on which other analyses are ultimately based (X_smo_db)                                                                           
%#%                                                                                                                                            
%#% faxsmo - the frequency axis of XsmoDb. plotsgm(taxsg,faxsmo,XsmoDb) will                                                                   
%#%     plot the target spectrogram over which the smoothed formant tracks                                                                     
%#%     can be plotted                                                                                                                         
%#% Fuzzy MGTrack with stability check                                                                                                         
%#% multiple tries of MG track at different  selective lpc fhi cutoffs                                                                         
%#% with a 'stability check' for extra formant in range                                                                                        
%#% (If you add one extra coefficient and things really change, this is not a good cutoff)                                                     
%#% with ABS verification of spectrum levels                                                                                                   
%#% A baroque formant tracker                                                                                                                  
%#% Version 4.. using MGMedian tracker 5 Jan 2000 and extra median smooth                                                                      
%#%   Also... selective LPC goes for 5 formant analysis                                                                                        
%#% This is on basis of Markel and Grey example p 159 5 extra coefs above F5                                                                   
%#% But only lowest 3 are modeled subsequently                                                                                                 
%#% Also.. 0.9 premphasis used                                                                                                                 
%#% Also... Spectrum of Target (large scale) LPC is used                                                                                       
%#% Also .. Number of coefficients in large scale LPC is made more conservative                                                                
%#% clear all;                                                                                                                                 
%#                                                                                                                                             
%#% close all;                                                                                                                                 
%#% fclose all;                                                                                                                                
%#% Version 4.1                                                                                                                                
%#% Bandwidth expectation corrected 60 Hz or .06 *Formant frequency                                                                            
%#% Version 4.1a dB/octave slope returned  from  anbysynchk3 (v1.1) and saved in mtx files                                                     
%#% Version 4.1b 'noload' arg added to getNextPfaKid for continuation of runs (no name checking)                                               
%#theNargsIn=nargin                                                                                                                            
%#                                                                                                                                             
%#if nargin==0                                                                                                                                 
%#	pausemsg('Testing... Go find a wave file')                                                                                                  
%#	fname=uigetpath('*.wav');                                                                                                                   
%#	[x,Fs]=wavread(fname);                                                                                                                      
%#	watchlevel=1;                                                                                                                               
%#	f34cutoffs=round(exp(linspace(log(3000),log(5000),6)));                                                                                     
%#	[bestRec,allTrialsRec,scorecompslabels]=tracker4xpOneFile(x,Fs,f34cutoffs,fname,watchlevel);                                                
%#	figure(1);                                                                                                                                  
%#	clf                                                                                                                                         
%#	plot(bestRec.taxsg,bestRec.savefest);                                                                                                       
%#	title('Best track guess')                                                                                                                   
%#	kmenu=menu('Make text archive', 'Y', 'N')                                                                                                   
%#	if kmenu==1                                                                                                                                 
%#		inmemarchive({'Nearey','Working'},'tracker4xpOneFileAr.txt',0)                                                                             
%#	end                                                                                                                                         
%#                                                                                                                                             
%#	return                                                                                                                                      
%#                                                                                                                                             
%#end                                                                                                                                          
%#                                                                                                                                             
%#MEGABATCHDEBUG=0;                                                                                                                            
%#RANDOMSELECTION=0;                                                                                                                           
%#                                                                                                                                             
%#                                                                                                                                             
%#batchrun=watchlevel==0;                                                                                                                      
%#                                                                                                                                             
%#                                                                                                                                             
%#if batchrun                                                                                                                                  
%#	warning off                                                                                                                                 
%#	pausemsg('pause off')                                                                                                                       
%#	% show the best one                                                                                                                         
%#	% show alternate (extra coefficient) candidate analyses ( 2*NFT+1 and 2*NFT+2 coefs)                                                        
%#	% show all the candidate analysis                                                                                                           
%#else                                                                                                                                         
%#	warning on                                                                                                                                  
%#	pausemsg('pause on Debug')                                                                                                                  
%#	% show alternate (extra coefficient) candidate analyses ( 2*NFT+1 and 2*NFT+2 coefs)                                                        
%#	% show all the candidate analysis                                                                                                           
%#                                                                                                                                             
%#end                                                                                                                                          
%#                                                                                                                                             
%#% if batchrun % figure out total number of elements to process                                                                               
%#% 	possave=ftell(ffnl);                                                                                                                      
%#% 	eof=0;                                                                                                                                    
%#% 	nSigsTot=0;                                                                                                                               
%#% 	while ~eof                                                                                                                                
%#% 		[t,eof]=fgetline(ffnl,1);                                                                                                                
%#% 		if ~eof,                                                                                                                                 
%#% 			nSigsTot=nSigsTot+1;                                                                                                                    
%#% 		end                                                                                                                                      
%#% 	end                                                                                                                                       
%#% 	fseek(ffnl,possave,-1);                                                                                                                   
%#% end                                                                                                                                        
%#                                                                                                                                             
%#                                                                                                                                             
%#% figure out                                                                                                                                 
%#% showbest=1                                                                                                                                 
%#% watch=1                                                                                                                                    
%#% pause on                                                                                                                                   
%#% NEMPH=1;                                                                                                                                   
%#% emphset=linspace(.7,.95,NEMPH);                                                                                                            
%#                                                                                                                                             
%#%hitargset=3000*exp(linspace(log(1.0),log(1.4),NHITARG)); % Corrected for consistency.. max is 1.5 male                                      
%#clear checkhalt                                                                                                                              
%#hitargset=f34cutoffs;                                                                                                                        
%#NHITARG=length(f34cutoffs);                                                                                                                  
%#%ntry=NEMPH*NHITARG;                                                                                                                         
%#% We're only doing one emph....                                                                                                              
%#ntry=NHITARG;                                                                                                                                
%#%==============================                                                                                                              
%#% Schafer and Rabiner male ranges                                                                                                            
%#% JASA 47 no 2 1970 p 634-648                                                                                                                
%#Fmn(1)=200;Fmx(1)=900;                                                                                                                       
%#Fmn(2)=550;Fmx(2)=2700; % fig 9 p 640                                                                                                        
%#Fmn(3)=1100;Fmx(3)=2950;                                                                                                                     
%#% My own guess: F4mi                                                                                                                         
%#Fmn(4)=2700; Fmx(4)=3950;                                                                                                                    
%#%==============================                                                                                                              
%#                                                                                                                                             
%#                                                                                                                                             
%#% Let's set an absolute upper target for the smoothed spectrogram                                                                            
%#% plenty of coefficients for lowest frequency voice                                                                                          
%#                                                                                                                                             
%#FsmoHi=4/3*max(f34cutoffs)+100;% =6000 %  four formants for highest voice                                                                    
%#%                                                                                                                                            
%#                                                                                                                                             
%#                                                                                                                                             
%#%VSELECT=[2 3 6 8]                                                                                                                           
%#VSELECT=[1:12];                                                                                                                              
%#calcdist=0;                                                                                                                                  
%#                                                                                                                                             
%#tic                                                                                                                                          
%#                                                                                                                                             
%#inext=0;                                                                                                                                     
%#                                                                                                                                             
%#                                                                                                                                             
%#if batchrun                                                                                                                                  
%#	% progressmonitor(0)                                                                                                                        
%#end                                                                                                                                          
%#scorecompslabels=cellstr(parse('score,presence,bwreason,ampreason,contreason,distreason,rabs,rangereason,rfstable',','));                    
%#                                                                                                                                             
%#processingcomplete=0;                                                                                                                        
%#lastfileprocessed='';                                                                                                                        
%#                                                                                                                                             
%#if watchlevel>0                                                                                                                              
%#	close all                                                                                                                                   
%#end                                                                                                                                          
%#                                                                                                                                             
%#                                                                                                                                             
%#tmin=0;                                                                                                                                      
%#tmax=length(x)/Fs*1000;                                                                                                                      
%#if ~batchrun                                                                                                                                 
%#	try                                                                                                                                         
%#		playsc(x,Fs)                                                                                                                               
%#	end                                                                                                                                         
%#end                                                                                                                                          
%#                                                                                                                                             
%#% INITIAL SPECTROGRAM                                                                                                                        
%#% Window setup                                                                                                                               
%#win=getwin(100,'COS4', Fs); % 100 ms cosine 4 window                                                                                         
%#% get approx bw of window... Half bw here.                                                                                                   
%#% to know how to widen formant bws                                                                                                           
%#winSpec=10*log10(abs(fft(win)));                                                                                                             
%#dfwin=Fs/length(winSpec);                                                                                                                    
%#imin=min(find(winSpec<(winSpec(1)-3)));                                                                                                      
%#bwwin=2*interp1(winSpec(1:imin),linspace(0,dfwin,imin)',winSpec(1)-3);                                                                       
%#premph=.95; % version 3.and later                                                                                                            
%#FloTarg=0;                                                                                                                                   
%#dt=2;                                                                                                                                        
%#df=10;                                                                                                                                       
%#fast=1;                                                                                                                                      
%#                                                                                                                                             
%#[X2sg,taxsg,faxsg]=tsfftsgm(tmin,tmax,x,Fs,win,dt,df,premph,fast);%,rowistime,wantcomplex)                                                   
%#if watchlevel>3                                                                                                                              
%#	figure(1)                                                                                                                                   
%#	clf                                                                                                                                         
%#	plotsgm(taxsg,faxsg,10*log10(X2sg));                                                                                                        
%#	colorbar                                                                                                                                    
%#	title(['NarrowSGM', fname])                                                                                                                 
%#	pausemsg('NarrowSGM')                                                                                                                       
%#end % if watch                                                                                                                               
%#%=================================                                                                                                           
%#%% Target smoothed spectrogram (to check against abs                                                                                         
%#%=================================                                                                                                           
%#%TargetSpectrumType='CEP'                                                                                                                    
%#TargetSpectrumType='LPC';                                                                                                                    
%#%=================================                                                                                                           
%#                                                                                                                                             
%#switch TargetSpectrumType                                                                                                                    
%#% 	case 'CEP'                                                                                                                                
%#% 		%Schaefer and Rabiner window                                                                                                             
%#% 		cwin=10;                                                                                                                                 
%#% 		sgmonly=1;                                                                                                                               
%#% 		tau=[0:1./Fs:3.6/1000]'; % non zero delays                                                                                               
%#% 		den=36/10000; %10 Khz in original pformula 1.3 of Olive                                                                                  
%#% 		i1=find(tau<=2/1000);                                                                                                                    
%#% 		i2=find(tau>2/1000&tau<3.6/1000);                                                                                                        
%#% 		cwin=zeros(size(tau));                                                                                                                   
%#% 		tau1=2/1000;                                                                                                                             
%#% 		deltau=1.6/1000;                                                                                                                         
%#% 		cwin(i1)=1;                                                                                                                              
%#% 		cwin(i2)=.5*(1+cos(pi*(tau(i2)-tau1)/deltau)); % Schaefer and Rabiner JASA 47 p 638 (1970)                                               
%#% 		if 0                                                                                                                                     
%#% 			figure(37)                                                                                                                              
%#% 			plot(tau*1000,cwin)                                                                                                                     
%#% 			title('Cepstral window (lifter)')                                                                                                       
%#% 			pausemsg                                                                                                                                
%#% 		end                                                                                                                                      
%#% 		[rcepc,Xsmodb]=fastsgm2rceps(X2sg,cwin);%,nfftXdb)                                                                                       
%#% 		maxsgbin=max(find(faxsg<=FsmoHi));                                                                                                       
%#% 		faxsmo=faxsg(1:maxsgbin);                                                                                                                
%#% 		FsmoHi=faxsmo(end);                                                                                                                      
%#% 		Xsmodb=Xsmodb(1:maxsgbin,:);                                                                                                             
%#% 		if watch                                                                                                                                 
%#% 			figure(1);                                                                                                                              
%#% 			plotsgm(taxsg,faxsmo,Xsmodb);                                                                                                           
%#%                                                                                                                                            
%#% 			colorbar                                                                                                                                
%#% 			title('Cepstrogram  for target');                                                                                                       
%#% 			pausemsg                                                                                                                                
%#% 		end                                                                                                                                      
%#case 'LPC'                                                                                                                                   
%#	% but this coul                                                                                                                             
%#	% we need to keep this in the same frequency range as the cepstrum would have                                                               
%#	% been.. he cepstrum is in the original freq scale.                                                                                         
%#	%emph(itry)=premph; % for later reporting                                                                                                   
%#	% alpc needs to be a cell... varying sizes                                                                                                  
%#	% gainsq could be a 2d  array... but easier to handle as cell                                                                               
%#	% fhi is fine as a vector (one value for each try)                                                                                          
%#	Beq=125;                                                                                                                                    
%#	FloTarg=0;                                                                                                                                  
%#	lpcord=2*round(FsmoHi/(450*2))+5; %  Only a few extra... previous example had 2x as many                                                    
%#	% This might start resolving harmonics.                                                                                                     
%#	[alpcsmo,gainsqsmo,Floact,FsmoHi]=sgm2alpcsel(X2sg,Fs,FloTarg,FsmoHi,lpcord,Beq);                                                           
%#	% could do a test here for too many (>6) narrow band formants and reduce                                                                    
%#	% till they disappear We are hoping that BEQ will fix it                                                                                    
%#	df=faxsg(2); % same resolution as original spectrogram                                                                                      
%#	stype='dB';                                                                                                                                 
%#	[Xsmodb,faxsmo]=alpc2sgm(alpcsmo,gainsqsmo,FsmoHi*2,df,fast,stype);                                                                         
%#	X2smo=10.^(Xsmodb/10); % Power spectrum version 4 so smaller selections can be derived                                                      
%#	if watchlevel>1                                                                                                                             
%#		figure(1)                                                                                                                                  
%#		plotsgm(taxsg,faxsmo,Xsmodb)                                                                                                               
%#		colorbar                                                                                                                                   
%#		title('LPCogram for target');                                                                                                              
%#		pause                                                                                                                                      
%#	end                                                                                                                                         
%#end % smoothing case                                                                                                                         
%#                                                                                                                                             
%#nfaxsg=length(faxsg);                                                                                                                        
%#nfft=(nfaxsg-1)*2;                                                                                                                           
%#% The deemphasis function ... which will be linearly interpolated later                                                                      
%#demph=20*log10(abs(fft([1,-premph]',nfft)));                                                                                                 
%#demph=-demph(1:nfaxsg);                                                                                                                      
%#if watchlevel>3                                                                                                                              
%#	figure(37)                                                                                                                                  
%#	plot(faxsg,demph);                                                                                                                          
%#	grid on                                                                                                                                     
%#	title(' Deemphasis')                                                                                                                        
%#	pausemsg                                                                                                                                    
%#end                                                                                                                                          
%#                                                                                                                                             
%#FloTarg=0;                                                                                                                                   
%#lpcord=7; % try for 3 fmnts EXACTLY                                                                                                          
%#                                                                                                                                             
%#% Fuzzy trapezpoidal functions                                                                                                               
%#bwtrpx= [0 .5  1  2  3  5  10 20 5000]; % trapeziodal function x bandwidth (as ratio to expected bw)                                         
%#bwtrpy= [0 .25 1 .8 .5 .2 .1   0   0];                                                                                                       
%#                                                                                                                                             
%#contx=[0 100 200 300 400 5000];                                                                                                              
%#conty=[1  .5 .1   .05 0   0];                                                                                                                
%#                                                                                                                                             
%#fdistx=[0 100 300 500 1200 2000 4000 Fs];                                                                                                    
%#fdisty=[0 .1  .5   .9   1   .9  .5   0 ];                                                                                                    
%#                                                                                                                                             
%#% As fraction of expected range                                                                                                              
%#frngx=[-20000 -.2  -.05   0      1 1.05  1.2 10000];                                                                                         
%#frngy=[0        0     .5   1     1 .5      0    0 ];                                                                                         
%#                                                                                                                                             
%#amptrpx=[-1000 -50 -30 -20 -10 0]; % amp rel to max in db                                                                                    
%#amptrpy=[0      0  .3   .8 .9  1];                                                                                                           
%#                                                                                                                                             
%#                                                                                                                                             
%#% maybe this isn't right the pre-emphais should be undone                                                                                    
%#% before the check by resynth                                                                                                                
%#% add a deemph which is  -fft(1, -preemph)                                                                                                   
%#score=-inf; % bad  score;                                                                                                                    
%#scorecomps=zeros(ntry,9);                                                                                                                    
%#fest={};                                                                                                                                     
%#bwest={};                                                                                                                                    
%#itry=0;                                                                                                                                      
%#% We are doing only one preemphasis here                                                                                                     
%#                                                                                                                                             
%#dBPerOct=zeros(ntry,1); % preemphis required by anbysynchk3                                                                                  
%#for iFhiTarg=1:NHITARG                                                                                                                       
%#                                                                                                                                             
%#	itry=itry+1;                                                                                                                                
%#	Beq=125;                                                                                                                                    
%#	FhiTarg{itry}=hitargset(iFhiTarg);                                                                                                          
%#	% The high target is expected at (F3+F4)/2.. compare that to the 'base male' viz 3000                                                       
%#	estscale=FhiTarg{itry}/3000;                                                                                                                
%#	ftrngmin=Fmn*estscale;                                                                                                                      
%#	ftrngmax=Fmx*estscale;                                                                                                                      
%#                                                                                                                                             
%#	emph(itry)=premph; % for later reporting                                                                                                    
%#	% alpc needs to be a cell... varying sizes                                                                                                  
%#	% gainsq could be a 2d  array... but easier to handle as cell                                                                               
%#	% fhi is fine as a vector (one value for each try)                                                                                          
%#                                                                                                                                             
%#	% Alpc{itry,1} will be the 'opt fit (rignt number of coefs for the range'                                                                   
%#	% Alpc{itry,2) will be the 'extra formant one to check that we aren't including another formant                                             
%#	% 3 extra coefficients                                                                                                                      
%#	% The theory here is that a good cutoff won't change much if a few extra coefs are added                                                    
%#	% % One could be cleverer here with a strategic choice of an expected 3 ft                                                                  
%#	% % and an expected 4 ft range...with the 4 ft range of one hyp cutoff analysis                                                             
%#	% % serving as the 3 ft range of another higher cutoff.. but                                                                                
%#	% % But choice of grid points would be tricky to say the least.                                                                             
%#	% % This just posits one 'extra formant guard analysis' for each cutoff                                                                     
%#	% we have added lpc coefficients and scaled up the FhiTarg                                                                                  
%#	%	[alpc{itry,1},gainsq{itry,1},flo,fhi(itry)]=sgm2alpcsel(X2sg,Fs,FloTarg,FhiTarg{itry}*4/3,lpcord+2,Beq);                                  
%#	% try with only 1 extra                                                                                                                     
%#	%	[alpc{itry,2},gainsq{itry,2},flo,fhi(itry)]=sgm2alpcsel(X2sg,Fs,FloTarg,FhiTarg{itry}*4/3,lpcord+1,Beq);                                  
%#                                                                                                                                             
%#	% Version 4 This is done on smoothed spectrum instead... We have to trick sgm2alpcsel to think we have                                      
%#	% an fft spectrum (N/2+1);                                                                                                                  
%#	% If faxsmo is even length, we'll skip the last element                                                                                     
%#	if rem(length(faxsmo),2)==0 % even case.. shorten                                                                                           
%#		nuse=length(faxsmo)-1;                                                                                                                     
%#	else                                                                                                                                        
%#		nuse=length(faxsmo);                                                                                                                       
%#	end                                                                                                                                         
%#	FsSmo=faxsmo(nuse)*2;                                                                                                                       
%#	% we're actually trying 4 formants                                                                                                          
%#	SizX2smo=size(X2smo);                                                                                                                       
%#	nuse;FsSmo;FloTarg;FiTargT=FhiTarg{itry}*4/3;lpcord2=lpcord+2;Beq;                                                                          
%#                                                                                                                                             
%#	[alpc{itry,1},gainsq{itry,1},flo,fhi(itry)]=sgm2alpcsel(X2smo(1:nuse,:),FsSmo,FloTarg,FhiTarg{itry}*4/3,lpcord+2,Beq);                      
%#	% try with only 1 extra                                                                                                                     
%#	[alpc{itry,2},gainsq{itry,2},flo,fhi(itry)]=sgm2alpcsel(X2smo(1:nuse,:),FsSmo,FloTarg,FhiTarg{itry}*4/3,lpcord+3,Beq);                      
%#                                                                                                                                             
%#                                                                                                                                             
%#                                                                                                                                             
%#                                                                                                                                             
%#                                                                                                                                             
%#	for ixt=1:2                                                                                                                                 
%#		nt=size(alpc{itry,1},1);                                                                                                                   
%#		maxft=floor(lpcord/2)+1; % allow for 1 extra formant                                                                                       
%#		fc{itry,ixt}=repmat(NaN,nt,maxft);                                                                                                         
%#		bw{itry,ixt}=fc{itry,ixt};                                                                                                                 
%#		ampdb{itry,ixt}=fc{itry,ixt};                                                                                                              
%#                                                                                                                                             
%#		for it=1:size(alpc{itry},1);                                                                                                               
%#			[fct,bwt,ampt]=	fbaRoot(alpc{itry,ixt}(it,:),gainsq{itry,ixt}(it),2*fhi(itry));                                                           
%#			npk=length(fct);                                                                                                                          
%#			fc{itry,ixt}(it,1:npk)=fct;                                                                                                               
%#			bw{itry,ixt}(it,1:npk)=bwt;                                                                                                               
%#			ampdb{itry,ixt}(it,1:npk)=ampt;                                                                                                           
%#		end                                                                                                                                        
%#		fast=1; stype='DB';                                                                                                                        
%#		globDb=70; frameDb=70;                                                                                                                     
%#		fcutoff=fhi(itry)*3/4;  % scale down the frequency                                                                                         
%#		bwthresh=2000; % try anything                                                                                                              
%#                                                                                                                                             
%#		%	fest                                                                                                                                     
%#		% this version uses mgftrackmed                                                                                                            
%#		[fest{itry,ixt},bwest{itry,ixt},ampest{itry,ixt}]=mgftrackmed(3,fc{itry,ixt},bw{itry,ixt},ampdb{itry,ixt},fcutoff,bwthresh,globDb,frameDb);
%#		fest{itry,ixt}=medsmoterp(fest{itry,ixt},5);  %% extra med smoothing of frequencies                                                        
%#		%	fest                                                                                                                                     
%#		% See what the tracker is doing                                                                                                            
%#		if watchlevel>2                                                                                                                            
%#			figure(38+ixt)                                                                                                                            
%#			clf                                                                                                                                       
%#			nct=size(fest{itry,ixt},2);                                                                                                               
%#			fbaplot(taxsg,nct,fest{itry,ixt},bwest{itry,ixt},ampest{itry,ixt},fhi(itry),'tri')                                                        
%#			plot(taxsg,fc{itry,ixt},'*')                                                                                                              
%#			title(['Analysis ', num2str(ixt)]);                                                                                                       
%#			pausemsg                                                                                                                                  
%#		end % if watch                                                                                                                             
%#	end % for ixt                                                                                                                               
%#                                                                                                                                             
%#	%                                                                                                                                           
%#	% A pseudo correlation figure of merit for the concordance of the two coefficeint density tracs                                             
%#	ff1=fest{itry,1};                                                                                                                           
%#	ff2=fest{itry,2};                                                                                                                           
%#	rfstable=1-sqrt(mean((ff1(:)-ff2(:)).^2))./std(ff1(:));                                                                                     
%#                                                                                                                                             
%#                                                                                                                                             
%#                                                                                                                                             
%#                                                                                                                                             
%#	% Fuzzy figure of merit... as                                                                                                               
%#	% As missing is low (presence is high)                                                                                                      
%#	% As continuity is high, as bw is reasonable , as amplitude it reasonable                                                                   
%#	presence=1;                                                                                                                                 
%#	bwreason=1;                                                                                                                                 
%#	ampreason=1;                                                                                                                                
%#	contreason=1;                                                                                                                               
%#	distreason=1;                                                                                                                               
%#	rangereason=1;                                                                                                                              
%#                                                                                                                                             
%#	for ift=1:3                                                                                                                                 
%#		there=find(bwest{itry,1}(:,ift)>0);                                                                                                        
%#		if length(there)==0,                                                                                                                       
%#			presence=0;                                                                                                                               
%#		else                                                                                                                                       
%#			presence=presence* length(there)/nt;                                                                                                      
%#		end                                                                                                                                        
%#		if isnan(presence)                                                                                                                         
%#			disp NANPRESENCE                                                                                                                          
%#			% pausemsg                                                                                                                                
%#		end                                                                                                                                        
%#		maxamp=max(ampest{itry,1}(there,ift));                                                                                                     
%#		if presence==0                                                                                                                             
%#			ampreason=0; bwreason=0; contreason=0;                                                                                                    
%#			score(itry)=0;                                                                                                                            
%#			break                                                                                                                                     
%#		end                                                                                                                                        
%#		if ift>1 & calcdist                                                                                                                        
%#			tthere=find(bwest{itry,1}(:,ift)>0 & bwest{itry,1}(:,ift-1)>0);                                                                           
%#			fdist=abs(fest{itry,1}(tthere,ift)-fest{itry,1}(tthere,ift-1));                                                                           
%#			distreason=mean(interp1(fdistx,fdisty,fdist));                                                                                            
%#		end                                                                                                                                        
%#		%Current formants position within expected range                                                                                           
%#		festreltorange=(fest{itry,1}(there,ift)-ftrngmin(ift) )./(ftrngmax(ift)-ftrngmin(ift));                                                    
%#		rangereason=rangereason*mean(interp1(frngx,frngy,festreltorange));                                                                         
%#		% amp reason.. average peak amp should't be too far below the peak amplitude                                                               
%#		ampreason=ampreason*mean(interp1(amptrpx,amptrpy,ampest{itry,1}(there,ift)-maxamp));                                                       
%#		% reasonable badwidths  % CODE CORRECTED 60 hz or 6 percent of the frequency                                                               
%#		bwt=bwest{itry,1}(there,ift);                                                                                                              
%#		bwexp=(bwt./max(60,0.06*fest{itry,1}(there,ift))); % expected bandwidths                                                                   
%#		bwreason=bwreason*mean(interp1(bwtrpx,bwtrpy,bwexp));                                                                                      
%#		%                                                                                                                                          
%#		ft=fest{itry,1}(there,ift);                                                                                                                
%#		cont=abs(diff(ft));                                                                                                                        
%#		contreason=contreason*mean(interp1(contx,conty,cont));                                                                                     
%#	end % for ift                                                                                                                               
%#                                                                                                                                             
%#	%[Xlpc,faxlpc]=alpc2sgm(alpc{itry},gainsq{itry},fhi(itry)*2,df,fast,stype);                                                                 
%#	% Target spectrum X                                                                                                                         
%#	%Xlpc+repmat(interp1(faxsg,demph,faxlpc),1,size(Xlpc,2)); %                                                                                 
%#                                                                                                                                             
%#                                                                                                                                             
%#	% The target spectrum at this curoff frequency to match.....(dont match above fcutoff);                                                     
%#	% Interpolate the emphasis function in the frequency range of range of Xtarg                                                                
%#	% The axis choice must be a subset of the smoothed axis, in case it is different                                                            
%#	% from the original spectrogram (sg) axis                                                                                                   
%#	% note that fcutoff is lower 3/4 than fhi(itry)                                                                                             
%#                                                                                                                                             
%#	imaxtarg=max(find(faxsmo<=fcutoff));                                                                                                        
%#	faxtarg=faxsmo(1:imaxtarg);                                                                                                                 
%#	Xtarg=Xsmodb(1:imaxtarg,:);                                                                                                                 
%#	Xdemph=repmat(interp1(faxsg,demph,faxtarg),1,size(Xtarg,2));                                                                                
%#	EMPHCORRECT=0;                                                                                                                              
%#	if EMPHCORRECT                                                                                                                              
%#		Xtarg=Xtarg+Xdemph; % Re-define the target                                                                                                 
%#		igr=1;                                                                                                                                     
%#	else                                                                                                                                        
%#		igr=0;                                                                                                                                     
%#	end                                                                                                                                         
%#	% suppose we                                                                                                                                
%#	[rabs,dbPred,dbRes,dBPerOct(itry)]=anbysynchk3(faxtarg,Xtarg,fest{itry,1},bwwin, igr);                                                      
%#	%	xFuzzyMGtrackPt2                                                                                                                          
%#	%%%%% SHOULD FILTER OUT NANs in scores....                                                                                                  
%#	%% And should limit ranges to zeros                                                                                                         
%#                                                                                                                                             
%#	score(itry)=rabs*presence*bwreason*ampreason*contreason*distreason*rangereason*rfstable;                                                    
%#                                                                                                                                             
%#                                                                                                                                             
%#                                                                                                                                             
%#	[maxscore,ibest]=max(score(1:itry));                                                                                                        
%#	if ibest==itry                                                                                                                              
%#		dbPredSave=dbPred;                                                                                                                         
%#		XtargSave=Xtarg;                                                                                                                           
%#		faxtargSave=faxtarg;                                                                                                                       
%#	end                                                                                                                                         
%#	scorecomps(itry,:)=[ score(itry), presence,bwreason,ampreason,contreason,distreason,rabs,rangereason,rfstable];                             
%#                                                                                                                                             
%#	%showbsettracks                                                                                                                             
%#	if watchlevel>=1                                                                                                                            
%#		dbgtracker4xshowtracks % invoke script                                                                                                     
%#		pausemsg                                                                                                                                   
%#		iFhiTarg                                                                                                                                   
%#	end                                                                                                                                         
%#                                                                                                                                             
%#end % for iFhiTarg hicutoff                                                                                                                  
%#allTrialsRec.taxsg =taxsg;                                                                                                                   
%#allTrialsRec.fest =fest;                                                                                                                     
%#allTrialsRec.scorecomps =scorecomps;                                                                                                         
%#allTrialsRec.f34cutoffs =f34cutoffs;                                                                                                         
%#allTrialsRec.fname =fname;                                                                                                                   
%#allTrialsRec.dBPerOct =dBPerOct;                                                                                                             
%#% if savealltrials                                                                                                                           
%#% 	save(fsaveTrialsName,'taxsg','fest','scorecomps', 'f34cutoffs','fname', 'dBPerOct');                                                      
%#% end                                                                                                                                        
%#savefest=fest{ibest,1};                                                                                                                      
%#scorecompsbest=scorecomps(ibest,:);                                                                                                          
%#f34cutoffbest=f34cutoffs(ibest);                                                                                                             
%#bestRec.taxsg =taxsg;                                                                                                                        
%#bestRec.savefest =savefest;                                                                                                                  
%#bestRec.scorecompsbest =scorecompsbest;                                                                                                      
%#bestRec.f34cutoffbest =f34cutoffbest;                                                                                                        
%#bestRec.fname =fname;                                                                                                                        
%#                                                                                                                                             
%#                                                                                                                                             
%#%save(fsaveName,'taxsg','savefest','scorecompsbest', 'f34cutoffbest','fname');                                                               
%#                                                                                                                                             
%#return                                                                                                                                       
%#                                                                                                                                             
%#                                                                                                                                             
%#                                                                                                                                             
%#                                                                                                                                             
%#                                                                                                                                             
%#                                                                                                                                             
%#                                                                                                                                             
%#-h- tsfftsgm.m                                                                                           
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/tsfftsgm.m 2004/6/2 14:20
         
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:Sigantools:tsfftsgm.m 2002/11/6 19:5
%#                                                                                                         
%#function [X2,tax,fax,nfft]=tsfftsgm(t1,t2,x,Fs,win,dt,df,premph,fast,rowistime,wantcomplex);             
%#%function [X2,tax,fax,nfft]=tsfftsgm(t1,t2,x,Fs,win,dt,df,premph,fast,rowistime,wantcomplex);            
%#%                                     1  2 3  4  5   6  7   8     9     10        11                     
%#% 30 Dec 1998 Copyright T. Nearey.                                                                       
%#% T)ime S)election FFT (all times in ms)                                                                 
%#% Returns magsq (power) spectrum (by default)                                                            
%#% t1,t2 first and last times see below                                                                   
%#% x- signal vector                                                                                       
%#% Fs- sample rate, Hz                                                                                    
%#% win-window vector                                                                                      
%#% dt - hop duration                                                                                      
%#% df - frequency resolution (desired spacing of FFT bins);                                               
%#% if empty or 0,then set on basis of window length (nextpower of two)                                    
%#% premph filter by 1+premph*z^-1; default 0                                                              
%#% fast Use toolbox FFT spectrogram default =1 (this argument is now ignored.. try/catch used instead     
%#% rowistime (see below)                                                                                  
%#% wantcomplex - default 0, if 1 X2 is complex (unfolded spectrum)                                        
%#% Centers first window on t1 (pads left with zero if necessary)                                          
%#% Centers last window on earliest hop >=t2 (pads right if necessary)                                     
%#% Set t1, t2 to 0 Inf or [], [], for whole signal.                                                       
%#% By default returns FREQ as the rows and TIME as cols to be consistent with specgram                    
%#% and Slaney aud toolbox                                                                                 
%#% Rowistime tilts this                                                                                   
%#nx=length(x);                                                                                            
%#if ischar(win),error('win must be a numeric vector'); end                                                
%#if isempty(t1), t1=0; t1=0;end                                                                           
%#if isempty(df)|df==0, dfgiven=0; else dfgiven=1; end                                                     
%#if isempty(t2)|t2<=0|t2==inf, t2=ceil(nx/Fs*1000); end                                                   
%#if nargin<11, wantcomplex=0; end                                                                         
%#if nargin<9|isempty(fast) fast=1; end                                                                    
%#if exist('specgram')==0, fast=0; end % see if toolbox is avaialble                                       
%#if nargin<10|isempty(rowistime);                                                                         
%#	rowistime=0;                                                                                            
%#end                                                                                                      
%#	hopms=dt;                                                                                               
%#	nhop=round(Fs*hopms/1000);                                                                              
%#	nwin=length(win);                                                                                       
%#	nfftwin=2^ceil(log(nwin)/log(2));                                                                       
%#	if dfgiven                                                                                              
%#		nfft=2^ceil(log(Fs/df)/log(2));                                                                        
%#		if nfftwin>nfft, nfft=nfftwin; end;                                                                    
%#	else                                                                                                    
%#		nfft=nfftwin;                                                                                          
%#		df=Fs/nfft;                                                                                            
%#	end                                                                                                     
%#                                                                                                         
%#                                                                                                         
%#                                                                                                         
%#	if nwin<nfft                                                                                            
%#			 npad=nfft-nwin;                                                                                      
%#			 padzer=zeros(npad,1);                                                                                
%#	else                                                                                                    
%#			padzer=[];                                                                                            
%#	end                                                                                                     
%#                                                                                                         
%#	novlp=nwin-nhop;                                                                                        
%#%nwin,nhop,novlp                                                                                         
%#	if novlp<0, fast=0; end % specgram won't take neg overlaps                                              
%#% 	pause                                                                                                 
%#% Use same strategy as specgram for number of time slices, but first pad with a half window of           
%#% zeros so leftmost frame is centered on both sides of signal                                            
%#if size(x,2)~=1;x=x(:);end                                                                               
%#first=round(t1/1000*Fs)+1 - ceil(nwin/2);                                                                
%#% the last time must be at or after time requested                                                       
%#%                                                                                                        
%#last=round(t2/1000*Fs)+1 + ceil(nwin/2); % +nhop-1; don't stretch                                        
%#%first, last                                                                                             
%#padleft=[];                                                                                              
%#if first<1, padleft=zeros(-first+1,1); first=1; end                                                      
%#padright=[];                                                                                             
%#if last>nx, padright=zeros(last-nx,1); last=nx; end                                                      
%#                                                                                                         
%#                                                                                                         
%#x=[padleft;x(first:last);padright];                                                                      
%#	if premph>0                                                                                             
%#		x=filter([1,-premph],1,x); %preemphasize the whole buffer                                              
%#	end                                                                                                     
%#nx=length(x);                                                                                            
%#ncol = fix((nx-novlp)/(nwin-novlp));                                                                     
%#% ncol                                                                                                   
%#% pause                                                                                                  
%#colindex = 1 + (0:(ncol-1))*(nwin-novlp);                                                                
%#tax=(colindex-1)'/Fs *1000+t1;                                                                           
%#nfold=nfft/2+1;                                                                                          
%#fax = ((1:nfold)'-1)*Fs/nfft; % frequency axis for whole range                                           
%#try                                                                                                      
%#	%B = SPECGRAM(A,NFFT,Fs,WINDOW,NOVERLAP)                                                                
%#	X2 = specgram(x,nfft,Fs,win,novlp);                                                                     
%#	if ~wantcomplex                                                                                         
%#		X2=abs(X2(1:nfold,1:length(tax))).^2;                                                                  
%#	end                                                                                                     
%#catch% the slow, mem conserving way                                                                      
%#	if length(x)<(nwin+colindex(ncol)-1)                                                                    
%# 	   x(nwin+colindex(ncol)-1) = 0;   % zero-pad x                                                        
%#   end                                                                                                   
%#   %sizex=size(x)                                                                                        
%#   if wantcomplex                                                                                        
%#	   X2=zeros(nfft,ncol);                                                                                 
%# 	else                                                                                                   
%#		X2=zeros(nfold,ncol);                                                                                  
%#	end                                                                                                     
%#	for icol=1:ncol                                                                                         
%#		ci=colindex(icol);                                                                                     
%#		ce=ci+nwin-1;                                                                                          
%#		%sizewin=size(win)                                                                                     
%#		%xsecsize=size(x(ci:ce))                                                                               
%#		xp=[win.*x(ci:ce);padzer];                                                                             
%#		if ~wantcomplex                                                                                        
%#			R=abs(fft(xp)).^2; % here's your POWER                                                                
%#	% 	size(R(1:nfold))                                                                                     
%#	% 	size(X(icol,:))                                                                                      
%#			X2(:,icol)=R(1:nfold);                                                                                
%#		else                                                                                                   
%#			X2(:,icol)=fft(xp);                                                                                   
%#		end                                                                                                    
%#                                                                                                         
%#	end % for icol                                                                                          
%#end                                                                                                      
%#if rowistime, X2=X2';end                                                                                 
%#                                                                                                         
%#                                                                                                         
%#-h- uigetpath.m                                                                                          
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/uigetpath.m 2004/6/2 14:20
        
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:filetools:uigetpath.m 2002/11/6 19:5
%#                                                                                                         
%#function wholepathname=uigetpath(filterspec, dialogTitle, x,y);                                          
%#%function wholepathname=uigetpath(filterspec, dialogTitle, x,y);                                         
%#%  [FILENAME, PATHNAME] = UIGETFILE('filterSpec', 'dialogTitle', X, Y)                                   
%#tnargin=nargin;                                                                                          
%#switch tnargin                                                                                           
%#case 0, [f,p]=uigetfile('*.*');                                                                          
%#case 1, [f,p]=uigetfile(filterspec);                                                                     
%#case 2, [f,p]=uigetfile(filterspec,dialogTitle);                                                         
%#case 3, [f,p]=uigetfile(filterspec,dialogTitle,x);                                                       
%#otherwise, [f,p]=uigetfile(filterspec,dialogTitle,x,y);                                                  
%#end                                                                                                      
%#if ~isstr(f),                                                                                            
%#	wholepathname=0;                                                                                        
%#else                                                                                                     
%#	wholepathname=[p,f];                                                                                    
%#end                                                                                                      
%#-h- vec.m                                                                                         
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/vec.m 2004/6/2 14:20
       
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:tmnstats:vec.m 2002/11/6 19:5
%#                                                                                                  
%#function x=vec(y)                                                                                 
%#% the vec operator accessable as a function                                                       
%#	x=y(:);                                                                                          
%#return                                                                                            
%#-h- wavread.m                                                                                  
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/wavread.m 2004/6/2 14:20

%#%  Saved from Eps1:Desktop Folder:WorkingFall2k1:NeareyTracker4xApr2k1:wavread.m 2002/11/6 19:5
%#                                                                                               
%#function [y,Fs,bits]=wavread(file,ext)                                                         
%#%WAVREAD Read Microsoft WAVE (".wav") sound file.                                              
%#%   Y=WAVREAD(FILE) reads a WAVE file specified by the string FILE,                            
%#%   returning the sampled data in Y. The ".wav" extension is appended                          
%#%   if no extension is given.  Amplitude values are in the range [-1,+1].                      
%#%                                                                                              
%#%   [Y,FS,BITS]=WAVREAD(FILE) returns the sample rate (FS) in Hertz                            
%#%   and the number of bits per sample (BITS) used to encode the                                
%#%   data in the file.                                                                          
%#%                                                                                              
%#%   [...]=WAVREAD(FILE,N) returns only the first N samples from each                           
%#%       channel in the file.                                                                   
%#%   [...]=WAVREAD(FILE,[N1 N2]) returns only samples N1 through N2 from                        
%#%       each channel in the file.                                                              
%#%   SIZ=WAVREAD(FILE,'size') returns the size of the audio data contained                      
%#%       in the file in place of the actual audio data, returning the                           
%#%       vector SIZ=[samples channels].                                                         
%#%                                                                                              
%#%   Supports multi-channel data, with up to 16 bits per sample.                                
%#%                                                                                              
%#%   See also WAVWRITE, AUREAD.                                                                 
%#                                                                                               
%#% NOTE: This file reader only supports Microsoft PCM data format.                              
%#%       It also does not support wave-list data.                                               
%#                                                                                               
%#%   Copyright (c) 1984-98 by The MathWorks, Inc.                                               
%#%   $Revision: 5.9 $  $Date: 1997/11/21 23:24:12 $                                             
%#                                                                                               
%#%   D. Orofino, 11/95                                                                          
%#                                                                                               
%#% Parse input arguments:                                                                       
%#nargchk(1,2,nargin);                                                                           
%#if nargin<2, ext=[]; end    % Default - read all samples                                       
%#exts = prod(size(ext));     % length of extent info                                            
%#if ~strncmp(lower(ext),'size',exts) & (exts > 2),                                              
%#   error('Index range must be specified as a scalar or 2-element vector.');                    
%#end                                                                                            
%#if ~ischar(ext) & exts==1,                                                                     
%#   if ext==0,                                                                                  
%#      ext='size';           % synonym for size                                                 
%#   else                                                                                        
%#      ext=[1 ext];          % Prepend start sample index                                       
%#   end                                                                                         
%#end                                                                                            
%#                                                                                               
%#% Open WAV file:                                                                               
%#try                                                                                            
%#[fid,msg] = open_wav(file);                                                                    
%#catch                                                                                          
%#	lasterr                                                                                       
%#	error('halt')                                                                                 
%#end                                                                                            
%#                                                                                               
%#error(msg);                                                                                    
%#                                                                                               
%#% Find the first RIFF chunk:                                                                   
%#[riffck,msg] = find_cktype(fid,'RIFF');                                                        
%#error(msg);                                                                                    
%#                                                                                               
%#% Verify that RIFF file is WAVE data type:                                                     
%#[rifftype,msg] = find_rifftype(fid,'WAVE');                                                    
%#error(msg);                                                                                    
%#                                                                                               
%#% Find optional chunks, and don't stop till <data-ck> found:                                   
%#found_fmt  = 0;                                                                                
%#found_data = 0;                                                                                
%#                                                                                               
%#while(~found_data),                                                                            
%#   [ck,msg] = find_cktype(fid);                                                                
%#   error(msg);                                                                                 
%#                                                                                               
%#   switch ck.ID                                                                                
%#   case 'fact'                                                                                 
%#      % Optional <fact-ck> found:                                                              
%#      [factdata,msg] = read_factck(fid, ck);                                                   
%#      error(msg);                                                                              
%#                                                                                               
%#   case 'fmt'                                                                                  
%#      % <fmt-ck> found                                                                         
%#      found_fmt = 1;                                                                           
%#      fmtck = ck;                                                                              
%#      [wavefmt,msg] = read_wavefmt(fid,fmtck);                                                 
%#      error(msg);                                                                              
%#                                                                                               
%#   case 'data'                                                                                 
%#      % <data-ck> found:                                                                       
%#      datack = ck;                                                                             
%#      found_data = 1;                                                                          
%#      if ~found_fmt,                                                                           
%#         error('Corrupt WAV file: found data before format information.');                     
%#      end                                                                                      
%#                                                                                               
%#      if strncmp(lower(ext),'size',exts) | ...                                                 
%#            (~isempty(ext) & all(ext==0)),                                                     
%#         % Caller doesn't want data - just data size:                                          
%#         [samples,msg] = read_wavedat(datack,wavefmt,-1);                                      
%#         fclose(fid);                                                                          
%#         error(msg);                                                                           
%#         y = [samples wavefmt.nChannels];                                                      
%#                                                                                               
%#      else                                                                                     
%#         % Read <wave-data>:                                                                   
%#         [datack,msg] = read_wavedat(datack,wavefmt,ext);                                      
%#         fclose(fid);                                                                          
%#         error(msg);                                                                           
%#         y = datack.Data;                                                                      
%#                                                                                               
%#      end                                                                                      
%#                                                                                               
%#   otherwise                                                                                   
%#      % Skip over data in unprocessed chunks:                                                  
%#      if(fseek(fid,ck.Size,0)==-1),                                                            
%#         error('Incorrect chunk size information in RIFF file.');                              
%#      end                                                                                      
%#   end                                                                                         
%#end                                                                                            
%#                                                                                               
%#% Parse structure info for return to user:                                                     
%#Fs = wavefmt.nSamplesPerSec;                                                                   
%#if wavefmt.wFormatTag == 1,                                                                    
%#   bits = wavefmt.nBitsPerSample;                                                              
%#else                                                                                           
%#   bits = [];  % Unknown                                                                       
%#end                                                                                            
%#                                                                                               
%#% end of wavread()                                                                             
%#                                                                                               
%#                                                                                               
%#% ------------------------------------------------------------------------                     
%#% Private functions:                                                                           
%#% ------------------------------------------------------------------------                     
%#                                                                                               
%#% ---------------------------------------------                                                
%#% OPEN_WAV: Open a WAV file for reading                                                        
%#% ---------------------------------------------                                                
%#function [fid,msg] = open_wav(file)                                                            
%#% Append .wav extension if it's missing:                                                       
%#if isempty(findstr(file,'.')),                                                                 
%#  file=[file '.wav'];                                                                          
%#end                                                                                            
%#                                                                                               
%#[fid,msg] = fopen(file,'rb','l');   % Little-endian                                            
%#                                                                                               
%#if fid == -1,                                                                                  
%#   if isempty(msg),                                                                            
%#      msg = 'Cannot open specified WAV file for input.';                                       
%#   end                                                                                         
%#   error([msg,' [',file,']']) % tmn mod for more info;                                         
%#end                                                                                            
%#                                                                                               
%#return                                                                                         
%#                                                                                               
%#% ---------------------------------------------                                                
%#% READ_CKINFO: Reads next RIFF chunk, but not the chunk data.                                  
%#%   If optional sflg is set to nonzero, reads SUBchunk info instead.                           
%#%   Expects an open FID pointing to first byte of chunk header.                                
%#%   Returns a new chunk structure.                                                             
%#% ---------------------------------------------                                                
%#function [ck,msg] = read_ckinfo(fid)                                                           
%#                                                                                               
%#msg     = '';                                                                                  
%#ck.fid  = fid;                                                                                 
%#ck.Data = [];                                                                                  
%#                                                                                               
%#[s,cnt] = fread(fid,4,'char');                                                                 
%#if cnt~=4,                                                                                     
%#   msg = 'Truncated chunk header found - possibly not a WAV file.';                            
%#   return;                                                                                     
%#end                                                                                            
%#                                                                                               
%#ck.ID = deblank(setstr(s'));                                                                   
%#% Read chunk size (skip if subchunk):                                                          
%#[sz,cnt] = fread(fid,1,'ulong');                                                               
%#if cnt~=1,                                                                                     
%#   msg = 'Truncated chunk data found - possibly not a WAV file.';                              
%#   return                                                                                      
%#end                                                                                            
%#ck.Size = sz;                                                                                  
%#return                                                                                         
%#                                                                                               
%#% ---------------------------------------------                                                
%#% FIND_CKTYPE: Finds a chunk with appropriate type.                                            
%#%   Searches from current file position specified by fid.                                      
%#%   Leaves file positions to data of desired chunk.                                            
%#%   If optional sflg is set to nonzero, finds a SUBchunk instead.                              
%#% ---------------------------------------------                                                
%#function [ck,msg] = find_cktype(fid,type)                                                      
%#                                                                                               
%#msg = '';                                                                                      
%#if nargin<2, type = ''; end                                                                    
%#                                                                                               
%#[ck,msg] = read_ckinfo(fid);                                                                   
%#if ~isempty(msg), return; end                                                                  
%#                                                                                               
%#% Was a required chunk type specified?                                                         
%#if ~isempty(type) & ~strcmp(lower(ck.ID),lower(type)),                                         
%#   msg = ['<' ftype '-ck> did not appear as expected'];                                        
%#end                                                                                            
%#return                                                                                         
%#                                                                                               
%#                                                                                               
%#% ---------------------------------------------                                                
%#% FIND_RIFFTYPE: Finds the RIFF data type.                                                     
%#%   Searches from current file position specified by fid.                                      
%#%   Leaves file positions to data of desired chunk.                                            
%#% ---------------------------------------------                                                
%#function [rifftype,msg] = find_rifftype(fid,type)                                              
%#msg = '';                                                                                      
%#[rifftype,cnt] = fread(fid,4,'char');                                                          
%#dtype = lower(setstr(rifftype)');                                                              
%#                                                                                               
%#if cnt~=4,                                                                                     
%#   msg = 'Truncated RIFF data type - possibly not a WAV file.';                                
%#elseif ~strcmp(dtype,lower(type)),                                                             
%#   msg = 'Not a WAV file.';                                                                    
%#end                                                                                            
%#                                                                                               
%#return                                                                                         
%#                                                                                               
%#                                                                                               
%#% ---------------------------------------------                                                
%#% READ_FACTCK: Read the FACT chunk:                                                            
%#% ---------------------------------------------                                                
%#function [factdata,msg] = read_factck(fid,ck)                                                  
%#                                                                                               
%#orig_pos    = ftell(fid);                                                                      
%#total_bytes = ck.Size; % # bytes in subchunk                                                   
%#nbytes      = 4;       % # of required bytes in <fact-ck> header                               
%#msg = '';                                                                                      
%#                                                                                               
%#if total_bytes < nbytes,                                                                       
%#   msg = 'Error reading <fact-ck> chunk.';                                                     
%#   return                                                                                      
%#end                                                                                            
%#                                                                                               
%#% Read standard <fact-ck> data:                                                                
%#factdata.dwFileSize  = fread(fid,1,'ulong');  % Samples per second                             
%#                                                                                               
%#% Skip over any unprocessed data:                                                              
%#rbytes = total_bytes - (ftell(fid) - orig_pos);                                                
%#if rbytes,                                                                                     
%#   if(fseek(fid,rbytes,'cof')==-1),                                                            
%#      msg = 'Error reading <fact-ck> chunk.';                                                  
%#   end                                                                                         
%#end                                                                                            
%#return                                                                                         
%#                                                                                               
%#                                                                                               
%#% ---------------------------------------------                                                
%#% READ_WAVEFMT: Read WAVE format chunk.                                                        
%#%   Assumes fid points to the <wave-fmt> subchunk.                                             
%#%   Requires chunk structure to be passed, indicating                                          
%#%   the length of the chunk in case we don't recognize                                         
%#%   the format tag.                                                                            
%#% ---------------------------------------------                                                
%#function [fmt,msg] = read_wavefmt(fid,ck)                                                      
%#                                                                                               
%#orig_pos    = ftell(fid);                                                                      
%#total_bytes = ck.Size; % # bytes in subchunk                                                   
%#nbytes      = 14;  % # of required bytes in <wave-format> header                               
%#msg = '';                                                                                      
%#                                                                                               
%#if total_bytes < nbytes,                                                                       
%#   msg = 'Error reading <wave-fmt> chunk.';                                                    
%#   return                                                                                      
%#end                                                                                            
%#                                                                                               
%#% Read standard <wave-format> data:                                                            
%#fmt.wFormatTag      = fread(fid,1,'ushort'); % Data encoding format                            
%#fmt.nChannels       = fread(fid,1,'ushort'); % Number of channels                              
%#fmt.nSamplesPerSec  = fread(fid,1,'ulong');  % Samples per second                              
%#fmt.nAvgBytesPerSec = fread(fid,1,'ulong');  % Avg transfer rate                               
%#fmt.nBlockAlign     = fread(fid,1,'ushort'); % Block alignment                                 
%#                                                                                               
%#% Read format-specific info:                                                                   
%#switch fmt.wFormatTag                                                                          
%#case 1                                                                                         
%#   % PCM Format:                                                                               
%#   [fmt, msg] = read_fmt_pcm(fid, ck, fmt);                                                    
%#end                                                                                            
%#                                                                                               
%#% Skip over any unprocessed fmt-specific data:                                                 
%#rbytes = total_bytes - (ftell(fid) - orig_pos);                                                
%#if rbytes,                                                                                     
%#   if(fseek(fid,rbytes,'cof')==-1),                                                            
%#      msg = 'Error reading <wave-fmt> chunk.';                                                 
%#   end                                                                                         
%#end                                                                                            
%#                                                                                               
%#return                                                                                         
%#                                                                                               
%#                                                                                               
%#% ---------------------------------------------                                                
%#% READ_FMT_PCM: Read <PCM-format-specific> info                                                
%#% ---------------------------------------------                                                
%#function [fmt,msg] = read_fmt_pcm(fid, ck, fmt)                                                
%#                                                                                               
%#% There had better be a bits/sample field:                                                     
%#total_bytes = ck.Size; % # bytes in subchunk                                                   
%#nbytes      = 14;  % # of bytes already read in <wave-format> header                           
%#msg = '';                                                                                      
%#                                                                                               
%#if (total_bytes < nbytes+2),                                                                   
%#   msg = 'Error reading <wave-fmt> chunk.';                                                    
%#   return                                                                                      
%#end                                                                                            
%#[bits,cnt] = fread(fid,1,'ushort');                                                            
%#nbytes=nbytes+2;                                                                               
%#if (cnt~=1),                                                                                   
%#   msg = 'Error reading PCM <wave-fmt> chunk.';                                                
%#   return                                                                                      
%#end                                                                                            
%#fmt.nBitsPerSample=bits;                                                                       
%#                                                                                               
%#% Are there any additional fields present?                                                     
%#if (total_bytes > nbytes),                                                                     
%#   % See if the "cbSize" field is present.  If so, grab the data:                              
%#   if (total_bytes >= nbytes+2),                                                               
%#      % we have the cbSize ushort in the file:                                                 
%#      [cbSize,cnt]=fread(fid,1,'ushort');                                                      
%#      nbytes=nbytes+2;                                                                         
%#      if (cnt~=1),                                                                             
%#         msg = 'Error reading PCM <wave-fmt> chunk.';                                          
%#         return                                                                                
%#      end                                                                                      
%#      fmt.cbSize = cbSize;                                                                     
%#   end                                                                                         
%#                                                                                               
%#   % Check for anything else:                                                                  
%#   if (total_bytes > nbytes),                                                                  
%#      % Simply skip remaining stuff - we don't know what it is:                                
%#      if (fseek(fid,total_bytes-nbytes,0) == -1);                                              
%#         msg = 'Error reading PCM <wave-fmt> chunk.';                                          
%#         return                                                                                
%#      end                                                                                      
%#   end                                                                                         
%#end                                                                                            
%#return                                                                                         
%#                                                                                               
%#                                                                                               
%#% ---------------------------------------------                                                
%#% READ_WAVEDAT: Read WAVE data chunk                                                           
%#%   Assumes fid points to the wave-data chunk                                                  
%#%   Requires <data-ck> and <wave-format> structures to be passed.                              
%#%   Requires extraction range to be specified.                                                 
%#%   Setting ext=[] forces ALL samples to be read.  Otherwise,                                  
%#%       ext should be a 2-element vector specifying the first                                  
%#%       and last samples (per channel) to be extracted.                                        
%#%   Setting ext=-1 returns the number of samples per channel,                                  
%#%       skipping over the sample data.                                                         
%#% ---------------------------------------------                                                
%#function [dat,msg] = read_wavedat(datack,wavefmt,ext)                                          
%#                                                                                               
%#% In case of unsupported data compression format:                                              
%#dat     = [];                                                                                  
%#fmt_msg = '';                                                                                  
%#                                                                                               
%#switch wavefmt.wFormatTag                                                                      
%#case 1                                                                                         
%#   % PCM Format:                                                                               
%#   [dat,msg] = read_dat_pcm(datack,wavefmt,ext);                                               
%#case 2                                                                                         
%#   fmt_msg = 'Microsoft ADPCM';                                                                
%#case 6                                                                                         
%#   fmt_msg = 'CCITT a-law';                                                                    
%#case 7                                                                                         
%#   fmt_msg = 'CCITT mu-law';                                                                   
%#case 17                                                                                        
%#   fmt_msg = 'IMA ADPCM';                                                                      
%#case 34                                                                                        
%#   fmt_msg = 'DSP Group TrueSpeech TM';                                                        
%#case 49                                                                                        
%#   fmt_msg = 'GSM 6.10';                                                                       
%#case 50                                                                                        
%#   fmt_msg = 'MSN Audio';                                                                      
%#case 257                                                                                       
%#   fmt_msg = 'IBM Mu-law';                                                                     
%#case 258                                                                                       
%#   fmt_msg = 'IBM A-law';                                                                      
%#case 259                                                                                       
%#   fmt_msg = 'IBM AVC Adaptive Differential';                                                  
%#otherwise                                                                                      
%#   fmt_msg = ['Format #' num2str(wavefmt.wFormatTag)];                                         
%#end                                                                                            
%#if ~isempty(fmt_msg),                                                                          
%#   msg = ['Data compression format (' fmt_msg ') is not supported.'];                          
%#end                                                                                            
%#return                                                                                         
%#                                                                                               
%#                                                                                               
%#% ---------------------------------------------                                                
%#% READ_DAT_PCM: Read PCM format data from <wave-data> chunk.                                   
%#%   Assumes fid points to the wave-data chunk                                                  
%#%   Requires <data-ck> and <wave-format> structures to be passed.                              
%#%   Requires extraction range to be specified.                                                 
%#%   Setting ext=[] forces ALL samples to be read.  Otherwise,                                  
%#%       ext should be a 2-element vector specifying the first                                  
%#%       and last samples (per channel) to be extracted.                                        
%#%   Setting ext=-1 returns the number of samples per channel,                                  
%#%       skipping over the sample data.                                                         
%#% ---------------------------------------------                                                
%#function [dat,msg] = read_dat_pcm(datack,wavefmt,ext)                                          
%#                                                                                               
%#dat = [];                                                                                      
%#msg = '';                                                                                      
%#                                                                                               
%#% Determine # bytes/sample - format requires rounding                                          
%#%  to next integer number of bytes:                                                            
%#BytesPerSample = ceil(wavefmt.nBitsPerSample/8);                                               
%#if (BytesPerSample == 1),                                                                      
%#   dtype='uchar'; % unsigned 8-bit                                                             
%#elseif (BytesPerSample == 2),                                                                  
%#   dtype='short'; % signed 16-bit                                                              
%#else                                                                                           
%#   msg = 'Cannot read PCM file formats with more than 16 bits per sample.';                    
%#   return                                                                                      
%#end                                                                                            
%#                                                                                               
%#total_bytes       = datack.Size; % # bytes in this chunk                                       
%#total_samples     = total_bytes / BytesPerSample;                                              
%#SamplesPerChannel = total_samples / wavefmt.nChannels;                                         
%#if ~isempty(ext) & ext==-1,                                                                    
%#   % Just return the samples per channel, and fseek past data:                                 
%#   dat = SamplesPerChannel;                                                                    
%#   if(fseek(datack.fid,total_bytes,'cof')==-1),                                                
%#	   msg = 'Error reading PCM file format.';                                                    
%#   end                                                                                         
%#   return                                                                                      
%#end                                                                                            
%#                                                                                               
%#% Determine sample range to read:                                                              
%#if isempty(ext),                                                                               
%#   ext = [1 SamplesPerChannel];    % Return all samples                                        
%#else                                                                                           
%#   if prod(size(ext))~=2,                                                                      
%#      msg = 'Sample limit vector must have 2 elements.';                                       
%#      return                                                                                   
%#   end                                                                                         
%#   if ext(1)<1 | ext(2)>SamplesPerChannel,                                                     
%#      msg = 'Sample limits out of range.';                                                     
%#      return                                                                                   
%#   end                                                                                         
%#   if ext(1)>ext(2),                                                                           
%#      msg = 'Sample limits must be given in ascending order.';                                 
%#      return                                                                                   
%#   end                                                                                         
%#end                                                                                            
%#                                                                                               
%#% Skip over leading samples:                                                                   
%#if ext(1)>1,                                                                                   
%#   % Skip over leading samples, if specified:                                                  
%#   if(fseek(datack.fid, ...                                                                    
%#         BytesPerSample*(ext(1)-1)*wavefmt.nChannels,0)==-1),                                  
%#	   msg = 'Error reading PCM file format.';                                                    
%#      return                                                                                   
%#   end                                                                                         
%#end                                                                                            
%#                                                                                               
%#% Read desired data:                                                                           
%#nSPCext    = ext(2)-ext(1)+1; % # samples per channel in extraction range                      
%#dat        = datack;  % Copy input structure to output                                         
%#extSamples = wavefmt.nChannels*nSPCext;                                                        
%#dat.Data   = fread(datack.fid, [wavefmt.nChannels nSPCext], dtype);                            
%#                                                                                               
%#% if cnt~=extSamples, dat='Error reading file.'; return; end                                   
%#% Skip over trailing samples:                                                                  
%#if(fseek(datack.fid, BytesPerSample * ...                                                      
%#      (SamplesPerChannel-ext(2))*wavefmt.nChannels, 0)==-1),                                   
%#   msg = 'Error reading PCM file format.';                                                     
%#   return                                                                                      
%#end                                                                                            
%#                                                                                               
%#% Determine if a pad-byte is appended to data chunk,                                           
%#%   skipping over it if present:                                                               
%#if rem(datack.Size,2),                                                                         
%#   fseek(datack.fid, 1, 'cof');                                                                
%#end                                                                                            
%#% Rearrange data into a matrix with one channel per column:                                    
%#dat.Data = dat.Data';                                                                          
%#% Normalize data range: min will hit -1, max will not quite hit +1.                            
%#if BytesPerSample==1,                                                                          
%#   dat.Data = (dat.Data-128)/128;  % [-1,1)                                                    
%#else                                                                                           
%#   dat.Data = dat.Data/32768;  % [-1,1)                                                        
%#end                                                                                            
%#                                                                                               
%#return                                                                                         
%#                                                                                               
%#% end of wavread.m                                                                             
%#-h- wtregA.m                                                                                         
%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/wtregA.m 2004/6/2 14:20
       
%#%  Saved from Eps1:Desktop Folder:MATLAB5p2r10:Toolbox:NeareyMLTools:tmnstats:wtregA.m 2002/11/6 19:5
%#                                                                                                     
%#function [p,yhat,res,pcov,df] = wtregA(x,y,w)                                                        
%#% modified  for correct covariance estimate (df)                                                     
%#% This weighting is correct                                                                          
%#%  [p,yhat,res,pcov,df] =  wtregA(x,y,w)                                                             
%#% weighted fit                                                                                       
%#if nargin<3,                                                                                         
%#w=1;                                                                                                 
%#end                                                                                                  
%#w=w(:);                                                                                              
%#if length(w)<=1                                                                                      
%#	w=w*ones(size(y));                                                                                  
%#end                                                                                                  
%#[n,q]=size(x); %size(y); size(w);                                                                    
%#% Solve least squares problem.                                                                       
%#q_ones=ones(1,size(x,2));                                                                            
%#% Square roots of weights are used in the transformation of x and y                                  
%#p = (sqrt(w(:,q_ones)).*x) \( sqrt(w).*y);                                                           
%#if nargout>1                                                                                         
%#	yhat=x*p;                                                                                           
%#end                                                                                                  
%#                                                                                                     
%#if nargout>2                                                                                         
%#	res = (y- yhat).*sqrt(w); % Weighted Residuals                                                      
%#end                                                                                                  
%#df=n-q;                                                                                              
%#if nargout>3                                                                                         
%#%    Draper and smith 66 p 79                                                                        
%#	 R = (x')*(x.*w(:,q_ones));                                                                         
%#	 pcov = sum(res.^2)/df*pinv(R);    % Errors of the fit                                              
%#% pause                                                                                              
%#% sig2 is sum(res.^2)                                                                                
%#end                                                                                                  
%#                                                                                                     
%#                                                                                                     
%#                                                                                                     
