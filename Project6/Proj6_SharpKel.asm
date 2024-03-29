TITLE String Primitives and Macros     (Proj6_SharpKel.asm)

; Author: Kelley Sharp
; Last Modified: 3/07/2021
; OSU email address: sharpkel@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 06                 Due Date: 3/14/2021
; Description: This program asks the user to enter 10 signed decimal integers,
;	no more than 32 bits long. After validation passes for 10 numbers, the program
;	will display the numbers back to the user along with the sum and rounded (floor) average.

INCLUDE Irvine32.inc
ExitProcess proto, dwExitCode:dword

COUNT        EQU 12  ; we want 10 characters + a sign "+"/"-" and a null byte
ARRAYSIZE    EQU 10

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
intro1	    BYTE "PROGRAMMING ASSIGNMENT 6: Getting low (level) with I/0 Procedures", 0
intro2	    BYTE "Written by: Kelley Sharp", 0
intro3	    BYTE "Please enter 10 signed decimal integers.", 0
intro4      BYTE "Each number needs to fit into a 32-bit register.", 0
intro5      BYTE "Afterwards I will give you the full list of integers, their sum, and average.", 0

; Prompt
prompt      BYTE "Please enter a signed number: ", 0
errorMsg    BYTE "ERROR: You did not enter an signed number or your number was too big.", 0

; Label/Misc Strings
listLabel	BYTE "These are the numbers you entered: ", 0 
sumLabel	BYTE "The sum of the numbers is: ", 0
avgLabel	BYTE "The rounded (floor) average is: ", 0
commaDL		BYTE ", ", 0   ; delimiter for list output

; User data variables
inputStr    BYTE   COUNT		DUP(?)  ; tmp storage for ReadVal
strLen		DWORD  ?					; store the length of the input string
numbers     SDWORD ARRAYSIZE	DUP(?)  ; store the input numbers
sum         SDWORD 0
avg         SDWORD 0


; Summary & Conclusion Strings
goodbye		BYTE "I hope you enjoyed using my program! The end.", 0


.code
main PROC

	PUSH OFFSET intro5
	PUSH OFFSET intro4
	PUSH OFFSET intro3
	PUSH OFFSET intro2
	PUSH OFFSET intro1
	CALL Introduction

	PUSH strLen
	PUSH COUNT
	PUSH OFFSET inputStr
	PUSH OFFSET errorMsg
	PUSH OFFSET prompt
	PUSH ARRAYSIZE
	PUSH OFFSET numbers
	CALL EnterNumbers

	PUSH OFFSET commaDL
	PUSH OFFSET listLabel
	PUSH ARRAYSIZE
	PUSH OFFSET numbers
	CALL PrintArray

	PUSH OFFSET avg
	PUSH OFFSET sum
	PUSH ARRAYSIZE
	PUSH OFFSET numbers
	CALL ComputeSumAvg

	PUSH OFFSET avgLabel
	PUSH avg
	PUSH OFFSET sumLabel
	PUSH sum
	CALL PrintSumAvg	

	PUSH OFFSET goodbye
	CALL Farewell

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
; Postconditions: Sets the value of inputNum data member to the integer equivalent of the last
;				  valid string that was entered
;
; Receives: 
;     prompt   [EBP+8]  what to print to user
;     errorMsg [EBP+12] what to print if the user enters a bad input
;     inputStr [EBP+16] output parameter by reference
;     count    [EBP+20] size of the buffer
;     inputNum [EBP+24] output parameter to store the parsed number
;     strLen   [EBP+28] maximum string length size
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
	PUSHFD

	_getInputAndInitialize:
		mGetString [EBP+8], [EBP+16], [EBP+20], [EBP+28]
		; prepare string to be looped over
		MOV  ESI, [EBP+16] ; put string in ESI
		MOV  ECX, [EBP+28] ; put length in ECX for loop
		CLD
		MOV  isFirstChar, 1
		MOV  currentNum, 0
		MOV  isNegative, 0

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
		JO	  _error  ; check for overflow issues when doing arithmetic here
		ADD   EAX, nextDigit
		JO	  _error
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
		JO	  _error

	_storeStr:
		MOV   EAX, currentNum
		; assign inputNum (output parameter) the value of currentNum local
		MOV   EDI, [EBP+24] 
		MOV   [EDI], EAX

	; restore registers
	POPFD
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
;     inputNum     [EBP+8] reference to the number the user entered
; ---------------------------------------------------------------------------------
WriteVal PROC
	; local variables
	LOCAL isNegative:BYTE ; byte flag to store whether the input is a negative number
	LOCAL currentNum:SDWORD  ; this is to store the mathematical total
	LOCAL currentDigit:SDWORD  ; this is to store a single digit
	LOCAL outputStr[15]:BYTE ; store the string that will be printed
	LOCAL remainderCount:DWORD  ; our algorithm needs to know how many remainders we got

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
		LEA  EDI, outputStr  ; prepare outputStr for iteration by loading offset
		CLD
		MOV  remainderCount, 0
		MOV  isNegative, 0
		MOV  currentDigit, 0
		MOV EAX, ESI
		MOV currentNum, EAX
	
	_checkSign:
		CMP  currentNum, 0
		JL   _setIsNegative
		MOV  isNegative, 0
		JMP  _processDigit

	_setIsNegative:
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
		; the first digit is the final state of currentNum
		MOV  EAX, currentNum
		MOV  currentDigit, EAX
		; check if we need to prepend a negative sign
		CMP  isNegative, 1
		JE   _writeNegativeSign
		JMP  _appendToStr

	_writeNegativeSign:
		MOV  EAX, 45
		STOSB
		JMP _appendToStr

	_processRemainder:
		POP  EAX
		DEC  remainderCount
		MOV  currentDigit, EAX
		JMP  _appendToStr

	_appendToStr:
		MOV   EAX, currentDigit
		ADD   EAX, 48  ; convert integer to ASCII char code
		STOSB
		CMP   remainderCount, 0
		JG    _processRemainder

	_strEnd:
		MOV		EAX, 0 ; null byte (0) at the end of the string
		STOSB
		; load the offset of outputStr and print it to console
		LEA		EDX, outputStr
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
; Name: EnterNumbers
;
; Calls ReadVal in a loop and puts the entries into an array
;
; Preconditions: empty numbers array
;
; Postconditions: filled numbers array
;
; Receives:
;     numbers     [EBP+8]  the address of the numbers array
;     ARRAYSIZE   [EBP+12] the constant ARRAYSIZE
;     prompt	  [EBP+16] prompt for ReadVal
;     errorMsg    [EBP+20] errorMessage for validation in ReadVal
;     inputStr    [EBP+24] value to hold temporary string input
;     count       [EBP+28] length of string input
;     strLen      [EBP+36] max string length (constant)
; ---------------------------------------------------------------------------------
EnterNumbers PROC
	; preserve registers
	PUSH EBP
	MOV  EBP, ESP
	PUSH ECX
	PUSH EDI
	PUSHFD

	_setupLoop:
		MOV ECX, [EBP+12] ; loop through length of array
		MOV EDI, [EBP+8] ; set EDI to first array element

	_fillLoop:
		PUSH strLen
		PUSH EDI
		PUSH [EBP+28]
		PUSH [EBP+24]
		PUSH [EBP+20]
		PUSH [EBP+16]
		CALL ReadVal
		ADD  EDI, 4
		LOOP _fillLoop

	; restore registers
	POPFD
	POP ECX
	POP EDI
	POP EBP

	RET 28

EnterNumbers ENDP

; ---------------------------------------------------------------------------------
; Name: PrintArray
;
; Loop through the array and call WriteVal for each value
;
; Preconditions: filled numbers array
;
; Postconditions: printed comma-separated values to console
;
; Receives:
;     numbers     [EBP+8]  the address of the numbers array
;     ARRAYSIZE   [EBP+12] the constant ARRAYSIZE
;     label		  [EBP+16] display text (offset)
;     commaDL	  [EBP+20] a comma delimiter (offset)
; ---------------------------------------------------------------------------------
PrintArray PROC
	; preserve registers
	PUSH EBP
	MOV  EBP, ESP
	PUSH ECX
	PUSH EDI
	PUSHFD

	_setupLoop:
		MOV ECX, [EBP+12] ; loop through length of array
		MOV EDI, [EBP+8] ; set EDI to first array element

	_displayLabel:
		CALL CrLf
		mDisplayString [EBP+16]
		CALL CrLf

	_fillLoop:
		PUSH [EDI]
		CALL WriteVal
		CMP  ECX, 1
		JNE  _printDelimiter
		JMP  _continue

	_printDelimiter:
		; this puts a comma between all but the last
		mDisplayString  [EBP+20]

	_continue:
		ADD  EDI, 4
		LOOP _fillLoop

	; restore registers
	POPFD
	POP ECX
	POP EDI
	POP EBP

	RET 16

PrintArray ENDP
; ---------------------------------------------------------------------------------
; Name: ComputeSumAvg
;
; Loop through the array and generate the sum and (floored) avergage
;
; Preconditions: filled numbers array
;
; Postconditions: assigned value to output parameters sum and avg
;
; Receives:
;     numbers     [EBP+8]  the address of the numbers array
;     ARRAYSIZE   [EBP+12] the constant ARRAYSIZE
;     sum		  [EBP+16] output parameter for sum data (reference)
;     avg		  [EBP+20] output parameter for avg data (reference)
; ---------------------------------------------------------------------------------
ComputeSumAvg PROC
	LOCAL runningTotal:SDWORD
	LOCAL arrSize:SDWORD

	; preserve registers
	PUSH EAX
	PUSH EBX
	PUSH ECX
	PUSH EDX
	PUSH EDI
	PUSHFD

	_setupLoop:
		MOV ECX, [EBP+12] ; loop through length of array
		MOV EDI, [EBP+8] ; set EDI to first array element
		MOV runningTotal, 0

	_sumLoop:
		MOV EAX, runningTotal
		MOV EBX, [EDI]
		ADD EAX, EBX
		MOV runningTotal, EAX
		ADD EDI, 4
		LOOP _sumLoop

	_storeSum:
		MOV EAX, runningTotal
		MOV EBX, [EBP+16]
		; assign to sum memory location
		MOV [EBX], EAX

	_avg:
		MOV  EAX, [EBP+12]
		MOV  arrSize, EAX
		MOV  EAX, runningTotal
		CDQ
		IDIV arrSize
		CMP  EDX, 0
		JNE  _checkRound
		JMP  _storeAvg

	_checkRound:
		; floor-rounding for negative numbers means
		CMP EAX, 0
		JL  _floorNegative
		JMP _storeAvg

	_floorNegative:
		DEC EAX
	
	_storeAvg:
		MOV EBX, [EBP+20]
		MOV [EBX], EAX

	; restore registers
	POPFD
	POP EDI
	POP EDX
	POP ECX
	POP EBX
	POP EAX

	RET 16

ComputeSumAvg ENDP

; ---------------------------------------------------------------------------------
; Name: PrintSumAvg
;
; Displays the values of sum and avg with labels
;
; Receives: 
;     sum      [EBP+8]
;     sumLabel [EBP+12]
;     avg      [EBP+16]
;     avgLabel [EBP+20]
; ---------------------------------------------------------------------------------
PrintSumAvg PROC
	; preserve registers
	PUSH EBP
	MOV  EBP, ESP
	PUSH EDX

	_printSum:
		CALL CrLf
		mDisplayString [EBP+12]
		PUSH [EBP+8]
		CALL WriteVal
		CALL CrLf

	_printAvg:
		mDisplayString [EBP+20]
		PUSH [EBP+16]
		CALL WriteVal
		CALL CrLf

	; restore registers
	POP EDX
	POP EBP
	RET 16
PrintSumAvg ENDP


; ---------------------------------------------------------------------------------
; Name: Farewell
;
; Displays a parting message
;
; Receives: 
;     goodbye   [EBP+8]
; ---------------------------------------------------------------------------------
Farewell PROC
	PUSH EBP
	MOV  EBP, ESP

	CALL CrLf
	mDisplayString [EBP+8]
	CALL CrLf

	POP EBP
	RET  4

Farewell ENDP

END main
