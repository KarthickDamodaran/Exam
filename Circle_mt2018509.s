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
	 ;VCVT.U32.F32 s17,s17
	 ;VMOV.F32 r0,s17
	 ;VMOV.F32 r1,s17
	 ;BL printMsg2p
	 MOV r3,#0
	 MOV r9,#361 ;(Total Angle in a circle +1 for comparison and branching)
pin  VLDR.F32 s6,=30;Number of series terms required
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
sign VLDR.F32 s7,=1
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
	 
new  AND r4,r6,#1
	 CMP r4,r5
	 BEQ sin
	 AND r10,r7,#1
	 CMP r10,r5
     BEQ oddcos
     VDIV.F32 s4,s4,s7
     VADD.F32 s9,s4,s9
	 ADD r7,r7,r5
com	 VMOV.F32 s8,s10
	 VADD.F32 s8,s8,s5
	 ADD r6,r6,r5
	 VCMP.F32 s8,s6
	 vmrs    APSR_nzcv, FPSCR
	 BLT sign
	 
stop VDIV.F32 s14,s11,s9
     VMUL.F32 s20,s9,s30;r*cos theta stored in s20
	 VMUL.F32 s21,s11,s30;r*sin theta stored in s21
	 ;VCVT.U32.F32 s20,s20
	 ;VCVT.U32.F32 s21,s21
	 ;VMOV.F32 r0,s20
	 ;VMOV.F32 r1,s21
	 ;BL printMsg2p
	 ;VMUL.F32
	 VADD.F32 s18,s18,s20
	 VADD.F32 s19,s19,s21
	 VCVT.U32.F32 s18,s18
	 VCVT.U32.F32 s19,s19
	 VMOV.F32 r0,s18
	 VMOV.F32 r1,s19
	 BL printMsg2p
     ADD r3,r3,#1
	 VADD.F32 s17,s17,s5
     CMP r3,r9
	 BNE pin
here B here

sin	 AND r10,r8,#1
     CMP r10,r5
     BEQ oddsin
     VDIV.F32 s4,s4,s7
     VADD.F32 s11,s4,s11
	 ADD r8,r8,r5
	 B com
	 
oddsin VDIV.F32 s4,s4,s7
       VSUB.F32 s11,s11,s4
	   ADD r8,r8,r5
	   B com
	   
oddcos VDIV.F32 s4,s4,s7
       VSUB.F32 s9,s9,s4
	   ADD r7,r7,r5
	   B com	   
	   
     ENDFUNC
     END