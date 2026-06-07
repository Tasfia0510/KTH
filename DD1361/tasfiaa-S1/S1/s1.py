def dna():          # uppgift 1 - matchar en sträng endast om det bara består av A,C,G,T (DNA)
    # ^ = början av en string
    # [] = karaktär klass, inuti specifierar vi karaktärerna vi vill matcha, endast en matchas
    # ACGT = alla nucleotide bases i DNA, definerar DNA 
    # $ = slutet av en string
    # med både ^ och $ garanterar vi att alla element måste vara A, C, G eller T för att det ska matchas 
    return "^[ACGT]+$"
    
def sorted():       # uppgift 2 
    # * = 0 eller fler matchar med karaktären innan (inga siffror är obligatoriska därav *)
    # t.ex 0 eller flera 9:or 
    # varje siffra får förekomma 0 eller flera gånger men i fallande ordning 
    return "^9*8*7*6*5*4*3*2*1*0*$"

def hidden1(x):     # uppgift 3
    # indata x är strängen som vi vill konstruera ett regex för att söka efter
    # .* = 0 eller mer av vilken karaktär som helst
    # . matchar vilken karaktär som helst
    # * betyder 0 eller fler 
    # tar hänsyn till att strängen kan ha andra tecken än x innan och efter därav ^.* och .*$
    return "^.*" + x + ".*$"

def hidden2(x):     # uppgift 4
    # indata x är strängen som vi vill konstruera ett regex för att söka efter
    # join tar alla element i strängen som är separerade med .* (0 eller flera char) och sätter ihop de enstaka karaktärerna i en sträng
    # t.ex om x = progp separeras det såhär: .*p.*r.*o.*g.*p.*
    return "^.*" + ".*".join(x) + ".*$"

def equation():     # uppgift 5
    # ekvationen kan börja med -+ men måste därefter ha minst en/flera siffror
    # sedan kan det finnas en operator  → då måste det finnas en/flera siffror -  denna sekvens kan finnas noll eller flera gånger
    # sedan kan det finnas ett HL som består av 1 likahetstecken, ett eller flera uttryck som följer samma struktur i VL

    return "^[-+]?\d+([-+*/]\d+)*(=[-+]?\d+([-+*/]\d+)*)?$"

def parentheses():  # uppgift 6
    # finns ett mönster, (...)* betyder 0 eller flera gånger av det som står precis före 
    # så då betyder (...)* att det kan finnas 0,1,2,3… "( )" 
    # endast upp till djup 5 → därav endast 5 höger- "(" och vänster ")" paranteser 
    # "\(" markerar att det är en parentes, för att matcha höger och vänster parantes 
    # + tillåter inte tom sträng 
    return "^(\((\((\((\((\(\))*\))*\))*\))*\))+$"

def sorted3():      # uppgift 7
    # tips: börja med att skriva ett reguljärt uttryck för tre siffror i stigande ordning där den mittersta siffran är t.ex. “4”
    # för 4 → [0-3]4[5-9]
    # för 0-9 → vårt svar
    # kan endast ta emot tal → \d 
    return "^\d*(0[1][2-9]|[0-1]2[3-9]|[0-2]3[4-9]|[0-3]4[5-9]|[0-4]5[6-9]|[0-5]6[7-9]|[0-6]7[8-9]|[0-7]8[9])\d*$"


# Testing
from sys import stdin
import re

def main():
    def hidden1_test(): return hidden1('test')
    def hidden2_test(): return hidden2('test')
    tasks = [dna, sorted, hidden1_test, hidden2_test, equation, parentheses, sorted3]
    print('Skriv in teststrängar:')
    while True:
        line = stdin.readline().rstrip('\r\n')
        if line == '': break
        for task in tasks:
            result = '' if re.search(task(), line) else 'INTE '
            print('%s(): "%s" matchar %suttrycket "%s"' % (task.__name__, line, result, task()))


if __name__ == '__main__': main()

# FRÅGA 1 
# Ja det går nog och vi tror att det kan skrivas med regex och python. 
# Steg 1: Första steget är att ta reda på vad glappet är (1, 2, 3, 4...). 
# Steg 2: Andra steget är att vi kan använda ".{ }" för att få samma mellanrum  
# Steg 3: Tredje steget är att lägga till antal på glappet med join. Sen kan det returnera strängen som matchas. 

# FRÅGA 2
# Ja, det går att kombinera uppgifterna 5 & 6, så länge det är ett begränsat djup  
# Steg 1: En komplicerad och jätte lång lösning är att kopiera in lösning 5 i lösning 6 för varje djup (5 ggr)
# Dock blir detta hårdkodat, man kanske kan göra en liknande approach som i fråga 1, att man listar ut djupet 
# och sen stoppar in det baserad på det istället för att kopiera 

# FRÅGA 3 
# Nej, inte direkt 
# För att kunna generalisera de intilligande siffrorna (så att det inte bara är 3), så behöver man kunna jämföra värden och 
# begränsa dem för att se om tal är mindre eller större vilket inte kan göras av regex, regex matchar mest bara strängar.
# Isåfall kanske man behöver externa funktioner/metoder som inte är regex 
