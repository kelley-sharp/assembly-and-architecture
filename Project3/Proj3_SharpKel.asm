TITLE Data Validation, Looping, and Constants     (Proj3_SharpKel.asm)

; Author: Kelley Sharp
; Last Modified: 2/07/2021
; OSU email address: sharpkel@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 03                 Due Date: 2/07/2021
; Description: Program prompts user to enter numbers within the specified range. When a non-negative number is entered calculations based on the valid numbers entered are displayed

INCLUDE Irvine32.inc

.data
intro		BYTE "Hi, I'm Kelley. Welcome to the Integer Accumulation Game!", 0
intro_2		BYTE "What is your name? ", 0
rules_1     BYTE "Please enter a number in ranges [-200, -100] or [-50, -1].", 0
rules_2		BYTE "Enter a non-negative number when you are finished to see results", 0
username	BYTE 33 DUP(0) ;string from user input
hello       BYTE "Hello ", 0
instruct	BYTE "Enter number: ", 0
notify		BYTE "Number Invalid!", 0
count		DWORD ?
average		DWORD ?
max			DWORD ?
min 		DWORD ?
sum			DWORD ?


.code
main PROC

; Display program title and programmer's name
	mov EDX, OFFSET intro
	call WriteString
	call CrLf

; Get the user's name
	mov EDX, OFFSET intro_2
	call WriteString
	mov EDX, OFFSET username ; point to the buffer for username
	mov ECX, 32 ;specify max characters at 21
	call ReadString

; Greet user by name
	mov EDX, OFFSET hello
	call WriteString
	mov EDX, OFFSET username
	call WriteString
	call CrLf
	call CrLf

; Display rules to the game
	mov EDX, OFFSET rules_1
	call CrLf
	call WriteString
	mov EDX, OFFSET rules_2
	call CrLf
	call WriteString
	call CrLf

; Get current number from user
_DisplayInstructions:
	mov EDX, OFFSET instruct
	call WriteString
	call ReadInt

; Validate the user input
	cmp EAX, -100
	JE  _TallyNumber ; if the number is equal to -100
	JG	_GreaterThan100Signed ; if the number is greater than -100
	JL  _LessThan100Signed ; if the number is less than -100

_GreaterThan100Signed:
	cmp EAX, 0 
	JGE _DisplayData ; if the number is greater than or equal to zero
	cmp EAX, -50
	JGE  _TallyNumber ; if the number is between -50 and -1
	JL  _NotifyUser ; if the number is also less than -50 (between -100 and -50)

_LessThan100Signed:
	cmp EAX, -200
	JGE  _TallyNumber ; if the number is in between -200 and -100
	JL  _NotifyUser ; if the number is less than -200

_TallyNumber:
	; Increment Count
	; Compute min/max
	; Sum
	; Compute current Rounded Avg
	JMP _DisplayInstructions


; Notify the user of invalid negative numbers
_NotifyUser:
	mov EDX, OFFSET notify
	call WriteString
	call CrLf
	JMP _DisplayInstructions


; Count and accumulate the valid user inputs
_DisplayData:
; Calculate the (rounded integer) average of the valid numbers
; Display count, sum, max, min, and average of the valid numbers 
; Say goodbye (with the user's name)

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
