function [flag, h, hrk1, hrk2]=Refraction_conduite_1(iterations)
%iterations=100;
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

R1=0.11; %Rayon externe [m]
R2=0.1; %Rayon interne [m]
D=0.12; %demi-bord extérieur [m]

%hauteur de l'objet d'image dans le plan x = 0 [m]
 if(isdir(['C:/Users/vrouille/Documents/octave/refractionConduite/i' num2str(iterations)]) == 0)
	mkdir(['i' num2str(iterations)])
endif
	cas2=1;	%pour enregistrer les images meme quand le cas 2 est nul
    %flag=[0 0]; % pour fitter les cas sans que le nombre de colonnes plante 
	
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
	delta=a^4*d^2-(1+a^2)*(a^2*d^2-R1^2); %discriminant réduit avec b'=2b=2*a²d
	if(delta >= 0) % 2 intersection ou tangente %dans tus les cas on determine le 1er point atteint
		x1 = ((-a^2*d - sqrt(delta))/(1+a^2));
		y1 = (a*(x1+d));
		if((y1<=R1 && y1 >= 0) && (x1>=-R1 && x1<=0 )) %P1 doit être sur le cercle externe 
			if(isreal(x1) || isreal(y1))%si coordonées de P2 sont réelles		
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
				if(delta1 >= 0) % 2 intersection ou tangente %dans tous les cas on determine le 1er point atteint
					x2 = ((-a1*b1 - sqrt(delta1))/(1+a1^2));
					y2 = (a1*x2+b1);
					if((y2<=R2 && y2 >= 0) && (x2>=-R2 && x2<=0 )) %P2 doit être sur le cercle	interne
						if(isreal(x2) || isreal(y2))
							%si coordonées de P2 sont réelles	% rayon refracté
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
							if( y3<=R2 ) %si le point d'intersection est dans le cercle interne
								z1=R1*exp(i*2*pi*[0:.01:1]);
								z2=R2*exp(i*2*pi*[0:.01:1]);
								subplot(2,1,1);
								plot(z1,'k',z2,'k',[-d;0],[0;h],'-og',[0;0],[R2;-R2],'b',[x1;x2;0],[y1;y2;y3],'-or');
								xlabel("x [m]");ylabel("y [m]");
								title(["Réfraction à travers une interface circulaire Air-PMMA de diamètre " num2str(2000*R1) "mm suivie d'une interface circulaire PMMA-Eau de diamètre " num2str(2000*R2) "mm"]);
								hrk1(k)=y3;
								if(cas2 == 0)
									saveas(1,['C:/Users/vrouille/Documents/octave/refractionConduite/i', num2str(iterations) ,'/hrk12_', num2str(k), '.png']);
								endif
							else
								disp(["cas 1:Le point d\'intersection de coordonn\x82", "es[0", num2str(y3), "] \x85 l\'it\x82" "ration ", num2str(k),"n\xF8 est hors du cercle interne de rayon R2=", num2str(R2)]);
								if(flag(1) == 0)
									flag(1)= k-1;
								endif %fin flag check pour figer le nombre de colonnes a interpoler par la suite
							endif %fin point en x=0 verif position verticale
						else 	
							disp(["coordonn\x82", "es complexes pour P2"])
						endif %fin verif pts complexes 2
					else	
						disp(["Cas 1 : les coordonn\x82", "es de P2 sont hors du cercle"]);
					endif % fin verif cercle 2
								% % if(flag(1) == 0)
									% % flag(1)= k-1;
								% % endif %fin flag check pour figer le nombre de colonnes a interpoler par la suite
				else
					disp("Cas 1 :pas de point d\'intersection P2");
				endif %fin verif intersection P2
			else
				disp(["Cas 1 :  coordonn\x82","es complexes pour P1"])
			endif %fin verif nb cplx
		else
			disp(["Cas 1 : les coordonn\x82","es de P1 sont hors du cercle"])
		endif	%fin verif cercle 1
	else
		disp("Cas 1 :pas de point d\'intersection P1");
	endif %fin verif pofint d'intersection P1
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%---------------------CASE 2-----------------------------%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% intersection point P1 de rayon et de coté at x=-D
%	x1=-D;
%	y1=a*(d-D);
%	
%	% rayon refracté
%	% angle de refraction: sin(alpha)=nPMMA*sin(alpha1)
%	alpha1= asin (sin(alpha)/nPMMA);
%	
%	% equation du rayon : (y-y1)=a1(x-x1) => y=a1*x+b1 où 
%	a1=tan(alpha1);
%	b1=y1-a1*x1;
%	
%	% intersection point P2 de rayon et de cercle X²+Y²=R2²
%	% y2=a1*x2+b1 & x2²+y2²=R2² => x2²*(1+a1²)+2a1*x2*b1+b1²=R2²
%	% 	delta=a1²b1²-(1+a1²)(b1²-R2²)
%	%	x2 = (-a1*b1 - sqrt(delta))/(1+a1²) => y2
%	delta1=a1^2*b1^2-(1+a1^2)*(b1^2-R2^2);
%	if(delta1 >=0) %au moins une intersection avec le coté du carré
%		x2 = (-a1*b1 - sqrt(delta1))/(1+a1^2);
%		y2 = (a1*x2+b1);
%		if((y2<=R2 && y2 >= 0) && (x2>=-R2 && x2<=0)) % si P2 est dans le  cercle interne
%        if(isreal(x2) || isreal(y2))%si coordonées de P2 sont réelles
%            %Rayon réfracté
%            % orientation de la normale au cerlce de rayon R2 à P2
%            beta1=atan2(y2,-x2);
%            
%            %angle refraction: nH20*sin(alpha2+beta1)=nPMMA*sin(alpha1+beta1)
%            alpha2= asin (nPMMA*sin(alpha1+beta1)/nH2O) - beta1;
%            
%            % equation du rayon : (y-y2)=a2(x-x2) => y=a2*x+b2
%            a2=tan(alpha2);
%            b2=y2-a2*x2;
%            
%            % intersection point P3 de rayon refracté and x=0 plane
%            y3=y2-a2*x2;
%            if(y3<=R2) %si le point d'intersection est dans le cercle
%              z2=R2*exp(i*2*pi*[0:.01:1]);
%              subplot(2,1,2)
%              plot([D;-D;-D;D;D],[-D;-D;D;D;-D],'k',z2,'k',[-d;0],[0;h],'-og',[0;0],[R2;-R2],'b',[x1;x2;0],[y1;y2;y3],'-or');
%              xlabel("x [m]");ylabel("y [m]");
%              title(["Réfraction à travers une interface plane Air-PMMA d'arête " num2str(2000*D) "mm suivie d'une interface circulaire PMMA-Eau de diamètre " num2str(2000*R2) "mm"])
%              
%              hrk2(k)=y3;
%              if(exist(['C:/Users/vrouille/Documents/octave/refractionConduite/i', num2str(iterations) ,'/hrk12_', num2str(k), '.png']) == 0)
%                saveas(1,['C:/Users/vrouille/Documents/octave/refractionConduite/i', num2str(iterations) ,'/hrk12_', num2str(k), '.png']) ;
%              endif
%            else
%                disp(["cas 2:Le point d\'intersection de coordonnees[", num2str(y3), "] a l\'iteration ", num2str(k)," est hors du cercle interne de rayon R2=", num2str(R2)]);
%                cas2=0;
%				if(flag(2) == 0)%figer le nombre de colonnes a interpoler par la suite
%                    flag(2)=k-1;
%                endif%fin flag check pour 
%            endif
%        else
%            disp(["Cas 2 :coordonn\x82","es complexes pour P2 "]);
%        endif
%		else
%				disp("Cas 2 : P2 hors du cercle");	
%		endif
%	else
%		disp("Cas 2 : Pas de points d\'intersection pour P2")
%	endif
%	
%	%---For test-debug mode only---%
%	if(k==1)
%		disp("\tk\ta\td\th\tR1\t\tx1\tR2\tx2");
%	endif
               % cas2=0;
				% % if(flag(2) == 0)%figer le nombre de colonnes a interpoler par la suite
                   % % flag(2)=k-1;
               % % endif%fin flag check pour 
	
	disp([k y3 R2 ]);
	%drawnow
	%pause
	%--------------------------------%
endfor  
endfunction