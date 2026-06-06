//This file written 2024 by Artur Podobas and Pedro Antunes

// For copyright and licensing, see file COPYING */

/* Below functions are external and found in other files. */
extern void print(const char*);
extern void print_dec(unsigned int);
extern void display_string(char*);
extern void time2string(char*,int);
extern void tick(int*);
extern void delay(int);
extern int nextprime( int );

int mytime = 0x5957;
char textstring[] = "text, more text, and even more text!";

/* Assignment 2 -- timer variablar */ 

volatile int* timer_status = (volatile int*) 0x4000020; // address till timer, time out flag  
volatile int* timer_control = (volatile int*) 0x4000024; // kontroll register 
volatile int* timer_periodL = (volatile int*) 0x4000028; // period l 
volatile int* timer_periodH = (volatile int*) 0x400002C; // period h  

volatile int timeoutcount = 0; 

/* Assignment 1g -- Returnerar status för push-knapp */
int get_btn(void) {
volatile int *btn = (volatile int*) (0x040000d0);
int btn_value = *btn;
int and_mask = 0x1; // LSB
return btn_value & and_mask;
}

/* Assignment 1f -- Returnerar status för toggles */
int get_sw(void) {
volatile int* sw = (int*) 0x04000010; // set the address of all the toggle switches
int sw_value = *sw;  //
int and_mask = 0x3FF; // 3ff = 001 111 111 111
return sw_value & and_mask;
}


/* Assignment 1e -- Visar 7-segment display (dvs siffrorna för tiden)*/
void set_displays(int display_number, int value) {
int display_value = 0;

if( display_number < 0 || display_number > 5) {
  print("invalid number");
  return;
}

if ( value < 0 || value > 9) {
  print("invalid value");
  return;
}

// 10 cases för att vi vill ha siffror från 0-9
switch (value) {
  case 0:
    display_value = 64;         // 1 000 000 binary (a,b,c,d,e,f)
    break;
  case 1:
    display_value = 121;        // 1 111 001 binary (b,c)
    break;
  case 2:
    display_value = 36;         // 0 100 100 binary (a,b,d,e,g)
    break;
  case 3:
    display_value = 48;         // 0 110 000 binary (a,b,c,d,g)
    break;
  case 4:
    display_value = 25;         // 0 011 001 binary (b,c,f,g)
    break;
  case 5:
    display_value = 18;         // 0 010 010 binary (a,c,d,f,g)
    break;
  case 6:
    display_value = 2;          // 0 000 010 binary (a,c,d,e,f,g)
    break;
  case 7:
    display_value = 120;        // 1 111 000 binary (a,b,c)
    break;
  case 8:
    display_value = 0;          // 0 000 000 binary (a,b,c,d,e,f,g)
    break;
  case 9:
    display_value = 24;         // 0 011 000 binary (a,b,c,f,g)
    break;
  default:
    display_value = 64;         // låt 64 vara (alltså 0) synas när inget av casen körs
}

int offset = 0x10 * display_number;
volatile int *display_address = (volatile int*) (0x04000050 + offset);
*display_address = display_value;
}

/* Assignment 1c -- funktion som ställer in lamporna*/
void set_leds(int led_mask) {
volatile int *leds = (volatile int*) 0x4000000;
*leds = 0b1111111111 & led_mask; // led mask ger värdet till leds
}

/* Below is the function that will be called when an interrupt is triggered. */
void handle_interrupt(unsigned cause)
{}

/* Add your code here for initializing interrupts. */
/* Assignment 2b -- initialisera timer */ 
void labinit(void) { 

// interrups / timeouts varje 100ms (10 timeouts / s) ==> // 30 000 000 / 10 = 3 000 000 timeouts  
// tolkat det som att klockan visar 10 sekunder efter en sekund 
*timer_periodL = 0xC6C0; // 1100011011000000 för the lower bits (periodL), deferera pekaren 
*timer_periodH = 0x002D; // 0000000000101101 för the higher biths (periodH), deferera pekaren 

// kontroll registret låter oss att stoppa (interrupts)
// bit 3 (STOP) är avstängd, bit2 (START), bit1 (CONT) och bit0 (ITO) är avstängd (0110)
*timer_control = 0x6; // 0b0110 = 6  
} 

//helper function to mask out digit so that it can then be used to display
int get_number(int time, int position) {
int masking = time >> position;
return 0xF & masking;
}

/* Your code goes into main as well as any needed functions. */
int main() {
// Call labinit()
labinit();

/*  Assignment 1d -- Lyser fyra lampor binärt till 15 */
int count_leds = 0;             // counter som räknar LED-kombinationen 
while(count_leds <= 0xF) {
  set_leds(count_leds);
  delay(2);
  count_leds++;
}

volatile int seconds = 0;
volatile int minutes = 0;
volatile int hours = 0;

// Enter a forever loop
while (1) {
volatile int sw_value = get_sw();
volatile int btn_value = get_btn();
volatile int exit_withSwitch = sw_value >>7 & 0x1; // SW0 dvs den första switchen ska avsluta loopen

if(exit_withSwitch) {
     break;
 }

// om knappen är nedtryckt så läser den de två mest signifikatna switcharna 
if (btn_value == 1 ) {
    volatile int determine_displays = sw_value >> 8 & 0x3;
    volatile int read_6lsb = sw_value & 0x3F;

   switch(determine_displays) {
    case 1:
      seconds = read_6lsb;
      break;
    case 2:
      minutes = read_6lsb;
      break;
    case 3:
      hours = read_6lsb;
      break;
    default:
      break;
   }

   //uppdaterar resp display plats
  set_displays(0, seconds % 10);
  set_displays(1, seconds / 10);
  set_displays(2, minutes % 10);
  set_displays(3, minutes / 10);
  set_displays(4, hours % 10);
  set_displays(5, hours / 10);

  // hela tiden i binär form 
  mytime = (hours / 10 << 20) | (hours % 10 << 16) | (minutes / 10 << 12) | (minutes % 10 << 8) | (seconds / 10 << 4) | seconds % 10;

  }

   if (*timer_status & 0x1) {             // Om TO är 1  
    *timer_status = 0;                    // börja räkna om  
    timeoutcount++;                      // kommentera bort alla timeoutcount och en måsvinge på slutet för uppgift b 

  if (timeoutcount == 10) {             
    timeoutcount = 0; 
    
    tick( &mytime );     // Ticks the clock once
    time2string( textstring, mytime ); // Converts mytime to string
    display_string( textstring ); //Print out the string 'textstring'
  }

  volatile int seconds_first = get_number(mytime, 0); //  maska 4 lsb och får entalssifran på sekund
  volatile int second_second = get_number(mytime, 4); // maska 4 lsb och skifta och får tiotalssiffran på sekund
  volatile int minutes_first = get_number(mytime, 8);
  volatile int minutes_second = get_number(mytime, 12);
  volatile int hours_first = get_number(mytime, 16);
  volatile int hours_second = get_number(mytime, 20);

  seconds = second_second * 10 + seconds_first; // får ett set med två tal, alltså antal sek
  minutes = minutes_second * 10 + minutes_first;
  hours = hours_second * 10 + hours_first;


  //om sek eller minuter går upp till 60 så ska den inte fortsätta utan öka minuter resp timmar
  if(seconds >= 60 ) {
    minutes++;
  }
  
  if(minutes >= 60) {
    hours++;
  }

  if (hours == 24) {
    hours = 0; 
  }

  //uppdaterar resp display plats
  set_displays(0, seconds % 10);
  set_displays(1, seconds / 10);
  set_displays(2, minutes % 10);
  set_displays(3, minutes / 10);
  set_displays(4, hours % 10);
  set_displays(5, hours / 10);

mytime = (hours / 10 << 20) | (hours % 10 << 16) | (minutes / 10 << 12) | (minutes % 10 << 8) | (seconds / 10 << 4) | seconds % 10;
 }

 } 

}


