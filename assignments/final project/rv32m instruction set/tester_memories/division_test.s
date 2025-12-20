# Program makes use of test_mem_div.txt
lw x1, 4(x1) 
lw x2, 8(x1) 
div x3, x2, x1 
divu x4, x2, x1
rem x5, x2, x1
remu x7, x2, x1
div x7, x5, x3
div x3, x2, x1 
