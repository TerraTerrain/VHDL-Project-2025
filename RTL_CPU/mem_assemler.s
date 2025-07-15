addi x1, x0, 1      # x1 = 1
addi x2, x0, 2      # x2 = 2
addi x3, x0, 3      # x3 = 3
addi x4, x0, 4      # x4 = 4
addi x5, x0, 5      # x5 = 5

addi x5, x0, 32     # x5 = 32 (base address for memory)

sw x1, 0(x5)        # mem[32] = x1
sw x2, 4(x5)        # mem[36] = x2
sw x3, 8(x5)        # mem[40] = x3
sw x4, 12(x5)       # mem[44] = x4
sw x5, 16(x5)       # mem[48] = x5

addi x1, x1, 10     # x1 = x1 + 10
addi x2, x2, 20     # x2 = x2 + 20
addi x3, x3, 30     # x3 = x3 + 30

andi x4, x4, 0xF    # x4 = x4 & 0xF
andi x5, x5, 0xF    # x5 = x5 & 0xF
andi x1, x1, 0xF    # x1 = x1 & 0xF

ori x2, x2, 0xA     # x2 = x2 | 0xA
ori x3, x3, 0xA     # x3 = x3 | 0xA
ori x4, x4, 0xA     # x4 = x4 | 0xA

add x5, x1, x2      # x5 = x1 + x2
add x1, x3, x4      # x1 = x3 + x4
add x2, x5, x1      # x2 = x5 + x1

sub x3, x2, x1      # x3 = x2 - x1
sub x4, x3, x2      # x4 = x3 - x2
sub x5, x4, x3      # x5 = x4 - x3

and x1, x1, x2      # x1 = x1 & x2
and x2, x2, x3      # x2 = x2 & x3
and x3, x3, x4      # x3 = x3 & x4

sll x4, x1, x2      # x4 = x1 << x2
sll x5, x3, x4      # x5 = x3 << x4
sll x1, x5, x2      # x1 = x5 << x2

srl x2, x3, x1      # x2 = x3 >> x1
srl x3, x4, x2      # x3 = x4 >> x2
srl x4, x5, x3      # x4 = x5 >> x3

sra x5, x1, x2      # x5 = x1 >>> x2
sra x1, x3, x4      # x1 = x3 >>> x4
sra x2, x5, x1      # x2 = x5 >>> x1

lw x3, 0(x5)        # x3 = mem[32]
lw x4, 4(x5)        # x4 = mem[36]
lw x5, 8(x5)        # x5 = mem[40]

sw x1, 12(x5)       # mem[44] = x1
sw x2, 16(x5)       # mem[48] = x2
sw x3, 20(x5)       # mem[52] = x3

beq x1, x1, label1
bne x2, x3, label2
blt x4, x5, label3

label1:
addi x1, x0, 1
label2:
addi x2, x0, 2
label3:
addi x3, x0, 3
jal x4, label4
addi x5, x0, 0    # skipped
label4:
jalr x1, 0(x2)
