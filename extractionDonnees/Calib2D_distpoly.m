function [I,J, cdu, cdv, imc, resolution, ugc, vgc, xg,yg ,errU,errV,uv,px,py]=Calib2D_distpoly(img,polyOrder=4, nxy=[19 8], ws=32) %eventually add polynome order
	%function [I,J, cdu, cdv, imc, resolution,ugc, vgc, xg,yg,errU,errV,uv]=Calib2D_distpoly(img,polyOrder,nxy, ws) %eventually add polynome order
	%This function calibrates and corrects a pattern which will be then used for correcting another image
	%INPUT 
		% img : can either be a filepath from a picture or a variable containing picture data 
		% polyOrder : ask the order of polynomial function to control the accuracy of the point reprojections - valeur par defaut :4
		% nxy : nb de points en abscisses et en ordonnees - valeur par defaut  [19 8]
		% ws : taille des marqueurs - vaelur par defaut 32
	%OUTPUT 
		% cdu, cdv : coordinates coefficients used for polynomial function  
		% imc : corrected data for image img 
		% imcParticle : corrected particle image using pattern imc 
		% resolution: new grid resolution of imc
		% ugc, vgc : corrected coordinates using a polynomial  
		% I,J : real coordinates extracted from locate or locate_2 function 
		% xg, yg : new grid coordinates
		% errU, errV : standard errors for each axes
		% uv : reprojected coordinates 
		% px,py : coordinates of origin (method 2)
	
	[im,mx,my] = imprep(img);	% -- prepare image for processing --    
    bSave=input("Would you like to save the image that gonna be printed ? (y)es or (n)o :\n If yes, a dialog will ask you where to. Don't forget the ' '\n")
	if(bSave == 'y')	
		folderPath=uigetdir();
	endif
	
	[I,J,uv, M, u, v,XX,YY,px,py] = imcalib(im,nxy,ws);			% -- Calibrate image (Find matrix and new coordinates )-- 
	[imc,ugc,vgc, xg, yg,cdu,cdv,resolution,errU,errV]=imcorrectPattern(im, img, M, uv, u, v, I, J, polyOrder, bSave, folderPath="");	% -- Managing distorsion --
	im2correct=input("Fill in the path of the picture you want to correct:\n");
	[imp, yim, xim]=imcorrectParticles(im2correct,ugc,vgc, xg, yg,bSave);	% -- Enhance particle image using pattern --
	
endfunction