s=struct();
for b=1:25;
	s.(genvarname("i",fieldnames(s)))=0;
endfor

	 s.i='mire2D8TE/20-05-16/11502003-2016-05-20-163747.tif';
	s.i1='mire2D8TE/20-05-16/11502003-2016-05-20-164000.tif';
	s.i2='mire2D8TE/20-05-16/11502003-2016-05-20-164000.tif';
	s.i3='mire2D8TE/20-05-16/11502003-2016-05-20-164218.tif';
	s.i4='mire2D8TE/20-05-16/11502003-2016-05-20-164130.tif';
	s.i5='mire2D8TE/20-05-16/11502003-2016-05-20-164218.tif';
	s.i6='mire2D8TE/20-05-16/11502003-2016-05-20-164255.tif';
	s.i7='mire2D8TE/20-05-16/11502003-2016-05-20-164310.tif';
	s.i8='mire2D8TE/20-05-16/11502003-2016-05-20-164355.tif';
	s.i9='mire2D8TE/20-05-16/11502003-2016-05-20-165140.tif';
   s.i10='mire2D8TE/20-05-16/11502003-2016-05-20-165246.tif';
   s.i11='mire2D8TE/20-06-16/11502003-2016-05-20-165215.tif';
   s.i12='mire2D8TE/08-6-16/11502003-2016-06-08-165248.pgm';
   s.i13='mire2D8TE/08-6-16/11502003-2016-06-08-165801.pgm';
   s.i14='mire2D8TE/08-6-16/11502003-2016-06-08-170107.pgm';
   s.i15='mire2D8TE/08-6-16/11502003-2016-06-08-171809.pgm';
   s.i16='mire2D8TE/08-6-16/fc2_save_2016-06-08-172207-0000.tif';
   s.i17='mire2D8TE/08-6-16/fc2_save_2016-06-08-172207-0001.tif';
   s.i18='mire2D8TE/08-6-16/fc2_save_2016-06-08-172207-0002.tif';
   s.i19='mire2D8TE/08-6-16/fc2_save_2016-06-08-172207-0003.tif';
   s.i20='mire2D8TE/08-6-16/fc2_save_2016-06-08-172207-0004.tif';
   s.i21='mire2D8TE/08-6-16/fc2_save_2016-06-08-172207-0005.tif';
   s.i22='mire2D8TE/08-6-16/fc2_save_2016-06-08-172207-0006.tif';
   s.i23='mire2D8TE/08-6-16/fc2_save_2016-06-08-172207-0007.tif';
   s.i24='mire2D8TE/08-6-16/fc2_save_2016-06-08-172207-0008.tif';
   s.i25='mire2D8TE/08-6-16/fc2_save_2016-06-08-172207-0009.tif';
%[xx,yy]=ginput(1);clf;imagesc(imc);a=5*I;b=5*J;hold on; plot(a+xx,b+yy);colormap  gray;