TITLE Nested Loops and Procedures     (Proj4_SharpKel.asm)

; Author: Kelley Sharp
; Last Modified: 2/21/2021
; OSU email address: sharpkel@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 04                 Due Date: 2/21/2021
; Description: Program prompts user to enter number of prime numbers they would like to see (between 1 and 200 prime numbers).
;	If user enters an invalid number, notifies them of the number being out of range.
;	If user enters a valid number, that number of primes will be printed starting with "2".
;   The program will print up to 10 primes per line (the final line can have less than 10).
;   (Extra Credit) Also the prime numbers are aligned into columns.

INCLUDE Irvine32.inc
ExitProcess proto, dwExitCode:dword

.data
; Global Constants (with text-equivalents for easier string interpolation)
LOWER    EQU 1
LOWER_T  EQU <"1"> 
UPPER	 EQU 200
UPPER_T  EQU <"200">
PER_LINE EQU 10

; Intro & Prompt Strings
intro		BYTE "Hi, I'm Kelley. Welcome to the Prime Number Generator!", 0
eCred		BYTE "**EC: Align the output columns", 0
rules		BYTE "I can show you between ", LOWER_T," and ", UPPER_T," prime numbers.", 0
prompt		BYTE "Please enter the # of primes you'd like to see [", LOWER_T, "...", UPPER_T, "]: ", 0
invalid_n	BYTE "I can't fulfill that request. Your number is outside my range.", 0

; numerical variables
numberOfPrimes		DWORD ?  ; what the user will input
currentNum          DWORD 2  ; for storing prime candidates. Start from 2 since 1 is not prime.
currentDivisor		DWORD 2  ; for checking whether the currentNum is prime. Divide starting from 2.
numberPrintedSoFar  DWORD 0  ; ensuring we only print 10 per line

; variables for formatting the primes (with extra credit column alignment)
spacer				BYTE "   ", 0
digitSpacer			BYTE "   ", 0 ; single digits need this much padding, e.g. "1   "
doubleDigitSpacer	BYTE "  ", 0  ; same as above for double digits, e.g.	   "10  "
tripleDigitSpacer   BYTE " ", 0   ; same as above for triple digits, e.g.      "100 "

; Summary & Conclusion Strings
goodbye		BYTE "I hope you've enjoyed your prime time. Goodbye!", 0

.code
main PROC

	CALL introduction
	CALL getUserData
	CALL showPrimes
	CALL farewell	

	Invoke ExitProcess, 0
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Displays program title, programmer's name and instructions
; ---------------------------------------------------------------------------------
introduction PROC
; Display program title and programmer's name
	MOV EDX, OFFSET intro
	CALL WriteString
	CALL CrLf

; Display extra credit statement
	MOV EDX, OFFSET eCred
	CALL WriteString
	CALL CrLf

; Display objective
	MOV EDX, OFFSET rules
	CALL WriteString
	CALL CrLf

	RET

introduction ENDP

; ---------------------------------------------------------------------------------
; Name: getUserData
;
; Takes user input and validates it
;
; Preconditions: The input number is type DWORD.
;
; Postconditions: Changes registers EAX (input) and EDX (printing). Sets numberOfPrimes variable.
;
; Receives: None
;
; Returns: Nothing (void)
; ---------------------------------------------------------------------------------
getUserData PROC
	; prompt the user for input
	CALL CrLf
	MOV EDX, OFFSET prompt
	CALL WriteString
	CALL ReadInt

	; validate input
	MOV numberOfPrimes, EAX
	CALL validate
	RET
getUserData ENDP

; ---------------------------------------------------------------------------------
; Name: validate
;
; Subprocedure of getUserData. If the user input is a numberOfPrimes between 1 and 200,
;   that numberOfPrimes is stored in the global "numberOfPrimes" variable, otherwise the user is
;	prompted to enter a valid numberOfPrimes.
; ---------------------------------------------------------------------------------
validate PROC
	CMP numberOfPrimes, LOWER
	JL _NotifyUser ; If numberOfPrimes is less than 1
	CMP numberOfPrimes, UPPER
	JG _NotifyUser ; If numberOfPrimes is greater than 200
	RET

	_NotifyUser:
		MOV EDX, OFFSET invalid_n ; says "out of range"
		CALL WriteString
		CALL CrLf
		CALL getUserData
		RET
validate ENDP

; ---------------------------------------------------------------------------------
; Name: showPrimes
;
; Takes a valid numberOfPrimes, calculates that many prime numbers, and displays them to user.
;
; Preconditions: The global variable numberOfPrimes is type DWORD.
;
; Postconditions: Changes registers EAX (division, comparisons), ECX (loop counter, division), EDX (division, printing) 
;
; Receives: None
;
; Returns: Nothing (void)
; ---------------------------------------------------------------------------------
showPrimes PROC
	CALL CrLf
	MOV currentNum, 2  ; start from 2 b/c 1 is not defined as prime

	MOV ECX, numberOfPrimes  ; loop this many times
	_enumeratePrimesUpToNumberOfPrimes:
		PUSH ECX  ; Preserve outer loop counter
		CALL isPrime
		POP ECX   ; Restore outer loop counter
		LOOP _enumeratePrimesUpToNumberOfPrimes

	CALL CrLf
	RET
	
showPrimes ENDP

; ---------------------------------------------------------------------------------
; Name: isPrime
;
; Subprocedure of showPrimes, this computes whether the current number is prime or not.
; If the current number isn't a prime, it increments until it finds a prime. Then it prints 
; and returns control to the outer loop
;
; Preconditions: The global variables currentNum and currentDivisor are of type DWORD
;
; Postconditions: Changes registers EAX (division, comparisons), ECX (division), EDX (division, printing),
;                 global variables currentDivisor, currentNum
;
; Receives: None
;
; Returns: Nothing (void)
; ---------------------------------------------------------------------------------
isPrime PROC
    
	MOV currentDivisor, 2  ; primes are divisible by 1, so start testing divisors from 2
	_findNextPrime:
		; break condition - if we made it to where currentDivisor == currentNum, then it's prime
		mov EAX, currentDivisor
		CMP EAX, currentNum  
		JE _isPrime  

		; if the current number divides cleanly by something other than 1 or itself it's not a prime
		MOV EAX, currentNum
		CDQ
		DIV currentDivisor
		CMP EDX, 0
		JE _isNotPrime

		; this continues this "while" loop
		INC currentDivisor
		JMP _findNextPrime

	_isNotPrime:
		; this ensures we skip over non-prime numbers
	    INC currentNum
		MOV currentDivisor, 2  ; reset divisor
		JMP _findNextPrime
	
	_isPrime:
		; when we've found a prime, we can print it and conclude this iteration of the outer loop
		CALL printPrime	
		INC currentNum
		RET
		
isPrime ENDP

; ---------------------------------------------------------------------------------
; Name: printPrime
;
; Subprocedure of isPrime. This is specifically for formatting the primes in a
; column, with the correct number printed per line.
;
; Preconditions: The global variables currentNum is of type DWORD; the other global variables are byte strings
;
; Postconditions: Changes registers EAX (comparisons), EDX (printing), global variable numberPrintedSoFar
;
; Receives: None
;
; Returns: Nothing (void)
; ---------------------------------------------------------------------------------
printPrime PROC

	; print the number itself with minimum spacing applied
	MOV EAX, currentNum
	CALL WriteDec
	MOV EDX, OFFSET spacer
	CALL WriteString

	; extra credit - align the output columns by applying extra spacing
	CMP EAX, 10    
	JL  _addDigitSpacers
	CMP EAX, 100
	JL _addDoubleDigitSpacers
	CMP EAX, 1000
	JL _addTripleDigitSpacers

	JMP _determineNewLine

	_addDigitSpacers:
		MOV EDX, OFFSET digitSpacer
		CALL WriteString
		JMP _determineNewLine

	_addDoubleDigitSpacers:
		MOV EDX, OFFSET doubleDigitSpacer
		CALL WriteString
		JMP _determineNewLine

	_addTripleDigitSpacers:
		MOV EDX, OFFSET tripleDigitSpacer
		CALL WriteString
		JMP _determineNewLine

	_determineNewLine:
		; ensure we only print 10 primes per line
		INC numberPrintedSoFar
		MOV EAX, numberPrintedSoFar
		CMP EAX, PER_LINE    
		JE _addNewLine
		RET

	_addNewLine:
		CALL CrLf
		MOV numberPrintedSoFar, 0
		RET

printPrime ENDP

; ---------------------------------------------------------------------------------
; Name: farewell
;
; Displays parting message with a goodbye
; ---------------------------------------------------------------------------------	
farewell PROC

	CALL CrLf
	MOV EDX, OFFSET goodbye
	CALL WriteString
	CALL CrLf

	RET

farewell ENDP

END main
