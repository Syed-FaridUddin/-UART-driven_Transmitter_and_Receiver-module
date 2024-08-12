Properties:


* Designed a Generic module with user dependent Baud Rate and Data Bits
* Tx and Rx use 4 smaller generic modules: BaudClockGenerator, Serializer, ShiftRegister , Synchronizer. 
* RTL description in VHDL HDL, complied and Simulated on Quartus Prime & Modelsim.

Note: 

=> While simulating on ModelSim, please make sure you are using "use 1076-2008" VHDL version.
Otherwise, complier will throw an error showing output-signal cannot be read.

=> Change the number of bits to transmit, clock-rate used and the baud rate in the "TopLevelModule_TB" and all other modules
arrange themselves.