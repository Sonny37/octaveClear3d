function [uv,uv_interp,uv0]=locate_grid4pt(I,nxy,ws,amax,a);
	%function [uv,uv_interp,uv0]=locate_grid4pt(I,nxy,ws);
	%locate markers on a rectangular grid from a 4-point mouse selection
	%of the four corners of the grid
	%
	%INPUT
	% I : 2D grayscale image buffer (negate if white markers on a dark background)
	% nxy : grid dimension , nxy(1): number of markers in first direction, nxy(2) : number of markers in second direction
	% ws : window size for subpixel localization using correlation with a Gaussian
	%
	% OUTPUT
	% uv: list of localized points
	% uv_interp : list of predictor points (homographic interpolation between the 4 corners)
	% uv0 : coordinates of the manually selected 4 corners
	%
	% L. CHATELLIER 2016/05/19
	
	if(a==1)
		suffix='st';
		else
		suffix='th';
	endif

	%    hold off;
		colormap gray;
		imagesc(I);
		hold on
		u0=nan(4,1);
		v0=nan(4,1);
		h=plot(u0,v0,'-xb');
		title(['Click ' num2str(1+4*(a-1)) suffix ' to ' num2str(4+4*(a-1)) 'th grid points']);
		drawnow

	for k=1:4
		[u0(k),v0(k)]=ginput(1);
		set(h,'xdata',u0,'ydata',v0);
		drawnow
	endfor

	set(h,'xdata',u0([1:end 1]),'ydata',v0([1:end 1])); 

	pause(.2)

	uv0=[u0 v0];

	if prod(size(nxy))==1
	 nxy=nxy([1 1]);
	endif
		
	%u0 pos for each possibilities			
	upx0 = {0 [0, 35]./70 [0, 25, 50 ]./70 [0, 20, 40, 60 ]./70 [0 ,15,30,45,60]./70 [0,10,20,30,40,50,60]./70};
	upx1 = {1 [30,70]./70 [20,45 , 70]./70 [15, 35  55, 70]./70 [10,25,40,55,70]./70 [5,15,25,35,45,55,70]./70};

	%determine la position relative des coordonnées selon le nombre d'itérations de grilles souhaitées
	data = [u0 v0 [upx0{1,amax}(a); upx1{1,amax}(a); upx1{1,amax}(a); upx0{1,amax}(a)] [0;0;1;1]];
	if(a == 1)
		data_n=data;
	else
		data_n=[data_n;data];
		
	M2D=cal_ft_2D(data_n);

	nx=nxy(1)-1;
	ny=nxy(2)-1;

	[X,Y]=meshgrid([0+5*(a-1):nx/amax+5*(a-1)]/nx,[0:ny]/ny);

	uv_interp=(M2D*[X(:) Y(:) ones(prod(nxy)/amax,1)]')';
	uv_interp=uv_interp(:,1:2)./uv_interp(:,[3 3]);

	%uv_interp(1:5,:) %pour voir si la matrice a des valeurs + ou -
	data
	pause
	uv=locate_refine(uv_interp,double(I)',ws);

	hold on;
	h1=plot(u0,v0,'xb');
	h2=plot(uv_interp(:,1),uv_interp(:,2),'+g');
	h3=plot(uv(:,1),uv(:,2),'or');
	title('Detection result');
	if(a == amax)
		legend({'selected markers'},{'interpolated grid'},{'detected markers'});
	endif
endfunction