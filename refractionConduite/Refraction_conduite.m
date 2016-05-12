% compute refraction of light rays from an external camera
% to a vertical plane inside a water filled PMMA duct
% 2 cases:
%  1-duct of outer radius R1 and inner radius R2
%  2-duct of outer edge 2D (square section) and inner radius R2

%refraction indexes

%water
nH2O=1.33

%PMMA
nPMMA=1.51

%Camera center (adapt using sensor size, focal length and ROI)
d=1 % 1m left of duct center

%Outer radius [m]
R1=0.11
%Inner radius [m]
R2=0.1

%Outer half-edge [m]
D=0.12

%height of image object in plane at x=0 [m]
for k=1:13

hk(k)=(k-1)/13*0.13
h=hk(k)

%h=0.05

%slope and angle of undisturbed ray from camera center (-d,0) to (0,h)
a=h/d
alpha=atan(a)

z=R1*exp(i*2*pi*[0:.01:1]);

plot(z,'k',[-d;0],[0;h])
 
%CASE 1

% intersection point P1 of ray and circle X²+Y²=R1²
% y1=a*(x1+d) & x1²+y1²=R1² => (1+a²)x1²+2a²dx1+a²d²-R1²=0
% 	delta=a⁴d²-(1+a²)(a²d²-R1²)
%	x1 = (-a²d - sqrt(delta))/(1+a²) => y1
delta=a^4*d^2-(1+a^2)*(a^2*d^2-R1^2)
x1 = (-a^2*d - sqrt(delta))/(1+a^2)
y1 = a*(x1+d)

%refracted ray
% orientation of normal to R1 circle at P1
beta=atan2(y1,-x1)

% refraction angle: nPMMA*sin(alpha1+beta)=sin(alpha+beta)
alpha1= asin (sin(alpha+beta)/nPMMA) - beta

% equation of ray : (y-y1)=a1(x-x1) => y=a1*x+b1
% with
a1=tan(alpha1)
b1=y1-a1*x1;

% intersection point P2 of refracted ray and circle X²+Y²=R2²
% y2=a1*x2+b1 & x2²+y2²=R2² => x2²*(1+a1²)+2a1*x2*b1+b1²=R2²
% 	delta=a1²b1²-(1+a1²)(b1²-R2²)
%	x2 = (-a1*b1 - sqrt(delta))/(1+a1²) => y2
delta1=a1^2*b1^2-(1+a1^2)*(b1^2-R2^2)
x2 = (-a1*b1 - sqrt(delta1))/(1+a1^2)
y2 = a1*x2+b1

%refracted ray
% orientation of normal to R2 circle at P2
beta1=atan2(y2,-x2)

% refraction angle: nH20*sin(alpha2+beta1)=nPMMA*sin(alpha1+beta1)
alpha2= asin (nPMMA*sin(alpha1+beta1)/nH2O) - beta1

% equation of ray : (y-y2)=a2(x-x2) => y=a2*x+b2
% with
a2=tan(alpha2)
b2=y2-a2*x2;

% intersection point P3 of refracted ray and x=0 plane
% y3=y2-a2*x2
y3=y2-a2*x2

z1=R1*exp(i*2*pi*[0:.01:1]);
z2=R2*exp(i*2*pi*[0:.01:1]);

subplot(2,1,1)
plot(z1,'k',z2,'k',[-d;0],[0;h],'-og',[0;0],[R2;-R2],'b',[x1;x2;0],[y1;y2;y3],'-or')
axis equal; xlabel("x [m]");ylabel("y [m]");
title(["Réfraction à travers une interface circulaire Air-PMMA de diamètre " num2str(2000*R1) "mm suivie d'une interface circulaire PMMA-Eau de diamètre " num2str(2000*R2) "mm"])

hrk1(k)=y3

%CASE 2
% intersection point P1 of ray and edge at x=-D
x1=-D;
y1=a*(d-D)

%refracted ray
% refraction angle: sin(alpha)=nPMMA*sin(alpha1)
alpha1= asin (sin(alpha)/nPMMA)

% equation of ray : (y-y1)=a1(x-x1) => y=a1*x+b1
% with
a1=tan(alpha1)
b1=y1-a1*x1;

% intersection point P2 of refracted ray and circle X²+Y²=R2²
% y2=a1*x2+b1 & x2²+y2²=R2² => x2²*(1+a1²)+2a1*x2*b1+b1²=R2²
% 	delta=a1²b1²-(1+a1²)(b1²-R2²)
%	x2 = (-a1*b1 - sqrt(delta))/(1+a1²) => y2
delta1=a1^2*b1^2-(1+a1^2)*(b1^2-R2^2)
x2 = (-a1*b1 - sqrt(delta1))/(1+a1^2)
y2 = a1*x2+b1

%refracted ray
% orientation of normal to R2 circle at P2
beta1=atan2(y2,-x2)

% refraction angle: nH20*sin(alpha2+beta1)=nPMMA*sin(alpha1+beta1)
alpha2= asin (nPMMA*sin(alpha1+beta1)/nH2O) - beta1

% equation of ray : (y-y2)=a2(x-x2) => y=a2*x+b2
% with
a2=tan(alpha2)
b2=y2-a2*x2;

% intersection point P3 of refracted ray and x=0 plane
% y3=y2-a2*x2
y3=y2-a2*x2


z2=R2*exp(i*2*pi*[0:.01:1]);

subplot(2,1,2)

plot([D;-D;-D;D;D],[-D;-D;D;D;-D],'k',z2,'k',[-d;0],[0;h],'-og',[0;0],[R2;-R2],'b',[x1;x2;0],[y1;y2;y3],'-or')

axis equal; xlabel("x [m]");ylabel("y [m]");
title(["Réfraction à travers une interface plane Air-PMMA d'arête " num2str(2000*D) "mm suivie d'une interface circulaire PMMA-Eau de diamètre " num2str(2000*R2) "mm"])

hrk2(k)=y3;

drawnow
pause

end

