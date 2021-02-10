TITLE Data Validation, Looping, and Constants     (Proj3_SharpKel.asm)

; Author: Kelley Sharp
; Last Modified: 2/07/2021
; OSU email address: sharpkel@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 03                 Due Date: 2/07/2021
; Description: Program prompts user to enter numbers within the specified range. When a non-negative number is entered calculations based on the valid numbers entered are displayed

INCLUDE Irvine32.inc

.data
; Constants with text-equivalents for easier string interpolation
LOWER_MIN   EQU -200
LOWER_MIN_T EQU <"-200"> 
LOWER_MAX   EQU -100
LOWER_MAX_T EQU <"-100">
UPPER_MIN   EQU -50
UPPER_MIN_T EQU <"-50">
UPPER_MAX   EQU -1
UPPER_MAX_T EQU <"-1">

; Intro & Prompt Strings
intro		BYTE "Hi, I'm Kelley. Welcome to the Integer Accumulation Game!", 0
xtra_cred	BYTE "**EC: Number the lines during user input. Increment the line number only for valid number entries", 0
intro_2		BYTE "What is your name? ", 0
rules_1     BYTE "Please enter a number in ranges [", LOWER_MIN_T, ",", LOWER_MAX_T, "] or [", UPPER_MIN_T, ",", UPPER_MAX_T, "].", 0
rules_2		BYTE "Enter a non-negative number when you are finished to see results.", 0
username	BYTE 33 DUP(0) ;string from user input
hello       BYTE "Hello ", 0
period		BYTE ". ", 0
instruct	BYTE "Enter number: ", 0
notify		BYTE "Number Invalid!", 0

; These variables are for numeric calculations
count		DWORD 0
average		DWORD ?
max			DWORD -201 ; set max to below the lower bound
min 		DWORD 0 ; set min to above the upper bound
sum			DWORD ?
remainder	DWORD 0
half        DWORD 2 ; for dividing by two

; Summary & Conclusion Strings
val_nums1	BYTE "You entered ", 0
val_nums2	BYTE " valid numbers.", 0
max_msg		BYTE "The maximum valid number is ", 0
min_msg		BYTE "The minimum valid number is ", 0
sum_msg		BYTE "The sum of your valid numbers is ", 0
avg_msg		BYTE "The rounded average is ", 0
no_nums		BYTE "No valid numbers entered.", 0 
goodbye		BYTE "Farewell my dear ", 0
exclaim		BYTE "!", 0


.code
main PROC

; Display program title and programmer's name
	mov EDX, OFFSET intro
	call WriteString
	call CrLf
	mov EDX, OFFSET xtra_cred
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
	;Do the first numbered line of user input
	mov EAX, count
	call writeDec
	mov EDX, OFFSET period
	call WriteString

; Get current number from user
_DisplayInstructions:
	mov EDX, OFFSET instruct
	call WriteString
	call ReadInt

; Validate the user input
	cmp EAX, LOWER_MAX
	JE  _TallyNumber ; if the number is equal to LOWER_MAX
	JG	_GreaterThanLowerMaxSigned ; if the number is greater than LOWER_MAX
	JL  _LessThanLowerMaxSigned ; if the number is less than LOWER_MAX

_GreaterThanLowerMaxSigned:
	cmp EAX, 0 
	JGE _DisplayData ; if the number is greater than or equal to zero
	cmp EAX, UPPER_MIN
	JGE  _TallyNumber ; if the number is between UPPER_MIN and UPPER_MAX
	JL  _NotifyUser ; if the number is also less than UPPER_MIN (between LOWER_MAX and UPPER_MIN)

_LessThanLowerMaxSigned:
	cmp EAX, LOWER_MIN
	JGE  _TallyNumber ; if the number is in between LOWER_MIN and LOWER_MAX
	JL  _NotifyUser ; if the number is less than LOWER_MIN

; Do Computations
_TallyNumber:
	; Increment Count 
	INC count
	; Sum
	ADD sum, EAX
 
_UpdateMinMax:
	; Compute min/max
	cmp EAX, min
	JL _UpdateMin
	cmp EAX, max
	JG _UpdateMax
	JMP _CalculateAverage

_CalculateAverage:
	; Compute current rounded average

	; First divide the sum by the count (integer division)
	mov EAX, sum
	CDQ
	IDIV count
	mov average, EAX

	; Then, determine if we need to round up
	; We round up if the remainder is greater than
	;  half of the count
	mov remainder, EDX
	mov EAX, count
	CDQ
	IDIV half
	NEG remainder
	cmp remainder, EAX
	JGE _RoundUp
	; Number the next line of user input
	mov EAX, count
	call writeDec
	mov EDX, OFFSET period
	call WriteString
	; Prompt user again
	JMP _DisplayInstructions

; Rounding "up" is actually decrementing b/c negative
_RoundUp:
	DEC average
	; Number the next line of user input
	mov EAX, count
	call writeDec
	mov EDX, OFFSET period
	call WriteString
	; Prompt user again
	JMP _DisplayInstructions


_UpdateMin:
	mov min, EAX
	JMP _UpdateMinMax

_UpdateMax:
	mov max, EAX
	JMP _UpdateMinMax


; Notify the user of invalid negative numbers
_NotifyUser:
	mov EDX, OFFSET notify
	call WriteString
	call CrLf
	; Number the next line of user input
	mov EAX, count
	call writeDec
	mov EDX, OFFSET period
	call WriteString
	; Prompt user again
	JMP _DisplayInstructions

; Display data 
_DisplayData:
	; Handle the case where no valid numbers are entered
	cmp count, 0
	JE _NoNumbers
	; Display the number of valid numbers entered
	mov EDX, OFFSET val_nums1
	call WriteString
	mov EAX, count
	call WriteDec
	mov EDX, OFFSET val_nums2
	call WriteString
	call CrLf
	; display the max 
	mov EDX, OFFSET max_msg
	call WriteString
	mov EAX, max
	call WriteInt
	call CrLf
	; display the min
	mov EDX, OFFSET min_msg
	call WriteString
	mov EAX, min
	call WriteInt
	call CrLf	
	; display the sum
	mov EDX, OFFSET sum_msg
	call WriteString
	mov EAX, sum
	call WriteInt
	call CrLf
	; display the rounded average
	mov EDX, OFFSET avg_msg
	call WriteString
	mov EAX, average
	call WriteInt
	call CrLf
	JMP _SayGoodbye

_NoNumbers:
	mov EDX, OFFSET no_nums
	call WriteString
	call CrLf
	;Do the first numbered line of user input again
	mov EAX, count
	call writeDec
	mov EDX, OFFSET period
	call WriteString
	;Prompt user again
	JMP _DisplayInstructions 



; Say goodbye (with the user's name)
_SayGoodbye:
	call CrLf
	call CrLf
	mov EDX, OFFSET goodbye
	call WriteString
	mov EDX, OFFSET username
	call WriteString
	mov EDX, OFFSET exclaim
	call WriteString
	call CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
