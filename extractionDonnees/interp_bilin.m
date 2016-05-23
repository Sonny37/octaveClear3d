function [fi,b]=interp_bilin(x,y,f,xi,yi)
%function [fi,b]=interp_bilin(x,y,f,xi,yi)
% return bilinear interpolation fi of f(x,y)
% at locations (xi,yi)
% fi=b1+b1*xi+b3*yi+b4*xi*yi
% x,y,f must be 4*1 vectors
%
% L. CHATELLIER 2012/06/09

b=[ones(4,1) x(:) y(:) x(:).*y(:)]\f(:);

fi=b(1)+b(2)*xi+b(3)*yi+b(4)*xi.*yi;
