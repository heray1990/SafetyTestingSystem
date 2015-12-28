VERSION 5.00
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "mscomm32.ocx"
Begin VB.Form Form1 
   Caption         =   "����������ݱ��湤��"
   ClientHeight    =   7215
   ClientLeft      =   165
   ClientTop       =   855
   ClientWidth     =   7200
   LinkTopic       =   "Form1"
   ScaleHeight     =   7215
   ScaleWidth      =   7200
   StartUpPosition =   3  '����ȱʡ
   Begin VB.CommandButton Command1 
      Caption         =   "writeExcel"
      Height          =   495
      Left            =   5640
      TabIndex        =   6
      Top             =   1080
      Width           =   1335
   End
   Begin VB.Timer Timer1 
      Left            =   6480
      Top             =   360
   End
   Begin VB.Frame Frame2 
      Caption         =   "���Խ��"
      Height          =   1005
      Left            =   120
      TabIndex        =   3
      Top             =   6120
      Width           =   5295
      Begin VB.Label lbResult 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
         Caption         =   "Checking"
         BeginProperty Font 
            Name            =   "΢���ź�"
            Size            =   18
            Charset         =   134
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   570
         Left            =   120
         TabIndex        =   4
         Top             =   240
         Width           =   5025
      End
   End
   Begin VB.TextBox txtReceive 
      BeginProperty Font 
         Name            =   "Consolas"
         Size            =   10.5
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   4395
      Left            =   120
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   2
      Top             =   1680
      Width           =   5265
   End
   Begin VB.Frame Frame3 
      Caption         =   "����"
      Height          =   820
      Left            =   120
      TabIndex        =   1
      Top             =   840
      Width           =   5295
      Begin VB.TextBox txtInput 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "΢���ź�"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   435
         Left            =   120
         TabIndex        =   0
         Text            =   "123456789"
         Top             =   240
         Width           =   5025
      End
   End
   Begin MSCommLib.MSComm MSComm1 
      Left            =   5640
      Top             =   240
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      DTREnable       =   -1  'True
   End
   Begin VB.Label lbModelName 
      Alignment       =   2  'Center
      Caption         =   "Label1"
      BeginProperty Font 
         Name            =   "΢���ź�"
         Size            =   24
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   120
      TabIndex        =   5
      Top             =   120
      Width           =   5295
   End
   Begin VB.Menu tbSetComPort 
      Caption         =   "���ô���"
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim strCommInput As String

Private Sub Command1_Click()
    Dim i, j, cnt As Integer
    Dim exl As Object
    Dim wb As Object
    Dim sht As Object
    Dim t1, t2, t As Date
    
    t1 = Now
      
    Set exl = CreateObject("Excel.Application")
    Set wb = exl.Workbooks.Open(App.path & "\sample2.xls")
    Set sht = wb.ActiveSheet
    
    sht.Cells(1, 1) = "R"
    sht.Cells(1, 2) = "G"
    sht.Cells(1, 3) = "B"
    
    cnt = 100
    For i = 2 To 20
        For j = 1 To 3
            sht.Cells(i, j) = cnt
            cnt = cnt + 1
        Next j
    Next i
      
    exl.ActiveWorkbook.Save
    exl.ActiveWorkbook.Close
    exl.Quit
    
    t2 = Now
    
    t = t2 - t1
    
    MsgBox Second(t)
End Sub

Private Sub Form_Load()
    setTVCurrentComBaud = 9600
    subInitComPort
    subInitInterface

    lbModelName = strCurrentModelName
End Sub

Private Sub Form_Unload(Cancel As Integer)

On Error GoTo ErrExit
  
    If MSComm1.PortOpen = True Then
        MSComm1.PortOpen = False
    End If
  
    End
Exit Sub

ErrExit:
    MsgBox Err.Description, vbCritical, Err.Source
End Sub

Private Sub subInitComPort()
    sqlstring = "select * from CommonTable where Mark='ATS'"
    Executesql (sqlstring)

    If rs.EOF = False Then
        setTVCurrentComID = rs("ComID")
    Else
        MsgBox "Read Data Error,Please Check Your Database!", vbOKOnly + vbInformation, "Warning!"
    End
    End If

    Set cn = Nothing
    Set rs = Nothing
    sqlstring = ""

    ComInit
End Sub

Private Sub subInitInterface()
    txtInput.Text = ""
    Log_Clear
End Sub

Private Sub subInitBeforeRunning()
    strSerialNo = UCase$(txtInput.Text)
    
    lbResult.Caption = "Checking"
    lbResult.BackColor = &HFFFFFF
    Log_Clear
    txtReceive.ForeColor = &H80000008
End Sub

Private Sub subInitAfterRunning()
    txtInput.Text = ""
    txtInput.SetFocus
End Sub

Private Sub subMainProcesser()
On Error GoTo ErrExit
    subInitBeforeRunning
    
    SAFE_STOP
    
    SAFE_RES_AREP "ON"
    DelayMS 500
    
    SAFE_STAR
    DelayMS 500
    
ErrExit:
    'MsgBox Err.Description, vbCritical, Err.Source
    'MsgBox "subMainProcesser Error"
End Sub

Private Sub MSComm1_OnComm()
On Error GoTo Err
    Select Case MSComm1.CommEvent
        Case comEvReceive
            DelayMS 500
            strCommInput = MSComm1.Input
            Call textReceive
        'Case comEvSend
    End Select
Err:
    'MsgBox "MSComm1_OnComm Error"
End Sub

Private Sub textReceive()

On Error GoTo Err
    If Trim(strCommInput) <> "" And Trim(strCommInput) <> vbCr _
        And Trim(strCommInput) <> vbLf And Trim(strCommInput) <> vbCrLf Then
        Log_Info strCommInput
        If Trim(strCommInput) = """PASS""" & vbCrLf Or Trim(strCommInput) = """PASS""" & vbLf Then
            Log_Info "Pass"
            GoTo PASS
        Else
            Log_Info "Fail"
            GoTo FAIL
        End If
    Else
        Exit Sub
    End If
    
PASS:
    lbResult.Caption = "PASS"
    lbResult.BackColor = &HFF00&
    Call subInitAfterRunning
    Exit Sub

FAIL:
    lbResult.Caption = "NG"
    lbResult.BackColor = &HFF&
    Call subInitAfterRunning
    Exit Sub

Err:
    Log_Info "Unknown message"
End Sub

Private Sub tbSetComPort_Click()
    Form2.Show
End Sub

Private Sub txtInput_KeyPress(KeyAscii As Integer)
    'ASCII = 13 means "Enter" of keyboard.
    If KeyAscii = 13 Then
        subMainProcesser
    End If
End Sub
