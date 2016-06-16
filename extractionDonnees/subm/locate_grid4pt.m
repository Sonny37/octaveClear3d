function [uv,uv_interp,uv0]=locate_grid4pt(I,nxy,ws,amax);
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
	for a=1:amax
		
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

		uv0{a}=[u0 v0];

		if prod(size(nxy))==1
		 nxy=nxy([1 1]);
		endif
			
		%u0 pos for each possibilities	(amax from 1 to 6)		
		upx0 = {0 [0, 35]./70 [0, 25, 50 ]./70 [0, 20, 40, 60 ]./70 [0 ,15,30,45,60]./70 [0,10,20,30,40,50,60]./70};
		upx1 = {1 [30,70]./70 [20,45 , 70]./70 [15, 35  55, 70]./70 [10,25,40,55,70]./70 [5,15,25,35,45,55,70]./70};

		%determine la position relative des coordonnées selon le nombre d'itérations de grilles souhaitées
		
		data{a} = [u0 v0 [upx0{1,amax}(a); upx1{1,amax}(a); upx1{1,amax}(a); upx0{1,amax}(a)] [0;0;1;1]];
	
	M2D=cal_ft_2D(data{a})	
	nx=nxy(1)-1;
	ny=nxy(2)-1;
	
	[X,Y]=meshgrid([0+5*(a-1):nx/amax+5*(a-1)]/nx,[0:ny]/ny);
	
	uv_interp{a}=(M2D*[X(:) Y(:) ones(prod(nxy)/amax,1)]')';
	uv_interp{a}=uv_interp{a}(:,1:2)./uv_interp{a}(:,[3 3]);
	
	uv{a}=locate_refine(uv_interp{a},double(I)',ws);
	endfor
	
	uv0	=	[uv{1,1}; uv0{1,2}; uv0{1,3}];
	uv	=	[uv{1,1}; uv{1,2}; uv{1,3}];
	uv_interp=[uv_interp{1,1}; uv_interp{1,2}; uv_interp{1,3}];
	
	
	hold on;
	
	title('Detection result','fontsize', 14, 'fontname','latex', 'fontweight', 'bold')
	
	plot(u0,v0,'xb;selected markers;');
	plot(uv_interp(:,1),uv_interp(:,2),'+g;interpolated grid;');
	plot(uv(:,1),uv(:,2),'or;detected markers;');
	
	hh=legend('location', 'northoutside');%only to get handle
	set(hh,'Units', 'normalized', 'fontsize', 12, 'orientation', 'horizontal');
	set(gca,'fontsize', 12, 'fontname','latex')	
	
endfunction