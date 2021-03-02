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

; Intro Strings
intro		BYTE "Hi, I'm Kelley. Let's do some random numbers stuff!", 0
describe1	BYTE "First the program will randomly generate ", ARRAYSIZE_T," numbers with values between ", LO_T, " and ", HI_T, ".", 0
describe2	BYTE "Then you will be given the median of these numbers.", 0
describe3	BYTE "Then you will get to see what these numbers look like sorted in ascending order.", 0
describe4	BYTE "Finally the program will print how many of each number we got, starting with the ", LO_T, "s.", 0

; Label Strings
random_msg	BYTE "Here's ", ARRAYSIZE_T, " random numbers, all disorganized:", 0 
median_msg	BYTE "And the median of the numbers is....", 0
exclaim		BYTE "!", 0
sorted_msg	BYTE "This is what they look like sorted:", 0
list_msg	BYTE "And here's the counts of each number, starting with how many ", LO_T, "s there were:", 0 

; Numerical variables
median_num  DWORD ?  ; To be calculated

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
	; CALL fillArray
	; CALL sortList
	; CALL exchangeElements
	; CALL displayMedian
	; CALL displayList
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
	MOV  EDX, [EBP + 24]
	CALL WriteString
	CALL CrLf
	; Display description
	MOV  EDX, [EBP + 20]
	CALL WriteString
	CALL CrLf
	MOV  EDX, [EBP + 16]
	CALL WriteString
	CALL CrLf
	MOV  EDX, [EBP + 12]
	CALL WriteString
	CALL CrLf
	MOV  EDX, [EBP + 8]
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
; Preconditions: 
;
; Postconditions: 
;
; Receives: LO, HI, ARRAYSIZE
;
; Returns: someArray
; ---------------------------------------------------------------------------------
fillArray PROC
fillArray ENDP

; ---------------------------------------------------------------------------------
; Name: sortList
;
; Sorts an array in ascending order.
;
; Preconditions: 
;
; Postconditions:  
;
; Receives: someArray, ARRAYSIZE
;
; Returns: someArray (sorted)
; ---------------------------------------------------------------------------------
sortList PROC
sortList ENDP

; ---------------------------------------------------------------------------------
; Name: exchangeElements
;
; If your sorting algo exchanges element positions, this would loop through the array
;	and swap values at the indicated positions, i and j. 
;
; Preconditions: 
;
; Postconditions:  
;
; Receives: someArray[i], someArray[j]
;
; Returns: The new values of someArray[i] and someArray[j] 
; ---------------------------------------------------------------------------------
exchangeElements PROC	
exchangeElements ENDP

; ---------------------------------------------------------------------------------
; Name: displayMedian
;
; Prints the median of values in the array.
;
; Preconditions: 
;
; Postconditions: 
;
; Receives: median_msg, someArray, ARRAYSIZE
;
; Returns: None
; ---------------------------------------------------------------------------------
displayMedian PROC
displayMedian ENDP

; ---------------------------------------------------------------------------------
; Name: displayList
;
; Prints the array.
;
; Preconditions: 
;
; Postconditions: 
;
; Receives: someArray
;
; Returns: None
; ---------------------------------------------------------------------------------
displayList PROC
displayList ENDP

; ---------------------------------------------------------------------------------
; Name: countList
;
;
;
; Preconditions: 
;
; Postconditions: 
;
; Receives: someArray, ARRAYSIZE, LO, HI
;
; Returns: someArray2
; ---------------------------------------------------------------------------------
countList PROC
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
	MOV  EDX, [EBP + 8]
	CALL WriteString
	CALL CrLf

	POP EBP
	RET  4

farewell ENDP

END main
