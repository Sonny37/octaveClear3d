function [uv,uv_interp,uv0]=locate_grid4pt_0(I,nxy,ws);
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

hold off;
colormap gray;
imagesc(I);
hold on
u0=nan(4,1);
v0=nan(4,1);
h=plot(u0,v0,'-xb');
hold off
title('Click 1st to 4th grid points');
drawnow

for k=1:4
[u0(k),v0(k)]=ginput(1);
set(h,'xdata',u0,'ydata',v0);
drawnow
end
set(h,'xdata',u0([1:end 1]),'ydata',v0([1:end 1]));

pause(.2)


uv0=[u0 v0];

if prod(size(nxy))==1
 nxy=nxy([1 1]);
end

data=[u0 v0 [0;1;1;0] [0;0;1;1]];
M2D=cal_ft_2D(data);

nx=nxy(1)-1;
ny=nxy(2)-1;
[X,Y]=meshgrid([0:nx]/nx,[0:ny]/ny);

uv_interp=(M2D*[X(:) Y(:) ones(prod(nxy),1)]')';
uv_interp=uv_interp(:,1:2)./uv_interp(:,[3 3])

pause(.5)

uv=locate_refine(uv_interp,double(I)',ws);
hold on;
plot(u0,v0,'xb;selected markers;');
plot(uv_interp(:,1),uv_interp(:,2),'+g;interpolated grid;')
plot(uv(:,1),uv(:,2),'or;detected markers;');
title('Detection result');
hold off






