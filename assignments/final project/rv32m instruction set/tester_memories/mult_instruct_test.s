# Multiplication Instructions (mul, mulh, mulhsu, mulhu) Test Program
# Program makes use of tester_dmem.hex
# Note: All values are written in Two's Complement Form.
# Henry Tejada Deras - 12-08-2025
add x2, x0, x0 # Set stack pointer
lw x5 0(x3) # 00000008 -> x5
lw x6 4(x3) # 0000000A -> x6
mul x7, x5, x6 # 8 [00000008] * 10 [0000000A] = 80 [00000050]
lw x6 36(x3) # FFFF0123 -> x6
mul x7, x5, x6 # 8 [00000008] * -65245 [FFFF0123] = -521960 [FFF80918]
lw x5, 28(x3) # 98756462 -> x5
lw x6, 24(x3) # 09876354 -> x6
mul x7, x5, x6 # -1737137054 [98756462] * 159867732 [09876354] = -277712160996141528 [FC255E42CE04D628]; saves lower 32 bits [CE04D628]
mulh x7, x5, x6 # -1737137054 [98756462] * 159867732 [09876354] = -277712160996141528 [FC255E42CE04D628]; saves upper 32 bits [FC255E42]
mulhsu x7, x5, x6 # -1737137054 [98756462] * 159867732 [09876354] = -277712160996141528 [FC255E42CE04D628]; saves upper 32 bits [FC255E42]
mulhu x7, x5, x6 # 2557830242 [98756462] * 159867732 [09876354] = 408914519629551144 [05ACC196CE04D640]; saves upper 32 bits [05ACC196]
mulhu x7, x6, x5 # 2557830242 [09876354] * 159867732 [98756462] = 408914519629551144 [05ACC196CE04D640]; saves upper 32 bits [05ACC196]