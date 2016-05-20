function [M]=cal_ft_2D(data,kuv);
%function [M]=cal_ft_2D(data [,kuv]);
% pinhole 2D camera calibration (homography) using Faugeras & Toscani constraint
%
% data : calibration points [ui vi Xi Yi]
%        with Xi,Yi in real units of length  and ui,vi in pixels 
% kuv  : CCD chip resolution (ku,kv) in px per unit of length (default 1)


[ndata,ncoord]=size(data);
if ncoord~=4
 error('cal_ft_2D : data must be of the form [ui vi Xi Yi]');
end

if nargin<2
 kuv=[1 1];
end
if prod(size(kuv))==1
 kuv=kuv*[1 1];
end

%world coordinates
wx=data(:,3);
wy=data(:,4);

%image coordinates
u=data(:,1)/kuv(1);
v=data(:,2)/kuv(2);

%reorder world and image coordinates to obtain 8 camera matrix coefficients : M11..M14, M21..M24,M31..M33
Lu=[wx wy 0*u+1 0*u 0*u 0*u -wx.*u -wy.*u];
Lv=[0*v 0*v 0*v wx wy 0*v+1 -wx.*v -wy.*v];
L=reshape([Lu';Lv'],8,2*ndata)';
l=reshape([u';v'],2*ndata,1);

M=pinv(L)*l;

%Force last coefficient M34
M(9)=1;
%reorder M as a proper camera matrix
M=reshape(M,3,3)';
%normalize M using Faugeras and Toscani constraint
M=M/sqrt(sum(M(3,1:2).^2));

endfunction
