% ett palindrom kräver att max en bokstav har en udda frekvens, ett tal i mitten
% därför blir det att om det finns flera udda så maste alla tas bort förutom en 
%därför blir svaret antal udda-1 
:- [kattio].

%huvudpredikatet
% tar ett ord, gör om till en lista av karaktärer, sorterar och tar bort dubletter, räknar unika udda bokstäver
% svaret blir antalet udda -1 då en får vara i mitten
check(Word, Output) :- 
    string_chars(Word, ListChars), %skapar en lista av karaktarer
    sort(ListChars, UniqueChars), %sorterar och tar bort dubletter
    count_odd(UniqueChars, ListChars, Odd),
    Output is max(0, Odd-1). 

%räknar hur manga bokstaver som har udda antal
count_odd([], _, 0).

%rekursivt - tar första bokstaven, räknar frekvensen, räknar rekursivt för resten, lägger till om frekvensen är udda
count_odd([First|Rest], ListChars, Odd) :-
    count(First, ListChars, Freq),
    count_odd(Rest, ListChars, RestOdd),
    add_odd(Freq, RestOdd, Odd).

% rekursivt räknar ut antal av en viss bokstav
count(_, [], 0).

%om första bokstaven matchar current, så räkna den
count(Current, [Current|Letters], Freq) :-
    count(Current, Letters, Freq1), 
    Freq is Freq1 +1.

%om inte - hoppa över och fortsätt vidare med resten av bokstäverna 
count(Current, [Other | Letters], Freq) :-
    Current \= Other, 
    count(Current, Letters, Freq).

%lägg till 1 i Odd om antalet av en bokstav är udda
add_odd(Freq,Rest, Odd) :-
    1 is Freq mod 2, 
    !,                  % cut, om det är udda så ska den inte ga tillbaka, sluta backtracking till add_odd(_rest, rest)
    Odd is Rest +1.

add_odd(_,Rest, Rest). 

main :- 
    read_string(Word), 
    check(Word, Output), 
    write(Output).