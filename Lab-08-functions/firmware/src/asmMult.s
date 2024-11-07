/*** asmMult.s   ***/
/* SOLUTION; used to test C test harness
 * VB 10/14/2023
 */
    
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Robert Nelson"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,a_Sign,b_Sign,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0 
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0 
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

.global asmUnpack, asmAbs, asmMult, asmFixSign, asmMain
.type asmUnpack,%function
.type asmAbs,%function
.type asmMult,%function
.type asmFixSign,%function
.type asmMain,%function

/* function: asmUnpack
 *    inputs:   r0: contains the packed value. 
 *                  MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *              r1: address where to store unpacked, 
 *                  sign-extended 32 bit a value
 *              r2: address where to store unpacked, 
 *                  sign-extended 32 bit b value
 *    outputs:  r0: No return value
 *              memory: 
 *                  1) store unpacked A value in location
 *                     specified by r1
 *                  2) store unpacked B value in location
 *                     specified by r2
 */
asmUnpack:   
    push {r4-r11, LR}
    /*** STUDENTS: Place your asmUnpack code BELOW this line!!! **************/
    
    /***
     * Copy the value passed into r0 to a new register
     * This will allow us to manipulate it indendently
    ***/
    mov r4, r0
    /***
     * Perform an arithmetic shift right by 16 bits
     * The A bits were previously the 16 MSB, and need to be moved down
     * ASR also performs the necessary sign extension of A
     ***/
    asr r5, r4, 16
    
    /* Store the now-unpacked value of A */
    str r5, [r1]
    
    /* Begin with the same process as above moving r0 to new register */
    mov r4, r0
    /***
     * Perform a logical shift left by 16 bits
     * The B bits are sitting in the LSB but bit 31 is used for sign extension
     * So an LSL will move the bits to where the B sign value is the MSB
     * After this, perform an ASR by 16 bits to sign extend the MSB
     * This process is incredibly similar to A, but with one extra step
    ***/
    lsl r5, r4, 16
    asr r5, r5, 16
    
    str r5, [r2]
    
    pop {r4-r11, LR}
    bx LR
    /*** STUDENTS: Place your asmUnpack code ABOVE this line!!! **************/


    /***************  END ---- asmUnpack  ************/

 
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit 0 = "+", 1 = "-")
 *    outputs:  r0: Absolute value of r0 input. Same value as stored to location given in r1
 *              memory: store absolute value in location given by r1
 *                      store sign bit in location given by r2
 */    
asmAbs:  

    /*** STUDENTS: Place your asmAbs code BELOW this line!!! **************/
    push {r4-r11, LR}
    /***
     * Get sign bit of both arguments
     * Do this by performing a logical shift
     * We want to fill with leading zeros to get only 1 or 0
    ***/
    mov r3, r0
    lsr r3, 31
    
    str r3, [r2]
    
    /***
     * Get the absolute value of our arguments
     * This is done by performing a negation (pseudo-instruction for RSB)
     * If either argument is zero, that means they are already its abs
     * Take this value and store it into its respective *_Abs
    ***/
    mov r3, r0
    cmp r3, 0
    neglt r3, r3
    
    str r3, [r1]
    
    mov r0, r3
    
    pop {r4-r11, LR}
    bx LR

    /*** STUDENTS: Place your asmAbs code ABOVE this line!!! **************/


    /***************  END ---- asmAbs  ************/

 
/* function: asmMult
 *    inputs:   r0: contains abs value of multiplicand (a)
 *              r1: contains abs value of multiplier (b)
 *    outputs:  r0: initial product: r0 * r1
 */ 
asmMult:   

    /*** STUDENTS: Place your asmMult code BELOW this line!!! **************/
    push {r4-r11, LR}
    
    mov r2, 0
    
    /***
     * Check if our LSB is 1 using AND in order to mask other bits
     * This makes comparison easy, just compare against zero
     * If the LSB is 1, then add the multiplicand to the initial product
     * Shift multiplicand left one bit, multiplier right by 1
    ***/
    multiply:
    and r3, r1, 1
    cmp r3, 0
    addne r2, r2, r0
    lsl r0, r0, 1
    lsr r1, r1, 1
    
    /***
     * If the multiplier has not yet been reduced to zero, we are not done
     * Loop back to the beginning of our operation
    ***/
    cmp r1, 0
    bne multiply
    
    mov r0, r2
    
    pop {r4-r11, LR}
    bx LR
    
    zero:
    mov r0, 0
    
    pop {r4-r11, LR}
    bx LR

    /*** STUDENTS: Place your asmMult code ABOVE this line!!! **************/

   
    /***************  END ---- asmMult  ************/


    
/* function: asmFixSign
 *    inputs:   r0: initial product from previous step: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
asmFixSign:   
    
    /*** STUDENTS: Place your asmFixSign code BELOW this line!!! **************/
    push {r4-r11, LR}
    /***
     * If the signs are equal, result will be positive
     * If not equal, result will be negative
     * Compare signs to one another, then check if one argument is zero
     * Zero is considered positive, so a zero result will override negative
    ***/
    cmp r1, r2
    
    mov r3, 1
    moveq r3, 0
    
    cmp r0, 0
    moveq r3, 0
    
    cmp r3, 1
    negeq r0, r0
    
    pop {r4-r11, LR}
    bx LR
    
    /*** STUDENTS: Place your asmFixSign code ABOVE this line!!! **************/


    /***************  END ---- asmFixSign  ************/



    
/* function: asmMain
 *    inputs:   r0: contains packed value to be multiplied
 *                  using shift-and-add algorithm
 *           where: MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *    outputs:  r0: final product: sign-corrected product
 *                  of the two unpacked A and B input values
 *    NOTE TO STUDENTS: 
 *           To implement asmMain, follow the steps outlined
 *           in the comments in the body of the function
 *           definition below.
 */  
asmMain:   
    
    /*** STUDENTS: Place your asmMain code BELOW this line!!! **************/
    push {r4-r11, LR}
    
    /* START initialize to zero */
    ldr r2, =a_Multiplicand
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =b_Multiplier
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =rng_Error
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =a_Sign
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =b_Sign
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =prod_Is_Neg
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =a_Abs
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =b_Abs
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =init_Product
    ldr r3, =0
    str r3, [r2]
    
    ldr r2, =final_Product
    ldr r3, =0
    str r3, [r2]
    /* END initialize to zero */
    
    /* Step 1:
     * call asmUnpack. Have it store the output values in a_Multiplicand
     * and b_Multiplier.
    */
    ldr r1, =a_Multiplicand
    
    ldr r2, =b_Multiplier
    
    bl asmUnpack
    
    /* Step 2a:
      * call asmAbs for the multiplicand (a). Have it store the absolute value
      * in a_Abs, and the sign in a_Sign.
    */
    ldr r0, =a_Multiplicand
    ldr r0, [r0]
    
    ldr r1, =a_Abs
    
    ldr r2, =a_Sign
    
    bl asmAbs
    
    /* Step 2b:
      * call asmAbs for the multiplier (b). Have it store the absolute value
      * in b_Abs, and the sign in b_Sign.
    */
    
    ldr r0, =b_Multiplier
    ldr r0, [r0]
    
    ldr r1, =b_Abs
    
    ldr r2, =b_Sign
    
    bl asmAbs
    
    /* Step 3:
     * call asmMult. Pass a_Abs as the multiplicand, 
     * and b_Abs as the multiplier.
     * asmMult returns the initial (positive) product in r0.
     * In this function (asmMain), store the output value  
     * returned asmMult in r0 to mem location init_Product.
    */
    
    ldr r0, =a_Abs
    ldr r0, [r0]
    
    ldr r1, =b_Abs
    ldr r1, [r1]
    
    bl asmMult
    
    ldr r2, =init_Product
    str r0, [r2]


    /* Step 4:
     * call asmFixSign. Pass in the initial product, and the
     * sign bits for the original a and b inputs. 
     * asmFixSign returns the final product with the correct
     * sign. Store the value returned in r0 to mem location 
     * final_Product.
    */
    
    ldr r0, [r2]
    
    ldr r1, =a_Sign
    ldr r1, [r1]
    
    ldr r2, =b_Sign
    ldr r2, [r2]
    
    bl asmFixSign
    
    ldr r1, =final_Product
    str r0, [r1]


    /* Step 5:
      * END! Return to caller. Make sure of the following:
      * 1) Stack has been correctly managed.
      * 2) the final answer is stored in r0, so that the C call 
      *    can access it.
    */
    pop {r4-r11, LR}
    bx LR
    /*** STUDENTS: Place your asmMain code ABOVE this line!!! **************/


    /***************  END ---- asmMain  ************/

 
    
    
.end   /* the assembler will ignore anything after this line. */
