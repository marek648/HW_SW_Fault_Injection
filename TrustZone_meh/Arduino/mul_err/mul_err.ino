//Fault injection to multiplication SAM L11
//Athor: Marek Lörinc
//Date: 08.05.2022

//Pin used on teensy (D11, D10, D9)
#define PIN_GLITCH      11
#define PIN_READ        10
#define PIN_RESET       9

//Minimum and maximum time of glitch in nanoseconds
#define GLITCH_WIDTH_MIN 80
#define GLITCH_WIDTH_MAX 120
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

unsigned int tries=0;
bool end = false;
void loop() {
  delay(100);
  if(!end){   //If glitch is successfull, stop glitching
    //Reset SAM L11 because sometimes glitches causes that SAM L11 freeze and multiplication fault isnt possible
    digitalWriteFast(PIN_RESET, LOW);
    delay(40);
    digitalWriteFast(PIN_RESET, HIGH);
    
    for(unsigned int j = GLITCH_WIDTH_MIN; j < GLITCH_WIDTH_MAX; j++){
      tries++;
      //Send glitch
      digitalWriteFast(PIN_GLITCH, LOW);
      delayNanoseconds(j);
      digitalWriteFast(PIN_GLITCH, HIGH);
      delay(15);
      //Check if glitch was successful
      if (digitalRead(PIN_READ)) {
        Serial.print("Glitch width: ");
        Serial.println(j);
        Serial.print("Tries: ");
        Serial.println(tries); 
        end = true;   
        break;
      }
    }
    
  }
}
