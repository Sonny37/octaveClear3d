%polynomialOrder, nCase, hrk1, hrk2, h, iterations, echantillons
function [p, e, eStd] = fitRefracted(hk,hrk1, hrk2, R2, polynomialOrder, iterations, cpt)%polynomialOrder, nCase, hrk1, hrk2, h, iterations, echantillons

	i1=find((hrk1 <= R2) & (hrk1 != NaN));
	i2=find((hrk2 <= R2) & (hrk2 != NaN));
		
	%hrk1= hrk1(find(hrk1 != 0));
	hrk1= hrk1(i1);
	hrk2= hrk2(i2);
 	hk1=hk(i1);
	hk2=hk(i2);
	%hrk2= hrk2(find(hrk2 != 0));
	%hrk2= hrk2(find(hrk2 != NaN));
	
	% test=[columns(hrk2) < columns(hrk1) columns(hrk2) > columns(hrk1)];
	
	% nbCol=[columns(hrk1) columns(hrk2)];
	
	% if(test(1) == 1) %+ de colonnes cas1
		% hrk2=[hrk2 zeros(1,columns(hrk1)-columns(hrk2))];
	% elseif (test(2) == 1)%+ de colonnes cas2
		% hrk1=[hrk1 zeros(1,columns(hrk2)-columns(hrk1))];
	% else
		% %hrk1 et hrk2 on la meme taille
	% endif
	
	% a=hrk1-hk1;	
	% b=hrk2-hk2;
	
	h{1}=hk1;
	h{2}=hk2;
	e{1}=hrk1-hk1;	
	e{2}=hrk2-hk2;
	
	% m_cases=[a ; b];
	 string4=["xg;" "polynomeordre" num2str(2*cpt) ";"];
     m_legend=["-sg;ecart1;"; "-sg;ecart2;"; "or;fonction;" ; string4];
        
for k=1:2
    figure(2*cpt+k) %détermination de la cohérence du polynôme avec la courbe originelle
    % m_cases(k,1:nbCol(k));
	% m_legend(k,:);
	% m_fig=plot(m_cases(k,1:nbCol(k)), m_legend(k,:));
    % hold on;
    
	% m_x = get(m_fig, "xdata");	%abscisses
    % m_y = get(m_fig, "ydata");	%ordonnees
    m_n = polynomialOrder; %ordre du polnome
    % m_p = polyfit(m_x, m_y, m_n); %interpolation polynomiale
     %evaluation du polynome
    p{k}=polyfit(h{k},e{k},m_n);
	
	 %xfit = linspace(min(m_x),max(m_x),echantillons);
     efit{k} = polyval(p{k},h{k});
	 eStd{k}=std(efit{k}-e{k}); % deviation std 
	 
     plot(h{k},e{k},m_legend(3,:),h{k}, efit{k}, m_legend(4,:)); %affichage de la fonction et du polynôme
     legend Location NorthEastOutside
     saveas(2*cpt+k, ['i' num2str(iterations) '/hrk_',num2str(k),'_fitting_ordre_',num2str(polynomialOrder),'.png']);
endfor
	eStd
	 
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
