/* Kodskelett för labb S3 i DD1361 Programmeringsparadigm
 *
 * Författare: Per Austrin, Tasfia Alam, Carolina Frisk Garcia
 * 
 * Syfte med uppgiften:
 * - Hitta alla tillstånd som accepterar av en automat (våra testfall), upp till en gräns
 */
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

public class DFA {

	// alla tillstånd
	int DFA_stateCount; 
	int DFA_startState;

	// Q - lista med alla tillstånd ex: [0, 1, 2, 3, 4, 5]
	List<Integer> states = new ArrayList<Integer>(); 
	// F -  lista med accepterande tillstånd
	List<Integer> acceptingStates = new ArrayList<Integer>(); 
	// δ - två dimisionell array, transitions[from][tecken] = to (tillståndet vi ska till)
	int[][] transitions;  

	/**
	 * klass som håller koll på vilket tillstånd vi är i, sträng, vi har byggt upp, och djup
	 * djupet är viktigt att kolla på pga bfs (breadth first search)
	 */
	public static class Info {
		int state;
		String string;
		int depth; 

		Info(int state, String string, int depth) {
			this.state = state; 
			this.string = string;
			this.depth = depth;
		}
	}

	/**
	 * skapar automat med stateCount tillstånd
	 * låter alla övergångar vara -1 från början (alltså inga övergånagr just nu)
	 * 
	 * @param stateCount totalt antal tillståmd 
	 * @param startState starttillstånd q0
	 */
	public DFA(int stateCount, int startState) {
		DFA_stateCount = stateCount;
		DFA_startState = startState; 

		// lägga till alla tillstånd i DFA
		for (int i = 0; i < stateCount; i++) {
			states.add(i);
		}
		// finns totalt 128 ASCII tecken
		// eftersom DFA är deterministisk funkar det
		transitions = new int[stateCount][128];
		for (int i = 0; i < stateCount; i++) {
			for (int j = 0; j < 128; j++) {
				transitions[i][j] = -1; // -1 betyder ingen transition finns 
			}
		} 
	}

	/**
	 * Markerar ett tillstånd som accepterande
	 *  
	 * @param state tillståndet som är accepterande
	 */
	public void setAccepting(int state) {
		acceptingStates.add(state);
	}

	/**
	 * Anger att det finns en övergång från from till to med tecknet char. (lägg till övergång)
	 * 
	 * @param from tillståndet vi börjar i
	 * @param to tillståndet vi går till
	 * @param c tecknet som triggar övergången (som vi läser på testfall)
	 */
	public void addTransition(int from, int to, char c) {
		transitions[from][c] = to;
	}

	/**
	 * 
	 * returnerar olika strängar som automaten accepterar, upp till 5000 tecken
	 * använder BFS (breadth first search)
	 * 
	 * @param maxCount max antal strängar att vi ska returnera
	 * @return lista med accepterande strängar
	 */
	public List<String> getAcceptingStrings(int maxCount) {
		// bfs använder en queue (FIFO) för att hålla koll på alla noder vi har besökt
		List<String> result = new ArrayList<>();
		Queue<Info> queue = new LinkedList<>();
		// räknar hur många gånger varje tillstånd besöks
		int[] visitedCount = new int [DFA_stateCount];

		// starttillstånd, börjar på djup 0
		queue.add(new Info(DFA_startState, "", 0));
		//starttillståndet har besökts
		visitedCount[DFA_startState]++;

		while (!queue.isEmpty() && result.size() < maxCount) {
			Info current = queue.poll(); // ta ut första ur kön

			// om current tillstånd accepterar, lägger vi till i strängen
			if (acceptingStates.contains(current.state))
			result.add(current.string);

			// max 5000 accepterande tillstånd (från uppgiftsbeskrivningen)
			if (current.depth >= 5000) {
				continue; 
			}

			// prova alla tecken 
			for (int c = 0; c < 123; c++) {
				int nextState = transitions[current.state][c];
				if (nextState != -1 && visitedCount[nextState] < maxCount) {
					visitedCount[nextState]++; 	// tillåter besök endast under maxCount, ökar räknaren till nästa tillstånd
					
					/**
					 * lägger till info objektet:
					 * 1. nästa tillstånd vi ska till, 
					 * 2. gamla sträng + nya char (bygger upp)
					 * 3. går till nästa djup
					 */
					queue.add(new Info(nextState, current.string + (char)c, current.depth + 1));
				}
			}

		}
		return result;
	}
}
