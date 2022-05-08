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
$swstack = 10
'========== Alias I/O ====================================
Relay_01 Alias Portb.2
Relay_02 Alias Portc.0
Relay_03 Alias Portc.1
Clk Alias Portd.3
Psou Alias Portd.2
Psin Alias Pind.2

'========== DIM Value s ==================================
Dim Io_flag As Bit , Interlock As Bit , 7seg_flag As Bit
Dim Bt As Byte , Backup_flag As Bit
Dim Fault_response_bit As Bit , Fault_response_dflag As Bit
Dim Auto As Bit , Manual As Bit , Manual_dflag As Bit , Auto_dflag As Bit
Dim Cut_value_dflag As Bit , Es_dflag As Bit , Counter_dflag As Bit
Dim Micro_switch_dflag As Bit
Dim Login As Bit , Pass_ok As Bit , Start_bit As Bit , Meno_enable As Bit
Dim Tic_cnt0 As Byte , Isr_temp As Byte
Dim Timers(50) As Word , Temp(4) As Word , Num_show As Byte
Dim Digits(5) As Word
Dim Digit_display As Word , Cut_value As Word , Cut_value_old As Word
Dim Step1_value As Byte , Step2_value As Word
Dim Eram_cut_value As Eram Word
Dim Led1 As Bit , Led2 As Bit , Led3 As Bit
Dim Str_dly As Byte , Pls_dly As Byte
Dim Keys As Byte , Sw1 As Bit , Sw2 As Bit , Sw3 As Bit
Dim 7seg_point_1 As Bit , 7seg_point_2 As Bit , 7seg_point_3 As Bit , 7seg_point_4 As Bit
'========================================================
Declare Sub Strt
Declare Sub Send(byval Y As Byte)
Declare Sub Ak
Declare Sub Stp

'========== Const For Delay 10ms with Timer0 ============
'Const 10ms = 65536 - 1250                                   '10 ms
Const 1ms = $ff - 125                                       '1ms
'========== Configuration Pins ==========================
Config Portb = Output
Config Portc = Output
Config Portd = Output
Config Relay_01 = Output
Config Relay_02 = Output
Config Relay_03 = Output

'========== Configuration Micro Processor ===============
Config Timer0 = Timer , Prescale = 64                       '16 bit,own code reloads
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
Timers(2) = 0
Timers(3) = 0
Timers(4) = 0
Timers(5) = 0
Led1 = 0
Led2 = 0
Led3 = 0
Relay_01 = 0
Relay_02 = 0
Relay_03 = 0
Pls_dly = 1
Str_dly = 5
'______________________________________________
'Disable Timer1
'Disable Capture1
'Counter1 = 0
'Step1_value = 2
Main_loop:
'----- MACHINE CONTROL
   Cut_value = 0
   Do
      If 7seg_flag = 1 Then Gosub Display_7segment
      If Timers(2) = 0 Then
         Toggle 7seg_point_4
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
'Stop Timer0
   Set Io_flag
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
'Start Timer0
Return

'====== Display_7segment
Display_7segment:
   Reset 7seg_flag

   'Digit_display = Cut_value
   Digit_display = Keys
   Digits(1) = Digit_display \ 1000
   Temp(1) = Digit_display Mod 1000
   Digits(2) = Temp(1) \ 100
   Temp(2) = Temp(1) Mod 100
   Digits(3) = Temp(2) \ 10
   Digits(4) = Temp(2) Mod 10
   Config Psou = Output
   Strt
   Send &H8F                                                'Display Is On & Brightness Is High
   Ak
   Stp
   Strt
   Send &H40                                                'Data Instruction Set Hex40 For Write SRAM Data In Address Auto Increment 1 Mode
   Ak
   Stp
   Strt
   Send &HC0                                                'Addres Instruction Setting, First Digit (HexC0) MSB Display
   Ak
   Num_show = Lookup(digits(1) , Dta)
   Num_show.7 = 7seg_point_1
   Send Num_show
   Ak
   Num_show = Lookup(digits(2) , Dta)
   Num_show.7 = 7seg_point_2
   Send Num_show
   Ak
   Num_show = Lookup(digits(3) , Dta)
   Num_show.7 = 7seg_point_3
   Send Num_show
   Ak
   Num_show = Lookup(digits(4) , Dta)
   Num_show.7 = 7seg_point_4
   Send Num_show
   Ak
   Num_show = &B00000000
   Num_show.1 = Led1
   Num_show.0 = Led2
   Num_show.2 = Led3
   Send Num_show
   Ak
   Stp
   Strt
   Send &H42
   Ak
   'Config Dio = Input
   Keys = 0
   Config Psin = Input
   Shiftin Psin , Clk , Keys , 3

   If Keys = &HEF Then
      Sw1 = 1
   Elseif Keys = &H6F Then
      Sw2 = 1
   Elseif Keys = &HAF Then
      Sw3 = 1
   Else
      Sw1 = 0
      Sw2 = 0
      Sw3 = 0
   End If
Return

'____________________ Data Change _____________________________
Dta:
   Data &B00111111 , &B00000110 , &B01011011 , &B01001111 , &B01100110 , &B01101101 _
    , &B01111101 , &B00000111 , &B01111111 , &B01101111 , &B01110111 , &B01111100 _
    , &B00111001 , &B01000111 , &B01111001 , &B01110001 , &B01000000 , &B00000000 _
    , &B00000001 , &B00001000 , &B01001000 , &B01001001 , &B01110000 , &B01110011 _
    , &B01110111 , &B01010100 , &B00111110 , &B01110001 , &B00111110 , &B00111000 _
    , &B00111001 , &B00000000
'_________________________ Sub s ______________________________
Sub Strt
   Set Clk
   Set Psou
   Timers(1) = Str_dly
   Do
      If Timers(1) = 0 Then Exit Do
   Loop
   Reset Psou
End Sub
Sub Stp
   Reset Clk
   Reset Psou
   Waitus Pls_dly
   Set Clk
   Waitus Pls_dly
   Set Psou
End Sub
Sub Ak
   Reset Clk
   Waitus Pls_dly
   Set Clk
   Waitus Pls_dly
End Sub
Sub Send(y As Byte)
   For Bt = 0 To 7
      Reset Clk
      Psou = Y.bt
      Waitus Pls_dly
      Set Clk
      Waitus Pls_dly
   Next Bt
End Sub