package bus_numbers;

import java.util.*;

public class bus_numbers{
    //kontrollerar om b följer direkt efter a 
    public static boolean follows(int a, int b) {
        return b == a+1;
    }
    /**
     * motsvarar sublist och takegroup
     * input: [141 142 143 174 175 180], output: [[141 142 143], [174, 175], [180]]
     * @param lines tar hela listan med alla buslines
     * @return en lista med listor - groups 
     */
  
    public static List<List<Integer>> makeSublist(List<Integer> lines) {
        List<List<Integer>> groups = new ArrayList<>();
        
       for(int i=0; i<lines.size(); i++) {
        List<Integer> currGroup = new ArrayList<>();
        currGroup.add(lines.get(i));    // lägger till första talet i listan

        // om nästa tal b direkt följer direkt efter a så lägger den till och flyttar fram ett steg för att ta nästa tal och jämföra
        while (i +1 < lines.size() && follows(lines.get(i), lines.get(i+1))) {
            currGroup.add(lines.get(i+1));
            i++;
        }
        groups.add(currGroup);  // när gruppen är klar lägger den in den i groups 
       }
       return groups;
    }
    /**
     * motsvarar fixformat
     * om gruppen är större eller lika med 3 så tar den första och sista talet och separerar de med -
     * annars lägg till alla separata tal i listan med hjälp av string.valueOf som omvandlar till string 
     * @param group alla grupper som finns i listan
     * @return resultatet
    */
    public static List<String> fixFormat(List<Integer> group) {
        List <String> result = new ArrayList<>();

        if(group.size() >=3) {
            result.add(group.get(0) + "-" + group.get(group.size()-1));
        } else {
            for(int i =0; i<group.size(); i++) {
                result.add(String.valueOf(group.get(i)));
            }
        }
        return result;
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int n = scanner.nextInt(); // n

        List<Integer> listBuslines = new ArrayList<>(); // läser in busslinjerna och lägger in de en och en i listan
        for(int i =0; i<n; i++) {
            listBuslines.add(scanner.nextInt());
        }

        Collections.sort(listBuslines); // sortera

        List<List<Integer>> grouped = makeSublist(listBuslines); //gruppera 

        List<String> answer = new ArrayList<>();  // formattera rätt 
        for(int i=0; i<grouped.size(); i++) {
            answer.addAll(fixFormat(grouped.get(i)));
        }
        System.out.println(String.join(" ", answer));   // skriv ut alla buslines med ett mellanrum mellan de
       
        scanner.close();
    }
}