%variables requises
% uv u v 
function[deltaU, deltaV, cdu, cdv, errU, errV] = distorsion2d(uv, u, v, numeroCamera)

%évaluation de la distorsion de l'inversion de matrice

deltaU=(uv(:,1)-u);
deltaV=(uv(:,2)-v);
%u v uv u² v² u²v v²u u^3 v^3 u^3*v u²v² uv^3
vars=[ones(rows(u), 1) u v u.*v (u.^2) (v.^2) (u.^2).*v u.*(v.^2) (u.^3) (v.^3) (u.^3.*v) u.^2.*v.^2  (u.*v.^3)];

cdu=vars\deltaU; 
cdv=vars\deltaV;
uCorrige=vars*cdu;
vCorrige=vars*cdv;
errU=std(uv(:,1)-u-uCorrige); %erreur standard
errV=std(uv(:,2)-v-vCorrige);


if(numeroCamera == 1)
	save 'C:\Users\vrouille\Downloads\calib_mire_2d\Matrix_CamStdError1.txt' errU errV;
	else
	save 'C:\Users\vrouille\Downloads\calib_mire_2d\Matrix_CamStdError2.txt' errU errV;
endif


endfunction