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
$regfile = "m8def.dat"
$crystal = 8000000
'$baud = 9600
$framesize = 40
$hwstack = 20
$swstack = 10
'========== Alias I/O ====================================
Output_01 Alias Portb.2
Output_02 Alias Portc.0
Output_03 Alias Portc.1
Clk Alias Portd.3
Dio Alias Portd.2
Pdio Alias Pind.2

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
Dim Pulse_delay As Byte
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
Config Output_01 = Output
Config Output_02 = Output
Config Output_03 = Output

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
Strt
Send &H8F                                                   'Display Is On & Brightness Is High
Ak
Stp

'_________ Defult Value Timers ________________
Timers(1) = 0
Timers(2) = 0
Timers(3) = 0
Timers(4) = 0
Timers(5) = 0                                               ' 60 s Delay
Timers(6) = 0
Timers(7) = 0
Led1 = 0
Led2 = 0
Led3 = 0
Output_01 = 0
Output_02 = 0
Output_03 = 0
Pulse_delay = 12
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
         Incr Cut_value
         Timers(2) = 1000
      End If
      If Timers(3) = 0 Then
         Toggle Led1
         Timers(3) = 600
      End If
      If Timers(4) = 0 Then
         Toggle Led2
         Timers(4) = 100
      End If
      If Timers(5) = 0 Then
         Toggle Led3
         Timers(5) = 322
      End If
      If Timers(6) = 0 Then
         'Toggle Output_01
         Timers(6) = 1000
      End If

      If Timers(7) = 0 Then

         Timers(7) = 100
      End If


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
      For Isr_temp = 1 To 50
         If Timers(isr_temp) <> 0 Then Decr Timers(isr_temp)
      Next
   End If
   Timer0 = 1ms
'Start Timer0
Return

'====== Display_7segment
Display_7segment:
   Reset 7seg_flag

   Digit_display = Cut_value
   Digits(1) = Digit_display \ 1000
   Temp(1) = Digit_display Mod 1000
   Digits(2) = Temp(1) \ 100
   Temp(2) = Temp(1) Mod 100
   Digits(3) = Temp(2) \ 10
   Digits(4) = Temp(2) Mod 10
   Config Dio = Output
   Strt
   Send &H40                                                'Data Instruction Set Hex40 For Write SRAM Data In Address Auto Increment 1 Mode
   Ak
   Stp
   Strt
   Send &HC0                                                'Addres Instruction Setting, First Digit (HexC0) MSB Display
   Ak
   Num_show = Lookup(digits(1) , Dta)
   Send Num_show
   Ak
   Num_show = Lookup(digits(2) , Dta)
   Send Num_show
   Ak
   Num_show = Lookup(digits(3) , Dta)
   Send Num_show
   Ak
   Num_show = Lookup(digits(4) , Dta)
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
   config  Pdio = Input


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
   Set Dio
   Timers(1) = 1
   Do
      If Timers(1) = 0 Then Exit Do
   Loop
   Reset Dio
End Sub
Sub Stp
   Reset Clk
   Reset Dio
   Waitus Pulse_delay
   Set Clk
   Waitus Pulse_delay
   Set Dio
End Sub
Sub Ak
   Reset Clk
   Waitus Pulse_delay
   Set Clk
   Waitus Pulse_delay
End Sub
Sub Send(y As Byte)
   For Bt = 0 To 7
      Reset Clk
      Dio = Y.bt
      Waitus Pulse_delay
      Set Clk
      Waitus Pulse_delay
   Next Bt
End Sub