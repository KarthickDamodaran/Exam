    AREA     appcode, CODE, READONLY
     EXPORT __main
     IMPORT printMsg
	 IMPORT printMsg2p
	 IMPORT printMsg4p
     ENTRY
	 ;IMPORTANT COMMENTS; RADIUS PRESENT IN S30
;x coordinate of pixel is in s18 (which changes in course of iteration and is getting printed by printmsg2p)
;y coordinate of pixel is in s19 (which changes in course of iteration and is getting printed by printmsg2p)
;the pixel points (x,y) appear on the format x y on every line on the terminal
;Since x and y get always printed together, I used the printmsg routine to print x seperately and y seperately and then I copied to excel sheet.
__main  FUNCTION	
     VLDR.F32 s17,=0;initial theta
	 VLDR.F32 s30,=100 ;radius
	 MOV r3,#0;incremented to see if required theta range is covered, Theta incremented in steps of 1 degree
	 MOV r9,#361 ;(Total Angle in a circle +1 for comparison and branching)
	 BL printMsg; called to print the table heading "x y"
pin  VLDR.F32 s6,=30;Number of series terms required in exp(x);cos series is calculated by ignoring odd powers and vice versa for sin
	 VLDR.F32 s5,=1;s5 initialised with 1 for incrementing various other registers
	 VLDR.F32 s8,=0;Holds the 'n' value i.e to calculate x^n in the series expansion
	 VLDR.F32 s9,=0;Holds the final sin or cos value from where it is taken for processing like addition of centre offset
	 VLDR.F32 s11,=0;
     VLDR.F32 s18,=240;x coordinate on VGA screen, centre of circle's x coordinate
     VLDR.F32 s19,=330;y coordinate on VGA screen, centre of circle's x coordinate
	 MOV r5,#1;used for comparison purposes
	 MOV r6,#0;used to keep track if it is an odd power or even power. if odd power, accumulated for sin and vice versa
	 MOV r7,#0;used to keep track the alternating signs in cos and sine series
	 MOV r8,#0;
	 BL cos;calling subroutine to compute x=r*cos theta + x offset
	 VLDR.F32 s8,=0
	 VLDR.F32 s9,=0
	 VLDR.F32 s11,=0
     
	 MOV r5,#1
	 MOV r6,#0
	 MOV r7,#0
	 MOV r8,#0
     
	 ;The above few lines after BL cos restore the contents before calling sin subroutine
	 BL sin;calling subroutine to compute y=r*sin theta + y offset
	 BL printMsg2p;printing (x,y) as "x y",where x=r*cos(theta)+x offset on VGA;y=r*sin(theta)+y offset on VGA
	 ADD r3,r3,#1;loop count incremented
	 VADD.F32 s17,s17,s5;increment theta
     CMP r3,r9;increment loop count and repeat till required theta range is covered
	 BLT pin
	 
stop B stop
;General Algorithm followed in calculating sin or cos:
;1. Take input argument theta in degrees and convert to radian.(stored in s3 register)
;2. calculate factorial whose result is available in s7 register.n! is calculated where n is the current iteration count
;3. calculate x^n and store in s4 register.
;4. calculate x^n/n! by using VDIV and store it back in s4 register
;5. If iteration count is even, accumulate the corresponding terms with alternate signs for the cosine series
;6. If iteration count is odd, accumulate te corresponding terms with alternate signs for the sine series
;	2 through 6 are repeated till we calculate the required number of series terms;
;7. Give the required offset so as to shift the centre of the circle from (0,0) to some other point.
;8. Convert and print in integer form.
;9. repeat till the entire theta range is covered.

;subroutine for calculating cos
cos  VLDR.F32 s7,=1;s7 used to hold factorial result of an iteration. initialised with 1 for 0!
     VMOV.F32 s10,s8;s8 contains the current 'n', stored in s10 to be retrieved later
loop VCMP.F32 s8, #0;check if n==0
     vmrs    APSR_nzcv, FPSCR
     BEQ next;if n==0, leave s7 undisturbed
     VMUL.F32 s7,s8,s7;else compute n! iteratively till n reaches 0
     VSUB.F32 s8,s8,s5
     B loop
	 
next VMOV.F32 s8,s10;current 'n' retrieved for calculating x^n
     VMOV.F32 s3,s17;input theta in degrees copied to s3 register
     VLDR.F32 s16,=0.01745329251;pi/180 factor to convert input degree to radian value
     VMUL.F32 s3,s16,s3;radian=degree*pi/180
	 VLDR.F32 s5,=1
	 VLDR.F32 s4,=1;s4 to contain x^n, initialised with 1 as x^0=1
	 VCMP.F32 s8,#0;if n==0,x^n=1 and hence leave s4 undisturbed
	 vmrs    APSR_nzcv, FPSCR
	 BEQ new
	 
term VMUL.F32 s4,s4,s3;else compute x^n iteratively, where x is the input in radian available in s3
     VSUB.F32 s8,s8,s5;decrementing n;n=n-1
	 VCMP.F32 s8,#0;
	 vmrs    APSR_nzcv, FPSCR
	 BGT term
	 
	 
	 
new  VDIV.F32 s4,s4,s7;calculating the series term as(x^n)/n!
     AND r6,r6,#1;checking if 'n' even or dd
     CMP r6,r5;r5 has 1 in it. checking if 'n' is even by using BLT
	 BLT func;;r6<r5 only when r6=0, i.e n is even. if n is even use the term for cos series. ignore odd terms. Just the reverse for sine
ret	 ADD r6,r6,#1;increment r6 i.e 'n'
	 VMOV.F32 s8,s10;retreiving iteration count
	 VADD.F32 s8,s8,s5;increment 'n';both s8 and r6 are incremented together as both have the same 'n' in different forms for different purposes
	 VCMP.F32 s8,s6;check if required series terms calculated
	 vmrs    APSR_nzcv, FPSCR
	 BLT cos;if there are few more terms to be calculated, repeat the process
	 VMUL.F32 s9,s9,s30;once cos theta is available, we calculate r*cos theta
	 VADD.F32 s9,s9,s18;centre shift, x=r*cos theta + offset
	 VCVT.U32.F32 s29,s9;conversion to integer
	 VMOV.F32 r0,s29;moved into r0 for passing as a parameter to print
	 BX lr
	 
;subroutine for calculating sin
sin  VLDR.F32 s7,=1
     VMOV.F32 s10,s8
loop1 VCMP.F32 s8, #0
      vmrs    APSR_nzcv, FPSCR
     BEQ next1
     VMUL.F32 s7,s8,s7
     VSUB.F32 s8,s8,s5
     B loop1
	 
next1 VMOV.F32 s8,s10
      VMOV.F32 s3,s17
     ;VLDR.F32 s3,=90;Number for which tan x is to be calculated i.e x input in degree
     VLDR.F32 s16,=0.01745329251;pi/180 factor to convert input degree to radian value
     VMUL.F32 s3,s16,s3
	 VLDR.F32 s5,=1
	 VLDR.F32 s4,=1
	 VCMP.F32 s8,#0
	 vmrs    APSR_nzcv, FPSCR
	 BEQ new1
	 
term1 VMUL.F32 s4,s4,s3;
     VSUB.F32 s8,s8,s5
	 VCMP.F32 s8,#0
	 vmrs    APSR_nzcv, FPSCR
	 BGT term1
	 
	 
	 
new1  VDIV.F32 s4,s4,s7
     AND r6,r6,#1
     CMP r6,r5
	 BEQ func1
ret1	 ADD r6,r6,#1
	    VMOV.F32 s8,s10
	   VADD.F32 s8,s8,s5
	 VCMP.F32 s8,s6
	 vmrs    APSR_nzcv, FPSCR
	 BLT sin
	 VMUL.F32 s9,s9,s30
	 VADD.F32 s9,s9,s19
	 VCVT.U32.F32 s29,s9
	 VMOV.F32 r1,s29
	 BX lr
	 
func1 AND r7,r7,#1
     CMP r7,r5
	 BEQ subt1
	 ADD r7,r7,#1
ret11 
     VADD.F32 s9,s9,s4
	 
	 B ret1

subt1 VSUB.F32 s9,s9,s4
	 ADD r7,r7,#1
	 B ret1	 
	 
func AND r7,r7,#1
     CMP r7,r5
	 BEQ subt
	 ADD r7,r7,#1
 
     VADD.F32 s9,s9,s4
	 
	 B ret

subt VSUB.F32 s9,s9,s4
	 ADD r7,r7,#1
	 B ret

     ENDFUNC
     END