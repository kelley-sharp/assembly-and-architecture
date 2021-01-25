TITLE Basic Logic and Arithmetic Program     (Proj1_SharpKel.asm)

; Author: Kelley Sharp
; Last Modified: 1/24/2021
; OSU email address: sharpkelD@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 01                 Due Date: 1/24/2021
; Description: Program that asks the user for three numbers in descending order, calculates basic aritmetic involving these numbers and displays the results

INCLUDE Irvine32.inc

.data

Intro BYTE "Hi, I'm Kelley and I'm here to show you some basic arithmetic based on the numbers you give me.", 0 
Prompt_1 BYTE "Enter three numbers in descending order.", 0
Prompt_A BYTE "First number: ", 0
Prompt_B BYTE "Second number: ", 0
Prompt_C BYTE "Third number: ", 0
Int_A DWORD ?
Int_B DWORD ?
Int_C DWORD ?
add_symb BYTE " + ", 0
sub_symb BYTE " - ", 0
equ_symb BYTE " = ", 0
A_add_B DWORD ?     ; To be calculated
A_sub_B DWORD ?     ; To be calculated
A_add_C DWORD ?     ; To be calculated
A_sub_C DWORD ?     ; To be calculated  
B_add_C DWORD ?     ; To be calculated
B_sub_C DWORD ?     ; To be calculated
A_add_B_add_C DWORD ?     ; To be calculated
Outro BYTE "Thanks for using my program, goodbye!", 0

.code
main PROC

; Introduction
mov EDX, OFFSET Intro
call WriteString
call CrLf
call CrLf

; Get data from the user
mov EDX, OFFSET Prompt_1
call WriteString
call CrLf

	;Get first number
mov EDX, OFFSET Prompt_A
call WriteString
	; Pre-conditions of ReadDec: none
call ReadDec
	; Post-conditions of ReadDec: value is stored in EAX
mov Int_A, EAX

	;Get second number
mov EDX, OFFSET Prompt_B
call WriteString
call ReadDec
mov Int_B, EAX

	;Get third number
mov EDX, OFFSET Prompt_C
call WriteString
call ReadDec
mov Int_C, EAX
call CrLf
call CrLf

; Calculate the required values
	;A+B
mov EAX, Int_A
ADD EAX, Int_B
mov A_add_B, EAX
	;A+B+C
mov EBX, Int_C
ADD EBX, A_add_B
mov A_add_B_add_C, EBX
	;A-B
mov EAX, Int_A
SUB EAX, Int_B
mov A_sub_B, EAX
	;A+C
mov EAX, Int_A
ADD EAX, Int_C
mov A_add_C, EAX
	;A-C
mov EAX, Int_A
SUB EAX, Int_C
mov A_sub_C, EAX
	;B+C
mov EAX, Int_B
ADD EAX, Int_C
mov B_add_C, EAX
	;B-C	
mov EAX, Int_B
SUB EAX, Int_C
mov B_sub_C, EAX

; Display the results
	;A+B
mov EAX, Int_A
call WriteDec
mov EDX, OFFSET add_symb
call WriteString
mov EAX, Int_B
call WriteDec
mov EDX, OFFSET equ_symb
call WriteString
mov EAX, A_add_B
call WriteDec
call CrLf
	;A-B
mov EAX, Int_A
call WriteDec
mov EDX, OFFSET sub_symb
call WriteString
mov EAX, Int_B
call WriteDec
mov EDX, OFFSET equ_symb
call WriteString
mov EAX, A_sub_B
call WriteDec
call CrLf
	;A+C
mov EAX, Int_A
call WriteDec
mov EDX, OFFSET add_symb
call WriteString
mov EAX, Int_C
call WriteDec
mov EDX, OFFSET equ_symb
call WriteString
mov EAX, A_add_C
call WriteDec
call CrLf
	;A-C
mov EAX, Int_A
call WriteDec
mov EDX, OFFSET sub_symb
call WriteString
mov EAX, Int_C
call WriteDec
mov EDX, OFFSET equ_symb
call WriteString
mov EAX, A_sub_C
call WriteDec
call CrLf
	;B+C
mov EAX, Int_B
call WriteDec
mov EDX, OFFSET add_symb
call WriteString
mov EAX, Int_C
call WriteDec
mov EDX, OFFSET equ_symb
call WriteString
mov EAX, B_add_C
call WriteDec
call CrLf
	;B-C
mov EAX, Int_B
call WriteDec
mov EDX, OFFSET sub_symb
call WriteString
mov EAX, Int_C
call WriteDec
mov EDX, OFFSET equ_symb
call WriteString
mov EAX, B_sub_C
call WriteDec
call CrLf
	;A+B+C
mov EAX, Int_A
call WriteDec
mov EDX, OFFSET add_symb
call WriteString
mov EAX, Int_B
call WriteDec
mov EDX, OFFSET add_symb
call WriteString
mov EAX, Int_C
call WriteDec
mov EDX, OFFSET equ_symb
call WriteString
mov EAX, A_add_C
call WriteDec
call CrLf
call CrLf

; Say goodbye
mov EDX, OFFSET Outro
call WriteString
call CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
