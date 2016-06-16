function [imc,ugc,vgc, xg, yg,cdu,cdv,resolution,errU,errV] = imcorrectPattern(im, img, M, uv, u, v, I, J, polyOrder, bSave, folderPath)    
    %INPUT:
	%	im,img : calibrated and original pictures
	% 	M : calibrated matrice
	% 	uv, u , v : projected and detected  coordinates
	% 	I,J : position of markers on the grid
	% 	cdu,cdv : coordinates coefficients used for polynomial function 
	%   resolution:  new grid resolution of imc
	%   errU, errV : standard errors for each axes
	%	bSave, folderpath : additionnal parameters if figures want to be saved
	%
	% OUTPUT
		%imc : corrected image
		
	%évaluation de la distorsion de l'inversion de matrice
	deltaU=(uv(:,1)-u);
    deltaV=(uv(:,2)-v);
        
	%1 u v uv u² v² u²v v²u u^3 v^3 u^3*v u²v² uv^3
	Poly_uv=[ones(rows(u), 1) 	...	
				u 		v ...
				u.^2	u.*v 			v.^2	...  
				u.^3	power(u,2).*v 	u.*power(v,2)  			v.^3 ... 
				u.^4 	power(u,3).*v 	power(u,2).*power(v,2) 	u.*power(v,3) 	v.^4];
	
	cols=[1 3 6 10 15];
	Poly_uv=Poly_uv(:,1:cols(polyOrder+1));
	
	cdu=Poly_uv\deltaU; %coeffficients
	cdv=Poly_uv\deltaV;
	
	uCorrige=Poly_uv*cdu; %coordonnées corrigées
	vCorrige=Poly_uv*cdv;
	
	errU=[std(uv(:,1)-u) std(uv(:,1)-u-uCorrige)] ; %erreur standard
	errV=[std(uv(:,2)-v) std(uv(:,2)-v-vCorrige)];
        
    
	figure;	grid on;
	plot(uv(:,1),uv(:,2),'og;points reprojetes;',uv(:,1)-uCorrige, uv(:,2)-vCorrige,'xb;points corriges;', u, v, 'sr;points detectes;');
	legend(gcf,"location", "northoutside");
	if(bSave == 'y')
		saveas(gcf,[folderPath 'Mire_Reconstruction' img(end-9:end-4) '.png']);
	endif
	figure % WITH SUBPLOTS AND DATA
	subplot(211);
	p1=plot(u,uv(:,1)-u,'ob',u,uv(:,1)-uCorrige-u,'xm');  % pour observer l'erreur de positionnement de chaque point
	
	subplot(212);
	p2=plot(v,uv(:,2)-v,'og',v,uv(:,2)-vCorrige-v,'xr');  % pour observer l'erreur de positionnement de chaque point
	
	hL = legend([p1,p2],{' sur u','sur v'});
	title('erreur de reprojections');
	
	% Programatically move the Legend to the center west
	set(hL,'Position', [0.01 0.49 0.2 0.05],'Units', 'normalized');
	
	if(bSave == 'y')
		saveas(gcf,[folderPath 'errRepro' img(end-9:end-4) '.png']);
	endif	
	
	figure
	plot(uv(:,1)-u, uv(:,2)-v,'o',uv(:,1)-u-uCorrige,uv(:,2)-v-vCorrige,'x')
	title('Ecarts entre les coordonnees u et v avant et apres calibration', 'fontsize', 16, 'fontweight', 'bold');
	
	%   SAVING FIGURE with end name of file
	if(bSave == 'y')
		saveas(gcf,[folderPath 'MireEcarts' img(end-9:end-4) '.png']); 
	endif
	
	%Etirer Images
  	imin=min(I(:))-1;
	imax=max(I(:))+1;
	jmin=min(J(:))-1;
	jmax=max(J(:))+1;
	
    suv=M*[imin imax; jmin jmax; 1 1];
    suv=suv(1:2,:)./suv([3;3],:);
    resolution=sqrt((suv(2,1)-suv(1,1))^2+(suv(2,2)-suv(1,2))^2);
    
   
    %Création grille X Y à résolution imposée
    figure
	[xg,yg]=meshgrid(imin*5:1/16:imax*5,jmin*5:1/16:jmax*5);
    
    % Projection de X Y vers u v 
    suvg=M*[xg(:) yg(:) 0*xg(:)+1]';
    
	ug=(suvg(1,:)./suvg(3,:))';
    vg=(suvg(2,:)./suvg(3,:))';
    
    Ig=interp2(im,ug,vg);
    Ig=reshape(Ig,size(xg));
    
	imagesc(Ig); 
	%modify image settings
	title('Mire avant correction','fontsize',16, 'fontname', 'Times','fontweight','bold')
	set(gca,'fontsize',16, 'fontname', 'Times');
	
	if(bSave == 'y')
		saveas(gcf,[folderPath 'MireEauavantCorrection' img(end-9:end-4) '.png'])
    endif
	%Correction de la Mire
		
	%formation du polynome	
	Poly_uvg=[ones(rows(ug), 1) 		...
				ug 		vg ...
				ug.^2	ug.*vg 				vg.^2	...  
				ug.^3	power(ug,2).*vg 	ug.*power(vg,2)  			vg.^3  ...
				ug.^4 	power(ug,3).*vg 	power(ug,2).*power(vg,2) 	ug.*power(vg,3) 	vg.^4];
	
	cols=[1 3 6 10 15];
	Poly_uvg=Poly_uvg(:,1:cols(polyOrder+1));
		
	ugCorrige=Poly_uvg*cdu; %ajout des coeeficients
    vgCorrige=Poly_uvg*cdv;
	
	%coordonées calculées corigées
	ugc=ug-ugCorrige;
	vgc=vg-vgCorrige;	
	
	%Construction de la nouvelle grille
	%pkg load signal
	
	%- AFFICHAGE MIRE CORRIGEE
	figure
	imc=interp2(im,ugc,vgc); %+dx +dy
	imc=reshape(imc, size(xg));
	
	axis equal
	imagesc(imc);
	
	%modify image settings
	title(['Mire apres correction - resolution ' num2str(resolution)],'fontsize',16, 'fontname', 'Times','fontweight','bold');
	set(gca,'fontsize',16, 'fontname', 'Times');
	
	hold on;
	if(bSave == 'y')
		saveas(gcf,[folderPath 'MireEauapresCorrection' img(end-9:end-4) '.png'])
	endif
endfunction
