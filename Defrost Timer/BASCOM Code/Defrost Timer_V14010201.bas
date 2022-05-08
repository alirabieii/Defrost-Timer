$regfile = "m8adef.dat"
$crystal = 8000000
$baud = 9600
$hwstack = 32
$swstack = 8
$framesize = 24
Config Portb = Output
Config Portc = Output
Config Portd = Input

Output_01 Alias Portb.2
Output_02 Alias Portc.0
Output_03 Alias Portc.1
Config Output_01 = Output
Config Output_02 = Output
Config Output_03 = Output
Dim Delay_t01 As Word
Delay_t01 = 5000

Main:
   Do
'_____ one ______
      Set Output_01
      Reset Output_02
      Reset Output_03
      Waitms Delay_t01
      Reset Output_01
      Set Output_02
      Reset Output_03
      Waitms Delay_t01
      Reset Output_01
      Reset Output_02
      Set Output_03
      Waitms Delay_t01
'_____ two ______
      Set Output_01
      Set Output_02
      Reset Output_03
      Waitms Delay_t01
      Reset Output_01
      Reset Output_02
      Reset Output_03
      Waitms Delay_t01
'___  three _____
      Set Output_01
      Set Output_02
      Set Output_03
      Waitms Delay_t01
      Reset Output_01
      Reset Output_02
      Reset Output_03
      Waitms Delay_t01
   Loop

   End