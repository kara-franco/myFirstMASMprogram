TITLE Sorting Random Integers																		(sorting-random-integers.asm)

; Author: Kara Franco
; CS 271-400 
; Programming Assigment #4   
; Due Date: August 2, 2015
;
; Description: A MASM program that sorts random numbers in descending order and displays the median. The user will 
; request the number of random numbers to generate and the program will display the numbers unsorted. Next, the program 
; will sort the numbers in descending order and display the median. Lastly, the sorted list will be displayed. 


INCLUDE Irvine32.inc


.data

;  GLOBAL CONSTANTS
	MIN = 10
	MAX = 200
	LO = 100
	HI = 999

; named variables
	request		DWORD	?
	array		DWORD	MAX   DUP(?)
	

; display messages
	displayName		BYTE	" --- Sorting Random Integers                                                     by Kara Franco ---", 0		
	extraMessage	BYTE	"           **Extra Credit #1: Display the numbers ordered by column instead of by row.** ", 0
	introMessage	BYTE	"   This program will generate random numbers for you in the range of [100 ... 999]. It will display" , 0Dh, 0Ah 
					BYTE	"   the unsorted list, the median of the list and the sorted list in descending order!", 0
	promptMessage	BYTE	"   Please enter how many numbers you would like to be generated in the range of [10 ... 200:  ", 0
	errorMessage	BYTE	" Opps, invalid input, please try again!", 0
	unsortMessage	BYTE	" The unsorted list is: ", 0
	sortMessage		BYTE	" The sorted list is: ", 0
	columnSpace		BYTE	"   ", 0
	medianMessage	BYTE	" The median of the list is: ", 0
	farewelMessage	BYTE	" Thank you, have a wonderful day! ", 0


.code

main PROC
	
; Introduction Section
	call	introduction

; Get Data Section
	push	OFFSET request
	call	getData
		

; Fill Array Section
	push	OFFSET array																
	push	request																		
	call	fillArray

; Display Unstorted Section
	
	push	OFFSET unsortMessage  
	push	OFFSET array 
	push	request 
	call	displayList

; Sort the Array Section
	push	OFFSET array 
	push	request 
	call	sortList

; Calculation and Display of Median Section
	push	OFFSET medianMessage  
	push	OFFSET array 
	push	request 
	call	displaymedian

; Display Sorted Section
	push	OFFSET sortMessage 
	push	OFFSET array 
	push	request 
	call	displayList

; Display Farewell Section
	call	farewell

invoke ExitProcess,0
main ENDP

;-------------------------------------------------------------------------------
; introduction PROC Description:
;
; Displays an introduction of the Sorting Random Numbers program to the user 
; and gives the user instructions.
;
; Receives: procedure uses global variable strings 
; Returns: nothing is returned
; Preconditions: no preconditions
; Registers Used: eax, edx 
;------------------------------------------------------------------------------- 

introduction PROC

	; set color to magenta 
		mov		eax, 5
		call	SetTextColor
	
	; user will be introduced to the program and given directions

	; display program title and programmer name
		call	CrLf
		mov		edx, OFFSET displayName
		call	WriteString
		call	CrLf
		call	CrLf

	; display the extra credit message
		mov		edx, OFFSET extraMessage
		call	WriteString
		call	CrLf
		call	CrLf

		; set color to slate blue 
		mov		eax, 3
		call	SetTextColor

	; display instruction for the user
		mov		edx, OFFSET introMessage
		call	WriteString
		call	CrLf
		call	CrLf
		
		ret
introduction ENDP

; -------------------------------------------------------------------------------
; getData PROC Description	
;	
; Displays a prompt for a user to enter the number of random numbers to 
; generate (request). If the user enters a number outside the range [10 ... 200]
; then user will be prompted again. 
;
; Receives: request (by reference)
; Returns: no data is returned 
; Preconditions: no preconditions
; Registers Used: eax, ebp, edi, edx
; References Used: Lecture 19 and Kip Irvine Assembly Language for x86 (ch 8)
; -------------------------------------------------------------------------------

getData PROC
	
	; set color to olive green
		mov		eax, 6
		call	SetTextColor
	
	; set up stack frame
		push	ebp
		mov		ebp, esp
		pushad
		
	; the addresss of request is now in edi
		mov		edi, [ebp + 8]

		returnToPrompt:
	; prompt the user to enter the amount of random numbers wanted (request)
	; user will be sent back here if the number is entered incorrectly
		
		mov		edx, OFFSET promptMessage
		call	WriteString
		call	ReadInt
		call	CrLf

	; compare the number entered to MIN (10) and MAX (200)
	; if number is too high or too low send errormessage
		cmp		eax, MIN
		jl		toErrorMessage
		cmp		eax, MAX
		jg		toErrorMessage
		jmp		exitProcedure

		toErrorMessage: 
	; after the error message send user back to number prompt 
		mov		edx, OFFSET errorMessage
		call	WriteString
		call	CrLf
		call	CrLf
		jmp		returnToPrompt

		exitProcedure:
	; save the number requested to edi register
		mov		[edi], eax

	; retore stack frame
		popad
		pop		ebp
		
		ret	4
getData	ENDP

	

; -----------------------------------------------------------------------------
; fillArray PROC Description	
;	
; Generates the random nummbers using RandomRange (Irvine Library) and saves 
; the numbers generated in the array named array.
; 
; Receives: request (by value) and array (by reference)
; Returns: array of random numbers generated saved in edi
; Preconditions: the user has requested a number in range
; Registers Used: ebp, edi, ecx, eax 
; References Used: Lecture 19 and Kip Irvine Assembly Language for x86 (ch. 9)
; ------------------------------------------------------------------------------

 fillArray PROC
	
	; call Randomize once to set up seed 
		call	Randomize

		; set up stack frame
		push	ebp
		mov		ebp, esp
		; array address starts here, put in edi
		mov		edi, [ebp + 12] 
		; value of request will be ecx count
		mov		ecx, [ebp + 8] 

	fillMore:
	; to find range: HI - LO + 1
		mov		eax, HI
		sub		eax, LO
		inc		eax

		call	RandomRange
		; add LO (100) to keep number in range 
		; example: random = 2 ---> 2 + 100 = 102 (in range)
		add		eax, LO  
	
	; move random number that was just generated into edi (array)
		mov		[edi], eax 
	; add 4 (DWORD) to next element holder	
		add		edi, 4
		loop	fillMore

	; restore stack frame
		pop		ebp
		ret		8
fillArray ENDP



; ------------------------------------------------------------------------
; sortList PROC Description	
; 	
; Procedure that uses the BubbleSort algorithm to sort the array in 
; descending order.
; 
; Receives: request (by value) and array (by reference)
; Returns: global data returned
; Preconditions: no preconditions
; Registers Used: eax, edx, 
; References: Kip Irvine Assembly Language for x86 (ch. 9)
; -------------------------------------------------------------------------

sortList PROC
	
	; set up stack frame
	push	ebp
	mov		ebp, esp
	; array address starts here, move to edi
	mov		edi, [ebp + 12] 
	; value of request will be ecx count
	mov		ecx, [ebp + 8]  	
	dec		ecx
		
	loopOne:
		push	ecx
	; use esi to look at elements, beginning at the first element
		mov		esi, edi
		
	loopTwo:
	; hold element in eax to compare to the next element in array (esi + 4)
		mov		eax, [esi]
		cmp		[esi + 4], eax
	; if the element is less then keep it where it is and go to next element
		jl		loopThree
	; if element to the right is greater, than exchange the elements location
		xchg	eax, [esi + 4]
		mov		[esi], eax
		
	loopThree: 
	; add 4 (DWORD) to access next element
		add		esi, 4
		loop	loopTwo
		pop		ecx
		loop	loopOne

		pop		ebp
		
		ret		8
sortList ENDP



; -----------------------------------------------------------------------------
; displayMedian PROC Description
;		
; A procedure that takes in a sorted list and finds the median. If the array
; has an even amount of elements then it will take the two middle elements,
; add them, and divide by 2. 
;
; Receives: request (by value) , array (by reference) and title (by reference)
; Returns: a title and the median of the sorted array
; Preconditions: the array must be sorted
; Registers Used: eax, ebp, esp, edx, esi, ecx
; -----------------------------------------------------------------------------

	
displayMedian PROC
	
	; set color to gray
		mov		eax, 8
		call	SetTextColor
	
	; set up stack frame
		push	ebp 
		mov		ebp, esp
	
	; address of title stored in edx
		mov		edx, [esp + 16] 
	; address of array starts here 
		mov		esi, [ebp + 12] 
	; request variable	
		mov		ecx, [ebp + 8]  

	; display the title 
		call	CrLf
		call	WriteString
		call	CrLf
	
	; divide request number by 2 to see if it is even or odd

		mov		eax, [ebp + 8] ; address of request 
		cdq	
		mov		ebx, 2
		div		ebx
		cmp		edx, 0
		je		evenMedian

	; if odd, get the middle elements position in memory (by dividing by the type (DWORD = 4))	
		mov		ebx, 4
		mul		ebx
	; place the value of the middle element into eax to display 	
		add		esi, eax
		mov		eax, [esi]

		mov		edx, OFFSET columnSpace
		call	WriteString
		
	; display the median	
		call	WriteDec
		call	CrLf
		jmp		medianEnd

	; if the array had an even number of elements we are sent here
		evenMedian: 

	; get the value that is nearest the middle (element)
		mov		ebx, 4
		mul		ebx
	; place that value in eax	
		add		esi, eax
		mov		eax, [esi]
	; hold value in edx, so we can add it to the number below
		mov		edx, eax 
	; subtract 4 to access the element below
		sub		esi, 4
		mov		eax, [esi]
	; add the two elements together
		add		edx, eax
	; divide the elements to get the median
		mov		eax, edx
		mov		edx, 0
		mov		ebx, 2
		div		ebx
	
	; element is rounded by not including the value in edx
	; display the value
		mov		edx, OFFSET columnSpace
		call	WriteString
		
		call	WriteDec
		call	CrLf

	medianEnd:

	; restore stack frame
		pop		ebp
		ret		8

displayMedian ENDP	



; -----------------------------------------------------------------------------
; displayList PROC Description	
;	
; A procedure that displays both the sorted and unsorted lists. 
;
; Receives: request (by value), array (by reference) and title (by reference)
; Returns: displays list
; Preconditions: array must be initialized and filled
; Registers Used: eax, ebp, esp, esi, ecx, edx
; References: Lecture 20
; -----------------------------------------------------------------------------

displayList PROC
	
	; set color to kelly green
		mov		eax, 2
		call	SetTextColor
	
	; set up stack frame
		push	ebp 
		mov		ebp, esp
	
	
	; address of title stored in edx
		mov		edx, [esp + 16] 
	; address of array starts here
		mov		esi, [ebp + 12]
	; address of request for loop control (array size)
		mov		ecx, [ebp + 8] 
	
	; display the title
		call	CrLf
		call	WriteString
		call	CrLf


	; loop to display the items in the array (array size is the counter)
	moreToPrint:
	
	mov		edx, OFFSET columnSpace
		call	WriteString

	; current element to be printed
		mov		eax, [esi] 
		call	WriteDec
		call	CrLf
	

	; add 4 (DWORD) to access the next element
		add		esi, 4 
		loop	moreToPrint


	endPrinting:
		call	CrLf
	
	; restore stack frame
		pop		ebp
		ret		8
displayList ENDP	



; ------------------------------------------------------------------------
; farewell PROC Description	
;	
; A procedure that displays a farewell message to the user. 
;
; Receives: global string variable
; Returns: displays the farewell message
; Preconditions: no preconditions
; Registers Used: eax, edx
; -------------------------------------------------------------------------

farewell	PROC

	; set color to slate blue 
		mov		eax, 3
		call	SetTextColor


	; display program farwwell message
		call	CrLf
		mov		edx, OFFSET farewelMessage
		call	WriteString
		call	CrLf
		call	CrLf

ret 
farewell ENDP

END main