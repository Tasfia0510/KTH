# Uppgift 1 (4p) — Unifiering

Betrakta följande fråga till ett Prologsystem:
```prolog
1 ? - T = f (a ,Y , Z ) , T = f (X ,X , b ) .
```

Vilka bindningar presenteras som resultat? Ge en kortfattad förklaring till
ditt svar!

#### Svar 
X = a 

Y = a 

Z = b 

T = (a, a, b)  

- Genom unifiering och "=" operatorn sätter vi T lika med varandra: f (a ,Y , Z ) = f (X ,X , b ) eftersom de är lika 
- Index 0 är satt till a och index 2 är satt till b 
- Eftersom a = X och Y = X så är X = Y = a 

--- 

# Uppgift 2 (6p) — Representation
En lista är en representation av sekvenser där den tomma sekvensen representeras av [] och en sekvens bestående av tre heltal 1, 2, 3 representeras av `[1,2,3]` eller i kanonisk syntax `’.’(1,’.’(2,’.’(3,[]))).`

Den exakta definitionen av en lista är:
```prolog
1 list ([]) .
2 list ([ H | T ]) : - list ( T ) .
```

Definiera predikatet remove_duplicates/2 som givet en lista returnerar alla element i samma ordning, men utan upprepningar. Till exempel:
```prolog
1 ? - remove_duplicates ([1 ,2 ,3 ,2 ,4 ,1 ,3 ,4] , E ) .
2 E = [1 ,2 ,3 ,4]
```

Förklara varför man kan kalla detta predikat för en funktion!

#### Svar

- Predikatet kan kallas för en funktion eftersom den beter sig som en.

- Vi skickar in en lista som tar in argument och sen med hjälp av en metod så returnerar det ett resultat (gör en ny lista). 

- Den returnerar ingen boolean utan en sekvens istället. 

---

# Uppgift 3 (6p) — Rekursion
Definiera predikatet `partstring/3` som, givet en lista, genererar en delsekvens
av längd `L` som förekommer konsekutivt i listan. Alla möjliga svar ska kunna
genereras med backtracking.

Exempel:

```prolog
1 ? - partstring ([1 ,2 ,3 ,4] , L , F ) .
2 F = [4] , L = 1 ;
3 F = [1 ,2] , L = 2 ;
4 F = [1 ,2 ,3] , L = 3 ;
5 F = [2 ,3] , L = 2 ;
6 ...
```

(Notera att `[1,2,4]` inte är giltigt eftersom 2 och 4 inte är konsekutiva
i listan.)

#### Anteckningar: Måste använda ; för backtracking

---

# Uppgift 4 (8p) — Representation
Definiera en representation av grafer där varje nod har ett unikt namn (en konstant) och grannarna är indikerade. 

Definiera sedan ett predikat som tar fram en väg som en lista av nodnamn från nod A till nod B, utan att passera någon nod mer än en gång. Om flera vägar finns ska de kunna genereras en efter en med backtracking. 
