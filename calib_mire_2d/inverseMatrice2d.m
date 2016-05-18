function [M, X, Y, u, v, uv, posCam] = inverseMatrice2d(pointsXYuv, numeroCamera)

if(findstr(pointsXYuv, "_dn_") == 98) %98 => pos du _dn_ ou up dans le path
	posCam="dn";
else
	posCam="up";
endif
% function [M, matA]= inverseMatrice2d(pointsXYuv)
camera1 = load (pointsXYuv);


%paramètres
X=camera1(:,1);
Y=camera1(:,2);
%Z=zeros(rows(Y),1);
u=camera1(:,end-1);
v=camera1(:,end);

% ---- creation de la matrice A ---
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
   figure(1)
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
   %saveas(1,['images ecarts val departs et calc/3en1/ecartsCam' num2str(numeroCamera) posCam '.png'])
   %save("-text", ['M/Matrix_Cam' num2str(numeroCamera) '_' posCam '.txt'], "M")
	drawnow
   endfunction