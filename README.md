# ENGR3410-01.25FA
Work for Computer Architecture Course (ENGR3410-01.25FA) in the 2025 Fall Semester.

**Synthesizing SystemVerilog Code Setup**

Envrionment Information: 
- Microsoft Windows 11

Setup Steps:
1) Download the most recent OSS CAD Suite build (can be downloaded from: [https://github.com/YosysHQ/oss-cad-suite-build](https://github.com/YosysHQ/oss-cad-suite-build)).
2) Install make by running the following command on the Windows Terminal:
    ```bash
    winget install ezwinports.make
    ```

Synthesizing SystemVerilog Code Instructions (make sure you are in the OSS CAD Suite Environment first):
- In the folder with the project, run the following command to synthezise the SystemVerilog code:
    ```bash
    make
    ```
- To program the custom FPGA board, run the following command:
    ```bash
    make prog
    ```