function [im,mx,my] = imprep(img)
	%INPUT 
	%	im : loaded image
	% OUTPUT  
	%	im : preconfigured image
	% 	mx, my : limits where image processing will be effective		

if strcmp('tiff',img(end-3:end)) || strcmp('tif',img(end-2:end)) || strcmp('pgm',img(end-2:end))
		im=double(imread(img)); % fichier
	else
		im=img; %matrice
	endif
	
	% -- reduce image to what we want to process --
	[height, width]=size(im);
	pkg load image
	imshow(img);
	[mx,my]=ginput(4);
	close(gcf)
	immask=poly2mask(mx, my, height, width);
	im=immask.*im; 
	
endfunction