' 修改 cbo地址描述_AfterUpdate 函數，使用參數化查詢
Private Sub cbo地址描述_AfterUpdate()
    On Error GoTo Err_Handler
    Dim qdf As DAO.QueryDef
    Dim rs As DAO.Recordset
    Dim sql As String

    If IsNull(Me.cbo地址描述) Or IsNull(Me.cbo收件單位) Then
        Me.txt客戶地址 = ""
        Exit Sub
    End If

    sql = "SELECT 客戶地址 FROM [客戶_地址] WHERE 客戶id = ? AND 地址描述 = ?"
    
    Set qdf = CurrentDb.CreateQueryDef("")
    qdf.sql = sql
    qdf.Parameters(0) = Nz(Me.cbo收件單位, 0)
    qdf.Parameters(1) = Nz(Me.cbo地址描述, "")
    
    Set rs = qdf.OpenRecordset()

    If Not rs.EOF Then
        Me.txt客戶地址 = Nz(rs!客戶地址, "")
        Debug.Print "找到客戶地址: " & Me.txt客戶地址
    Else
        Me.txt客戶地址 = ""
        Debug.Print "未找到客戶地址，客戶id = " & Nz(Me.cbo收件單位, 0) & ", 地址描述 = " & Nz(Me.cbo地址描述, "")
    End If

    rs.Close
    Set rs = Nothing
    Set qdf = Nothing
    Exit Sub

Err_Handler:
    MsgBox "地址錯誤 #" & Err.Number & ": " & Err.Description, vbCritical
    If Not rs Is Nothing Then rs.Close
    Set rs = Nothing
    Set qdf = Nothing
End Sub