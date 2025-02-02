
@echo off
@cls
title FPGA Auto Simulation batch script

echo ModelSim simulation
echo.
echo Press '1' to start simulation
echo.

goto run1

:input
set INPUT=
set /P INPUT=Type test number: %=%
if "%INPUT%"=="1" goto run1
goto end

:run1
@cls
echo Start Simulation;
echo.
echo.
cd testbench
vsim -do "do compile.do"
goto clean_workspace

:clean_workspace

rmdir /S /Q work
del vsim.wlf
del transcript.

:end