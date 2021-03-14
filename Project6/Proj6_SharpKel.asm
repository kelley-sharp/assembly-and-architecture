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

MAX_STR_SIZE EQU 32
COUNT        EQU 11

mGetString MACRO prompt, strInput, count
	; preserve registers
	PUSH EAX
	PUSH ECX
	PUSH EDX

	; display prompt
	MOV  EDX, prompt
	CALL WriteString
	; get input up to count
	MOV  EDX, strInput
	MOV  ECX, count  ; buffer size according to Irvine
	CALL ReadString

	; restore registers
	POP  EAX
	POP  EDX
	POP  ECX

ENDM

mDisplayString MACRO strOutput
	; preserve registers
	PUSH EDX

	; print string
	MOV  EDX, strOutput
	CALL WriteString

	; restore registers
	POP EDX

ENDM

.data
; Global Constants (with text-equivalents for easier string interpolation)

; Intro Strings
intro		BYTE "Getting low with I/0 Procedures", 0
intro2		BYTE "Designed and created by: Kelley Sharp", 0

; Prompt
prompt      BYTE "Please enter a signed number: ", 0
errorMsg    BYTE "ERROR: You did not enter an signed number or your number was too big.", 0

; Label/Misc Strings
list_msg	BYTE "These are the numbers you entered:", 0 
sum_msg		BYTE "The sum of the numbers is:", 0
average_msg	BYTE "The rounded average is:", 0

; User data variables
inputStr    BYTE MAX_STR_SIZE DUP(?)
inputNum    SDWORD ?

; Summary & Conclusion Strings
goodbye		BYTE "I hope you enjoyed using my program! The end.", 0

.code
main PROC

	CALL Introduction

	PUSH OFFSET inputNum
	PUSH COUNT
	PUSH OFFSET inputStr
	PUSH OFFSET errorMsg
	PUSH OFFSET prompt
	CALL ReadVal

	CALL Farewell

	Invoke ExitProcess, 0
main ENDP

; ---------------------------------------------------------------------------------
; Name: Introduction
;
; Displays programmer's name, program's name, and instructions.
; ---------------------------------------------------------------------------------
Introduction PROC
	PUSH EBP
	MOV  EBP, ESP 

	; Display programmer's name and program's name

	; Display Instructions


Introduction ENDP

; ---------------------------------------------------------------------------------
; Name: Readval
;
; Reads an input value from the user and applies validation
;
; Preconditions: None
;
; Postconditions: Sets the value of inputNum to the numeric equivalent of the last
;				  valid string that was entered
;
; Receives: 
;     prompt   [EBP+8]
;     errorMsg [EBP+12]
;     inputStr [EBP+16]
;     count    [EBP+20]
;     inputNum [EBP+24]
;
; ---------------------------------------------------------------------------------
ReadVal PROC
	LOCAL isNegative:BYTE
	LOCAL isFirstChar:BYTE
	; preserve registers

	PUSH EAX
	PUSH EBX
	PUSH ECX
	PUSH ESI

	_getInput:
		mGetString [EBP+8], [EBP+16], [EBP+20]

		; prepare string to be looped over
		MOV  ESI, [EBP+16]
		CLD
		MOV  ECX, 0
		MOV  isFirstChar, 1

	_loadNextByte:
		MOV  EAX, 0
		LODSB
		CMP  isFirstChar, 0
		JE   _checkByte

	_checkSignByte:
		CMP  AL, 45  ; "-" character
		JE   _hasNegativeSign
		CMP  AL, 43  ; "+" character
		JE	_hasPositiveSign
		; otherwise jump to checkByte normally
		JMP _checkByte

	_hasNegativeSign:
		MOV isNegative, 1
		MOV isFirstChar, 0

	_hasPositiveSign:
		MOV isNegative, 0
		MOV isFirstChar, 0

	_checkByte:
		; 0 indicates the null-termination byte
		CMP  AL, 0
		JE   _stringEnd
		; ensure it's a number
		CMP  AL, 48

	_stringEnd:
		CMP  ECX, 0
		JE   _error
	
	_error:
		





	; restore registers
	POP  ESI
	POP  ECX
	POP  EBX
	POP  EAX

	RET  16

ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: Farewell
;
; Displays parting message with a goodbye
; ---------------------------------------------------------------------------------	
Farewell PROC
	PUSH EBP
	MOV  EBP, ESP

	CALL CrLf
	MOV  EDX, [EBP+8]
	CALL WriteString
	CALL CrLf

	POP EBP
	RET  4

Farewell ENDP

END main
