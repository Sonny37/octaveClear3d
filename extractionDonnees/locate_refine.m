function datar=locate_refine(data,I,n);
%function datar=locate_refine(data,I,n);
% refinment of localize calibration points using correlation
% data : calibration points [ui vi] in pixels 
% I : calibration image
% n : 1:2 window size 

[ndata,ncoord]=size(data);
if ncoord~=2
 error('locate_refine : data must be of the form [ui vi]');
end

[ni,nj]=size(I);

%enlarge image using 0s
I=[zeros(n,nj+2*n); [zeros(ni,n) I zeros(ni,n)]; zeros(n,nj+2*n)];

%create reference correlation pattern (large Gaussian spot)
[x,y]=meshgrid([-n+1:n],[-n+1:n]);
r2=(x.^2+y.^2)/n^2*4;
i0=conj(fft2(exp(-r2)));

data=round(data);

ii=zeros(size(data,1),1);
jj=zeros(size(data,1),1);

for k=1:ndata
	im=I(data(k,1)+[1:2*n],data(k,2)+[1:2*n]);
	c=fftshift(real(ifft2(fft2(im).*i0)));
	[ii(k),jj(k)]=find(c==max(c(:)));
	mi=ii(k)+[-1:1];
	mj=jj(k)+[-1:1];

	%subpixel localization of maximum assuming Gaussian peak
	if ((ii(k)>1)&&(jj(k)>1)&&(ii(k)<2*n)&&(jj(k)<2*n))
	  ci=c(mi,jj(k));
	  cj=c(ii(k),mj);
	  di=.5*(log(ci(1))-log(ci(3)))/(log(ci(1))-2*log(ci(2))+log(ci(3)));
	  dj=.5*(log(cj(1))-log(cj(3)))/(log(cj(1))-2*log(cj(2))+log(cj(3)));
      ii(k)+=di;
      jj(k)+=dj;
    end
end

datar=data+[ii jj]-n-1;

endfunction
