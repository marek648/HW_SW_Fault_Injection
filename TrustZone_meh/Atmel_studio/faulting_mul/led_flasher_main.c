//Test if it is possible to inject fault (multiplication fault) to SAM L11  
//Author: Marek Lörinc
//Date: 08.05.2020

#include "atmel_start.h"
#include <hal_gpio.h>
#include <hal_delay.h>

//Used pins PA7 - LED, PA10 - output connected to teensy
#define LED0 GPIO(GPIO_PORTA, 7)
#define OUT0 GPIO(GPIO_PORTA, 10)

//Pins intialization
void init_pin(const uint8_t pin)
{
	gpio_set_pin_level(pin,
	// <y> Initial level
	// <id> pad_initial_level
	// <false"> Low
	// <true"> High
	false);

	// Set pin direction to output
	gpio_set_pin_direction(pin, GPIO_DIRECTION_OUT);
	gpio_set_pin_function(pin, GPIO_PIN_FUNCTION_OFF);
}

int main(void)
{
	atmel_start_init();
	init_pin(OUT0);
	//7539512921*996612921=7513975995115052241
	uint64_t curr_result = 7513975995115052241;	
	uint64_t result = 7513975995115052241;
	//Cycle ends if attack is successful
	while (result == curr_result) {
		curr_result = 7539512921;
		curr_result*= 996612921;
	}
	//If cycle ends, send logical 1 to Teensy and blink LED every 2 seconds 
	gpio_toggle_pin_level(OUT0);
	while(1){
		delay_ms(2000);
		gpio_toggle_pin_level(LED0);	
	};
	
}
