 function m_p = fitRefracted(polynomialOrder, hrk1, hrk2, h, iterations, echantillons,cpt)%polynomialOrder, nCase, hrk1, hrk2, h, iterations, echantillons
	a=hrk1-h;
	b=hrk2-h;
	m_cases=[a; b];
	m_legend=["-sg;ecart1;"; "-sg;ecart2;"; "ob;fonction;"; "-r;polynome;"];
	
	for k=1:2
	 figure(2*cpt+k) %determination de la cohérence du polynome avec la courbe originelle
	 m_fig=plot(m_cases(k,:), m_legend(k,:));
	 hold on;
	 m_x = get(m_fig, "xdata");	%abscisses
	 m_y = get(m_fig, "ydata");	%ordonnees
	 m_n = polynomialOrder; %ordre du polnome
	 m_p = polyfit(m_x, m_y, m_n); %interpolation polynomiale
	 	 
	 xfit = linspace(min(m_x),max(m_x),echantillons);
	 yfit = polyval(m_p,xfit);
	 plot(m_x,m_y,m_legend(3,:),xfit,yfit,m_legend(4,:)); %affichage de la fction et du polynôme
	 legend show Location NorthEastOutside
	 saveas(2+k, ['i' num2str(iterations) '/hrk_',num2str(k),'_fitting_ordre_',num2str(polynomialOrder),'.png']);
	 endfor
	 
	 endfunction