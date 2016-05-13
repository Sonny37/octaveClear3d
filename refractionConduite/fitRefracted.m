function m_p = fitRefracted(polynomialOrder, hrk1, hrk2, h, iterations, echantillons,cpt)%polynomialOrder, nCase, hrk1, hrk2, h, iterations, echantillons
   	nbCol=[columns(hrk1) columns(hrk2)]% avant la mise en fome des matrices
	
	hrk1= hrk1(find(hrk1<=R2));
	hrk2= hrk1(find(hrk2<=R2));
	
	test=[columns(hrk2) < columns(hrk1) columns(hrk2) > columns(hrk1)];
	
	if(test(1)) %+ de colonnes cas1
		hrk2=[hrk2 zeros(1,columns(hrk1)-columns(hrk2))];
	else if (test(2))%+ de colonnes cas1
		hrk1=[hrk1 zeros(1,columns(hrk1)-columns(hrk2))];
	else %autant de colonnes cas1 cas2
	endif
    
	a=hrk1(1,:)-h;
    b=hrk2(1,:)-h;
    
	m_cases=[a ; b];
    m_legend=["-sg;ecart1;"; "-sg;ecart2;"; "ob;fonction;"; "-r;polynome;"];
        
for k=1:2
    figure(2*cpt+k) %détermination de la cohérence du polynôme avec la courbe originelle
    m_fig=plot(m_cases(k,1:nbCol(k)), m_legend(k,:));
    hold on;
    m_x = get(m_fig, "xdata");	%abscisses
    m_y = get(m_fig, "ydata");	%ordonnees
    m_n = polynomialOrder; %ordre du polnome
    m_p = polyfit(m_x, m_y, m_n); %interpolation polynomiale
     %evaluation du polynome
    xfit = linspace(min(m_x),max(m_x),echantillons);
    yfit = polyval(m_p,xfit);
    plot(m_x,m_y,m_legend(3,:),xfit,yfit,m_legend(4,:)); %affichage de la fonction et du polynôme
    legend show Location NorthEastOutside
    saveas(2+k, ['i' num2str(iterations) '/hrk_',num2str(k),'_fitting_ordre_',num2str(polynomialOrder),'.png']);
endfor
	 
	 %for test only
	 % disp("flag :")
	 % flag
	 % pause;
	 % figure(2*cpt+1)
	 % a=hrk1(1,1:columns(hrk1))-h;
	 % m_legend=["-sg;ecart1;"; "-sg;ecart2;"; "ob;fonction;"; "-r;polynome;"];
	 % m_fig=plot(a, m_legend(1,:));
     % hold on;
     % m_x = get(m_fig, "xdata");	%abscisses
     % m_y = get(m_fig, "ydata");	%ordonnees
     % m_n = polynomialOrder; %ordre du polynome
     % m_p = polyfit(m_x, m_y, m_n); %interpolation polynomiale
	 % xfit = linspace(min(m_x),max(m_x),echantillons);
	 % yfit = polyval(m_p,xfit);
	 % plot(m_x,m_y,m_legend(3,:),xfit,yfit,m_legend(4,:)); 
	 % legend show Location NorthEastOutside
	 
	 endfunction
