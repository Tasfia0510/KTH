import java.io.IOException;
import java.util.*;
import java.util.regex.*;

public class leona {
    // UPPGIFT 3 - lexikal analys


    /**
    * klass med alla tokens - en klass med bara namn på konstanter 
    * 'static final' - 'static' betyder att de tillhör klassen utan objekt, så vi kan lättare komma åt dem  
    * medan 'final' håller dem oförändrade 
    */
    static class TokenType {
        static final String FORW = "FORW";
        static final String BACK = "BACK";
        static final String LEFT = "LEFT";
        static final String RIGHT = "RIGHT";
        static final String UP = "UP";
        static final String DOWN = "DOWN";
        static final String COLOR = "COLOR";
        static final String REP = "REP";
        static final String ERROR = "ERROR";
        static final String PERIOD = "PERIOD";
        static final String QUOTE = "QUOTE";
        static final String DECIMAL = "DECIMAL";
        static final String HEX = "HEX";
    }

    static class Token {
        // fält 
        String type;  
        String value; // för decimal, hex 
        int row; // för error message  

        // konstruktor 
        Token(String type, String value, int row) {
            this.type = type;
            this.value = value;
            this.row = row; 
        }
    }

    /**
     * lexikal analys är processen som omvandlar en sekvens av tecken till en sekvens av tokens 
     */
    static class lexerAnalysis {
        public List<Token> tokens = new ArrayList<>();

        /**
         * språket är case insensitive - spelar ingen roll med liten eller stor bokstav
         * men vi har hårdkodat med stora bokstäver så vi omvandlar till det  
        */
        public lexerAnalysis(String text) {
            makeTokens(text.toUpperCase());
        }

        // Definierar regex mönstret
        // regex för java: https://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html
        public void makeTokens(String text) {
        // %[^\\n]* - matchar alla tecken (i en kommentar) utom nyrad hur många gånger som helst, behövs för att vi ska kunna matcha kommentarer direkt efter ett kommando 
        // (?=\\s) - lookahead (?=..) tillåter oss att matcha ett mellanrum mellan ett kommando och argument, ex: FORW 12 och inte FORW12

    String pattern = 
        "(%.*?)(?=\\n|$)"                   // grupp 1 tillåter kommentarer                   
        + "|(\\.)"                          // grupp 2 PERIOD               
        + "|(FORW)(?=\\s|%[^\\n]*)"         // grupp 3 FORW med whitespace och sen kommentar på samma rad     
        + "|(BACK)(?=\\s|%[^\\n]*)"         // grupp 4      
        + "|(LEFT)(?=\\s|%[^\\n]*)"         // grupp 5    
        + "|(RIGHT)(?=\\s|%[^\\n]*)"        // grupp 6     
        + "|(UP)"                          // grupp 7       
        + "|(DOWN)"                         // grupp 8      
        + "|(COLOR)(?=\\s|%[^\\n]*)"        // grupp 9    
        + "|(REP)(?=\\s|%[^\\n]*)"          // grupp 10     
        + "|(#[0-9A-F]{6})"                 // grupp 11 HEX       
        + "|(\")"                           // grupp 12 QUOTE  
        + "|([1-9][0-9]*)(?=\\s|\\.|%[^\\n]*)"       // grupp 13 DECIMAL
        + "|(\\s)"                          // grupp 14               
        + "|([^\\s])";                      // grupp 15 ERROR - allt annat ska ge det 
    
    Pattern p = Pattern.compile(pattern); // kompilerar regexen till något som java kan tolka 
    Matcher m = p.matcher(text); // det som försöker matcha våran input med våran regex 
    
    int row = 1;
    
     while(m.find()) {
                if (m.group(1) != null) {
                        // om det är kommentarer fortsätt
                }else if (m.group(2) != null) {
                    tokens.add(new Token(TokenType.PERIOD, ".", row));
                } else if (m.group(3) != null) {
                    tokens.add(new Token(TokenType.FORW, "FORW", row));
                } else if (m.group(4) != null) {
                    tokens.add(new Token(TokenType.BACK, "BACK", row));
                } else if (m.group(5) != null) {
                    tokens.add(new Token(TokenType.LEFT, "LEFT", row));
                } else if (m.group(6) != null) {
                    tokens.add(new Token(TokenType.RIGHT, "RIGHT", row));
                } else if (m.group(7) != null) {
                    tokens.add(new Token(TokenType.UP, "UP", row)); 
                } else if (m.group(8) != null) {
                    tokens.add(new Token(TokenType.DOWN, "DOWN", row));
                } else if (m.group(9) != null) {
                    tokens.add(new Token(TokenType.COLOR, "COLOR", row));
                } else if (m.group(10) != null) {
                    tokens.add(new Token(TokenType.REP, "REP", row));
                } else if (m.group(11) != null) {
                    tokens.add(new Token(TokenType.HEX, m.group(11), row));
                } else if (m.group(12) != null) {
                    tokens.add(new Token(TokenType.QUOTE, m.group(12), row));            
                } else if (m.group(13) != null) {
                     tokens.add(new Token(TokenType.DECIMAL, m.group(13), row));      
                } else if (m.group(14) != null) {
                    // whitespace fortsätt (whitespace matchas men vi gör inget med det)  
                } else if (m.group(15) != null) {
                    tokens.add(new Token(TokenType.ERROR, m.group(15), row)); 
                }

                // räknar rader så att vi kan skriva vart vi ska ha syntaxfel
                for(int i= 0; i< m.group().length(); i++) {
                    if (m.group().charAt(i) == '\n') {
                        row++;
                    }
                }
                
            }
        }
    }

    // Uppgift 4 - parser och syntaxträd 

    /**
     * Denna klass är till för att skapa syntaxträdet
     */

    static class Node{
        String name;
        String value;
        List <Node> children = new ArrayList<>();

        Node(String name, String value) {
            this.name = name;
            this.value = value;
        }

        void print(String space) {
            // om noden har ett värde som inte är tomt printa ut det
            if(value != null && !value.equals("EPSILON")) {
                System.out.println(space + name + "(" + value + ")");
                // om värdet är tomt skriv bara ut epsilon
            } else if(value != null && value.equals("EPSILON")) {
                System.out.println(space + "EPSILON");
            } else {
                System.out.println(space + name);
            }
            
            for(int i =0; i< children.size(); i++) {
                children.get(i).print(space + " ");
            }
        }

    }
    /**
     * Denna klass är till för att skapa parsern 
     * En parser tar listan av tokens från lexern (meningsfulla tokens) och kollar om de följer grammatiken. 
     * Rekursiv medåkning tillåter oss att konstruera en effektiv parser baserat på vår grammatik genom att välja den vänstra ickeslutsymbolen
     */
    static class Parser {
        private List<Token> tokens;
        private int tokenPos = 0;

        Parser(lexerAnalysis lexer) {
            this.tokens = lexer.tokens;
        }

        // titta på nuvarande token utan att äta upp den 
        Token current() {
            return tokens.get(tokenPos);
        }

        // advance går vidare till nästa token
        void advance() {
            tokenPos++;
        }

        /**
         * check() matchar en token, "äter" upp den och returnerar nuvaranda token 
         * utdata kravet att felmeddelande ska skrivas ut om det är av fel typ 
         */
        Token check(String type){
            if(tokenPos >= tokens.size()) {
                error();
            }

            Token currentT = current();

            if(!(type.equals(currentT.type))) {
                error();
            }
            advance();
            return currentT;
        }

        void error() {
            int errorRow;
            if(tokenPos < tokens.size()) {
                errorRow = tokens.get(tokenPos).row;
            } else if (!tokens.isEmpty()) {
                errorRow = tokens.get(tokens.size() - 1).row;
            } else {
                errorRow = 1;
            }
            throw new IllegalArgumentException("Syntaxfel på rad " + errorRow); 
        }

        // <F> ::= <F1>  <F>  |  EPSILON
        // logik: tittar om nuvarande token kan börja med F1 annars tomt 
        Node ParseF(){
            if (tokenPos >= tokens.size()) {
                return new Node ("F", "EPSILON");
            }

            String type = current().type; // läser alltid endast en token (rekursiv medåkning)

            if(type.equals(TokenType.FORW) || type.equals(TokenType.BACK) || type.equals(TokenType.LEFT) || 
            type.equals(TokenType.RIGHT) || type.equals(TokenType.UP) || type.equals(TokenType.DOWN) ||
            type.equals(TokenType.COLOR) || type.equals(TokenType.REP)) {

                Node newNode = new Node ("F", null);
                newNode.children.add(ParseF1()); // först F1 (den vänstra ickeslutsymbolen)
                newNode.children.add(ParseF()); // sen resten (F), rekursivt anrop till sig själv
                return newNode;
            }

            if(type.equals(TokenType.ERROR)) {
                // ingen backtracking: för produktionsreglerna F, F1 etc får vi error direkt om ingen regel matchas (FORW, BACK, etc), så vi kan inte gå tillbaka och prova något annat
                error();
            }
            return new Node ("F", "EPSILON");
        }

        // <F1> ::= <F2> DECIMAL PERIOD | <F3> PERIOD | <F4> PERIOD | <REP> 
        Node ParseF1() {
            String type = current().type; 
            Node node = new Node("F1", null);
            
            // Om F2 så titta och lägg till som en node, både F2, decimal och period
            // <F2> DECIMAL PERIOD 
            if(type.equals(TokenType.FORW) || type.equals(TokenType.BACK) || type.equals(TokenType.LEFT) || type.equals(TokenType.RIGHT) ) {
                node.children.add(ParseF2());
                Token decimal = check(TokenType.DECIMAL); 
                node.children.add(new Node("DECIMAL", decimal.value));
                check(TokenType.PERIOD); 
                node.children.add(new Node("PERIOD", "."));

            } else if (type.equals(TokenType.UP) || type.equals(TokenType.DOWN)){
                // <F3> PERIOD
                node.children.add(ParseF3());
                check(TokenType.PERIOD);
                node.children.add(new Node("PERIOD", "."));

            } else if (type.equals(TokenType.COLOR)) {
                // <F4> PERIOD
                // blir lite upprepning men grammatiken blir mer strukturerd på detta sätt att ha COLOR HEX separat från UP, DOWN
                node.children.add(ParseF4());
                check(TokenType.PERIOD);
                node.children.add(new Node("PERIOD", "."));

            } else if (type.equals(TokenType.REP)) {
                // <REP>
                node.children.add(ParseREP());
            }
            else {
                error();
            }
            return node;
        }

        // <F2> ::= FORW | BACK | LEFT | RIGHT
        Node ParseF2() {
            Token t = current();

            if(t.type.equals(TokenType.FORW) || t.type.equals(TokenType.BACK) || t.type.equals(TokenType.LEFT) || t.type.equals(TokenType.RIGHT)) {
                advance();
                return new Node("F2", t.value);
            }
            error();
            return null; 
        }

        // <F3> ::= UP | DOWN 
        Node ParseF3() {
            Token t = current();

            if(t.type.equals(TokenType.UP) || t.type.equals(TokenType.DOWN)) {
                advance();
                return new Node("F3", t.value);
            }
            error();
            return null; 
        }

        // <F4> ::= COLOR HEX
        Node ParseF4() {
            check(TokenType.COLOR);
            Token hex = check(TokenType.HEX);

            return new Node("F4", hex.value);
        }

        // <REP> ::= REP DECIMAL <REPS>
        Node ParseREP() {
            Node node = new Node("REP", null);
            check(TokenType.REP);
            
            Token num = check(TokenType.DECIMAL);
            node.children.add(new Node("DECIMAL", num.value));

            node.children.add(ParseREPS());
            return node; 
        }

        // <REPS> ::= <F1> | QUOTE <F1> <F> QUOTE
        Node ParseREPS() {
            Node node = new Node("REPS", null);
            if(current().type.equals(TokenType.QUOTE)) {
                check(TokenType.QUOTE);
                node.children.add(ParseF1());
                node.children.add(ParseF());
                
                // måste kolla att det avslutar med en QUOTE om det börjar med en, annars syntaxfel 
                //if(tokenPos >= tokens.size()) {
                    //error();
                //}

                check(TokenType.QUOTE);
            }
            else {
                node.children.add(ParseF1());
            }
            return node;
        }

    }


    // UPPGIFT 5

    /**
     * Helper klass för segment format 
     */
     static class Segment{
        double x1, x2, y1, y2;
        String color; 

        Segment(double x1, double y1, double x2, double y2, String color) {
            this.x1 = x1;
            this.y1 = y1;
            this.x2 = x2;
            this.y2 = y2;
            this.color = color;
        }
    }

    /**
     * Fixa tillstånd hos leona så att den kan utföra handlingarna enligt instruktionerna 
     */
    static class LeonaState{
        // start tillstånd 
        double x = 0.0;
        double y = 0.0;
        double angle = 0.0;
        String color = "#0000FF";
        boolean pen_down; // om true = pennan ritar, om false = pennan flyttar 
        

        List<Segment> segments = new ArrayList<>();
 
        void moveForwards(double d) {
            double radianer = Math.toRadians(angle); // gör om till radianer istället för att göra pi / 180 grader
            double x2 = x + d* Math.cos(radianer);
            double y2 = y + d* Math.sin(radianer);

            // när pennan är nere ska den ritas
            if(pen_down) {
                Segment s = new Segment(x, y, x2, y2, color);
                segments.add(s);

            }

            // uppdatera position 
            x = x2;
            y = y2; 
        }

        void moveBackwards(double d) {
            moveForwards(-d);
        }

        void moveLeft(double degrees) {
            angle = (angle + degrees ) % 360;
        } 

        void moveRight(double degrees) {
            angle = (angle - degrees) % 360;
        }

        void penUp() {
            pen_down = false;
        }

        void penDown() {
            pen_down = true; 
        }

        void getColor(String hex_color) {
            if (!hex_color.startsWith("#")) {
                color = "#" + hex_color;
            } else {
                color = hex_color;
            }
        }

    }

    /**
     * Klass som översätter syntaxträdet till linje segment 
     */
    static class Execute {
        // tillstånd som håller koll på Leonas aktuella tillstånd 
        private LeonaState state;

        Execute() {
            this.state = new LeonaState(); 
        }

        // huvud funktion - början exekvera från roten (F)
        public void execute(Node root) {
            execute_F(root);
            printSegment();

        }

        public void execute_F(Node node) {
            if (node == null) {
                return; 
            }
            if (node.name.equals("F") && node.value != null && node.value.equals("EPSILON")) {
                return; 
            }

            // kör F1 (index 0)
            if (node.children.size() >= 1) { // finns första barnet (F1)
                execute_F1(node.children.get(0));
            }

            // kör resten F (index 1)
            if (node.children.size() >= 2) { // finns andra barnet (F), här har vi den rekursiva delen
                execute_F(node.children.get(1));
            }
        }

        public void execute_F1(Node node) {
            // en node här är F1 nod med barn t.ex F2, DECIMAL, PERIOD etc 
            Node firstChild = node.children.get(0);
            if(firstChild.name.equals("F2")) {
                String getCommand = firstChild.value; // FORW, BACK, etc 
                Node decimalNode = node.children.get(1); // andra barnet ger DECIMAL för F2
                double value = Double.parseDouble(decimalNode.value);

                if(getCommand.equals("FORW")) {
                    state.moveForwards(value);
                } else if (getCommand.equals("BACK")) {
                    state.moveBackwards(value);
                } else if (getCommand.equals("LEFT")) {
                    state.moveLeft(value);
                } else if (getCommand.equals("RIGHT")) {
                    state.moveRight(value);
                }

            } else if (firstChild.name.equals("F3")) {
                String getCommand = firstChild.value;

                if (getCommand.equals("UP")) {
                    state.penUp(); 
                } else if (getCommand.equals("DOWN")) {
                    state.penDown();
                }
            } else if (firstChild.name.equals("F4")) {
                state.getColor(firstChild.value);
            } else if (firstChild.name.equals("REP")) {
                executeREP(firstChild);
            }

     }

     /**
      * Hur många gånger vi upprepar något kommando 
      */
        // kör något kommando r antal gånger (decimal, heltal)
        public void executeREP(Node rep) {
            Node amount = rep.children.get(0); // barn 1, index 0, första noden ger antal gånger vi ska köra kommandot 
            int approx = Integer.parseInt(amount.value);

            Node repCommand = rep.children.get(1); // barn 2, index 1, vilket kommando som ska upprepas

            for (int i = 0; i < approx; i++) {
                executeREPS(repCommand);
            }
        }

        /**
         * Köra det som ska upprepas, antingen ett kommando eller en sekvens inom quotes "", får inte vara tom
         */
        public void executeREPS(Node reps) {
            Node firstChild = reps.children.get(0);
            
            if (firstChild.name.equals("F1")) {
                execute_F1(firstChild);
                
                // kör F1 (barn 2)
                if(reps.children.size() > 1) {
                    execute_F(reps.children.get(1));
                }
            
            }
        }

        public void printSegment() {
            for (int i = 0; i < state.segments.size(); i++) {
                Segment s = state.segments.get(i);
                System.out.printf("%s %.4f %.4f %.4f %.4f\n", s.color, s.x1, s.y1, s.x2, s.y2);
            }
        }
    }
    
// testa 
public static void main(String[] args) throws IOException {

    String input = new String(System.in.readAllBytes());

    lexerAnalysis lexer = new lexerAnalysis(input);

    /**
     * for (Token t : lexer.tokens) {
        System.out.println(t.type + " " + t.value + " row:" + t.row);
        }

    System.out.println(""); 
     */

    try {
        // köra parsern 
        Parser parser = new Parser(lexer);
        Node tree = parser.ParseF();
        //tree.print("");
        
        // om det finns token kvar så är det fel, ex ett extra citattecken
        if(parser.tokenPos < lexer.tokens.size()) {
            parser.error();
        }
        // exekvera
        Execute execute = new Execute();
        execute.execute(tree);

        } catch (IllegalArgumentException e) {
            System.out.println(e.getMessage());
        }
        
    } 
}