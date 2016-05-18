%variables requises
% uv u v 
function[deltaU, deltaV, cdu, cdv, errU, errV] = distorsion2d(uv, u, v, numeroCamera, posCam, j)

%évaluation de la distorsion de l'inversion de matrice

deltaU=(uv(:,1)-u);
deltaV=(uv(:,2)-v);
%u v uv u² v² u²v v²u u^3 v^3 u^3*v u²v² uv^3

vars{1}=[ones(rows(u), 1) u v u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2  (u.*v.^3)];
vars{2}=[u v u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2  (u.*v.^3)];
vars{3}=[ones(rows(u), 1) u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2  (u.*v.^3)];

string{1}="polynomeFull";
string{2}="polynomeSans1";
string{3}="polynomeSansu_et_v";


for k=1:3
	cdu=vars{k}\deltaU; 
	cdv=vars{k}\deltaV;
	uCorrige=vars{k}*cdu;
	vCorrige=vars{k}*cdv;
	errU{k}=std(uv(:,1)-u-uCorrige); %erreur standard
	errV{k}=std(uv(:,2)-v-vCorrige);

	%save ('-text',['err std u et v/MatrixCam' num2str(numeroCamera) '_' num2str(posCam) '_StdError_pol' string{k} '.txt'], "errU", "errV"); 
	endfor
endfunction

h1=plot(allerrU(1,:));	set(h1,"color",colormap(rand(10,3)));	hold on;
h2=plot(allerrU(2,:));	set(h2,"color",colormap(rand(10,3)));	hold on;
h3=plot(allerrU(3,:));	set(h3,"color",colormap(rand(10,3)));	hold on;
h4=plot(allerrU(4,:));	set(h4,"color",colormap(rand(10,3)));

