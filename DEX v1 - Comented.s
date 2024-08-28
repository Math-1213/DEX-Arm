// Register Usage:
// r0  -> Seven Segment Display Address
// r1  -> Button Address
// r2  -> Switch Address
// r3  -> Button Content
// r4  -> Switch Content
// r5  -> State: 0 = DEC (Decimal), 1 = HEX (Hexadecimal)
// r6  -> Aux for Decimal Conversion
// r7  -> Unit (Single Digit Value)
// r8  -> Decimal (Tens Digit Value)
// r9  -> Value to be Displayed
// r10 -> Previous Displayed Value (For storing accumulated digits)
// r11 -> Bit Shift (Used to shift digits for multi-digit display)
// r12 -> Number to be Displayed on the Seven Segment Display

.text
.global _start
_start:

    // Initialization of Registers
    ldr r0, =0xff200020   // Load the address of the Seven Segment Display into r0
    ldr r1, =0xff200050   // Load the address of the Button into r1
    ldr r2, =0xff200040   // Load the address of the Switch into r2
    mov r3, #0            // Initialize r3 (Button Content) to 0
    mov r4, #0            // Initialize r4 (Switch Content) to 0
    mov r5, #0            // Initialize r5 (State) to 0 (Decimal Mode)
    mov r10, #0           // Initialize r10 (Previous Displayed Value) to 0
    mov r11, #0           // Initialize r11 (Bit Shift) to 0
    mov r12, #0           // Initialize r12 (Number to be Displayed) to 0

_loop:
    // Main Loop: Check for Button Press
    mov r11, #0            // Reset Bit Shift to 0
    mov r10, #0            // Reset Previous Displayed Value to 0
    mov r12, #0            // Reset Number to be Displayed to 0
    mov r9, #0             // Reset Value to be Displayed to 0
    
    ldr r3, [r1]           		// Load the Button Content into r3
    cmp r3, #1             		// Check if Button 1 is pressed
    beq _button_pressed_load   	// If Button 1 is pressed, jump to load process
    cmp r3, #2             		// Check if Button 2 is pressed
    beq _button_pressed_convert // If Button 2 is pressed, jump to convert process
    b _loop                		// If no button is pressed, repeat the loop
    
_button_pressed_load:
    ldr r3, [r1]           		// Reload the Button Content (for debounce)
    cmp r3, #0             		// Check if Button 1 is released
    beq _button_released_load 	// If released, proceed with loading
    b _button_pressed_load 		// Otherwise, wait for release
    
_button_pressed_convert:
    ldr r3, [r1]           			// Reload the Button Content (for debounce)
    cmp r3, #0             			// Check if Button 2 is released
    beq _button_released_convert 	// If released, proceed with conversion
    b _button_pressed_convert 		// Otherwise, wait for release

_button_released_load:
    ldr r4, [r2]           // Load the Switch Content into r4
    mov r5, #1             // Set the state to Hexadecimal (1)
    b _predecimal          // Jump to pre-decimal conversion

_button_released_convert:
    cmp r5, #1             // Check the state (0 = DEC, 1 = HEX)
    beq _predecimal        // If in Hex mode, proceed with decimal processing
    b _prehex              // Otherwise, proceed with hexadecimal processing

_predecimal:
    mov r7, r4             // Move the Switch Content (r4) to r7 (Unit)
    b _decimal             // Jump to decimal conversion

_prehex:
    mov r7, r4             // Move the Switch Content (r4) to r7 (Unit)
    b _hex                 // Jump to hexadecimal conversion

_decimal:
    mov r5, #0             // Set the state to Decimal (0)
    cmp r7, #9             // Check if the unit is less than or equal to 9
    ble _posdecimal        // If yes, proceed to display
    mov r8, #0             // Otherwise, initialize decimal place

_division_dec:
    sub r7, r7, #10        // Subtract 10 from the unit to get the tens digit
    add r8, r8, #1         // Increment the tens place
    cmp r7, #9             // Check if the unit is still greater than 9
    bge _division_dec      // If yes, repeat division
    b _posdecimal          // Proceed to display

_hex:
    mov r5, #1             // Set the state to Hexadecimal (1)
    cmp r7, #15            // Check if the unit is less than or equal to 15
    ble _posdecimal        // If yes, proceed to display
    mov r8, #0             // Otherwise, initialize hexadecimal place

_division_hex:
    sub r7, r7, #16        // Subtract 16 to get the next hexadecimal digit
    add r8, r8, #1         // Increment the higher place digit
    cmp r7, #15            // Check if the unit is still greater than 15
    bge _division_hex      // If yes, repeat division
    b _posdecimal          // Proceed to display

_posdecimal:
    mov r9, r7             // Store the final digit in r9
    mov r7, r8             // Move the higher digit to r7 (for further processing)
    mov r8, #0             // Reset r8
    b _encoder             // Jump to encode the digit for display

_encoder:
    // Convert the number to its 7-segment representation
    cmp r9, #0             // Check if the digit is 0
    beq _0                 // If yes, jump to 0 conversion
    cmp r9, #1             // Check if the digit is 1
    beq _1                 // If yes, jump to 1 conversion
    cmp r9, #2             // Check if the digit is 2
    beq _2                 // If yes, jump to 2 conversion
    cmp r9, #3             // Check if the digit is 3
    beq _3                 // If yes, jump to 3 conversion
    cmp r9, #4             // Check if the digit is 4
    beq _4                 // If yes, jump to 4 conversion
    cmp r9, #5             // Check if the digit is 5
    beq _5                 // If yes, jump to 5 conversion
    cmp r9, #6             // Check if the digit is 6
    beq _6                 // If yes, jump to 6 conversion
    cmp r9, #7             // Check if the digit is 7
    beq _7                 // If yes, jump to 7 conversion
    cmp r9, #8             // Check if the digit is 8
    beq _8                 // If yes, jump to 8 conversion
    cmp r9, #9             // Check if the digit is 9
    beq _9                 // If yes, jump to 9 conversion
    cmp r9, #10            // Check if the digit is A (for hex mode)
    beq _A                 // If yes, jump to A conversion
    cmp r9, #11            // Check if the digit is B (for hex mode)
    beq _B                 // If yes, jump to B conversion
    cmp r9, #12            // Check if the digit is C (for hex mode)
    beq _C                 // If yes, jump to C conversion
    cmp r9, #13            // Check if the digit is D (for hex mode)
    beq _D                 // If yes, jump to D conversion
    cmp r9, #14            // Check if the digit is E (for hex mode)
    beq _E                 // If yes, jump to E conversion
    cmp r9, #15            // Check if the digit is F (for hex mode)
    beq _F                 // If yes, jump to F conversion
    b _loop                // If no match, return to the main loop

// Digit to 7-Segment Display Mapping
_0:
    mov r12, #63           // 0 -> 0111111 (Seven Segment Code)
    b _display

_1:
    mov r12, #6            // 1 -> 0000110
    b _display

_2:
    mov r12, #91           // 2 -> 1011011
    b _display

_3:
    mov r12, #79           // 3 -> 1001111
    b _display

_4:
    mov r12, #102          // 4 -> 1100110
    b _display

_5:
    mov r12, #109          // 5 -> 1101101
    b _display

_6:
    mov r12, #125          // 6 -> 1111101
    b _display

_7:
    mov r12, #7            // 7 -> 0000111
    b _display

_8:
    mov r12, #127          // 8 -> 1111111
    b _display

_9:
    mov r12, #103          // 9 -> 1100111
    b _display

_A:
    mov r12, #119          // A -> 1110111
    b _display

_B:
    mov r12, #124          // B -> 11111100
    b _display

_C:
    mov r12, #57           // C -> 0111001
    b _display

_D:
    mov r12, #94           // D -> 1011110
    b _display

_E:
    mov r12, #121          // E -> 1111001
    b _display

_F:
    mov r12, #113          // F -> 1110001

_display:
    // Display the Number on the 7-Segment Display
    lsl r12, r12, r11      // Shift the digit based on the current position (r11)
    orr r12, r12, r10      // Combine with the previously displayed digits (r10)
    str r12, [r0]          // Store the result to the Seven Segment Display
    mov r10, r12           // Update the previous display value with the current
    cmp r7, #0             // Check if there are more digits to process
    beq _loop              // If no, return to the main loop
    add r11, #8            // If yes, prepare for the next digit (shift by 8 bits)
    b _jump                // Jump to the next digit processing

_jump:
    cmp r5, #0             // Check if in Decimal Mode
    beq _decimal           // If yes, jump to decimal processing
    b _hex                 // Otherwise, jump to hexadecimal processing
