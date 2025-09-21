//Send logical 1 to teensy and blink LED every second if attack successfull
//Author: Marek Lörinc
//Date: 08.05.2020

#include "atmel_start.h"
#include "trustzone_veneer.h"
#include <hal_gpio.h>
#include <hal_delay.h>

//Used pins PA7 - LED, PA10 - output connected to teensy
#define LED0 GPIO(GPIO_PORTA, 7)
#define OUT0 GPIO(GPIO_PORTA, 10)


//IO pin initialization
void init_pin(const uint8_t pin)
{
	gpio_set_pin_level(pin,
	// <y> Initial level
	// <id> pad_initial_level
	// <false"> Low
	// <true"> High
	true);

	// Set pin direction to output
	gpio_set_pin_direction(pin, GPIO_DIRECTION_OUT);
	gpio_set_pin_function(pin, GPIO_PIN_FUNCTION_OFF);
}
/* Non-secure main*/
int main(void)
{
	/* Initializes MCU, drivers and middleware */
	atmel_start_init();
	//Init pin 10 and send logical 1 to pin A10 (not allowed if attack isn't successfull)
	init_pin(OUT0);
	//Init LED and send logical 1 to LED => LED is turned off (not allowed if attack isn't successfull)
	init_pin(LED0);
	

	/* Blink LED every 1 second */
	while (1) {
		gpio_toggle_pin_level(LED0);	//Change state of LED - not allowed if attack isnt successful
		delay_ms(1000);
	}
}
