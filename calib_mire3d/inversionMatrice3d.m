
function [M, X, Y, Z, u, v, uv] = inversionMatrice3d(pointsXYZUV)

%chargement des positions des points X Y Z u v
camera1 = load (pointsXYZUV);

%paramètres
X=camera1(:,1);
Y=camera1(:,2);
Z=camera1(:,3);
u=camera1(:,4);
v=camera1(:,5);

% ---- creation de la matrice A ---
% produits des matrices u par XYZ puis on les exprime en négatifs
muX= -u.*X;
muY= -u.*Y;
muZ= -u.*Z;
mvX= -v.*X;
mvY= -v.*Y;
mvZ= -v.*Z;
nbRows=rows(camera1);

matA = [X Y Z ones(nbRows,1)*[1 0 0 0 0] muX  muY muZ ];
matA= [ matA ; ones(nbRows,1)*[0 0 0 0] X Y Z ones(nbRows,1) mvX  mvY mvZ]; 
% ------------ matrice B ----------- 
matB = [u;v];

% ---------- Calcul matrice M d'apres AM=B soit M=B* (A à la puissance moins 1)
M = pinv(matA)*matB;
%passage d'une matrice 11,1 en matrice 4,3 en ajoutant m34=1
M = reshape([M;1],4,3)';
% norme des trois colonnes de la troisieme ligne de M
norm_r3= norm(M(3,1:3));
%O divise M par cette norme pour obtenir la position de chaque point de M 
M/=norm_r3;

uv = M*[X Y Z ones(nbRows,1)]';
uv = (uv(1:2,:)./uv([3,3],:))'; 

plot(uv(:,1)-u,'o');  % pour observer l'erreur de positionnement de chaque points

mean(uv(:,1)-u); % valeur moyenne des valeurs de l'erreur pour u 
mean(uv(:,2)-v) % valeur moyenne des valeurs de l'erreur pour u 
std(uv(:,2)-v) % erreur quadratique de v 
std(uv(:,1)-u) % erreur quadratique de u
min(uv(:,1)-u) % val min de u 
max(uv(:,1)-u) % val max de u

% norm(uv-[u v])
% norm(uv[:,1]-[u v])
 %r=sqrt((u-uv(:,1)).^2+(v-uv(:,2)).^2)
%mean(r)
sqrt(mean((u-uv(:,1)).^2+(v-uv(:,2)).^2)) % norme de u
sqrt(std(uv(:,1)-u)^2+std(uv(:,2)-v)^2) % norme de u d'apres l'erreur standard
endfunction
