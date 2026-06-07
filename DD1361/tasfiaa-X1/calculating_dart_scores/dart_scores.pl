%läs in filen kattio.pl
:- [kattio].

% hjälpfunktioner, sätter för respektive sektion

dart(single, I, I) :- between(1,20,I).

dart(double, I, Score) :- 
    between(1,20,I), 
    Score is 2*I. 

dart(triple, I, Score) :- 
    between(1,20,I), 
    Score is 3*I. 

%räkna ut kasten
calculate(Target, [(Section1, I1)]) :-
    dart(Section1, I1, Score1), 
    Score1 =:= Target. 

calculate(Target, [(Section1, I1), (Section2, I2)]) :-
    dart(Section1, I1, Score1), 
    dart(Section2, I2, Score2), 
    Score1 +Score2 =:= Target. 

calculate(Target, [(Section1, I1), (Section2, I2), (Section3, I3)]) :-
    dart(Section1, I1, Score1), 
    dart(Section2, I2, Score2), 
    dart(Section3, I3, Score3), 
    Score1 +Score2 + Score3 =:= Target. 

%skriva ut 
print_answer([]).

print_answer([(Section, I)| Rest] ):-
    write(Section), 
    write(' '), 
    write(I), 
    nl, 
    print_answer(Rest). 

% main 
main :- 
    read_int(Target), 
    calculate(Target, Answer), 
    !,
    print_answer(Answer).
main :- 
    write(impossible),
    nl. 
