TITLE Nested Loops and Procedures     (Proj4_SharpKel.asm)

; Author: Kelley Sharp
; Last Modified: 2/21/2021
; OSU email address: sharpkel@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 04                 Due Date: 2/21/2021
; Description: Program prompts user to enter number of prime numbers they would like to see (between 1 and 200 prime numbers).
;	If user enters an invalid number, notifies them of the number being out of range.
;	If user enters a valid number, that number of primes will be printed starting with "2". 

INCLUDE Irvine32.inc
ExitProcess proto, dwExitCode:dword

.data
; Constants with text-equivalents for easier string interpolation
LOWER    EQU 1
LOWER_T  EQU <"1"> 
UPPER	 EQU 200
UPPER_T  EQU <"200">
PER_LINE EQU 10

; Intro & Prompt Strings
intro		BYTE "Hi, I'm Kelley. Welcome to the Prime Number Generator!", 0
rules_1     BYTE "I'll show you between ", LOWER_T," and ", UPPER_T," prime numbers.", 0
rules_2		BYTE "Please enter the number of primes you'd like to see: ", 0
notify_1	BYTE "I can't fulfill that request. Your number is outside my range.", 0
notify_2	BYTE "Enter a number between 1 and 200", 0

; numerical variables
numberOfPrimes		DWORD ?
currentNum          DWORD ?
currentDivisor		DWORD ?
numberPrintedSoFar  DWORD 0

; variables for formatting the primes
spacer				BYTE "   ", 0
digitSpacer			BYTE "  ", 0  ; this and the one below are for extra credit
doubleDigitSpacer	BYTE " ", 0

; Summary & Conclusion Strings
goodbye		BYTE "I hope you've enjoyed your prime time. Goodbye!", 0

; Debugging
outerLoop	BYTE "OUTER LOOP", 0
innerLoop	BYTE "INNER LOOP", 0

.code
main PROC

	CALL introduction
	CALL getUserData
	CALL showPrimes
	CALL farewell	

	Invoke ExitProcess,0	; exit to operating system
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

; Display objective
	MOV EDX, OFFSET rules_1
	CALL WriteString
	CALL CrLf

; Display instructions
	MOV EDX, OFFSET rules_2
	CALL WriteString

	RET
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: getUserData
;
; Takes user input and validates it
;
; Preconditions: The input number is type DWORD.
;
; Postconditions: Changes register EAX.
;
; Receives: None
;
; Returns: The valid number of primes the user has requested.
; ---------------------------------------------------------------------------------
getUserData PROC
	CALL ReadInt
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
		MOV EDX, OFFSET notify_1 ; says "out of range"
		CALL WriteString
		CALL CrLf
		MOV EDX, OFFSET notify_2 ; says "try again"
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
; Preconditions: The input numberOfPrimes is type DWORD.
;
; Postconditions: Changes register EAX.
;
; Receives: None
;
; Returns: The valid number of primes the user has requested.
; ---------------------------------------------------------------------------------
showPrimes PROC
	MOV ECX, numberOfPrimes
	MOV currentNum, 2
	_enumeratePrimesUpToNumberOfPrimes:
		PUSH ECX  ; Preserve outer loop counter
		CALL isPrime
		POP ECX   ; Restore outer loop counter
		LOOP _enumeratePrimesUpToNumberOfPrimes
	RET
	
showPrimes ENDP

; ---------------------------------------------------------------------------------
; Name: isPrime
;
; Subprocedure of showPrimes, this one computes whether the current number is prime or not
; ---------------------------------------------------------------------------------
isPrime PROC
    
	MOV ECX, currentNum
	MOV currentDivisor, 2
	_findNextPrime:
		mov EAX, currentDivisor
		CMP EAX, currentNum  
		JE _isPrime  ; if we made it to where currentDivisor == currentNum, then it's prime

		MOV EAX, currentNum
		CDQ
		DIV currentDivisor
		CMP EDX, 0
		JE _isNotPrime  ; if the current number divides cleanly by something other than 1 or itself
		INC currentDivisor

		LOOP _findNextPrime


	_isNotPrime:
	    INC currentNum
		JMP _findNextPrime
	
	_isPrime:
		CALL printPrime	
		INC currentNum
		RET
		
isPrime ENDP

; ---------------------------------------------------------------------------------
; Name: printPrime
;
; Subprocedure of isPrime. This is specifically for formatting the primes in a column
; ---------------------------------------------------------------------------------
printPrime PROC

	MOV EAX, currentNum
	CALL WriteDec
	MOV EDX, OFFSET spacer
	CALL WriteString
	CMP EAX, 10     ; extra credit - align the output columns
	JL  _addDigitSpacers
	CMP EAX, 100
	JL _addDoubleDigitSpacers
	JMP _determineNewLine

	_addDigitSpacers:
		MOV EDX, OFFSET digitSpacer
		CALL WriteString
		JMP _determineNewLine

	_addDoubleDigitSpacers:
		MOV EDX, OFFSET doubleDigitSpacer
		CALL WriteString
		JMP _determineNewLine

	_determineNewLine:
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

	MOV EDX, OFFSET goodbye
	CALL CrLf

farewell ENDP

END main
