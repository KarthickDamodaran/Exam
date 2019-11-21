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
     VLDR.F32 s17,=0
	 VLDR.F32 s30,=100 ;radius
	 MOV r3,#0
	 MOV r9,#361 ;(Total Angle in a circle +1 for comparison and branching)
pin  VLDR.F32 s6,=30;Number of series terms required in exp(x);cos series is calculated by ignoring odd powers and vice versa for sin
	 VLDR.F32 s5,=1
	 VLDR.F32 s8,=0
	 VLDR.F32 s9,=0
	 VLDR.F32 s11,=0
     VLDR.F32 s18,=240;x coordinate on VGA screen, centre of circle's x coordinate
     VLDR.F32 s19,=330;y coordinate on VGA screen, centre of circle's x coordinate
	 MOV r5,#1
	 MOV r6,#0
	 MOV r7,#0
	 MOV r8,#0
	 BL cos;calling subroutine to compute x=r*cos theta + x offset
	 VLDR.F32 s8,=0
	 VLDR.F32 s9,=0
	 VLDR.F32 s11,=0
     
	 MOV r5,#1
	 MOV r6,#0
	 MOV r7,#0
	 MOV r8,#0
     ADD r3,r3,#1
	 ;The above few lines after BL cos restore the contents before calling sin subroutine
	 BL sin;calling subroutine to compute y=r*sin theta + y offset
	 BL printMsg2p;printing (x,y) as "x y",where x=r*cos(theta)+x offset on VGA;y-r*sin(theta)+y offset on VGA
	 VADD.F32 s17,s17,s5;increment theta
     CMP r3,r9;increment loop count and repeat till required theta range
	 BLT pin
	 
stop B stop

cos VLDR.F32 s7,=1
     VMOV.F32 s10,s8
loop VCMP.F32 s8, #0
     vmrs    APSR_nzcv, FPSCR
     BEQ next
     VMUL.F32 s7,s8,s7
     VSUB.F32 s8,s8,s5
     B loop
	 
next VMOV.F32 s8,s10
     VMOV.F32 s3,s17
     ;VLDR.F32 s3,=90;Number for which tan x is to be calculated i.e x input in degree
     VLDR.F32 s16,=0.01745329251;pi/180 factor to convert input degree to radian value
     VMUL.F32 s3,s16,s3
	 VLDR.F32 s5,=1
	 VLDR.F32 s4,=1
	 VCMP.F32 s8,#0
	 vmrs    APSR_nzcv, FPSCR
	 BEQ new
	 
term VMUL.F32 s4,s4,s3;
     VSUB.F32 s8,s8,s5
	 VCMP.F32 s8,#0
	 vmrs    APSR_nzcv, FPSCR
	 BGT term
	 
	 
	 
new  VDIV.F32 s4,s4,s7
     AND r6,r6,#1
     CMP r6,r5
	 BLT func
ret	 ADD r6,r6,#1
	 VMOV.F32 s8,s10
	 VADD.F32 s8,s8,s5
	 VCMP.F32 s8,s6
	 vmrs    APSR_nzcv, FPSCR
	 BLT cos
	 VMUL.F32 s9,s9,s30
	 VADD.F32 s9,s9,s18
	 VCVT.U32.F32 s29,s9
	 VMOV.F32 r0,s29
	 BX lr
	 

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