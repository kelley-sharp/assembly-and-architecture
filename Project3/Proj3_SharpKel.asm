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
intro_2		BYTE "What is your name?", 0
username	BYTE 33 DUP(0) ;string from user input
hello       BYTE "Hello ", 0
instruct	BYTE ". Please enter a number in ranges [-200, -100] or [-50, -1].", 0
notify		BYTE "That is and invalid negative number.", 0
count		DWORD ?
average		DWORD ?
max			DWORD ?
min 		DWORD ?


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


; Greet user by name and display instructions
	mov EDX, OFFSET hello
	call WriteString
	mov EDX, OFFSET username
	call WriteString

; Get current number from user
_DisplayInstructions:
	call WriteString
	mov EDX, OFFSET instruct
	call WriteString
	call ReadInt

	call ReadInt


; Validate the user input
ifValid:
	cmp EAX, -100
	JG	_SecondCheck ; if the number is greater than -100
	cmp EAX, -200
	JL  _NotifyUser ; if the number is less than -200
_SecondCheck:
	cmp EAX, -50
	JL _NotifyUser ; if the number is also less than -50
	cmp EAX, 0 
	JAE _DataDisplay ; if the number is greater than or equal to zero
	
	; jump to DisplayInstructions


; Notify the user of invalid negative numbers
_NotifyUser:
	mov EDX, OFFSET notify
	call WriteString


; Count and accumulate the valid user inputs
_DataDisplay:
; Calculate the (rounded integer) average of the valid numbers
; Display count, sum, max, min, and average of the valid numbers 
; Say goodbye (with the user's name)

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
