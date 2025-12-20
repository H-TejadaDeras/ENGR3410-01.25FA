# Branch Instructions Test Program
# Available Instructions: lb, lbu, lh, lhu, lw, sb, sh, sw, beq, bge, bgeu, blt
# bltu, bne
# Program makes use of tester_dmem.hex
# Henry Tejada Deras - 11-20-2025
add x2, x0, x0 # Set stack pointer
lw x5, 0(x2) # 01234567 -> x5
lw x6, 4(x2) # 76543210 -> x6
bne x5, x6, 8
sw x6, 1000(x2) # x6 -> 00002000 (address)
blt x6, x5, 24