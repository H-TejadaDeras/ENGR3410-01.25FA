# Memory Operations Test Program
# Available Instructions: lb, lbu, lh, lhu, lw, sb, sh, sw
# Program makes use of rv32i_test.txt
# Henry Tejada Deras - 11-14-2025
lw x5, 4(x3) # pc = 0x00
lw x6, 4(x3) # pc = 0x04
sw x5, -1(x3) # pc = 0x08