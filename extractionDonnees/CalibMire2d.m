%
%function [M] = CalibMire2d
%this function determine the matrice from using picture point detection
% It output a matrix from the AM= B product, given by u and v coordinates and X,Y real coordinates
	%valable pour une la première image prise de face
	
%INPUT
	%M : 3x3 matrix corresponding to the eight coefficients of the M matrix which will help position camera
	
%2016-05-20 V.ROUILLÉ L.CHATELLIER
	
spaceOnEdge=1.6774647887324; 						%1mm 
spacebetweenEdgeTwoDots=4.193661971831;			%2,5mm
diameterEachDot=3.3544995774648;					%2mm


%récupération de l'image
image=['mire2D8TE/11502003-2016-05-17-182355.tif'
;'mire2D8TE/11502003-2016-05-17-182524.tif' 
;'mire2D8TE/11502003-2016-05-17-182545.tif' 
;'mire2D8TE/11502003-2016-05-17-182604.tif' 
;'mire2D8TE/11502003-2016-05-17-182628.tif'
;'mire2D8TE/11502003-2016-05-17-182659.tif'
;'cam1_z000.tif'];

imageWater=['mire2D8TE/20-05-16/11502003-2016-05-20-163747.tif'
    ;'mire2D8TE/20-05-16/11502003-2016-05-20-163930.tif'
    ;'mire2D8TE/20-05-16/11502003-2016-05-20-164000.tif'
    ;'mire2D8TE/20-05-16/11502003-2016-05-20-164130.tif'
    ;'mire2D8TE/20-05-16/11502003-2016-05-20-164218.tif'
    ;'mire2D8TE/20-05-16/11502003-2016-05-20-164255.tif'
    ;'mire2D8TE/20-05-16/11502003-2016-05-20-164310.tif'
    ;'mire2D8TE/20-05-16/11502003-2016-05-20-164355.tif'
    ;'mire2D8TE/20-05-16/11502003-2016-05-20-165140.tif'
    ;'mire2D8TE/20-05-16/11502003-2016-05-20-165215.tif'
    ;'mire2D8TE/20-05-16/11502003-2016-05-20-165246.tif'
    ;'mire2D8TE/20-05-16/11502003-2016-05-20-165246_sanscontour.tif'];
    
	%for(n=1:7)
  %I=images{n};
    %	I=double(imread('mire2D8TE/11502003-2016-05-17-182355.tif'));
    
choixMethode = input ("Methode de localisation des points\n1 - en grille 4 par 4\n2 - par iteration\n"); 
%for n=1:rows(imageWater)
    n=1;
    im=double(imread(imageWater(n,:))); 
    nxy=[15 15];  %225 pts en 15 par 15
    ws=32;        % valeur exacte 4.19px....
    figure
    switch(choixMethode)
        case 1  %----- méthode 1 --------
                % localisation de l'image avec locate grid 4 pt ou 12 actuellmeent
            for a=1:3
                [uv,uv_interp,uv0] =locate_grid4pt(-im,nxy,ws,3,a);
                 temp1{a}=uv;
                 temp2{a}=uv_interp;
                 temp3{a}=uv0;  
            endfor
                uv=[temp1{1} ;temp1{2} ;temp1{3}];
                uv_interp=[temp2{1}; temp2{2}; temp2{3}];
                uv0=[temp3{1}; temp3{2}; temp3{3}];
                
            %setup coordonnées (en pixels) : 
            %sachant que la grille de l'image fait environ 1191 px  ou 7,1cm de coté
       
       
       
            %	 X(1)=spaceOnEdge+diameterEachDot/2;
            %	 Y(1)=X(1);

            % si une grille de 15 -------------------------------
            %	for(j=2:15)
            %		X(j)=X(j-1)+diameterEachDot/2+spacebetweenEdgeTwoDots+diameterEachDot/2;
            %		Y(j)=X(j);
            %	endfor 
              
             %si une grille de 5*3 = 15 ==> 5X sur 15Y *3 -------------------------------
                
            for j=2:15
                Y(j)=Y(j-1)+diameterEachDot+spacebetweenEdgeTwoDots;
                X(j)=Y(j-1)+diameterEachDot+spacebetweenEdgeTwoDots;
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
        case 2 %----- méthode 2 --------
            clf;
            imagesc(im);
            # cliquer un marqueur au centre de l'image, 
            # puis son voisin selon x et son voisin selon y pour créer un repère 
            # Oxy (cf points verts sur la figure jointe)
            [px,py]=ginput(3) 
            %2[X,Y,I,J,C,imref,immarker,imorg,im00]=locate(-im,round([py,px]),.7);
            [X,Y,I,J,C,imref,immarker,imorg,im00]=locate2(-im,round([py,px]),.7);

            clf;
            imagesc(im);
            hold on;
            plot(px,py,'og',X,Y,'*r');
            colormap gray
            %definir zone d'exclusion pour éliminer les points parasites.
            
            %récupération de coordonées réelles et calculées
            uv=[X Y];
            XX=[I*5];
            YY=[J*5];
        otherwise
        %do nothing
    endswitch
%-----------------inverse matrice 2d --------------------

    camera1 = uv;
    %paramètres
    %Z=zeros(rows(Y),1);
    u=camera1(:,end-1);
    v=camera1(:,end);

    % ---- création de la matrice A ---
    % produits des matrices u par XY puis on les exprime en négatifs
    muX= -u.*XX;
    muY= -u.*YY;
    mvX= -v.*XX;
    mvY= -v.*YY;
    nbRows=rows(camera1);

    matA = [XX YY ones(nbRows,1)*[1 0 0 0] muX  muY  ];
    matA= [ matA ; ones(nbRows,1)*[0 0 0] XX YY ones(nbRows,1) mvX  mvY ]; 


    % ------------ matrice B ----------- 
    matB = [u;v];

    % ---------- Calcul matrice M d'après AM=B soit M=B* (A à la puissance moins 1)
    M = pinv(matA)*matB;
    %passage d'une matrice 11,1 en matrice 4,3 en ajoutant m34=1
    M = reshape([M;1],3,3)';
    % norme des trois colonnes de la troisième ligne de M
    norm_r3= norm(M(3,1:3));
    %On divise M par cette norme pour obtenir la position de chaque point de M 
    M=M/sqrt(sum(M(3,1:2).^2));
    %M/=norm_r3;

    uv = M*[XX YY ones(nbRows,1)]'; %s*uv = M(3,3)*([X Y 1])
    uv = (uv(1:2,:)./uv([3,3],:))'; %uv=suv/s
    % affichage  des vecteurs u et v 
    
    %distorsion----------------------------------------------
    %évaluation de la distorsion de l'inversion de matrice
    deltaU=(uv(:,1)-u);
    deltaV=(uv(:,2)-v);
        
    typeDistorsion = input("affichage erreurs \n1- erreurs simples\n2- erreurs avec reconstruction grille:\n");
    switch(typeDistorsion)
    case 1    
        
        %1 u v uv u² v² u²v v²u u^3 v^3 u^3*v u²v² uv^3
        Poly_uv=[ones(rows(u), 1) u v u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2 (u.*v.^3)];
        
        %vars{2}=[u v u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2  (u.*v.^3)];
        %vars{3}=[ones(rows(u), 1) u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2  (u.*v.^3) ];

        string{1}="polynomeFull";
        %string{2}="polynomeSans1";
        %string{3}="polynomeSansu_et_v";
        cdu=Poly_uv\deltaU; %coefs
        cdv=Poly_uv\deltaV;
        uCorrige=Poly_uv*cdu; 
        vCorrige=Poly_uv*cdv;
        errU=std(uv(:,1)-u-uCorrige); %erreur standard
        errV=std(uv(:,2)-v-vCorrige);
        
        a(n,:)=[errU errV];
        
        
		folder=['iterate';'grid'];
        numImg=imageWater(n,strchr(imageWater(n,:), '-')(end)+1:end); 

		saveas(gcf,['Nouveau dossier/Water/' folder(choixMethode) 'Method/Mire_' num2str(numImg) '_Reconstruction.png']);

	figure
	grid on;
	plot(uv(:,1),uv(:,2),'og;"points calcules";',u+uCorrige,v+vCorrige,'xb;"poins corriges";', u, v, 'sr;"points initiaux";');
	
	folder=['gridMethod';'iterateMethod'];
	numImg=imageWater(n,strchr(imageWater(n,:), '-')(end)+1:end); 

	 saveas(gcf,['images/Water/' folder(choixMethode,1:findstr(folder (choixMethode,:), 'o')+1) '/Mire_' num2str(numImg) '_Reconstruction.png']);


	figure % WITH SUBPLOTS AND DATA
	title('Ecarts entre les coordonnees u et v avant et apres calibration')
	subplot(211);
	p1=plot(uv(:,1)-u,'ob');  % pour observer l'erreur de positionnement de chaque points

	subplot(212);
	p2=plot(uv(:,2)-v,'og');  % pour observer l'erreur de positionnement de chaque points


	  %LEGEND WITH DATA FROM THE SUBPLOTS
        %hL = legend([p1,p2,p3,p4,p5,p6],{'u VS u calcule','v VS v calcule','u vs uCorrige','v vs vCorrige','u calcule vs uCorrige','v calcule vs vCorrige'});
        hL = legend([p1,p2],{'u VS u calcule','v VS v calcule'});
        % Programatically move the Legend to the center west
        newPosition = [0.01 0.49 0.2 0.05]; %[  posx, pos y,espace legende et texte legende, interligne legende]
        newUnits = 'normalized';
        set(hL,'Position', newPosition,'Units', newUnits);
        %   SAVING FIGURE
        saveas(gcf,['images/Water/' folder(choixMethode,1:findstr(folder (choixMethode,:), 'o')+1) '/Mire_' num2str(numImg) '_Ecarts.png']);
%endfor

    case 2
    % Mesure de la resolution moyenne de l'image
    printf("Veuillez entrer le pas de d%ccalage mini et maxi pour chaque axe par rapport au \npoint O d'origine. Ce pas doit %ctre pris %c la derni%cre ligne ou colonne de points identifi%cs en rouge, les lignes non visibles ou non identifi%ces ne devant pas %ctre prises en compte.\n",130 , 136, 134 ,138,130,130,136);
	imin=input("imax= ");
	imax=input("imax = ");
    jmin=input("jmin = ");
    jmax=input("jmax = ");
    
    suv=M*[imin imax; jmin jmax; 1 1];
    suv=suv(1:2,:)./suv([3;3],:);
    resolution=sqrt(suv(2,1)-suv(1,1)^2+suv(2,2)-suv(1,2)^2);
    
   
    %Création grille X Y à résolution imposée
    figure
	[xg,yg]=meshgrid(-35:1/16:30,-35:1/16:35);
    
    % Projection de X Y vers u v 
    suvg=M*[xg(:) yg(:) 0*xg(:)+1]';
    ug=(suvg(1,:)./suvg(3,:))';
    vg=(suvg(2,:)./suvg(3,:))';
    
    Ig=interp2(im,ug,vg);
    Ig=reshape(Ig,size(xg));
    imagesc(Ig);
    % Correction de la distorsion uc et vc
    Poly_uvg=[ones(rows(ug),1) ug vg ug.*vg (ug.^2) (vg.^2) (ug.^2).*vg ug.*(vg.^2) (ug.^3) (vg.^3) (ug.^3.*vg) ug.^2.*vg.^2 (ug.*vg.^3)];
    
	mm=1;
	timer=time();
	while(mm*213 < 121363944 && time() < timer +10)
		start=(mm-1)*213+1;
		stop=213*mm;
		coefdeug(:,mm)=Poly_uvg(start:stop,:)\deltaU;
		coefdevg(:,mm)=Poly_uvg(start:stop,:)\deltaV;
	endwhile
	pause
	
    
    uCorrige=Poly_uvg*coefdeug'; 
    vCorrige=Poly_uvg*coefdevg';
	endswitch

 %  endfunction