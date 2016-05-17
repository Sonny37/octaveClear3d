iterations=1;
b=0;
while(b == 0) %tant que la valeur entrée n'est pas conforme
iterations = input("Entrer le nombre d'iterations: 10 20 50 75 100 150 200 300 500\t-> "); 
	switch (iterations)
	case {10,20,50, 75, 100, 150, 200, 300, 500}
		%disp("ok");
		%[ hk, hrk1, hrk2, R2]=Refraction_conduite_1(iterations); 
		for cpt=4			%ordre polynome,iterations,échantillons,cpt		   
			m_p=fitRefracted(hk, hrk1, hrk2, R2,2*cpt,iterations,cpt);
		endfor
		b=1;
	otherwise 
		disp("Inserer un nombre parmi les propositions ci dessous");%do nothing
	endswitch
endwhile
