' 使用常數定義連接字串，避免重複
Private Const DB_CONNECT As String = "ODBC;DSN=LabSystem32-FreeBSD;"

' 建立一個獲取連接的函數
Private Function GetConnection() As DAO.Database
    Dim db As DAO.Database
    Set db = CurrentDb
    ' 可以在這裡添加連接驗證邏輯
    Set GetConnection = db
End Function