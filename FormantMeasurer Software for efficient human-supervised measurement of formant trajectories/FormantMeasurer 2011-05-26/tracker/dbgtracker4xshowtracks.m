%  Saved from /Volumes/AlphaFW78/Tracker4XPBeta0p1/TNtracker~zip Folder/dbgtracker4xshowtracks.m 2004/6/2 14:20

%  Saved from Eps1:Desktop Folder:WorkingFall2k1:NeareyTracker4xApr2k1:dbgtracker4xshowtracks.m 2002/11/6 19:5

% dbgtracker4xshowtracks - a debugging script called by tracker 4x to graph stuff
% A
pausemsg('Watchlevel', watchlevel)
showbest=watchlevel>0;
showall=watchlevel>1
pauseeverywhere=watchlevel>2
showfstable=watchlevel>1
showAnbysyn=watchlevel>1
if showbest & itry==ntry  % a second pass  to show best
	nplotpass=2;
	%pausemsg
else
	nplotpass=1;
	%showbest
	itryisntry=itry==ntry;
	%
end
% nplotpass
% itry
% ntry
% pausemsg
for iplotpass=1:nplotpass
	shownow=watchlevel>0 & (showall| (showbest & iplotpass==2));
	pausemsg('Shownow',shownow, 'showall', showall,'showbest', showbest, 'iplotpass',iplotpass)
	pausemsg('nplotpass', nplotpass,'itry', itry,'ntry',ntry)
	if  shownow
		figure(47);
		% do the  sgms of the sub analyses and the fest plots.
		subplot(2,1,1);
		[Xlpcdb,faxlpc]=alpc2sgm(alpc{itry,1},gainsq{itry,1},fhi(itry)*2,df,fast,stype);
		plotsgm(taxsg,faxlpc,Xlpcdb)
		hold on
		colorbar
		plot(taxsg,ff1,'w','linewidth',2); hold on
		plot(taxsg,ff1);

		title('LPCogram for analysis 1');
		subplot(2,1,2);
		[Xlpcdb,faxlpc]=alpc2sgm(alpc{itry,2},gainsq{itry,2},fhi(itry)*2,df,fast,stype);
		plotsgm(taxsg,faxlpc,Xlpcdb)
		hold on
		colorbar
		plot(taxsg,ff1,'w','linewidth',2); hold on
		plot(taxsg,ff1);


		title('LPCogram for analysis 12');
		playsc(x,Fs)
		pausemsg
		col='bgrc';
		if iplotpass==2
			ishow=ibest;
			dbPred=dbPredSave;
			Xtarg=XtargSave;
			faxtarg=faxtargSave;
		else
			ishow=itry;
		end% if plotpass==2
		if showAnbysyn
			figure(2); clf
			if iplotpass==1;
				subplot(2,2,4);
				plot(taxsg,ff1,'-'); hold on;
				plot(taxsg,ff2+30,':');
				set(gca,'Ylim',[0,max(faxtarg)]);
			end %if iplotpass==1

			tstr=['premph-', num2str(emph(ishow)),'; fhi- ', num2str(fhi(ishow))];
			if iplotpass==2
				tstr=['best ', tstr];
			end	% if plotpass=2
			% Xtarg does not look like it is on the faxtarg axis.
			%
			showAnbysynSpect(taxsg,faxtarg, Xtarg,dbPred,tstr)

			[xx,yy]=ginput(1)
			while ~isempty(xx)
				xlabel(' Pick a spot for section')
				[jnk,isect]=min(abs(xx-taxsg));
				figure(38)
				plot(faxtarg,[Xtarg(:,isect),dbPred(:,isect)]);
				legend('Target','AnBySyn')
				xlabel(['t ',num2str(xx), 'isect ', num2str(isect)]);

				pausemsg
				figure(2)
				[xx,yy]=ginput(1)


			end	%while not empty
		end % if showanbysyn
		figure(1);
		%clf
		% 		[ax1,ax2]=splitfig2313;
		% 		subplot(ax1);

		hold on;

		%qdsgm(x,Fs);
		nft=3;
		try
			delete(lh1)
			delete(lh2)
			% 			delete(lh1K)
			% 			delete(lh2K)
		catch
			lasterr
		end %try
		for j=1:nft
			try
				ccc=[col(j),'-'];
				% 				cccK=[col(j),':'];
				lh1(j)=plot(taxsg,fest{ishow}(:,j),'w','linewidth',3);
				hold on;
				lh2(j)=plot(taxsg,fest{ishow}(:,j),ccc,'linewidth',1);
				% 				lh1K(j)=plot(taxfK,festK(:,j),'y','linewidth',3);
				% 				lh2K(j)=plot(taxfK,festK(:,j),cccK,'linewidth',1);
			catch
				lasterr
				disp('plottFK problems')
			end % try catch

		end %  for j..nft
		pausemsg
		figure(1)
		tstr=sprintf('sc %6.4f; prs %5.3f; bw %5.3f;  amp %5.3f; cont %5.3f; dist %5.3f; rabs %5.3f ; rng %5.3f; rfs %5.3f', scorecomps(ishow,:)) ;
		if iplotpass==2,
			tstr=['Best ',tstr];
			title(tstr);
			scorecomps,
			% 					xstr=sprintf('%d ', round(frealfest));
			% 					xlabel(xstr)
			%	jnk=menu('Best pausemsg menu','y', num2str(ibest));

			drawnow
			pausemsg
		end %if plotpass==2
		title(tstr)
		% 	fest{ishow}
		% 	ampest{ishow}
		% 	bwest{ishow}
		SSCORE=100*score
		pausemsg
	end % if shownow
end %iplotpass
if watchlevel>2
	pausemsg('Final pause in dbgtracker4xshowtracks')
end


