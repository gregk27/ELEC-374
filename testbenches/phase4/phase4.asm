ORG 0
    ldi R2, 0x69 
    ldi R2, 2(R2) 
    ld R1, 0x47 
    ldi R1, 1(R1) 
    ld R0, -7(R1) 
    ldi R3, 3 
    ldi R2, 0x43 
    brmi R2, 3 
    ldi R2, 6(R2) 
    ld R7, -2(R2) 
    nop
    brpl R7, 2 
    ldi R5, 4(R2) 
    ldi R4, -3(R5) 
target: 
    add R2, R2, R3 
    addi R7, R7, 3 
    neg R7, R7 
    not R7, R7 
    andi R7, R7, 0xF 
    ror R1, R0, R3 
    ori R7, R1, 9 
    shra R1, R7, R3 
    shr R2, R2, R3 
    st 0x8E, R2 
    rol R2, R0, R3 
    or R4, R3, R0 
    and R1, R2, R0 
    st 0x27(R1), R4 
    sub R0, R2, R4 
    shl R1, R2, R3 
    ldi R4, 6 
    ldi R5, 0x1B 
    mul R5, R4 
    mfhi R7 
    mflo R6 
    div R5, R4 
    ldi R10, 1(R4) 
    ldi R11, -2(R5) 
    ldi R12, 0(R6) 
    ldi R13, 3(R7) 
    jal R12 

    in R4
    st 0xAA, R4
    ldi R1, 0x2E
    ldi R7, 1
    ldi R5, 40
loop: 
    out R4
    ldi R5, -1(R5)
    brzr R5, 8
    ld R6, 0xF0
loop2: 
    ldi R6, -1(R6)
    nop
    brnz R6, -3
    shr R4, R4, R7
    brnz R4, -9
    ld R4, 0xAA
    jr R1
done:
    ldi R4, 0x55
    out R4

    halt

subA:
    ORG 0xA2 
    add R9, R10, R12 
    sub R8, R11, R13 
    sub R9, R9, R8 
    jr R15 
