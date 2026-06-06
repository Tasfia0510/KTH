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
extern int enable_interrupt(void);

int mytime = 0x5957;
char textstring[] = "text, more text, and even more text!";

/* Assignment 3b --- lägga till int prime */
int prime = 1234567;

/* Assignment 2 -- timer variablar */ 
volatile int* timer_status = (volatile int*) 0x4000020; // address till timer, time out flag  
volatile int* timer_control = (volatile int*) 0x4000024; // kontroll register 
volatile int* timer_periodL = (volatile int*) 0x4000028; // period l 
volatile int* timer_periodH = (volatile int*) 0x400002C; // period h  

volatile int timeoutcount = 0; 

//1g
int get_btn(void) {
volatile int *btn = (volatile int*) (0x040000d0);
int btn_value = *btn;
int and_mask = 0x1; // LSB
return btn_value & and_mask;
}

// 1f
int get_sw(void) {
volatile int* sw = (int*) 0x04000010; // set the address of all the toggle switches
int sw_value = *sw;  //
int and_mask = 0x3FF; // 3ff = 001 111 111 111
return sw_value & and_mask;
}


// 1e uppgift
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

void set_leds(int led_mask) {
volatile int *leds = (volatile int*) 0x4000000;
*leds = 0b1111111111 & led_mask; // led mask ger värdet till leds
}

//helper function to mask out digit so that it can then be used to display
int get_number(int time, int position) {
int masking = time >> position;
return 0xF & masking;
}


/* Below is the function that will be called when an interrupt is triggered. */
void handle_interrupt(unsigned cause) {

 // Assignemt 3 e/f -- handle-interrupt 
 if (cause == 16) {                                     // 16 är hårdvarans interrupt nummer för timern 
   *timer_status = 0;                                   // nollställer flaggan TO  
   timeoutcount++;                                      

   if (timeoutcount == 10) {                            // när vi har fått 10 timeouts sätter vi den till 0 så att det kan köra igen och ticka
    timeoutcount = 0; 
    tick (&mytime);

  volatile int seconds_first = get_number(mytime, 0); //  maska 4 lsb och får entalssifran på sekund
  volatile int second_second = get_number(mytime, 4); // maska 4 lsb och skifta och får tiotalssiffran på sekund
  volatile int minutes_first = get_number(mytime, 8);
  volatile int minutes_second = get_number(mytime, 12);
  volatile int hours_first = get_number(mytime, 16);
  volatile int hours_second = get_number(mytime, 20);

  //uppdaterar resp display plats
  set_displays(0, seconds_first);
  set_displays(1, second_second);
  set_displays(2, minutes_first);
  set_displays(3, minutes_second);
  set_displays(4, hours_first);  
  set_displays(5, hours_second);
   }
  }

    // surprise assessment 
  if (cause == 18) {                                   
    volatile int *button = (volatile int*) 0x040000dc;    // edge capture 
    *button = 1; // clear the input 
    tick(&mytime); // tick 
  volatile int seconds_first = get_number(mytime, 0); //  maska 4 lsb och får entalssifran på sekund
  volatile int second_second = get_number(mytime, 4); // maska 4 lsb och skifta och får tiotalssiffran på sekund
  volatile int minutes_first = get_number(mytime, 8);
  volatile int minutes_second = get_number(mytime, 12);
  volatile int hours_first = get_number(mytime, 16);
  volatile int hours_second = get_number(mytime, 20);

  //uppdaterar resp display plats
  set_displays(0, seconds_first);
  set_displays(1, second_second);
  set_displays(2, minutes_first);
  set_displays(3, minutes_second);
  set_displays(4, hours_first);  
  set_displays(5, hours_second);
  }
   }


/* Add your code here for initializing interrupts. */
/* Assignment 2 part b -- initialisera timer*/ 
void labinit(void) { 

// interrups / timeouts varje 100ms (10 timeouts / s) ==> // 30 000 000 / 10 = 3 000 000 timeouts  
*timer_periodL = 0xC6C0; // 1100011011000000 för the lower bits (periodL) 
*timer_periodH = 0x002D; // 0000000000101101 för the higher biths (periodH) 

// bit 3 (STOP) är avstängd, bit2 (START), bit1 (CONT) och bit0 (ITO) är på  
*timer_control = 0x6; // 0b0110 = 6  // denna rad är väl meningslöst

*timer_control = 0x7; //0b0111 = 7   // sätter på timer interupps (ITO)

volatile int* button_mask = (volatile int*) 0x40000d8;  // 0x40000d4-0x40000d8
*button_mask = 0b1;   // enable interrupt by setting it to 1 

enable_interrupt();                

} 

/* Assignent 3: part c */
int main ( void ) {
labinit();
while (1) {
print ("Prime: ");
prime = nextprime( prime );
print_dec( prime );
print("\n");
}
}


