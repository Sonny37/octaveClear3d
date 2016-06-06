%function [I,J, cdu, cdv, imc, resolution,ugc, vgc, xg,yg,errU,errV,uv]=Calib2D_distpoly(img,polyOrder) %eventually add polynome order
imload
img=input("s.i?:");
% img=s.i4;
polyOrder=4; % default value


%function [I,J, cdu, cdv, imc, resolution,ugc, vgc, xg,yg,errU,errV,uv]=Calib2D_distpoly(img) %eventually add polynome order
	%INPUT 
	%img : can either be a filepath from a picture or a variable containing picture data 
	%polyOrder : ask the ordre of polynomial function to control the accuac of the point reprojections
	%OUTPUT 
	%cdu, cdv : can either be a filepath from a picture or a variable containing picture data %INPUT 
	%cdv : can either be a filepath from a picture or a variable containing picture data %INPUT 
	%imc : corrected data for image img 
	% resolution: new grid resolution 
	%ugc, vgc : corrected coorcinates using a polynomial  
	%I,J : real coordinates extracted from locate or locate_2 see line 78
	
%img='E:\Projects\SourceTree\octaveClear3d\extractionDonnees\11502003-2016-05-20-165140.tif';	
% img='E:\Projects\SourceTree\octaveClear3d\extractionDonnees\11502003-2016-05-20-165215.tif';	
%img='11502003-2016-05-20-165246.tif';	

	if strcmp('tiff',img(end-3:end)) || strcmp('tif',img(end-2:end))
		im=double(imread(img)); % fichier
	else
		im=img; %matrice
	endif
	
    nxy=[15 15];  %225 pts en 15 par 15
    ws=32;        % valeur exacte 4.19px....
    
	choixMethode = input ("Methode de localisation des points\n1 - en grille 4 par 4\n2 - par iteration\n"); 
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
			spaceOnEdge=1.6774647887324; 						%1mm 
			spacebetweenEdgeTwoDots=4.193661971831;			%2,5mm
			diameterEachDot=3.3544995774648;					%2mm	
			
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
            % whos I J X Y
			
			% exclusion des derniers points de coordonées
			% les points les plus au bords 13*4 + 4*1
			% X(end-56:end)=[];
			% Y(end-56:end)=[];
			% I(end-56:end)=[];
			% J(end-56:end)=[];
			% X(end/2+1:end)=[];
			% Y(end/2+1:end)=[];
			% I(end/2+1:end)=[];
			% J(end/2+1:end)=[];
			X(1:end/2+1)=[];
			Y(1:end/2+1)=[];
			I(1:end/2+1)=[];
			J(1:end/2+1)=[];
					
			
            %récupération de coordonées réelles et calculées
            uv=[X Y];
            XX=[I*5];
            YY=[J*5];
        otherwise
        %do nothing
    endswitch

	
	
	
	%----------------- Inverse matrice 2D --------------------

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
    
	
    
    %-----------------Distorsion----------------------------------------------
    
	
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
	%vars{2}=[u v u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2  (u.*v.^3)];
	%vars{3}=[ones(rows(u), 1) u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2  (u.*v.^3) ];
	% polynomes différents mais trop grands avec une image réfracté sous l'eau
	
	string{1}="polynomeFull";
	%string{2}="polynomeSans1";
	%string{3}="polynomeSansu_et_v";
	
	cdu=Poly_uv\deltaU; %coefs
	cdv=Poly_uv\deltaV;
	
	uCorrige=Poly_uv*cdu; 
	vCorrige=Poly_uv*cdv;
	
	errU=[std(uv(:,1)-u) std(uv(:,1)-u-uCorrige)] ; %erreur standard
	errV=[std(uv(:,2)-v) std(uv(:,2)-v-vCorrige)];
        
    
	figure;	grid on;
	plot(uv(:,1),uv(:,2),'og;points reprojetes;',uv(:,1)-uCorrige, uv(:,2)-vCorrige,'xb;points corriges;', u, v, 'sr;points detectes;');
	saveas(gcf,['Mire_Reconstruction' img(end-9:end-4) '.png']);
	legend(gcf,"location", "northoutside");

	figure % WITH SUBPLOTS AND DATA
	subplot(211);
	p1=plot(u,uv(:,1)-u,'ob',u,uv(:,1)-uCorrige-u,'xm');  % pour observer l'erreur de positionnement de chaque point
	
	subplot(212);
	p2=plot(v,uv(:,2)-v,'og',v,uv(:,2)-vCorrige-v,'xr');  % pour observer l'erreur de positionnement de chaque point
	
	hL = legend([p1,p2],{' sur u','sur v'});
	title('erreur de reprojections');
	
	% Programatically move the Legend to the center west
	newPosition = [0.01 0.49 0.2 0.05]; %[  posx, pos y,espace legende et texte legende, interligne legende]
	newUnits = 'normalized';
	set(hL,'Position', newPosition,'Units', newUnits);
	saveas(gcf,['errRepro' img(end-9:end-4) '.png']);
	
	
	figure
	plot(uv(:,1)-u, uv(:,2)-v,'o',uv(:,1)-u-uCorrige,uv(:,2)-v-vCorrige,'x')
	title('Ecarts entre les coordonnees u et v avant et apres calibration');
	
	%   SAVING FIGURE
	saveas(gcf,['MireEcarts' img(end-9:end-4) '.png']);

    % Mesure de la resolution moyenne de l'image
    
	% mode auto : fonctionne uniquement si vous avez un écart de 7 par rapport à l'origine sur au moins 3 cotés'
	
	imin=-7;
	imax=7;
    jmin=-7;
    jmax=7;
	
	% Mode manuel de sélection des points : utile si la selection de l'origine n'est pas au"centre de l'image (décommenter lignes 199 à 225)
																												%commenter lignes 193 à 196
	%printf("Veuillez entrer le pas de d%ccalage mini et maxi pour chaque axe par rapport au \npoint O d'origine. Ce pas doit %ctre pris %c la derni%cre ligne ou colonne de points identifi%cs en rouge, les lignes non visibles ou non identifi%ces ne devant pas %ctre prises en compte.\n",130 , 136, 133 ,138,130,130,136);
	% imin=input("imin= ");
	% imax=input("imax = ");
    % jmin=input("jmin = ");
    % jmax=input("jmax = ");
	
	% %printf("Veuillez entrer maintenant le nombre de lignes %c priori non visibles sur les bords de la mire : \n Si c'est %c gauche de la mire ajouter le signe '-'.",133);
	% %di=input("dI =");
	% %dj=input("dJ = ");
	% if((imax-imin+1) != 15) % +1 en comptant le point origine
		% printf("Le nombre de lignes en abcisses est < %c 15. Sur les bords gauche et droit de la mire, une ligne manque : \n Si c'est %c gauche de la mire ajouter le signe '-' au chiffre.",133, 133);
		% di=input("dI =");
		% if(di < 0) % si - alors min
			% imin +=di;
		% else % si + alors max
			% imax+=di
		% endif
	% endif
	% if((jmax-jmin)+1 != 15)
		% printf("Le nombre de lignes en ordonn%ces est < %c 15. Sur les bords haut et bas de la mire, une ligne manque : si c'est en bas de la mire, ajouter le signe '-' au chiffre.", 130,133);
		% dj=input("dJ =");
		% if(dj < 0) % si - alors min
			% jmin +=dj;
		% else % si + alors max
			% jmax+=dj;
		% endif
	% endif	
    
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
	title('Mire avant correction')
	saveas(gcf,['MireEauavantCorrection' img(end-9:end-4) '.png'])
    
		%correction de la mire
		
	disp("correction")	;
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
	figure
	imc=interp2(im,ugc,vgc); %+dx +dy
	imc=reshape(imc, size(xg));
	
	%- AFFICHAGE MIRE CORRIGEE
	imagesc(imc);
	title(['Mire Corrigee - resolution =' num2str(resolution) ])
	
	saveas(gcf,['MireEauapresCorrection' img(end-9:end-4) '.png'])
	
	%------------- POUR REDIMENSIONER LA GRILLE (facultatif )--- commenter ou décommenter des lignes 273 à 349
	% printf("Indiquer le nombres de cercles et de demi cercles en sp%ccifiant la surface de la grille : exemple 15 x 15.\n",130);
	% x=input("x : ");
	% y=input("y : ");
	
	% if( x != 15)
		% dx=(15-x)*(px(2)-px(1));
	% else
		% dx=(px(2)-px(1))/2;
	% endif
	% if( y != 15)
		% dy=(15-y)*(py(2)-py(1));
	% else
		% dy=(py(2)-py(1))/2;
	% endif
	 
	 
	% side="    ";
	% while(side != "stop")
		% printf("Indiquer %cgalement les cot%cs o%c il manque la ou les lignes : droite = d, bas = b, haut = h, gauche = g\n",130,130,151);
		% side=input("cote :");
		% switch(side)
			% case "g"
				% imc=interp2(im,ugc-dx,vgc);
				% disp("1\n");
			% case "b"
				% imc=interp2(im,ugc,vgc+dy);
				% disp("2\n");
			% case "d"
				% imc=interp2(im,ugc+dx,vgc);
				% disp("3\n");
			% case "h"
				% imc=interp2(im,ugc,vgc-dy);
				% disp("4\n");
			% case {"gb", "bg"}
				% imc=interp2(im,ugc-dx,vgc+dy);
				% disp("5n");
			% case {"gh", "hg"}
				% imc=interp2(im,ugc-dx,vgc-dy);
				% disp("6\n");
			% case {"dh", "hd"}
				% imc=interp2(im,ugc+dx,vgc-dy);
				% disp("7\n");
			% case {"db", "bd"}
				% imc=interp2(im,ugc-dx,vgc+dy);
				% disp("8\n");
			% case {"hb", "bh"}
				% vgc2=[vgc(1:round(rows(vgc)/2-1))-dy;vgc(round(rows(vgc)/2));vgc(round(rows(vgc)/2)+1:rows(vgc))+dy];
				% imc=interp2(im,ugc,vgc2);
				% disp("9\n");
			% case {"dg", "gd"}
				% imc=interp2(im,ugc*(abs(dx)/2),vgc);
				% disp("10\n");
			% case{"dgh", "dhg", "ghd", "hdg", "hgd", "gdh" }
				% disp("11\n");
				% imc=interp2(im,ugc*(abs(dx)/2),vgc-dy);
			% case{"dgb", "dbg", "gbd", "bdg", "bgd", "gdb" }
				% imc=interp2(im,ugc*(abs(dx)/2),vgc+dy);
				% disp("12\n");
			% case{"dhb", "dbh", "hbd", "bdh", "bhd", "hdb" }
				% imc=interp2(im,ugc-dx,vgc*(abs(dy)/2));
				% disp("13\n");
			% case{"ghb", "gbh", "hbg", "bgh", "bhg", "hgb" }
				% imc=interp2(im,ugc+dx,vgc*(abs(dy)/2));
				% disp("14\n");
			% case{"ghbd", "ghdb", "gdhb", "dghb", "dgbh", "dbgh","bdgh", "bdhg","bhdg","hbdg", "hbgd", "hbdg","hdbg","dhbg","dhgb"}
				% imc=interp2(im,ugc-dx,vgc*(abs(dy)/2));
				% disp("15\n");
			% otherwise
				% disp("0\n");
				% % si d ou h 
		% endswitch
		
		 % %+dx +dy
		 % imc=reshape(imc, size(xg));
		 % imagesc(imc);
		
		 % title(['mire recorigee sur les cotes:' side])
	 % endwhile
%endfunction