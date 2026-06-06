% Uppgift 4 

:- consult('intro.pl'). 

% Visited = lista som håller koll på besökta noder
% Edge = listan med alla noder, (a,b), (a,c) etc. 
% Way = vägen fram (the path)

noder([
   (a,b),
   (a,c),
   (a,d),
   (a,e),
   (c,d),
   (d,f),
   (f,b),
   (e,b)
]).

% binda noderna åt båda hållen 
connection(X, Y, Edge) :- 
    member((X, Y), Edge);
    member((Y, X), Edge). 

% reverse metod (från föreläsning 5)
reverse([], []).                        % basfall för reverse: listan är tom 
reverse([H | T], X) :- 
    reverse(T, Resultat),               % vänder listan och sparar i Resultat 
    append(Resultat, [H] , X).          % lägger sedan till första elementet 

% huvudpredikat
path(A, B, Way) :-                      % 3 argument där A är start och B är slut 
    noder(Edge),                       
    path(A, B, [A], Way, Edge).         %  anropar till path med A redan i visited listan 

% basfall 
path(B, B, Visited, Way, _Edge) :-      % basfall för path: om start och slut för noden är detsamma så vänder den listan 
    reverse(Visited, Way).              % anropar reverse 

% hjälppredikat
path(A, B, Visited, Way, Edge) :-                           
    connection(A, Next, Edge),                          % tittar på nästa nod efter A (start) och ser om den finns med i listan edge 
    \+member(Next, Visited),                            % kolla om vi inte har besöjt Next i Visited 
    path(Next, B, [Next | Visited], Way, Edge).         % lägger till Next i Visited och rekursivt börja från Next (Next blir nya A)