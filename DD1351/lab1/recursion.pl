% Uppgift 3 

% List = input listan 
% Length = längden vi vill ha för varje delsekvens
% Sublist = delsekvensen 

:- consult('intro.pl'). 

partstring(List, Length, Sublist) :- 
    append(_, Rest, List),              % får alla rester, [a,b,c], [b,c], [c], []... (med backtracking)                  
    append(Sublist, _, Rest),           % Sublist + [skippa] = Rest,                    tar antal element från startposition (F)
    my_length(Sublist, Length),         % Räknar längden av våran delfrekvens (ger L), säger ja om det stämmer, annars hoppar den till andra append
    Length > 0.                         % Minst ett element                            tar bort delsekvensen 