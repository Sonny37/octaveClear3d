filePath{1}='C:\Users\vrouille\Documents\sourcetree\octaveClear3d\calib_mire_2d\fichiers originaux\cam1_mire3d_dn_mire3d.lcl';
filePath{2}='C:\Users\vrouille\Documents\sourcetree\octaveClear3d\calib_mire_2d\fichiers originaux\cam1_mire3d_up_mire3d.lcl';
filePath{3}='C:\Users\vrouille\Documents\sourcetree\octaveClear3d\calib_mire_2d\fichiers originaux\cam2_mire3d_dn_mire3d.lcl';
filePath{4}='C:\Users\vrouille\Documents\sourcetree\octaveClear3d\calib_mire_2d\fichiers originaux\cam2_mire3d_up_mire3d.lcl';

nCam={1,1,2,2}; % pour le numero de camera
sumerrV=0;
sumerrU=0;
for j=1:4

	[M, X, Y, u, v, uv, posCam] = inverseMatrice2d(filePath{j}, nCam{j});
	[deltaU, deltaV, cdu, cdv, errU, errV] = distorsion2d(uv, u, v, nCam{j}, posCam, j, sumerrU, sumerrV);
endfor	