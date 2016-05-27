function [Y,X,I,J,C,imref,immarker,imorg,im00]=locate2(imorg,p,clevel)
%function [X,Y,I,J]=locate2(im,p,clevel)
% or data=locate(im,p,clevel)
% find grid markers on an image
% im : image data to analyse (or tiff, png, jpg,... filename readable by Octave)
% p0 : 3x2 array defining origin and main axis points in image
%                   + p(3,:)
%                   |
%                   +---+ p(2,:)
%               p(1,:)
% X,Y : position of markers in image (X(1),Y(1) refers to p0(1,:))
% I,J : corresponding position of markers on a cartesian grid surrounding p0
%       so that p(1,:) <=> I=0, J=0
%               p(2,:) <=> I=1, J=0
%               p(3,:) <=> I=0, J=1 and so on for successive X and Y ...
% clevel : minimum correlation level to respect
% data : if only 1 arg out, data=[X Y I J];
%
% L. Chatellier 30/01/2009 - 04/02/2009

% is imorg a filename or data?
if ischar(imorg)
 if strcmp('tiff',imorg(end-3:end))||strcmp('tif',imorg(end-2:end))
  imorg=tiffread(imorg);
  imorg=double(imorg.data);% doesn't work for RGB tiffs
 else
  imorg=double(imread(imorg));
 end
end

[nx,ny]=size(imorg);

% initial 3-point base
p0=round(p(1,:));
p1=round(p(2,:));
p2=round(p(3,:));

%correlation level to repect
if nargin<3
 clevel=0.9;
end


%initial displacement steps
dx1=p1(1)-p0(1);
dy1=p1(2)-p0(2);
dx2=p2(1)-p0(1);
dy2=p2(2)-p0(2);

%define size of initial reference image
sratio=2;
sx=2^(ceil(log2(max(abs(dx1),abs(dx2))))-sratio)
sy=2^(ceil(log2(max(abs(dy1),abs(dy2))))-sratio)
%extend image limits for marker detection near borders
im=[zeros(sx,ny); imorg; zeros(sx,ny)];
im=[zeros(nx+2*sx,sy) im zeros(nx+2*sx,sy)];
%create a marker verification image
im0=zeros(nx+2*sx,ny+2*sy);

%use gaussian spot as marker
[xm,ym]=meshgrid([-sx+1:sx],[-sy+1:sy]);
r2=(xm.^2/sx.^2+ym.^2/sy.^2)*4;
imref=exp(-r2);


%compute fft2 for future use
Imref=fft2(imref-mean(imref(:)));
Cref=sqrt(sum(abs(Imref(:)).^2)/sx/sy)/2;

%image(imref);

x=p0(1);
y=p0(2);
%is it a black or a white marker?
immean=mean(imref(:))
%imcenter=imorg(p0(1),p0(2))
imcenter=imref(sx-1,sy-1)
iswhite=2*(imcenter>immean)-1
%find imref's center of gravity
xg=[-sx+1:sx]'*ones(1,2*sy);
yg=ones(2*sx,1)*[-sy+1:sy];
immarker=(iswhite*imref)>(iswhite*immean);
xg=sum(xg(:).*immarker(:))/sum(immarker(:));
yg=sum(yg(:).*immarker(:))/sum(immarker(:));
%or correlate with a 2D gaussian spot and find subpixel position of center
immarkref=iswhite*exp(-(([-sx+1:sx]'*ones(1,2*sy)).^2+(ones(2*sx,1)*[-sy+1:sy]).^2)/sx/sy*sratio^2);
[dXc,dYc,dxc,dyc]=imcorr(immarkref,imref,[2*sx,2*sy],0,0,0,'sub');

%record first point
%X=p0(1)+xg;     %use center of gravity
%Y=p0(2)+yg;
Xc=p0(1)+dXc+dxc; %use pixel+subpixel displacement from reference spot
Yc=p0(2)+dYc+dyc;
X=Xc;
Y=Yc;

I=0;
J=0;
dX1=dx1;
dX2=dx2;
dY1=dy1;
dY2=dy2;
C=1;

%put 1st point as negative in im0

im0(round(X)+[1:2*sx],round(Y)+[1:2*sy])=max(imref(:))-imref;
im0(round(X)+sx,round(Y)+sy)=255;

%try to find all grid points while turning around p0
if 1

kr=0;
kt=0;

% maximum distance between p0 and all other points
rmax=max(sqrt(([1 nx 1 nx]-x).^2+([1 ny ny 1]-y).^2));
% evaluate maximum number of markers surrounding p0
kmax=ceil(rmax/sqrt(min((dx1+dy1)^2,(dx2+dy2)^2)));

%increment radial distance from p0
	for kr=1:kmax;
 %turn around p0
		for kt=1:8*kr
		   if kt<=2*kr+1
				%p=p0+kr*[dx1,dy1]+(kt-(kr+1))*[dx2,dy2];
				m=[kr kt-kr-1];
		   elseif (kt>2*kr+1)&&(kt<=4*kr)
				%p=p0+kr*[dx2,dy2]-(kt-(3*kr+1))*[dx1,dy1];
				m=[-kt+3*kr+1 kr];
		   elseif (kt>4*kr)&&(kt<=6*kr+1)
				%p=p0-kr*[dx1,dy1]-(kt-(5*kr+1))*[dx2,dy2];
				m=[-kr -kt+5*kr+1];
		   elseif (kt>6*kr+1)
				%p=p0-kr*[dx2,dy2]+(kt-(7*kr+1))*[dx1,dy1];
				m=[kt-7*kr-1 -kr];
		   endif
		   %find closest identified point in grid (starts with p0)
		   [dref,kref]=min((I-m(1)).^2+(J-m(2)).^2);
		   %find the corresponding displacement on grid
		   dI=m(1)-I(kref);
		   dJ=m(2)-J(kref);
		   %approximate current point's position in image
		   x=round(X(kref)+dI*dX1(kref)+dJ*dX2(kref));
		   y=round(Y(kref)+dI*dY1(kref)+dJ*dY2(kref));
		   %is this point in the image?
		   if (x>0) && (x<=nx) && (y>0) && (y<=ny);
				%cross-correlate image around current and reference point

				im2=im(x+[1:2*sx],y+[1:2*sy]);
				im2=im2-mean(im2(:));
				Im2=fft2(im2);
				C2=sqrt(sum(abs(Im2(:)).^2)/sx/sy)/2;
				%use closest identified point as ref point
				% (better correlation level, but points are progressively swept away)
				if 0
					im1=im(round(X(kref))+[1:2*sx],round(Y(kref))+[1:2*sy]);
					im1=im1-mean(im1(:));
					Im1=fft2(im1);
					C1=sqrt(sum(abs(Im1(:)).^2)/sx/sy)/2;
					C12=fftshift(real(ifft2(Im2.*conj(Im1))));
					%or always use imref
					%keeps good centering, but reject more points)
				else
					C12=fftshift(real(ifft2(Im2.*conj(Imref))));
					C1=Cref;
				endif
					%imagesc(C12);pause

					%compare with imcorr
					%[dXc,dYc,dxc,dyc,Snr,C]=imcorr(im1,im2,[2*sx 2*sy],0,0,0,'sub');

					% if correlation >clevel : register new point
				c12=max(C12(:)/C1/C2);
				if c12>clevel
					[mx,my]=find(C12==max(C12(:)));
					mx=mx(1);
					my=my(1);
					%compare with imcorr, 2nd part
					%Xc=[Xc;x+dXc+dxc];
					%Yc=[Yc;y+dYc+dyc];
					%disp([C, max(C12(:))/C1/C2])
					%disp([kt,kref,mx,my,max(C12(:))/C1/C2])

					%Gaussian subpixel interpolation
					% 1D along x
					if (mx>1)&&(mx<2*sx)
						gx=C12(mx+[-1:1],my);
						if all(gx>0)
							dx=.5*(log(gx(1))-log(gx(3)))/(log(gx(1))-2*log(gx(2))+log(gx(3)));
							if abs(dx)<1
								x=x+dx;
							endif
						endif
					endif
					%1D along y
					if (my>1)&&(my<2*sy)
						gy=C12(mx,my+[-1:1]);
						if all(gy>0)
							dy=.5*(log(gy(1))-log(gy(3)))/(log(gy(1))-2*log(gy(2))+log(gy(3)));
							if abs(dy)<1
								y=y+dy;
							endif
						endif
					endif
					%update localisation with refined values
					x=x+mx-1-sx;
					y=y+my-1-sy;
					% is this point still in the initil imge?
					if (x>0) && (x<=nx) && (y>0) && (y<=ny);
						X=[X;x];
						Y=[Y;y];
						I=[I;m(1)];
						J=[J;m(2)];
						C=[C;c12];
						%local modification of d##
						%1st: retain ref values
						dX1=[dX1;dX1(kref)];
						dY1=[dY1;dY1(kref)];
						dX2=[dX2;dX2(kref)];
						dY2=[dY2;dY2(kref)];
						%2nd: modify displacement increment along grid directions
						if ~dI
							dX2(end)=(x-X(kref))/dJ;
							dY2(end)=(y-Y(kref))/dJ;
						endif
						if ~dJ
							dX1(end)=(x-X(kref))/dI;
							dY1(end)=(y-Y(kref))/dI;
						endif
						%3rd:; modify displacement increment in any direction
						if dI*dJ
						 %TODO:
						 %project or use a complex representation
						 % use DI/DJ and simplify
						endif
						%create an image of marker only
						im0(round(x)+[1:2*sx],round(y)+[1:2*sy])=im(round(x)+[1:2*sx],round(y)+[1:2*sy]);
						im0(round(x)+sx,round(y)+sy)=255;
						%put markers on original image
						if  (m(1)==1)&&(m(2)==0)
							im0(round(x)+sx+[-1:1],round(y)+sy+[-4:4])=255;
						elseif (m(2)==1)&&(m(1)==0)
							im0(round(x)+sx+[-3:-1 1:3],round(y)+sy+[-4:4])=255;
						else
							im0(round(x)+sx+[-1:1],round(y)+sy+[-1:1])=255;
						endif
					endif
				endif
			endif
		endfor
	endfor

end %if 0

im00=im0(sx+[1:nx],sy+[1:ny]);
