function [h, hrk1, hrk2]=Refraction_conduite_1(iterations)

% compute refraction of light rays from an external camera
% to a vertical plane inside a water filled PMMA duct
% 2 cases:
%  1-duct of outer radius R1 and inner radius R2
%  2-duct of outer edge 2D (square section) and inner radius R2

%refraction indexes
nH2O=1.33; %water
nPMMA=1.51;%PMMA
nair=1;

%Camera center (adapt using sensor size, focal length and ROI)
d=1; % 1m left of duct center

R1=0.11;%Rayon externe [m]
R2=0.1;%Rayon interne [m]
D=0.12;%demi-bord extérieur [m]

%hauteur de l'objet d'image dans le plan x = 0 [m]
 if(isdir(['C:/Users/vrouille/Documents/octave/refractionConduite/i' num2str(iterations)]) == 0)
	mkdir(['i' num2str(iterations)])
	endif
	%figure(1)
for k=1:iterations+1;
	hk(k)=(k-1)/iterations*0.13;
	h=hk(k);
	%pente et angle du rayon fixe du centre de caméra(-d,0) à (0,h)
	a=h/d;
	alpha=atan(a);
	
	z=R1*exp(i*2*pi*[0:.01:1]);
	
	plot(z,'k',[-d;0],[0;h]);
	%CASE 1
	% intersection point P1 de rayon et de cercle X²+Y²=R1²
	% y1=a*(x1+d) & x1²+y1²=R1² => (1+a²)x1²+2a²dx1+a²d²-R1²=0
	% 	delta=ad²-(1+a²)(a²d²-R1²)
	%	x1 = (-a²d - sqrt(delta))/(1+a²) => y1
	delta=a^4*d^2-(1+a^2)*(a^2*d^2-R1^2);
	x1 = real((-a^2*d - sqrt(delta))/(1+a^2));
	y1 = real(a*(x1+d));
	% rayon refracté
	% orientation de la normale au cercle de rayon R1 à  P1
	beta=atan2(y1,-x1);
	
	%  angle de réfraction: nPMMA*sin(alpha1+beta)=sin(alpha+beta)
	alpha1= asin (sin(alpha+beta)/nPMMA) - beta;
	
	% equation du rayon : (y-y1)=a1(x-x1) => y=a1*x+b1 avec :
	a1=tan(alpha1);
	b1=y1-a1*x1;
	
	% intersection point P2 de rayon et de cercle X²+Y²=R2²
	% y2=a1*x2+b1 & x2²+y2²=R2² => x2²*(1+a1²)+2a1*x2*b1+b1²=R2²
	% 	delta=a1²b1²-(1+a1²)(b1²-R2²)
	%	x2 = (-a1*b1 - sqrt(delta))/(1+a1²) => y2
	delta1=a1^2*b1^2-(1+a1^2)*(b1^2-R2^2);
	x2 = real((-a1*b1 - sqrt(delta1))/(1+a1^2));
	y2 = real(a1*x2+b1);
	
	% rayon refracté
	% orientation de la normale au cercle de rayon R2 à  P2
	beta1=atan2(y2,-x2);
	
	%  angle de refraction: nH20*sin(alpha2+beta1)=nPMMA*sin(alpha1+beta1)
	alpha2= asin(nPMMA*sin(alpha1+beta1)/nH2O) - beta1;
	
	% equation du rayon : (y-y2)=a2(x-x2) => y=a2*x+b2 où:
	a2=tan(alpha2);
	b2=y2-a2*x2;
	
	% intersection point P3 de rayon et de cercle X²+Y²=R3²
	% y3=y2-a2*x2
	y3=y2-a2*x2;
	
	z1=R1*exp(i*2*pi*[0:.01:1]);
	z2=R2*exp(i*2*pi*[0:.01:1]);
	subplot(2,1,1);
	plot(z1,'k',z2,'k',[-d;0],[0;h],'-og',[0;0],[R2;-R2],'b',[x1;x2;0],[y1;y2;y3],'-or');
	xlabel("x [m]");ylabel("y [m]");
	title(["Réfraction à travers une interface circulaire Air-PMMA de diamètre " num2str(2000*R1) "mm suivie d'une interface circulaire PMMA-Eau de diamètre " num2str(2000*R2) "mm"]);
	 hrk1(k)=y3;
	
	%saveas(gcf,['C:/Users/vrouille/Documents/octave/refractionConduite/cas1/hrk1_', num2str(k), '.png']) ;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%--------------------------------------------------------%
	%---------------------CASE 2-----------------------------%
	%--------------------------------------------------------%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% intersection point P1 de rayon et de coté at x=-D
	x1=-D;
	y1=a*(d-D);
	
	% rayon refracté
	% angle de refraction: sin(alpha)=nPMMA*sin(alpha1)
	alpha1= asin (sin(alpha)/nPMMA);
	
	% equation du rayon : (y-y1)=a1(x-x1) => y=a1*x+b1 où 
	a1=tan(alpha1);
	b1=y1-a1*x1;
	
	% intersection point P2 de rayon et de cercle X²+Y²=R2²
	% y2=a1*x2+b1 & x2²+y2²=R2² => x2²*(1+a1²)+2a1*x2*b1+b1²=R2²
	% 	delta=a1²b1²-(1+a1²)(b1²-R2²)
	%	x2 = (-a1*b1 - sqrt(delta))/(1+a1²) => y2
	delta1=a1^2*b1^2-(1+a1^2)*(b1^2-R2^2);
	x2 = real((-a1*b1 - sqrt(delta1))/(1+a1^2));
	y2 = real(a1*x2+b1);
	
	%Rayon réfracté
	% orientation de la normale au cerlce de rayon R2 à P2
	beta1=atan2(y2,-x2);
	
	%angle refraction: nH20*sin(alpha2+beta1)=nPMMA*sin(alpha1+beta1)
	alpha2= asin (nPMMA*sin(alpha1+beta1)/nH2O) - beta1;
	
	% equation du rayon : (y-y2)=a2(x-x2) => y=a2*x+b2
	a2=tan(alpha2);
	b2=y2-a2*x2;
	
	% intersection point P3 de rayon refracté and x=0 plane
	y3=y2-a2*x2;
	
	z2=R2*exp(i*2*pi*[0:.01:1]);
	
	subplot(2,1,2)
	plot([D;-D;-D;D;D],[-D;-D;D;D;-D],'k',z2,'k',[-d;0],[0;h],'-og',[0;0],[R2;-R2],'b',[x1;x2;0],[y1;y2;y3],'-or');
	xlabel("x [m]");ylabel("y [m]");
	title(["Réfraction à travers une interface plane Air-PMMA d'arête " num2str(2000*D) "mm suivie d'une interface circulaire PMMA-Eau de diamètre " num2str(2000*R2) "mm"])
	
	 hrk2(k)=y3;
%if(k>(iterations-0.05*iterations))
	  saveas(1,['C:/Users/vrouille/Documents/octave/refractionConduite/i', num2str(iterations) ,'/hrk12_', num2str(k), '.png']) ;
%		endif
	  endfor
endfunction