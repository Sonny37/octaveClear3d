iterations=1;
b=0;
while(b == 0) %tant que la valeur entrée n'est pas conforme
iterations = input("Entrer le nombre d'iterations: 50 75 100 150 200 300 500\t-> "); 
	switch (iterations)
	case {50, 75, 100, 150, 200, 300, 500}
		disp("ok");
    %flag pour éviter de  se retrouver avec des matrices à dimensionss différentes
		[flag, h, hrk1, hrk2]=Refraction_conduite_1(iterations); 
		for cpt=1:7
			m_p=fitRefracted(2*cpt,hrk1,hrk2,h, iterations,10,cpt,flag);
		endfor
		b=1;
	otherwise %do nothing
	endswitch
endwhile
