function [M] = CalibMire2d

	spaceOnEdge=1.6774647887324; 						%1mm 
	spacebetweenEdgeTwoDots=4.193661971831;			%2,5mm
	diameterEachDot=3.3544995774648;					%2mm
 
 
%récupération de l'image
	images={ double(imread('mire2D8TE/11502003-2016-05-17-182355.tif')) 
			, double(imread('mire2D8TE/11502003-2016-05-17-182524.tif')) 
			, double(imread('mire2D8TE/11502003-2016-05-17-182545.tif')) 
			, double(imread('mire2D8TE/11502003-2016-05-17-182604.tif')) 
			, double(imread('mire2D8TE/11502003-2016-05-17-182628.tif'))
			, double(imread('mire2D8TE/11502003-2016-05-17-182659.tif'))
			, double(imread('cam1_z000.tif'))};
			 
	n=input("Choix de l\'image : 1 2 3 4 5 6 ou 7\n ");
	I=images{n};
	nxy=[15 15]; %225 pts en 15 par 15
	ws=4;% valeur exacte 4.19....

%localisation de l'image
[uv,uv_interp,uv0]=locate_grid4pt(I,nxy,ws);

%setup coordonnées (en pixels) : 
	%sachant que la grille de l'image fait environ 1191 px  ou 7,1cm de coté

 
	 X(1)=spaceOnEdge+diameterEachDot/2;
	 Y(1)=X(1);
 
	for(j=2:15)
		X(j)=X(j-1)+diameterEachDot/2+spacebetweenEdgeTwoDots+diameterEachDot/2;
		Y(j)=X(j);
	endfor 
 
	X=[X X X X X X X X X X X X X X X];
	Y=[Y' Y' Y' Y' Y' Y' Y' Y' Y' Y' Y' Y' Y' Y' Y'];
	X=reshape(X,225,1);
	Y=sort(reshape(Y,225,1));
	
	%-----------------inverse matrice 2d --------------------

	camera1 = uv;
	%paramètres
	%Z=zeros(rows(Y),1);
	u=camera1(:,end-1);
	v=camera1(:,end);

	% ---- création de la matrice A ---
	% produits des matrices u par XY puis on les exprime en négatifs
	muX= -u.*X;
	muY= -u.*Y;
	mvX= -v.*X;
	mvY= -v.*Y;
	nbRows=rows(camera1);

	matA = [X Y ones(nbRows,1)*[1 0 0 0] muX  muY  ];
	matA= [ matA ; ones(nbRows,1)*[0 0 0] X Y ones(nbRows,1) mvX  mvY ]; 


	% ------------ matrice B ----------- 
	matB = [u;v];


	% ---------- Calcul matrice M d'apres AM=B soit M=B* (A à la puissance moins 1)
	M = pinv(matA)*matB;
	%passage d'une matrice 11,1 en matrice 4,3 en ajoutant m34=1
	M = reshape([M;1],3,3)';
	% norme des trois colonnes de la troisieme ligne de M
	norm_r3= norm(M(3,1:3));
	%On divise M par cette norme pour obtenir la position de chaque point de M 
	M/=norm_r3;

	uv = M*[X Y ones(nbRows,1)]'; %s*uv = M(3,3)*([X Y 1])
	uv = (uv(1:2,:)./uv([3,3],:))'; %uv=suv/s
	% affichage  des vecteurs u et v 
	figure(10)
	grid on;

	subplot(211);
	plot(u,v,'+;"u et v";', uv(:,1),uv(:,2),'s;"u\&v calcules";');
	legend boxoff 
	legend Location NorthOutside 

	subplot(223);
	plot(uv(:,1)-u,'o;"erreur entre les deux u";');  % pour observer l'erreur de positionnement de chaque points
	legend boxoff 
	legend Location NorthOutside  

	subplot(224);
	plot(uv(:,2)-v,'o;"erreur des deux v";');  % pour observer l'erreur de positionnement de chaque points
	legend boxoff 
	legend Location NorthOutside 
	drawnow
	
%distorsion----------------------------------------------

%évaluation de la distorsion de l'inversion de matrice

deltaU=(uv(:,1)-u);
deltaV=(uv(:,2)-v);
%u v uv u² v² u²v v²u u^3 v^3 u^3*v u²v² uv^3

vars{1}=[ones(rows(u), 1) u v u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2  (u.*v.^3)];
vars{2}=[u v u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2  (u.*v.^3)];
vars{3}=[ones(rows(u), 1) u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2  (u.*v.^3) ];

string{1}="polynomeFull";
string{2}="polynomeSans1";
string{3}="polynomeSansu_et_v";
disp("k\terrU\terrV")
for k=1:3
	cdu=vars{k}\deltaU; 
	cdv=vars{k}\deltaV;
	uCorrige=vars{k}*cdu;
	vCorrige=vars{k}*cdv;
	errU{k}=std(uv(:,1)-u-uCorrige); %erreur standard
	errV{k}=std(uv(:,2)-v-vCorrige);
	%save ('-text',['MatrixCam' '_' num2str(posCam) '_StdError_pol' string{k} '.txt'], "errU", "errV");
	[k errU{k} errV{k}] 
endfor



	%figure(2)
% h1=plot(allerrU(1,:));	set(h1,"color",colormap(rand(10,3)));	hold on;
% h2=plot(allerrU(2,:));	set(h2,"color",colormap(rand(10,3)));	hold on;
% h3=plot(allerrU(3,:));	set(h3,"color",colormap(rand(10,3)));	hold on;
% h4=plot(allerrU(4,:));	set(h4,"color",colormap(rand(10,3)));
	

   endfunction