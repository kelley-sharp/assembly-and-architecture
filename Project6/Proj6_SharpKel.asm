TITLE String Primitives and Macros     (Proj6_SharpKel.asm)

; Author: Kelley Sharp
; Last Modified: 3/07/2021
; OSU email address: sharpkel@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 06                 Due Date: 3/14/2021
; Description: This program asks the user to enter 10 signed decimal integers,
;	no more than 32 bits long. After validation passes for 10 numbers, the program
;	will display the numbers back to the user along with the sum and rounded average.

INCLUDE Irvine32.inc
ExitProcess proto, dwExitCode:dword

.data
; Global Constants (with text-equivalents for easier string interpolation)

; Intro Strings
intro		BYTE "Getting low with I/0 Procedures", 0
intro2		BYTE "Designed and created by: Kelley Sharp", 0

; Label/Misc Strings
list_msg	BYTE "These are the numbers you entered:", 0 
sum_msg		BYTE "The sum of the numbers is:", 0
average_msg	BYTE "The rounded average is:", 0

; Numerical variables

; Summary & Conclusion Strings
goodbye		BYTE "I hope you enjoyed using my program! The end.", 0

.code
main PROC

	CALL introduction
	CALL getUSerInput
	CALL validateInput
	CALL printNumbers
	CALL calcSum
	CALL calcAverage
	CALL printSum
	CALL printRoundedAverage
	CALL farewell

	Invoke ExitProcess, 0
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Displays programmer's name, program's name, and instructions.
; ---------------------------------------------------------------------------------
introduction PROC
	PUSH EBP
	MOV  EBP, ESP 

	; Display programmer's name and program's name

	; Display Instructions


introduction ENDP

; ---------------------------------------------------------------------------------
; Name:
;
; 
;
; Preconditions: 
;
; Postconditions: 
;
; Receives: 
;
; ---------------------------------------------------------------------------------


; ---------------------------------------------------------------------------------
; Name: farewell
;
; Displays parting message with a goodbye
; ---------------------------------------------------------------------------------	
farewell PROC
	PUSH EBP
	MOV  EBP, ESP

	CALL CrLf
	MOV  EDX, [EBP+8]
	CALL WriteString
	CALL CrLf

	POP EBP
	RET  4

farewell ENDP

END main
