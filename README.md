# fpga_calculator

This project makes a simple hexadecimal calculator from a DE-10 Standard FPGA.
The switches are used to set the inputs and determine which operation will be performed.
The calculator takes an 8 bit signed input in twos compliment form and outputs a 16 bit value in twos compliment form.

SW[9..8] select the operation as follows
	00	addition
	01	subtraction
	10	multiplication
	11	division

SW[7..0] and KEY 0 are used to set the inputs with the users setting the switches to the desired input then depressing KEY 0.
Once both inputs have been set, the users depresses KEY 1 to calculate the result.
The result is displayed on the lowest four seven-segment displays of the board.
For division, the displays 3 and 2 show the quotient while 1 and 0 show the remainder.
In case of division by zero, HEX5 displays an 'E' and all others are blank.

KEY 3 is reset, and an onboard 50MHz clock is used.

