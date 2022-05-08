$nocompile
Config Shiftin = New
'========== DIM Value s ==================================

Dim Led1 As Bit , Led2 As Bit , Led3 As Bit
Dim Str_dly As Byte , Pls_dly As Byte
Dim Keys As Byte , Sw1 As Bit , Sw2 As Bit , Sw3 As Bit
Dim Pointer_1 As Bit , Pointer_2 As Bit , Pointer_3 As Bit , Pointer_4 As Bit

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
Sub Send(byval Y As Byte)
   For Bt = 0 To 7
      Reset Clk
      Psou = Y.bt
      Waitus Pls_dly
      Set Clk
      Waitus Pls_dly
   Next Bt
End Sub

'====== Display_7segment
Sub Tm1637_print(digi_print As Word)
   Dim Temp(4) As Word , Num_show As Byte
   Dim Digits(5) As Word
   Digits(1) = Digi_print \ 1000
   Temp(1) = Digi_print Mod 1000
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
   Num_show.7 = Pointer_1
   Send Num_show
   Ak
   Num_show = Lookup(digits(2) , Dta)
   Num_show.7 = Pointer_2
   Send Num_show
   Ak
   Num_show = Lookup(digits(3) , Dta)
   Num_show.7 = Pointer_3
   Send Num_show
   Ak
   Num_show = Lookup(digits(4) , Dta)
   Num_show.7 = pointer_4
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
End Sub

'_________ Defult Value ________________
Led1 = 0
Led2 = 0
Led3 = 0
Relay_01 = 0
Relay_02 = 0
Relay_03 = 0
Pls_dly = 1
Str_dly = 5