s=struct();
for b=1:12;
	s.(genvarname("i",fieldnames(s)))=0;
endfor
s.i='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-163747.tif';
s.i1='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-164000.tif';
s.i2='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-164000.tif';
s.i3='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-164218.tif';
s.i4='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-164130.tif';
s.i5='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-164218.tif';
s.i6='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-164255.tif';
s.i7='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-164310.tif';
s.i8='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-164355.tif';
s.i9='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-165140.tif';
s.i10='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-165246.tif';
s.i11='C:/Users/vrouille/Documents/sourcetree/octaveClear3d/extractionDonnees/mire2D8TE/20-05-16/11502003-2016-05-20-165215.tif';

%[xx,yy]=ginput(1);clf;imagesc(imc);a=5*I;b=5*J;hold on; plot(a+xx,b+yy);colormap  gray;