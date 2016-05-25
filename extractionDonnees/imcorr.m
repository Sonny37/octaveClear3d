function [dX,dY,dx,dy,SnR,C,x,y,sub,C12]=imcorr(I1,I2,nw,overlap,I0,J0,options);
%function [dx,dy,DX,DY,SnR,x,y,sub,C,C12]=imcorr(I1,I2,nw,overlap,I0,J0,options);
% estimate the displacement field between two images I1 and I2
% nw: size of the interrogation cell (faster if power of 2)
%    nw can define a square (single valued nw) or a rectangle (nw=[nw_x nw_y]);
% overlap: overlapping of cells, in pixels
% I0,J0: initial displacement, can be empty ([]), scalar, or field
% options: string containing the options
%          'sub'  for the estimation of the subpixel displacement
%          'cor2' for a second order correlation function (shifted by 1px)
%          'verbose' display some informations during computation
% dx,dy: estimated subpixel displacement
% dX,dY: estimated integer displacement
% SnR: signal to noise ratio (highest peak/ 2nd highest peak)
% C  : value of highest correlation peak
% x,y: vector field coordinates in the image
% C12: Array containing the correlation matrixes cij (nw x nw):
%                 [c11] NaN [c12] NaN ...
%                  NaN  NaN  NaN  NaN ...
%              C= [c21] NaN [c22] NaN ...
%                  NaN  NaN  NaN  NaN ...
%                  ...  ...  ...  ... ...
% sub: subpixel method employed
%      none: 0
%      gaussian on x : +10, on y : +1
%      centroid on x : +20, on y : +2

%check parameters
if nargin<3
   error('Need 2 images and the cell size')
end
if nargin<4
   overlap=0;
end
%check initial displacement
if nargin<6
	I0=0;
   J0=0;
else
   if isempty(I0)
      I0=0;
   end
   if isempty(J0)
      J0=0;
   end
end
%check options
if nargin<7
   options='';
end

%check arguments / initialize arrays
nw=floor(nw);
if length(nw)<2
 nw=[nw nw];
end
nwx=nw(1);
nwy=nw(2);

nx=floor((size(I1,1)-nwx)/(nwx-overlap))+1;
ny=floor((size(I1,2)-nwy)/(nwy-overlap))+1;
[Nx,Ny]=size(I1);

if nargout>5
  C=nan*ones(nx,ny);
end

if nargout>9
	C12=nan*ones(nx*(nwx+1),ny*(nwy+1));
end

dX=zeros(nx,ny);
dY=zeros(nx,ny);
dx=zeros(nx,ny);
dy=zeros(nx,ny);
dI0=zeros(nx,ny);
dJ0=zeros(nx,ny);
SnR=zeros(nx,ny);
sub=zeros(nx,ny);

if any(size(dX)~=size(I0))|any(size(dY)~=size(J0));
 if prod(size(I0))==1
   I0=round(I0)*ones(nx,ny);
 else
   I0=dX;
   disp('Warning: initial X displacement rejected, set to 0');
 end
 if prod(size(J0))==1
   J0=round(J0)*ones(nx,ny);
 else
   J0=dY;
   disp('Warning: initial Y displacement rejected, set to 0');
 end
else
 I0=round(I0);
 J0=round(J0);
end
if findstr('verbose',options)
   disp(['Computing for ' num2str(nx*ny) ' ' num2str(nwx) 'x' num2str(nwy) ' cells...']);
end
for kx=1:nx;
   for ky=1:ny
      x0=(kx-1)*(nwx-overlap);
      y0=(ky-1)*(nwy-overlap);
      i1=I1(x0+[1:nwx],y0+[1:nwy]);
      i1=i1-mean(i1(:));
      %Fourier transform of the 1st interrogation window
      f1=fft2(i1)/std(i1(:),1);
      
      %check if the initial displacement reaches the edges
      x=min(x0+I0(kx,ky),Nx-nwx);
      y=min(y0+J0(kx,ky),Ny-nwy);
      x=max(0,x);
      y=max(0,y);
      dI0(kx,ky)=x-x0;
      dJ0(kx,ky)=y-y0;
      i2=I2(x+[1:nwx],y+[1:nwy]);
      i2=i2-mean(i2(:));
      %Fourier transform of the 2nd interrogation window
      f2=fft2(i2)/std(i2(:),1);
      % compute the cross-correlation function
      c12=real(fftshift(ifft2(conj(f1).*f2)))/nwx/nwy;
      
      
      %option 'cor2' : 2 order correlation function
      if findstr('cor2',options);
         if x0<(Nx-nwx-1) & x<(Nx-nwx-1)
                  i1=I1(x0+[1:nwx]+1,y0+[1:nwy]);
				      i1=i1-mean(i1(:));
				      f1=fft2(i1)/std(i1(:),1);
						i2=I2(x+[1:nwx]+1,y+[1:nwy]);
                  i2=i2-mean(i2(:));
                  f2=fft2(i2)/std(i2(:),1);
                  c12=c12.*real(fftshift(ifft2(conj(f1).*f2)))/nwx/nwy;
         elseif x0>1 & x>1
                  i1=I1(x0+[1:nwx]-1,y0+[1:nwy]);
				      i1=i1-mean(i1(:));
				      f1=fft2(i1)/std(i1(:),1);
						i2=I2(x+[1:nwx]-1,y+[1:nwy]);
                  i2=i2-mean(i2(:));
                  f2=fft2(i2)/std(i2(:),1);
                  c12=c12.*real(fftshift(ifft2(conj(f1).*f2)))/nwx/nwy;
         end
      end
      
      %find highest and 2nd highest peaks
      % 1. find falling edges of the sign of the derivatives
      %    nb: since flipud is used to crop by 1 pixel on each side
      %        in this case, PKX and PKY have to be positive
      PKX=[ones(1,nwy) ; flipud(diff(flipud(sign(diff(c12))))>0) ; ones(1,nwy)];
      PKY=[ones(1,nwx) ; flipud(diff(flipud(sign(diff(c12'))))>0) ; ones(1,nwx)]';
      % 2. sort the valid candidates
      [II,JJ]=find(PKX.*PKY);
      if ~isempty(II)
         [M,K]=sort(c12(II+(JJ-1)*nwx));
         dX(kx,ky)=II(K(end));
         dY(kx,ky)=JJ(K(end));
      % 3. the signal to noise is defined as the ratio of the 2 peaks
         if length(II)>1
            SnR(kx,ky)=M(end)/M(end-1);
         else
            SnR(kx,ky)=Inf;
         end
      else
         dX(kx,ky)=NaN;
         dY(kx,ky)=NaN;
         SnR(kx,ky)=NaN;
         M=1;
      end
      %note: although a raw peak research is faster
      %      this procedure ensures that only local peaks are selected
      
      %option 'sub' : subpixel
      if findstr('sub',options);
         if (dX(kx,ky)<nwx)&(dX(kx,ky)>1)
      	   %c=c12(dX(kx,ky)+[-1:1],dY(kx,ky)+[-1:1]);
	        	%-min(min(C((kx-1)*(nw+1)+[1:nw],(ky-1)*(nw+1)+[1:nw])));
		      cx=c12(dX(kx,ky)+[-1:1],dY(kx,ky));
	         if cx>0
			      %gaussian 
               dx(kx,ky)=.5*(log(cx(1))-log(cx(3)))/(log(cx(1))-2*log(cx(2))+log(cx(3)));
               sub(kx,ky)=sub(kx,ky)+10;
	         else
		   	   %centroid
               dx(kx,ky)=(cx(2)-cx(1))/sum(cx);
               sub(kx,ky)=sub(kx,ky)+20;
            end
         end
         if (dY(kx,ky)<nwy)&(dY(kx,ky)>1)
 	         cy=c12(dX(kx,ky),dY(kx,ky)+[-1:1]);
            if cy>0;
               %gaussian
               dy(kx,ky)=.5*(log(cy(1))-log(cy(3)))/(log(cy(1))-2*log(cy(2))+log(cy(3)));
               sub(kx,ky)=sub(kx,ky)+1;
            else
               %centroid
               dy(kx,ky)=(cy(2)-cy(1))/sum(cy);
               sub(kx,ky)=sub(kx,ky)+2;
            end
         end
      end
      %record value of highest correlation peak
      if nargout>5
         C(kx,ky)=M(end);
      end
      %record correlation matrix
      if nargout>9
         C12((kx-1)*(nwx+1)+[1:nwx],(ky-1)*(nwy+1)+[1:nwy])=c12/M(end);
      end
   end
end
%add initial displacement
dX=dX+dI0-nwx/2-1;
dY=dY+dJ0-nwy/2-1;

if nargout>6
	%x=-(nw-overlap)/2+(nw-overlap)*[1:nx]'es(1,ny)/nx;
   %y=-(nw-overlap)/2+(nw-overlap)*ones(nx,1)*[1:ny];
   x= ([1:nx]'-.5)/nx*ones(1,ny);
   y= ones(nx,1)*([1:ny]-.5)/ny;
end
noval=find((abs(dx)>1)|(abs(dy)>1)|(~isreal(dx))|(~isreal(dy)));
if ~isempty(noval)
   %dx(noval)=0;
   %dy(noval)=0;
   disp(['Subpixel displacements rejected: ' num2str(length(noval)) '/' num2str(nx*ny)]);
end
