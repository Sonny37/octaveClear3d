function [imp, yim, xim]= imcorrectParticles(im2correct,ugc,vgc, xg, yg,bSave)
	%INPUT
	% 	im2correct : image to correct using grid size of corrected pattern 
	%	ugc,vgc : corrected coodinates from pattern
	% 	xg,yg : new picture grid
	%OUTPUT
	% 	imp : particle image corrected 
	%	yim,xim : grid
	
	imp=imread(im2correct);
	
	imp=interp2(imp,ugc,vgc); 
	imp=reshape(imp, size(xg));
	figure;
	imagesc(imp);
	
	axis xy; % flip image horizontally
	axis equal;
	[lbwh]=get(gcf,"position");
	yim=lbwh(1,4);
	xim=lbwh(1,3);
	if(bSave == 'y')
		saveas(gcf, [folderPath 'ImgParticle' im2correct(end-9:end-3) '.png']);
	endif
endfunction