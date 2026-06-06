% Uppgift 2 

% Input = lista som inkluderar dubletter
% Observerat = lista som sparar element vi redan har sett
% Resultat = lista utan dubletter 

% H = head
% T = tail

:- consult('intro.pl'). 

% basfall för 2 argument 
remove_duplicates([], []).   

% huvudpredikat
remove_duplicates(Input, Resultat) :-     
    remove_duplicates(Input, [], Resultat).                                   % Observerat listan börjar tom    

% basfall för 3 argument
remove_duplicates([], _, []).                                                %_ ignorerar observerat listan och när man promtar input får man resultat

% Fall 1: Head finns inte i Observerat då lägger vi till det i Resultat 
remove_duplicates([H | T], Observerat, [H | Resultat]) :- 
    \+ member(H, Observerat), 
    remove_duplicates(T, [H | Observerat], Resultat). 

% Fall 2: Head finns i Observerat då skippar vi det (dvs lägger inte till den i nya listan)
remove_duplicates([H | T], Observerat, Resultat) :- 
    member(H, Observerat),
    remove_duplicates(T, Observerat, Resultat). 
