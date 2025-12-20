# Memory Operations Test Program Complete
# Tests the following Instructions: lb, lbu, lh, lhu, lw, sb, sh, sw
# Program makes use of rv32i_test.txt
# Henry Tejada Deras - 12-04-2025
lw x5, 0(x3)
lh x6, 4(x3)
lhu x7, 4(x3)
lb x28, 5(x3)
lbu x29, 5(x3)
sb x28, 250(x3)
lb x30, 250(x3) # verify byte was stored by previous instruction
sh x6, 300(x3)
lh x31, 300(x3) # verify half word was stored by previous instruction
sw x5, 100(x3)
lw x8, 100(x3) # verify word was stored by previous instruction