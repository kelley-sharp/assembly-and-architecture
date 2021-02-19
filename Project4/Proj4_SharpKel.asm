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

.data
; Constants with text-equivalents for easier string interpolation
LOWER    EQU 1
LOWER_T  EQU <"1"> 
UPPER	 EQU 200
UPPER_T  EQU <"200">

; Intro & Prompt Strings
intro		BYTE "Hi, I'm Kelley. Welcome to the Prime Number Generator!", 0
rules_1     BYTE "I'll show you between ", LOWER_T," and ", UPPER_T," prime numbers.", 0
rules_2		BYTE "Please enter the number of primes you'd like to see.", 0
notify		BYTE "I can't fulfill that request. Your number is outside my range.", 0

; Summary & Conclusion Strings
goodbye		BYTE "I hope you've enjoyed your prime time. Goodbye!", 0

.code
main PROC

	CALL introduction
	
	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Displays program title, programmer's name and instructions
; ---------------------------------------------------------------------------------
introduction PROC

; Display program title and programmer's name
	mov EDX, OFFSET intro
	call WriteString
	call CrLf

; Display objective
	mov EDX, OFFSET rules_1
	call WriteString
	call CrLf

; Display instructions
	mov EDX, OFFSET rules_2
	call WriteString
	call CrLf
	call farewell

introduction ENDP

; ---------------------------------------------------------------------------------
; Name: farewell
;
; Displays parting message with a goodbye
; ---------------------------------------------------------------------------------	
farewell PROC

	mov EDX, OFFSET goodbye
	call CrLf

farewell ENDP

END main
