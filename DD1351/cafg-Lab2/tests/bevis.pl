% läser filen med beviset (från dokumentation)
verify(InputFileName) :- see(InputFileName),
        read(Prems), read(Goal), read(Proof),
        seen,
        valid_proof(Prems, Goal, Proof).

% om sista raden i beviset inte är lika med högerledet i sekventen så ska den sluta
valid_proof(Prems, Goal, Proof) :-
        last(Proof, [_, Goal, _]),
        examine_proof(Prems, Proof, []).

% om tom stop! 
examine_proof(_,[],_). 

% kolla rader (uppifrån till ner) 
examine_proof(Prems, [CurrentLine | RemainingLines], CheckedLines) :-       
        check_line(Prems, CheckedLines, CurrentLine),  
        append(CheckedLines, [CurrentLine], Result),                    
        examine_proof(Prems, RemainingLines, Result).   

% box hantering - kollar boxens struktur för en rad (annars fortsätter till nästa)
verify_box(Line, Line, CheckedLines) :- 
        member([Line], CheckedLines). 

% box hantering - kollar om boxen har rätt struktur när boxen har mer än en rad 
verify_box(Start, End, CheckedLines) :- 
        member([Start | Tail], CheckedLines), 
        last(Tail, End).

% premisser 
check_line(Prems, _, [_, Formula, premise]) :- 
        member(Formula, Prems).                                                 

% box hantering - öppnar en box för antagelse 
check_line(Prems, CheckedLines, [FirstLine | BoxRest]) :- 
        FirstLine = [_, _, assumption], 
        append(CheckedLines, [FirstLine], Result),
        examine_proof(Prems, BoxRest, Result). 

% copy-regeln (copy(x))
check_line(_, CheckedLines, [_, Formula, copy(X)]) :-                            
        member([X, Formula, _], CheckedLines).  
                       
% alla regler 

% and - introduktion (andint(x,y))
check_line(_, CheckedLines, [_, and(A,B), andint(X,Y)]) :-
        member([X,A,_], CheckedLines),
        member([Y,B,_], CheckedLines).

% and- elimination 1 ( andel1(x))
check_line(_, CheckedLines, [_, A, andel1(X)]) :-
        member([X,and(A,_),_], CheckedLines). 

% and- elimination 2 ( andel2(x))
check_line(_, CheckedLines, [_, B, andel2(X)]) :-
        member([X,and(_,B),_], CheckedLines). 

% or- introduktion 1 (orint1(x))
check_line(_, CheckedLines, [_, or(A,_), orint1(X)]) :-
        member([X,A,_], CheckedLines).

% or- introduktion 2  (orint2(x))
check_line(_, CheckedLines, [_, or(_,B), orint2(X)]) :-
        member([X,B,_], CheckedLines).

% or - elimination (orel(x,y,z,u,w))
check_line(_, CheckedLines, [_, C, orel(X, Y, Z, U, W)]) :- 
        member([X, or(A,B),_], CheckedLines),
        verify_box([Y, A, assumption], [Z, C, _], CheckedLines),
        verify_box([U, B, assumption], [W, C, _], CheckedLines).

%implikation-introduktion (impint(x,y))
check_line(_, CheckedLines, [_, imp(A,B), impint(X,Y)]) :-
        verify_box([X, A, assumption], [Y, B, _], CheckedLines). 

%modus ponens (impel(x,y))
check_line(_, CheckedLines, [_, B, impel(X,Y)]) :- 
        member([X, A, _], CheckedLines), 
        member([Y, imp(A,B), _], CheckedLines). 

%negation-introduktion (negint(x,y))
check_line(_, CheckedLines, [_, neg(A), negint(X,Y)]) :- 
        verify_box([X, A, assumption], [Y, cont, _], CheckedLines). 

%negation-elimination
check_line(_, CheckedLines, [_, cont, negel(X,Y)]) :-
        member([X,A,_], CheckedLines),
        member([Y,neg(A),_], CheckedLines).

%falsum (contel(x))
check_line(_, CheckedLines, [_, _, contel(X)]) :- 
        member([X, cont, _], CheckedLines). 

%negation-negation-introduktion
check_line(_, CheckedLines, [_,neg(neg(A)),negnegint(X)]):-
        member([X,A,_], CheckedLines).

%negation-negation-elimination
check_line(_, CheckedLines, [_,A,negnegel(X)]):-
        member([X,neg(neg(A)),_], CheckedLines).

%modus-tollens 
check_line(_,CheckedLines, [_,_,mt(X,Y)]) :-
        member([X, imp(_,B),_], CheckedLines),
        member([Y, neg(B),_], CheckedLines).

%proof by contradiction - bevis genom motsägelse (pbc(x,y))
check_line(_, CheckedLines, [_, A, pbc(X, Y)]) :- 
        verify_box([X, neg(A), assumption], [Y, cont, _], CheckedLines).

%law of excluded middle - (lem)
check_line(_,_,[_, or(A,neg(A)), lem]).