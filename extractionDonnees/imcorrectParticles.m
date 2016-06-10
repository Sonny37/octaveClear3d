[imp, yim, xim]= function imcorrectParticles(im2correct,ugv,vgc, xg, yg)
	%INPUT
	% 	im2correct : image to correct using grid size of corrected pattern 
	%	ugc,vgc : corrected coodinates from pattern
	% 	xg,yg : new picture grid
	%OUTPUT
	% 	imp : particle image corrected 
	%	yim,xim : grid
	
	printf("Entrer le chemin de l'image à corriger:");
	imp=imread(im2correct);
	
	imp=interp2(imp,ugc,vgc); 
	imp=reshape(imc2, size(xg));
	figure;
	imagesc(imp);
	
	axis xy; % flip image horizontally
	axis equal;
	[l,b,w,h]=get(gcf,"position")
	yim=h;
	xim=w;
	if(bSave == 'y')
		saveas(gcf, [folderPath 'ImgParticle' im2correct(end-9:end-3) '.png']);
	endif
endfunction