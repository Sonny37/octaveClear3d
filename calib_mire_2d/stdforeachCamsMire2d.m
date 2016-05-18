filePath{1}='C:\Users\vrouille\Documents\sourcetree\octaveClear3d\calib_mire_2d\fichiers originaux\cam1_mire3d_dn_mire3d.lcl';
filePath{2}='C:\Users\vrouille\Documents\sourcetree\octaveClear3d\calib_mire_2d\fichiers originaux\cam1_mire3d_up_mire3d.lcl';
filePath{3}='C:\Users\vrouille\Documents\sourcetree\octaveClear3d\calib_mire_2d\fichiers originaux\cam2_mire3d_dn_mire3d.lcl';
filePath{4}='C:\Users\vrouille\Documents\sourcetree\octaveClear3d\calib_mire_2d\fichiers originaux\cam2_mire3d_up_mire3d.lcl';

nCam={1,1,2,2}; % pour le numero de camera

for j=1:4

	[M, X, Y, u, v, uv, posCam] = inverseMatrice2d(filePath{j}, nCam{j});
	[deltaU, deltaV, cdu, cdv, errU, errV] = distorsion2d(uv, u, v, nCam{j}, posCam, j);
	allerrU(j,1:3)=[errU{1} errU{2} errU{3}]
	allerrV(j,1:3)=[errV{1} errV{2} errV{3}]
	save ('-text','err std u et v/allstdErrors.txt', "allerrU", "allerrV");
	
endfor	
figure(2)
h1=plot(allerrU(1,:));		hold on;	%set(h1,"color",[colormap(rand(10,3))]);	
h2=plot(allerrU(2,:));		hold on;	%set(h2,"color",[colormap(rand(10,3))]);	
h3=plot(allerrU(3,:));		hold on;	%set(h3,"color",[colormap(rand(10,3))]);	
h4=plot(allerrU(4,:));					%set(h4,"color",[]colormap(rand(10,3))]);
figure(3)
h1=plot(allerrV(1,:));		hold on;	%set(h1,"color",[colormap(rand(10,3))]);	
h2=plot(allerrV(2,:));		hold on;	%set(h2,"color",[colormap(rand(10,3))]);	
h3=plot(allerrV(3,:));		hold on;	%set(h3,"color",[colormap(rand(10,3))]);	
h4=plot(allerrV(4,:));					%set(h4,"color",[]colormap(rand(10,3))]);