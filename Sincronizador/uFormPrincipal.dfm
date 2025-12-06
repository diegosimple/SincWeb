object FormPrincipal: TFormPrincipal
  Left = 0
  Top = 0
  Caption = 'Sincronizador FSVendas - v1.0'
  ClientHeight = 600
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object pgcPrincipal: TPageControl
    Left = 0
    Top = 0
    Width = 800
    Height = 545
    ActivePage = tsConfiguracao
    Align = alClient
    TabOrder = 0
    object tsConfiguracao: TTabSheet
      Caption = '1. Configura'#231#227'o da API'
      object lblEndpoint: TLabel
        Left = 24
        Top = 24
        Width = 91
        Height = 13
        Caption = 'Endpoint (URL API):'
      end
      object lblChaveAPI: TLabel
        Left = 24
        Top = 72
        Width = 53
        Height = 13
        Caption = 'Chave API:'
      end
      object lblTempo: TLabel
        Left = 24
        Top = 120
        Width = 189
        Height = 13
        Caption = 'Tempo de Sincroniza'#231#227'o (segundos):'
      end
      object lblQtdCelulares: TLabel
        Left = 24
        Top = 168
        Width = 151
        Height = 13
        Caption = 'Quantidade de Celulares Permitidos:'
      end
      object lblStatusConexao: TLabel
        Left = 440
        Top = 240
        Width = 86
        Height = 13
        Caption = 'Aguardando teste'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object edtEndpoint: TEdit
        Left = 24
        Top = 43
        Width = 545
        Height = 21
        TabOrder = 0
        Text = 'https://api.fsvendas.com.br/api'
      end
      object edtChaveAPI: TEdit
        Left = 24
        Top = 91
        Width = 545
        Height = 21
        PasswordChar = '*'
        TabOrder = 1
      end
      object spnTempo: TSpinEdit
        Left = 24
        Top = 139
        Width = 121
        Height = 22
        MaxValue = 3600
        MinValue = 30
        TabOrder = 2
        Value = 300
      end
      object spnQtdCelulares: TSpinEdit
        Left = 24
        Top = 187
        Width = 121
        Height = 22
        MaxValue = 20
        MinValue = 1
        TabOrder = 3
        Value = 5
      end
      object chkIniciarWindows: TCheckBox
        Left = 24
        Top = 232
        Width = 177
        Height = 17
        Caption = 'Iniciar com o Windows'
        TabOrder = 4
      end
      object chkMinimizarTray: TCheckBox
        Left = 24
        Top = 255
        Width = 177
        Height = 17
        Caption = 'Minimizar para Tray'
        Checked = True
        State = cbChecked
        TabOrder = 5
      end
      object btnSalvarConfig: TButton
        Left = 24
        Top = 304
        Width = 153
        Height = 33
        Caption = 'Salvar Configura'#231#245'es'
        TabOrder = 6
        OnClick = btnSalvarConfigClick
      end
      object btnTestarConexao: TButton
        Left = 280
        Top = 232
        Width = 153
        Height = 33
        Caption = 'Testar Conex'#227'o'
        TabOrder = 7
        OnClick = btnTestarConexaoClick
      end
    end
    object tsSincronizar: TTabSheet
      Caption = '2. O que Sincronizar'
      ImageIndex = 1
      object grpEnviar: TGroupBox
        Left = 16
        Top = 16
        Width = 345
        Height = 193
        Caption = ' Enviar para Nuvem '
        TabOrder = 0
        object chkEnviarEmpresa: TCheckBox
          Left = 24
          Top = 32
          Width = 297
          Height = 17
          Caption = 'Empresa / Usu'#225'rio / Esp'#233'cies / Vendedores'
          TabOrder = 0
        end
        object chkEnviarClientes: TCheckBox
          Left = 24
          Top = 64
          Width = 217
          Height = 17
          Caption = 'Clientes (POST / PUT)'
          TabOrder = 1
        end
        object chkEnviarProdutos: TCheckBox
          Left = 24
          Top = 96
          Width = 217
          Height = 17
          Caption = 'Produtos (POST)'
          TabOrder = 2
        end
        object chkEnviarPedidos: TCheckBox
          Left = 24
          Top = 128
          Width = 217
          Height = 17
          Caption = 'Pedidos (POST / PUT)'
          Enabled = False
          TabOrder = 3
        end
        object chkSincronizarImagens: TCheckBox
          Left = 24
          Top = 160
          Width = 217
          Height = 17
          Caption = 'Incluir Imagens de Produtos'
          TabOrder = 4
        end
      end
      object grpReceber: TGroupBox
        Left = 16
        Top = 224
        Width = 345
        Height = 121
        Caption = ' Receber da Nuvem '
        TabOrder = 1
        object chkReceberClientes: TCheckBox
          Left = 24
          Top = 32
          Width = 217
          Height = 17
          Caption = 'Clientes (GET)'
          TabOrder = 0
        end
        object chkReceberPedidos: TCheckBox
          Left = 24
          Top = 64
          Width = 217
          Height = 17
          Caption = 'Pedidos (GET)'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
      end
      object pnlAcoes: TPanel
        Left = 384
        Top = 16
        Width = 377
        Height = 329
        BevelOuter = bvNone
        TabOrder = 2
        object btnEnviarDados: TButton
          Left = 16
          Top = 32
          Width = 337
          Height = 41
          Caption = 'ENVIAR DADOS'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = btnEnviarDadosClick
        end
        object btnReceberDados: TButton
          Left = 16
          Top = 96
          Width = 337
          Height = 41
          Caption = 'RECEBER DADOS'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnClick = btnReceberDadosClick
        end
        object btnResetarEmpresa: TButton
          Left = 16
          Top = 160
          Width = 337
          Height = 41
          Caption = 'RESETAR EMPRESA'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = btnResetarEmpresaClick
        end
      end
      object grpAutomatico: TGroupBox
        Left = 16
        Top = 360
        Width = 345
        Height = 113
        Caption = ' Sincroniza'#231#227'o Autom'#225'tica '
        TabOrder = 3
        object chkSincAutoEnviar: TCheckBox
          Left = 24
          Top = 32
          Width = 257
          Height = 17
          Caption = 'Enviar automaticamente (via Timer)'
          TabOrder = 0
        end
        object chkSincAutoReceber: TCheckBox
          Left = 24
          Top = 64
          Width = 257
          Height = 17
          Caption = 'Receber automaticamente (via Timer)'
          TabOrder = 1
        end
      end
    end
    object tsLogs: TTabSheet
      Caption = '3. Logs e Progresso'
      ImageIndex = 2
      object memoLogs: TMemo
        Left = 0
        Top = 0
        Width = 792
        Height = 440
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object pnlLogsAcoes: TPanel
        Left = 0
        Top = 440
        Width = 792
        Height = 77
        Align = alBottom
        TabOrder = 1
        object btnLimparLog: TButton
          Left = 16
          Top = 16
          Width = 153
          Height = 33
          Caption = 'Limpar Log'
          TabOrder = 0
          OnClick = btnLimparLogClick
        end
        object btnExportarLog: TButton
          Left = 184
          Top = 16
          Width = 153
          Height = 33
          Caption = 'Exportar Log'
          TabOrder = 1
          OnClick = btnExportarLogClick
        end
        object chkSalvarLogsArquivo: TCheckBox
          Left = 360
          Top = 24
          Width = 225
          Height = 17
          Caption = 'Salvar logs em arquivo automaticamente'
          TabOrder = 2
          OnClick = chkSalvarLogsArquivoClick
        end
      end
    end
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 545
    Width = 800
    Height = 55
    Align = alBottom
    TabOrder = 1
    object prgSincronizacao: TProgressBar
      Left = 1
      Top = 1
      Width = 798
      Height = 25
      Align = alTop
      TabOrder = 0
    end
    object statusBar: TStatusBar
      Left = 1
      Top = 35
      Width = 798
      Height = 19
      Panels = <
        item
          Width = 500
        end
        item
          Width = 50
        end>
    end
  end
  object trayIconSincronizador: TTrayIcon
    PopupMenu = popupTray
    Visible = True
    OnDblClick = trayIconSincronizadorDblClick
    Left = 520
    Top = 88
  end
  object popupTray: TPopupMenu
    Left = 592
    Top = 88
    object mniAbrir: TMenuItem
      Caption = 'Abrir'
      OnClick = mniAbrirClick
    end
    object mniSincronizarAgora: TMenuItem
      Caption = 'Sincronizar Agora'
      OnClick = mniSincronizarAgoraClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mniSair: TMenuItem
      Caption = 'Sair'
      OnClick = mniSairClick
    end
  end
  object tmrSincronizacao: TTimer
    Enabled = False
    Interval = 300000
    OnTimer = tmrSincronizacaoTimer
    Left = 664
    Top = 88
  end
  object SaveDialogLog: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Arquivos de Texto|*.txt|Todos os Arquivos|*.*'
    Left = 728
    Top = 88
  end
end
