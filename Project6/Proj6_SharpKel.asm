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

mGetString MACRO prompt, strInput, count, strLen
	; preserve registers
	PUSH EAX
	PUSH ECX
	PUSH EDX

	; display prompt
	MOV  EDX, prompt
	CALL WriteString

	; get input up to count
	MOV  EDX, strInput ; set up EDX to point to strInput
	MOV  ECX, count  ; buffer size according to Irvine
	CALL ReadString
	MOV  strLen, EAX ; store length in strLen

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
intro1	    BYTE "Getting low with I/0 Procedures", 0
intro2	    BYTE "Designed and created by: Kelley Sharp", 0
intro3	    BYTE "Please enter 10 signed decimal integers.", 0
intro4      BYTE "Each number needs to fit into a 32-bit register.", 0
intro5      BYTE "Afterwards I will give you the full list of integers, their sum, and average.", 0

; Prompt
prompt      BYTE "Please enter a signed number: ", 0
errorMsg    BYTE "ERROR: You did not enter an signed number or your number was too big.", 0

; Label/Misc Strings
list_msg	BYTE "These are the numbers you entered:", 0 
sum_msg		BYTE "The sum of the numbers is:", 0
average_msg	BYTE "The rounded average is:", 0

; User data variables
inputStr    BYTE   MAX_STR_SIZE  DUP(?) ; for ReadVal
strLen		DWORD  ?  ; store the length of the input string
inputNum    SDWORD ?  ; used as output parameter for ReadVal and input parameter for WriteVal

; Summary & Conclusion Strings
goodbye		BYTE "I hope you enjoyed using my program! The end.", 0

debug		BYTE "YEP", 0

.code
main PROC

	PUSH OFFSET intro5
	PUSH OFFSET intro4
	PUSH OFFSET intro3
	PUSH OFFSET intro2
	PUSH OFFSET intro1
	CALL Introduction

	PUSH strLen
	PUSH OFFSET inputNum
	PUSH COUNT
	PUSH OFFSET inputStr
	PUSH OFFSET errorMsg
	PUSH OFFSET prompt
	CALL ReadVal

	PUSH inputNum
	CALL WriteVal

	;CALL Farewell

	Invoke ExitProcess, 0
main ENDP

; ---------------------------------------------------------------------------------
; Name: Introduction
;
; Displays programmer's name, program's name, and instructions.
;
; Receives: 
;     intro1   [EBP+8]
;     intro2   [EBP+12]
;     intro3   [EBP+16]
;     intro4   [EBP+20]
;     intro5   [EBP+24]
; ---------------------------------------------------------------------------------
Introduction PROC
	; preserve registers
	PUSH EBP
	MOV  EBP, ESP
	PUSH EDX

	; display name and title
	mDisplayString [EBP+8]
	CALL CrLf
	mDisplayString [EBP+12]
	CALL CrLf
	CALL CrLf

	; display instructions
	mDisplayString [EBP+16]
	CALL CrLf	
	mDisplayString [EBP+20]
	CALL CrLf	
	mDisplayString [EBP+24]
	CALL CrLf
	CALL CrLf

	; restore registers
	POP EDX
	POP EBP
	RET 20
Introduction ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
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
;     strLen   [EBP+28]
;
; ---------------------------------------------------------------------------------
ReadVal PROC
	; local variables
	LOCAL isNegative:BYTE ; byte flag to store whether the input is a negative number
	LOCAL isFirstChar:BYTE ; byte flag for looping - first case is special
	LOCAL currentNum:SDWORD ; store the current number, a running total until the end
	LOCAL nextDigit:SDWORD ; tmp variable to add to current number

	; preserve registers
	PUSH EAX
	PUSH EBX
	PUSH ECX
	PUSH EDX
	PUSH ESI
	PUSH EDI

	_getInputAndInitialize:
		mGetString [EBP+8], [EBP+16], [EBP+20], [EBP+28]
		; prepare string to be looped over
		MOV  ESI, [EBP+16] ; put string in ESI
		MOV  ECX, [EBP+28] ; put length in ECX for loop
		CLD
		MOV  isFirstChar, 1
		MOV  currentNum, 0

	_loadNextByte:
		; load in 1 byte at a time
		MOV   EAX, 0
		LODSB
		; skip ahead if not first byte
		CMP   isFirstChar, 0
		JE    _checkStrByte

	_checkSignByte:
		; the first char we check to see if there is a sign
		CMP  AL, 45  ; "-" character
		JE   _hasNegativeSign
		CMP  AL, 43  ; "+" character
		JE	 _hasPositiveSign
		; otherwise jump to checkByte normally
		JMP  _checkStrByte

	_hasNegativeSign:
		MOV  isNegative, 1
		MOV  isFirstChar, 0
		; check edge case where user just enters "-"
		CMP  ECX, 1
		JE   _error
		JMP  _continueLoop

	_hasPositiveSign:
		MOV  isNegative, 0
		MOV  isFirstChar, 0
		; check edge case where user just enters "+"
		CMP  ECX, 1
		JE   _error
		JMP  _continueLoop

	_checkStrByte:
		; ensure it's a valid digit 0-9
		CMP   AL, 48
		JB    _error
		CMP   AL, 57
		JA    _error

	_strToNum:
		; algorithm: (10 * currentNum) + nextDigit
		SUB   AL, 48
		MOVZX EAX, AL  ; zero-extend AL so it fits into SDWORD
		MOV   nextDigit, EAX
		MOV   EAX, currentNum
		MOV   EBX, 10
		MUL   EBX
		ADD   EAX, nextDigit
		MOV   currentNum, EAX

	_continueLoop:
		LOOP  _loadNextByte
		JMP   _stringEnd

	_error:
		mDisplayString [EBP+12]
		CALL  CrLf
		JMP  _getInputAndInitialize

	_stringEnd:
		CMP   isNegative, 1
		JE    _negate
		JMP   _storeStr

	_negate:
		NEG   currentNum

	_storeStr:
		MOV   EAX, currentNum
		; assign inputNum (output parameter) the value of currentNum local
		MOV   EDI, [EBP+24] 
		MOV   [EDI], EAX

	; restore registers
	POP  EDI
	POP  ESI
	POP  EDX
	POP  ECX
	POP  EBX
	POP  EAX

	RET  24

ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Prints a SDWORD value as a string of digits
;
; Preconditions: SDWORD in inputNum
;
; Postconditions: String printed to console
;
; Receives:
;     inputNum     [EBP+8]
; ---------------------------------------------------------------------------------
WriteVal PROC
	; local variables
	LOCAL isNegative:BYTE ; byte flag to store whether the input is a negative number
	LOCAL isFinalDigit:BYTE ; byte flag to store whether we're on the last digit
	LOCAL currentNum:SDWORD
	LOCAL currentDigit:SDWORD
	LOCAL outputStr[15]:BYTE
	LOCAL remainderCount:DWORD

	; preserve registers
	PUSH   EAX
	PUSH   EBX
	PUSH   ECX
	PUSH   EDX
	PUSH   EDI
	PUSH   ESI
	PUSHFD

	_initialize:
		MOV  ESI, [EBP+8] ; put inputNum in ESI
		LEA  EDI, outputStr  ; prepare outputStr for iteration
		CLD
		MOV  remainderCount, 0
		MOV  isNegative, 0
		MOV  currentDigit, 0

	_analyzeNumber:
		MOV EAX, ESI
		MOV currentNum, EAX
	
	_checkSign:
		CMP  currentNum, 0
		JL   _isNegative
		MOV  isNegative, 0
		JMP  _processDigit

	_isNegative:
		NEG  currentNum
		MOV  isNegative, 1

	_processDigit:
		CMP  currentNum, 10
		; continue dividing by 10 and storing the remainder until we have a single digit
		JGE  _divideByTen
		JMP  _writeFirstDigit

	_divideByTen:
		MOV  EAX, currentNum
		CDQ
		MOV  EBX, 10
		IDIV EBX
		MOV  currentNum, EAX
		; save the remainder on the stack
		PUSH EDX
		INC  remainderCount		
		JMP  _processDigit

	_writeFirstDigit:
		MOV  EAX, currentNum
		MOV  currentDigit, EAX
		CMP  isNegative, 1
		JE   _writeNegativeSign
		JMP _appendToStr

	_writeNegativeSign:
		MOV EAX, 45
		STOSB
		JMP _appendToStr

	_processRemainder:
		POP EAX
		DEC remainderCount
		MOV currentDigit, EAX
		JMP _appendToStr

	_appendToStr:
		MOV   EAX, currentDigit
		ADD   EAX, 48  ; convert integer to ASCII char code
		STOSB
		CMP  remainderCount, 0
		JG   _processRemainder

	_strEnd:
		MOV				EAX, 0 ; null byte (0) at the end of the string
		STOSB
		; load the offset of outputStr and print it to console
		LEA				EDX, outputStr
		mDisplayString	EDX


	; restore registers
	POPFD
	POP  ESI
	POP  EDI
	POP  EDX
	POP  ECX
	POP  EBX
	POP  EAX

	RET 4

WriteVal ENDP
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
