%polynomialOrder, nCase, hrk1, hrk2, h, iterations, echantillons
function m_p = fitRefracted(h,hrk1, hrk2, R2, polynomialOrder, iterations, echantillons, cpt)%polynomialOrder, nCase, hrk1, hrk2, h, iterations, echantillons
	
	
	
	hrk1= hrk1(find(hrk1<=R2));	
	hrk1= hrk1(find(hrk1 != 0)); 
	hrk1= hrk1(find(hrk1 != NaN));
	
	hrk2= hrk2(find(hrk2<=R2));
 	hrk2= hrk2(find(hrk2 != 0));
	hrk2= hrk2(find(hrk2 != NaN));
	
	test=[columns(hrk2) < columns(hrk1) columns(hrk2) > columns(hrk1)];
	
	nbCol=[columns(hrk1) columns(hrk2)]
	pause
	if(test(1) == 1) %+ de colonnes cas1
		hrk2=[hrk2 zeros(1,columns(hrk1)-columns(hrk2))];
	elseif (test(2) == 1)%+ de colonnes cas2
		hrk1=[hrk1 zeros(1,columns(hrk2)-columns(hrk1))];
	else
		%hrk1 et hrk2 on la meme taille
	endif
	
	a=hrk1(1,:)-h
	pause
    b=hrk2(1,:)-h
	pause
    
	m_cases=[a ; b];
	string4=["-r;" "polynomeordre_{" num2str(2*cpt) "};"];
    m_legend=["-sg;ecart1;"; "-sg;ecart2;"; "ob;fonction;" ; string4];
        
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
	 
	 % %for test only
	 % % pause;
	 % % figure(2*cpt+1)
	 % % a=hrk1(1,1:columns(hrk1))-h;
	 % % m_legend=["-sg;ecart1;"; "-sg;ecart2;"; "ob;fonction;"; "-r;polynome;"];
	 % % m_fig=plot(a, m_legend(1,:));
     % % hold on;
     % % m_x = get(m_fig, "xdata");	%abscisses
     % % m_y = get(m_fig, "ydata");	%ordonnees
     % % m_n = polynomialOrder; %ordre du polynome
     % % m_p = polyfit(m_x, m_y, m_n); %interpolation polynomiale
	 % % xfit = linspace(min(m_x),max(m_x),echantillons);
	 % % yfit = polyval(m_p,xfit);
	 % % plot(m_x,m_y,m_legend(3,:),xfit,yfit,m_legend(4,:)); 
	 % % legend show Location NorthEastOutside
endfunction
