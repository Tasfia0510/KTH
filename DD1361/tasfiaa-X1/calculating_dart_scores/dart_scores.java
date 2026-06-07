package calculating_dart_scores;

import java.util.*;

public class dart_scores {
    
    /**
     * motsvarar dart/3 (single, double, triple)
     * prolog: hanteras varje sektion som ett separat predikat med egna regler 
     * java: alla tre fallen samlas under en metod med if satster
     * @param section är kasttypen: "single", "double", "tripe"
     * @param i är sektionsvärde (1-20)
     * @return poängen för varje kast 
     */
    int score(String section, int i) {
        if (section.equals("single")) {
            return i;
        }
        if (section.equals("double")) {
            return 2*i;
        }
        return 3*i; 
    }

    /**
     * motsvarar calculate/2
     * prolog: definerar tre separata regler för 1,2 och 3 kast och provar alla kombinationer av sections och poäng med backtracking
     * java: saknar backtracking, alla kombinationer itereras manuellt med nästlade for loops
     * 
     * @param target poäng vi har fått
     * @return output, lista med sections och poäng t.ex ["triple 19", "double 15", "single 9"] eller "impossible"
     */
    ArrayList<String> calculate(int target) {
        String[] sections = {"single", "double", "triple"};

        // ett kast
        for (int s1 = 0; s1 < sections.length; s1++) {
            for (int i1 = 1; i1 <= 20; i1++) {
                if (score(sections[s1], i1) == target) {
                    ArrayList<String> result = new ArrayList<String>();
                    result.add(sections[s1] + " " + i1);
                    return result;
                }
            }
        }

        // ett och två kast
        for (int s1 = 0; s1 < sections.length; s1++) {
            for (int i1 = 1; i1 <= 20; i1++) {
                for (int s2 = 0; s2 < sections.length; s2++) {
                    for (int i2 = 1; i2 <= 20; i2++) {
                        if (score(sections[s1], i1) + score(sections[s2], i2) == target) {
                            ArrayList<String> result = new ArrayList<String>();
                            result.add(sections[s1] + " " + i1);
                            result.add(sections[s2] + " " + i2);
                            return result;
                        }     
                    }
                }
            }
        }

        // ett, två och tre kast
        for (int s1 = 0; s1 < sections.length; s1++) {
            for (int i1 = 1; i1 <= 20; i1++) {
                for (int s2 = 0; s2 < sections.length; s2++) {
                    for (int i2 = 1; i2 <= 20; i2++) {
                        for (int s3 = 0; s3 < sections.length; s3++) {
                            for (int i3 = 1; i3 <= 20; i3++) {
                                if (score(sections[s1], i1) + score(sections[s2], i2) + score(sections[s3], i3) == target) {
                                    ArrayList<String> result = new ArrayList<String>();
                                    result.add(sections[s1] + " " + i1);
                                    result.add(sections[s2] + " " + i2);
                                    result.add(sections[s3] + " " + i3);
                                    return result;
                                }    
                            }
                        } 
                    }
                }
            }
        } 
        // ingen matchar
        return null;
    }


    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int target = scanner.nextInt();
        dart_scores ds = new dart_scores(); // objekt
        ArrayList<String> answer = ds.calculate(target);

        if (answer == null) {
            System.out.println("impossible");
        } else {
            for (int i = 0; i < answer.size(); i++) {
                System.out.println(answer.get(i));
            }
        }
        scanner.close();
        
    }
}