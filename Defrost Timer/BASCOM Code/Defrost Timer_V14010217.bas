'IN the Name OF God
'______________________________________
'|Name Projects: Defrost Timer            |
'|2 Analog NTC10k Inputs & 3 Relay Outputs|
'|with 7Segment 4 digits                  |
'|RTOS MultiTasking                       |
'|     (Real Time Opertion System)        |
'|Micro Controller: ATMEGA8A/L            |
'|Date/Time: 1401-02-01   17:30           |
'|Compiler: Bascom AVR V2.0.8.5           |
'|Powered By: Ali Rabiee                  |
'|Program Version: v1.1                   |
'|Programmer: HATTEL Software V5.8        |
'|Detail: RTOS (vernal! O.S 2019)         |
'|________________________________________|
$regfile = "m8adef.dat"
$crystal = 8000000
$baud = 9600
$framesize = 40
$hwstack = 20
$swstack = 50
'========== Alias I/O ====================================
Relay_01 Alias Portb.2
Relay_02 Alias Portc.0
Relay_03 Alias Portc.1
Clk Alias Portd.3
Psou Alias Portd.2
Psin Alias Pind.2

'========== DIM Value s ==================================
Dim 7seg_flag As Bit
Dim Bt As Byte , Backup_flag As Bit
Dim Tic_cnt0 As Byte , Isr_temp As Byte
Dim Timers(50) As Word
Dim Number As Word
'========== Const For Delay 10ms with Timer0 ============
'Const 10ms = 65536 - 1250                                   '10 ms
Const 1ms = $ff - 99                                        '1ms
'========== Configuration Pins ==========================
Config Portb = Output
Config Portc = Output
Config Portd = Output
Config Relay_01 = Output
Config Relay_02 = Output
Config Relay_03 = Output
Config Submode = New

'========== Configuration Micro Processor ===============
Config Timer0 = Timer , Prescale = 64                       '16 bit,own code reloads
'Config Clock = User
'Config Timer1 = Counter , Edge = Falling , Capture_edge = Falling , Noise_cancel = 1
Enable Interrupts                                           'enable the use of interrupts
Enable Timer0
'Enable Urxc
On Timer0 Timer_0_int

'On Urxc1 Serial_interrupt
Timer0 = 1ms
Start Timer0
'==========   include Files ==========================
$include "TM1637_Configuration.inc"
'_________ Defult Value Timers ________________
Timers(1) = 0
Timers(2) = 1000
Timers(3) = 0
Timers(4) = 0
Timers(5) = 0

'______________________________________________
'Disable Timer1
'Disable Capture1
'Counter1 = 0
'Step1_value = 2
Main_loop:
'----- MACHINE CONTROL
  ' Time$ = "02:20:00"
   Do
      If 7seg_flag = 1 Then
         Call Tm1637_print(number)
         Reset 7seg_flag
      End If

      If Timers(2) = 0 Then
         Incr Number
         Toggle Pointer_4
         Timers(2) = 1000
      End If

      Led1 = Sw1
      Led2 = Sw2
      Led3 = Sw3
      Relay_01 = Sw1
      Relay_02 = Sw2
      Relay_03 = Sw3
   Loop

'---- End Of Program
   End

'---- INTERRUPT SERVICE ROUTINE
'On-chip Timer0 over-flow interrupts steal insignificant slices of CPU time in
' order to update any number of independent timers. The timer values halt at zero
' thereby doubling as 'Done' flags. Where timing ranges cannot be covered by
' single byte values it may be more economical to group them with multiple
' Tic_cnts in preference to expanding all timers to use multiple bytes.
Timer_0_int:
   Set Backup_flag
   Set 7seg_flag
   Incr Tic_cnt0
   If Tic_cnt0 => 1 Then                                    '1=1mS for easy scoping
      Tic_cnt0 = 0
      For Isr_temp = 1 To 5
         If Timers(isr_temp) <> 0 Then Decr Timers(isr_temp)
      Next
   End If
   Timer0 = 1ms
Return

'____________________ Data Change _____________________________
Dta:
   Data &B00111111 , &B00000110 , &B01011011 , &B01001111 , &B01100110 , &B01101101 _
   , &B01111101 , &B00000111 , &B01111111 , &B01101111 , &B01110111 , &B01111100 _
   , &B00111001 , &B01000111 , &B01111001 , &B01110001 , &B01000000 , &B00000000 _
   , &B00000001 , &B00001000 , &B01001000 , &B01001001 , &B01110000 , &B01110011 _
   , &B01110111 , &B01010100 , &B00111110 , &B01110001 , &B00111110 , &B00111000 _
   , &B00111001 , &B00000000