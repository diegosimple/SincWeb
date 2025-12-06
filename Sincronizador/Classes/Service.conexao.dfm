object ServiceConexao: TServiceConexao
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object FDConn: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      'Database=D:\delph\ERPZeus\install\BD\BASE5HOM.FDB'
      'Port=3060'
      'Server=127.0.0.1'
      'DriverID=FB')
    ConnectedStoredUsage = []
    LoginPrompt = False
    BeforeConnect = FBDriverLinkServiceDriverCreated
    Left = 528
    Top = 152
  end
  object Cursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 472
    Top = 232
  end
  object FBDriverLinkService: TFDPhysFBDriverLink
    VendorHome = 'D:\delph\ERPZeus\install\dlls'
    VendorLib = 'fbclient50.dll'
    Left = 288
    Top = 104
  end
  object Qry_Filial: TFDQuery
    Connection = FDConn
    SQL.Strings = (
      'select * from EMPRESA  where ID = :codigo')
    Left = 384
    Top = 120
    ParamData = <
      item
        Name = 'CODIGO'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
    object Qry_FilialID: TIntegerField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object Qry_FilialRAZAO_SOCIAL: TStringField
      FieldName = 'RAZAO_SOCIAL'
      Origin = 'RAZAO_SOCIAL'
      Size = 100
    end
    object Qry_FilialCNPJ: TStringField
      FieldName = 'CNPJ'
      Origin = 'CNPJ'
      Size = 18
    end
  end
end
