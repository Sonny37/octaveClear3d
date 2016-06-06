%variables requises
% uv u v 

function[deltaU, deltaV, cdu, cdv, errU, errV] = distorsion3d(uv, u, v)

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

figure(1,'PaperSize',[4,3]);
grid on;
y11 = deltaU;
y12 = deltaV;
subplot(321);
plot(y11,'x;"u";', y12,'o;"v";');
title('First subplot : Coefficients de u et de v');

y2_1 = cdu-errU;
y2_2 = cdu+errU;
y2=cdu;
subplot(322);
plot(y2,'-k;"normal";',y2_1, '--g;"erreur negative";', y2_2,'--r;"erreur negative";');
title('Ecart coefficients positifs et négatifs de u');

y3_1 = cdv-errV;
y3_2 = cdv+errV;
y3=cdv;
subplot(323);
plot(y3,'--k;"normal";', y3_1,'--g;"erreur negative";', y3_2,'--r;"erreur positive";');
title('Ecart coefficients positifs et négatifs de v');

y4_1 = uv(:,1);
y4_2 = u;
subplot(324);
plot(y4_1, 'og;"posU";', y4_2,'xb;"poscalcU";');
title('position des points u exacts et calcules');

y5_1 = uv(:,2);
y5_2 = v;
subplot(325);
plot(y5_1, '-og;"posV";', y5_2,'-xb;"poscalcV";');
title('position des points v exacts et calcules');
endfunction