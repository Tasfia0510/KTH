% läser filen med beviset (från dokumentation)
verify(Input) :-
    see(Input), read(T), read(L), read(S), read(F), seen,
    check(T, L, S, [], F).

% check_all: formlen gäller i alla tillstånd i en lista (för AX, AF, AG)

% basfall
check_all(_,_,[],_,_).

% fall 1: U är tom 
check_all(T, L, [S | Adjacent_S], [], F) :- 
    check(T, L, S, [], F), 
    check_all(T, L, Adjacent_S, [], F). 

% fall 2: U är inte tom 
check_all(T, L, [S | Adjacent_S], U, F) :-
    check(T, L, S, U, F), 
    check_all(T, L, Adjacent_S, [S | U], F). 

% check_atleast_one: formlen gäller för åtminstone ett tillstånd (för EX, EF, EG)

% basfall: tom lista, dvs har inga transitions till andra tillstånd (ej möjligt för E)
check_atleast_one(_, _, [], _, _) :- fail.  

% det är det här som kan skrivas med semi kolon (blir kortare)
% (1) - om första tillståndet uppfyller formeln
check_atleast_one(T, L, [S |_], U, F) :-     
    check(T, L, S, U, F).
    
% (2) - fortsätter med resten av listan tills någon tillstånd uppfyller formeln
check_atleast_one(T, L, [_| Adjacent_S], U, F) :- 
    check_atleast_one(T, L, Adjacent_S, U, F).


% literals 

% positive literal 
check(_, L, S, [], X) :- 
    member([S, Props], L),
    member(X, Props). 

% negated literal 
check(_, L, S, [], neg(X)) :- 
    member([S, Props], L),
    \+member(X, Props).

% And 
check(V, L, S, [], and(F,G)) :- 
        check(V, L, S, [], F),
        check(V, L, S, [], G).

% Or (verkar vara något knas här)
check(V, L, S, [], or(F,G)) :- 
        check(V, L, S, [], F);
        check(V, L, S, [], G).

% AX (p är sant i nästa tillstånd för alla vägar)
check(V, L, S, [], ax(F)) :-
    member([S, Props], V),
    check_all(V, L, Props, [], F). 

% EX (p är sant i något nästa tillstånd för någon väg)
check(V, L, S, [], ex(F)) :-
    member([S, Props], V),                                                  
    check_atleast_one(V, L, Props, [], F).

% AG (p är sant för alla tillstånd för alla vägar)
% S är i U - AG1 
check(_, _, S, U, ag(_)) :-
    member(S,U).

% S är inte i U - AG2
check(V, L, S, U, ag(F)) :-
        \+ member(S, U),
        check(V, L, S, [], F),
        member([S, Props], V),
        check_all(V, L, Props, [S | U], ag(F)).

% EG (p är sant för alla tillstånd i någon väg)
% EG1
check(_, _, S, U, eg(_)) :-
        member(S, U).
        
%EG2
check(V, L, S, U, eg(F)) :- 
        \+ member(S, U),
        check(V, L, S, [], F),
        member([S, Props], V),
        check_atleast_one(V, L, Props, [S | U], eg(F)).

% EF (det finns en väg där något p är sant)
% EF1
check(V, L, S, U, ef(F)) :- 
        \+ member(S, U),
        check(V, L, S, [], F).

% EF2 
check(V, L, S, U, ef(F)) :- 
        \+ member(S, U),
        member([S, Props], V),
        check_atleast_one(V, L, Props, [S | U], ef(F)).

% AF (p är sant för något tillstånd i alla vägar)
% AF1
check(V, L, S, U, af(F)) :-
        \+ member(S, U),
        check(V, L, S, [], F).

% AF2
check(V, L, S, U, af(F)) :- 
        \+ member(S, U),
        member([S, Props], V),
        check_all(V, L, Props, [S | U], af(F)).