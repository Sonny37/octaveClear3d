%variables requises
% uv u v 
function[deltaU, deltaV, cdu, cdv, errU, errV] = distorsion2d(uv, u, v, numeroCamera, posCam, j, sumerrU, sumerrV)

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

switch(j)
	case 2
		t=3;
	case 3
		t=6;
	case 4	
		t=9;
	otherwise
		t=0;
endswitch
for k=1:3
	cdu=vars{k}\deltaU; 
	cdv=vars{k}\deltaV;
	uCorrige=vars{k}*cdu;
	vCorrige=vars{k}*cdv;
	errU=std(uv(:,1)-u-uCorrige); %erreur standard
	errV=std(uv(:,2)-v-vCorrige);
	zz=t+k
	sumerrU(t+k)=errU;
	sumerrV(t+k)=errV;
	save ('-text',['err std u et v/MatrixCam' num2str(numeroCamera) '_' num2str(posCam) '_StdError_pol' string{k} '.txt'], "errU", "errV"); 
	save ('-text','err std u et v/allstdErrors.txt', "sumerrU", "sumerrV");
	endfor
endfunction