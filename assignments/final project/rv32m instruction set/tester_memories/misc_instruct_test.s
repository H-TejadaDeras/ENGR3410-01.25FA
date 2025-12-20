# Misc. Instructions (lui, auipc, jal, jalr) Test Program
# Available Instructions: All except ecall, ebreak, csrrw, csrrs, csrrc, 
# csrrwi, csrrsi, csrrci
# Program makes use of tester_dmem.hex
# Henry Tejada Deras - 11-27-2025
add x2, x0, x0 # Set stack pointer
lw x5, 0(x2) # 01234567 -> x5
lw x6, 4(x2) # 76543210 -> x6
lw x28, 40(x2) # 00000010 -> x28
auipc x8, 16
addi x9, x9, 10 # 00000000 -> 0000000A
addi x9, x9, 1 # 0000000A -> 0000000B
jal x10, 8 # Move to 2nd instruction down (lui)
addi x29, x0, x0 # Filler instruction; not meant to do anything
lui x9, 400000
jalr x10, 4002(x28) # Move to auipc instruction
addi x9, x9, 1 # 0000000B -> 0000000C