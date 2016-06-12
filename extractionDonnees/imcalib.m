function [I,J,uv,M, u, v,XX,YY,px,py] = imcalib(im,nxy,ws)
	%INPUT : 
	%	im : loaded image to calibrate
	%   nxy, ws : pattern data used for grid localization method
	%OUTPUT
	% 	I,J : markers coordinates
	%	uv u, v : reprojected coordinates and initial coordinates
	%	XX,YY : Calculated coordiantes
	%	px,py: coordinates of origin
	
	chdir('subm'); % go subfolder
	detectionMethod = input ("Methode de localisation des points\n1 - en grille 4 par 4\n2 - par iteration\n"); 
	switch(detectionMethod )
        case 1  %----- méthode 1 --- localisation de l'image avec locate grid 4 pt ou 12 actuellmeent
			amax=input("Preciser le nombre de grille que vous voulez effectuer sur la mire: ");
            
			for a=1:amax
				
				[uv,uv_interp,uv0] =locate_grid4pt(-im,nxy,ws,amax,a);
                 temp1{a}=uv;
                 temp2{a}=uv_interp;
                 temp3{a}=uv0;  
            endfor
			    uv=[temp1{1} ;temp1{2} ;temp1{3}];
                uv_interp=[temp2{1}; temp2{2}; temp2{3}];
                uv0=[temp3{1}; temp3{2}; temp3{3}];
                
            %setup coordonnées (en pixels) :     %sachant que la grille de l'image fait environ 1191 px  ou 7,1cm de coté
            %si une grille de 5*3 = 15 ==> 5X sur 15Y *3 -------------------------------
			espaceAuBord=1.6774647887324; 			%1mm 
			distDeuxPoints=4.193661971831;			%2,5mm
			diametrePoint=3.3544995774648;			%2mm	
			
			X(1)=espaceAuBord+diametrePoint/2;
            Y(1)=X(1);
            for j=2:15
                Y(j)=Y(j-1)+diametrePoint+distDeuxPoints;
                X(j)=Y(j-1)+diametrePoint+distDeuxPoints;
            endfor
            X1=repmat(X(1,1:5),15,1);
            X2=repmat(X(1,6:10),15,1);
            X3=repmat(X(1,11:15),15,1);
            
            X1=reshape(X1,75,1);
            X2=reshape(X2,75,1);
            X3=reshape(X3,75,1);
                
            X=[X1;X2;X3];
            
            Y1=repmat(Y,1,5);
            Y1=reshape(Y1,75,1);
            Y=repmat(Y1,3,1);
			
        case 2 %----- méthode 2 ----- itération autour d'un repère
			clf;
            imagesc(im);
            # cliquer un marqueur au centre de l'image, 
            # puis son voisin selon x et son voisin selon y pour créer un repère 
            # Oxy (cf points verts sur la figure jointe)
            [px,py]=ginput(3) 
           
		    [X,Y,I,J,C,imref,immarker,imorg,im00]=locate2(-im,round([py,px]),.65);
			clf;
            imagesc(im);
            hold on;
            
			plot(px,py,'og',X,Y,'*r');
			colormap gray
			hold on;
			comet(X,Y);
			pause;
			
			% exclusion des derniers points de coordonées
			% les points les plus au bords 13*4 + 4*1
			% X(end-56:end)=[];			% Y(end-56:end)=[];
			% I(end-56:end)=[];			% J(end-56:end)=[];
						
            %récupération de coordonées réelles et calculées
            uv=[X Y];
            XX=[I*5];
            YY=[J*5];
        otherwise        %do nothing
    endswitch
	
	%--- Inverse matrice 2D ---
    camera1 = uv;
    %paramètres
    u=camera1(:,end-1);	
    v=camera1(:,end);

    % --- création de la matrice A ---
    % produits des matrices u par XY puis on les exprime en négatifs
    muX= -u.*XX;
    muY= -u.*YY;
    mvX= -v.*XX;
    mvY= -v.*YY;
    nbRows=rows(camera1);

    matA = [XX YY ones(nbRows,1)*[1 0 0 0] muX  muY  ];
    matA= [ matA ; ones(nbRows,1)*[0 0 0] XX YY ones(nbRows,1) mvX  mvY ]; 

    % --- matrice B ---
    matB = [u;v];

    % --- Calcul matrice M d'après AM=B soit M=B* (A à la puissance moins 1) --- 
    M = pinv(matA)*matB;
    % --- passage d'une matrice 11,1 en matrice 4,3 en ajoutant m34=1 --- 
    M = reshape([M;1],3,3)';
    %  --- norme des trois colonnes de la troisième ligne de M  --- 
    norm_r3= norm(M(3,1:3));
    %  --- On divise M par cette norme pour obtenir la position de chaque point de M  --- 
    M/=norm_r3;

    uv = M*[XX YY ones(nbRows,1)]'; %s*uv = M(3,3)*([X Y 1])
    uv = (uv(1:2,:)./uv([3,3],:))'; %uv=suv/s
	chdir('..'); % back  main folder
endfunction