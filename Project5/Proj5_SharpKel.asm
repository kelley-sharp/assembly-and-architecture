TITLE Arrays, Addressing, and Stack-Passed Parameters     (Proj5_SharpKel.asm)

; Author: Kelley Sharp
; Last Modified: 2/28/2021
; OSU email address: sharpkel@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 05                 Due Date: 2/28/2021
; Description: After an introduction, the program generates an array with 200 random numbers between 10 and 29.
;	The random numbers are printed and the program displays the median value of the array.
;	The numbers are sorted in ascending order and printed.
;	Then starting with 10s, the number of instances for each number is displayed
;	and the program says goodbye. 

INCLUDE Irvine32.inc
ExitProcess proto, dwExitCode:dword

.data
; Global Constants (with text-equivalents for easier string interpolation)
LO			EQU 10
LO_T		EQU <"10">
HI			EQU 29
Hi_T		EQU <"29">
ARRAYSIZE	EQU 200
ARRAYSIZE_T EQU <"200">
PER_LINE    EQU 20

; Intro Strings
intro		BYTE "Hi, I'm Kelley. Let's do some random numbers stuff!", 0
describe1	BYTE "First the program will randomly generate ", ARRAYSIZE_T," numbers with values between ", LO_T, " and ", HI_T, ".", 0
describe2	BYTE "Then you will be given the median of these numbers.", 0
describe3	BYTE "Then you will get to see what these numbers look like sorted in ascending order.", 0
describe4	BYTE "Finally the program will print how many of each number we got, starting with the ", LO_T, "s.", 0

; Label/Misc Strings
random_msg	BYTE "Here's ", ARRAYSIZE_T, " random numbers, all disorganized:", 0 
median_msg	BYTE "And the median of the numbers is....", 0
exclaim		BYTE "!", 0
sorted_msg	BYTE "This is what they look like sorted:", 0
list_msg	BYTE "And here's the counts of each number, starting with how many ", LO_T, "s there were:", 0
space       BYTE " ", 0

; Numerical variables
arr			DWORD ARRAYSIZE DUP(?)
arrType		DWORD TYPE arr
arrBytes    DWORD SIZEOF arr
countsArr    DWORD ARRAYSIZE DUP(?)
median_num  DWORD ?  ; To be calculated
perLineIdx  DWORD 0 ; for iterating displayList per line

; Summary & Conclusion Strings
goodbye		BYTE "Hope this wasn't too random, bye!", 0

.code
main PROC

	PUSH OFFSET intro
	PUSH OFFSET describe1
	PUSH OFFSET describe2
	PUSH OFFSET describe3
	PUSH OFFSET describe4
	CALL introduction

	PUSH OFFSET arr
	PUSH LO
	PUSH HI
	PUSH ARRAYSIZE
	CALL fillArray

	PUSH perLineIdx
	PUSH OFFSET space
	PUSH PER_LINE
	PUSH OFFSET arr
	PUSH ARRAYSIZE
	PUSH OFFSET random_msg
	CALL displayList

	PUSH OFFSET arr
	PUSH ARRAYSIZE
	CALL sortList

	PUSH OFFSET arr
	PUSH ARRAYSIZE
	PUSH OFFSET median_msg
	CALL displayMedian


	PUSH perLineIdx
	PUSH OFFSET space
	PUSH PER_LINE
	PUSH OFFSET arr
	PUSH ARRAYSIZE
	PUSH OFFSET sorted_msg
	CALL displayList

	; <--- below is incomplete - ran out of time :-(  ---->
	; PUSH OFFSET space
	; PUSH LO
	; PUSH HI
	; PUSH OFFSET countsArr
	; PUSH OFFSET arr
	; PUSH ARRAYSIZE
	; PUSH OFFSET list_msg
	; CALL countList

	PUSH OFFSET goodbye
	CALL farewell

	Invoke ExitProcess, 0
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Displays programmer's name and a description of the program.
; ---------------------------------------------------------------------------------
introduction PROC
	PUSH EBP
	MOV  EBP, ESP 

	; Display programmer's name and enthusiastic message
	MOV  EDX, [EBP+24]
	CALL WriteString
	CALL CrLf
	CALL CrLf
	; Display description
	MOV  EDX, [EBP+20]
	CALL WriteString
	CALL CrLf
	MOV  EDX, [EBP+16]
	CALL WriteString
	CALL CrLf
	MOV  EDX, [EBP+12]
	CALL WriteString
	CALL CrLf
	MOV  EDX, [EBP+8]
	CALL WriteString
	CALL CrLf	

	POP  EBP
	RET  20

introduction ENDP

; ---------------------------------------------------------------------------------
; Name: fillArray
;
; Fills an array with randomly generated numbers.
;
; Preconditions: empty arr, two inclusive bounds
;
; Postconditions: arr is populated with random numbers within bounds
;
; Receives: ARRAYSIZE, HI, LO, arr
;
; ---------------------------------------------------------------------------------
fillArray PROC
	LOCAL hiAdjusted:DWORD  ; store the value of HI - LO for randomization

	_preserveRegisters:
		PUSH  EAX
		PUSH  ECX
		PUSH  EDI

	CALL Randomize

	_generateHiAdjusted:
		MOV   EAX, [EBP+12] ; HI
		MOV   EBX, [EBP+16] ; LO
		SUB   EAX, EBX
		INC   EAX
		MOV   hiAdjusted, EAX

	_setupLoop:
		MOV   ECX, [EBP+8]  ; loop counter through length of array
		MOV   EDI, [EBP+20]  ; set EDI to first array element

	_fillLoop:
		MOV   EAX, hiAdjusted  ; get a random number between [LO, HI]
		CALL  RandomRange
		ADD   EAX, [EBP+16] ; add LO to randomized number
		MOV   [EDI], EAX  ; set array element
		MOV   EAX, [EDI]
		ADD   EDI, 4  ; go to next array element
		LOOP  _fillLoop

	_restoreRegisters:
		POP   EDI
		POP   ECX
		POP   EAX

	RET  16
fillArray ENDP

; ---------------------------------------------------------------------------------
; Name: sortList
;
; Sorts an array in ascending order using a bubble-sort algorithm.
;
; Preconditions: arr is unsorted random array
;
; Postconditions:  arr is sorted in-place
;
; Receives: ARRAYSIZE, arr
;
; ---------------------------------------------------------------------------------
sortList PROC
	_preserveRegisters:
	    PUSH  EBP
		MOV   EBP, ESP
		PUSH  EAX
		PUSH  EBX
		PUSH  ECX
		PUSH  EDX
		PUSH  EDI
		PUSH  ESI

	_setupLoop:
		MOV   ECX, [EBP+8]  ; loop counter through length of array
		DEC   ECX  ; loop up to n - 1

	_outerLoop:
		PUSH  ECX  ; store ECX (inner loop will change this)
		MOV   EDI, [EBP+12]

	_innerLoop:
		; comparison of i with j
		MOV   EAX, [EDI]
		MOV   EBX, [EDI+4]
		CMP   EBX, EAX
		JGE    _continueInnerLoop

		; otherwise swap to ensure ascending order
		PUSH  EDI
		CALL exchangeElements

	_continueInnerLoop:
		ADD   EDI, 4
		LOOP  _innerLoop

	_continueOuterLoop:
		POP  ECX
		LOOP _outerLoop

	_restoreRegisters:
	    POP   ESI
		POP   EDI
		POP   EDX
		POP   ECX
		POP   EBX
		POP   EAX
		POP   EBP

	RET  16
sortList ENDP

; ---------------------------------------------------------------------------------
; Name: exchangeElements
;
; This is the swap procedure of the above sorting algorithm
;
; Preconditions: arr[i] and arr[j] are in unsorted order
;
; Postconditions:  arr[i] and arr[j] are swapped
;
; Receives: arr[i], arr[j]
;
; ---------------------------------------------------------------------------------
exchangeElements PROC
	_preserveRegisters:
		PUSH  EBP
		MOV   EBP, ESP
		PUSH  EAX
		PUSH  EBX
		PUSH  ECX
		PUSH  EDI

	_swap:
		MOV EDI, [EBP+8]  ; move first index into EDI
		MOV EAX, [EDI]  ; move first element to EAX
		MOV EBX, [EDI+4] ; move second element to EBX
		MOV [EDI], EBX ; assign first index to second element
		MOV [EDI+4], EAX  ; assign second index to first element


	_restoreRegisters:
		POP   EDI
		POP   ECX
		POP   EBX
		POP   EAX
		POP   EBP

	RET  4
exchangeElements ENDP

; ---------------------------------------------------------------------------------
; Name: displayMedian
;
; Prints the median of values in the array.
;
; Preconditions: sorted arr
;
; Postconditions: median value of sorted arr calculated & printed
;
; Receives: median_msg, ARRAYSIZE, arr
;
; ---------------------------------------------------------------------------------
displayMedian PROC
	_preserveRegisters:
		PUSH  EBP
		MOV   EBP, ESP
		PUSH  EAX
		PUSH  EBX
		PUSH  ECX
		PUSH  EDX
		PUSH  EDI

	_displayMsg:
		CALL CrLf
		CALL CrLf
		MOV  EDX, [EBP+8] 
		CALL WriteString
		CALL CrLf

	_computeMedian:
		MOV  EDI, [EBP+16] ; array itself
		MOV  EAX, [EBP+12] ; size of array
		CDQ
		MOV EBX, 2 ; divide by 2 and check remainder
		DIV EBX
		CMP EDX, 0
		JE _even
		MOV ECX, [EDI+EAX*4] ; get the middle element
		MOV EAX, ECX
		JMP _printMedian

	_even:
		MOV ECX, [EDI+EAX*4] ; get lower middle
		INC EAX
		MOV EDX, [EDI+EAX*4] ; get upper middle
		ADD ECX, EDX
		MOV EAX, ECX
		CDQ
		MOV EBX, 2
		DIV EBX
		JMP _printMedian

	_printMedian:
		CALL WriteDec
		CALL CrLF
		jmp _restoreRegisters



	_restoreRegisters:
	    POP   EDI
		POP   EDX
		POP   ECX
		POP   EBX
		POP   EAX
		POP   EBP

	RET  12

displayMedian ENDP

; ---------------------------------------------------------------------------------
; Name: displayList
;
; Prints the array with a specific number of items per line (default is 20).
;
; Preconditions: arr is populated
;
; Postconditions: arr is printed to the console
;
; Receives: sorted_msg, ARRAYSIZE, arr, PER_LINE, space, perLineIdx
;
; ---------------------------------------------------------------------------------
displayList PROC

	_preserveRegisters:
		PUSH EBP
		MOV  EBP, ESP
		PUSH EDX
		PUSH ECX
		PUSH EBX
		PUSH EAX
		PUSH EDI

	_printTitle:
		CALL CrLf
		MOV  EDX, [EBP+8]
		CALL WriteString
		CALL CrLf

	_setUpLoop:
		MOV  ECX, [EBP+12]  ; loop counter through length of array
		MOV  EDI, [EBP+16]  ; set EDI to first array element
		JMP  _printLoop

	_printLoop:
		; print the number
		MOV  EAX, [EDI]
		CALL WriteDec
		; print the space between
		MOV  EDX, [EBP+24]
		CALL WriteString
		ADD  EDI, 4  ; go to next array element

		; check if newline is needed
		MOV  EBX, [EBP+28]
		INC  EBX ; increment perLineIdx
		MOV  [EBP+28], EBX
		MOV  EBX, [EBP+20] ; perLine 
		CMP  EBX, [EBP+28] ; perLineIdx == perLine ?
		JE   _newLine
		JNE  _noNewLine

		_newLine:
			CALL CrLf
			MOV EBX, 0
			MOV [EBP+28], EBX ; reset perLineIdx

		_noNewLine:
			LOOP _printLoop

	_restoreRegisters:
		POP  EDI
		POP  EDX
		POP  ECX
		POP  EBX
		POP  EAX
		POP  EBP
		RET  24
displayList ENDP

; ---------------------------------------------------------------------------------
; Name: countList
;
; TBD
;
; ---------------------------------------------------------------------------------
countList PROC

	_preserveRegisters:
		PUSH EBP
		MOV  EBP, ESP
		PUSH EDX
		PUSH ECX
		PUSH EBX
		PUSH EAX
		PUSH EDI

	_printTitle:
		CALL CrLf
		MOV  EDX, [EBP+8]
		CALL WriteString
		CALL CrLf

	_setUpLoop:
		MOV  ECX, [EBP+12]  ; loop counter through length of array
		MOV  EDI, [EBP+16]  ; set EDI to first array element
		MOV  EAX, 0   ; store counts

	_countLoop:
		INC  EAX
		MOV EBX, [EDI] ; store value at EDI
		ADD EDI, 4
		CMP EBX, [EDI] ; check if the next is the same
		JNE  _printCount

	_printCount:
		; print the number and reset EAX
		CALL WriteDec
		MOV EAX, 0
		; print the space between
		MOV  EDX, [EBP+36]
		CALL WriteString

	_restoreRegisters:
		POP  EDI
		POP  EDX
		POP  ECX
		POP  EBX
		POP  EAX
		POP  EBP
		RET  28

countList ENDP

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
