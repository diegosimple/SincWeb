object FormPrincipalSINC: TFormPrincipalSINC
  Left = 0
  Top = 0
  Caption = 'SINC - Sincronizador FSVendas'
  ClientHeight = 550
  ClientWidth = 700
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
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 700
    Height = 550
    ActivePage = TabConfig
    Align = alClient
    TabOrder = 0
    object TabConfig: TTabSheet
      Caption = '1. Configura'#231#227'o'
      object GroupBox1: TGroupBox
        Left = 16
        Top = 16
        Width = 657
        Height = 481
        Caption = ' Configura'#231#245'es do Sistema '
        TabOrder = 0
        object Label1: TLabel
          Left = 24
          Top = 32
          Width = 83
          Height = 13
          Caption = 'Endpoint da API:'
        end
        object Label2: TLabel
          Left = 24
          Top = 83
          Width = 54
          Height = 13
          Caption = 'Chave API:'
        end
        object Label3: TLabel
          Left = 24
          Top = 134
          Width = 166
          Height = 13
          Caption = 'Tempo de Sincronismo (segundos):'
        end
        object Label4: TLabel
          Left = 24
          Top = 185
          Width = 131
          Height = 13
          Caption = 'Qtd. Celulares Permitidos:'
        end
        object EdtEndpoint: TEdit
          Left = 24
          Top = 51
          Width = 601
          Height = 21
          TabOrder = 0
          Text = 'https://api.fsvendas.com.br'
        end
        object EdtChaveAPI: TEdit
          Left = 24
          Top = 102
          Width = 601
          Height = 21
          PasswordChar = '*'
          TabOrder = 1
        end
        object EdtTempoSync: TEdit
          Left = 24
          Top = 153
          Width = 121
          Height = 21
          TabOrder = 2
          Text = '300'
        end
        object EdtQtdCelulares: TEdit
          Left = 24
          Top = 204
          Width = 121
          Height = 21
          TabOrder = 3
          Text = '5'
        end
        object ChkIniciarWindows: TCheckBox
          Left = 24
          Top = 256
          Width = 200
          Height = 17
          Caption = 'Iniciar com o Windows'
          TabOrder = 4
        end
        object ChkMinimizarTray: TCheckBox
          Left = 24
          Top = 288
          Width = 200
          Height = 17
          Caption = 'Minimizar para Tray (Bandeja)'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
        object BtnSalvarConfig: TButton
          Left = 24
          Top = 432
          Width = 297
          Height = 33
          Caption = 'Salvar Configura'#231#227'o'
          TabOrder = 6
          OnClick = BtnSalvarConfigClick
        end
        object BtnTestarConexao: TButton
          Left = 328
          Top = 432
          Width = 297
          Height = 33
          Caption = 'Testar Conex'#227'o com API'
          TabOrder = 7
          OnClick = BtnTestarConexaoClick
        end
      end
    end
    object TabSync: TTabSheet
      Caption = '2. Sincroniza'#231#227'o'
      ImageIndex = 1
      object GroupBox2: TGroupBox
        Left = 16
        Top = 16
        Width = 657
        Height = 481
        Caption = ' O que Sincronizar '
        TabOrder = 0
        object Label5: TLabel
          Left = 24
          Top = 357
          Width = 36
          Height = 13
          Caption = 'Status:'
        end
        object LblStatus: TLabel
          Left = 66
          Top = 357
          Width = 73
          Height = 13
          Caption = 'Aguardando...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGreen
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object ChkSyncEmpresa: TCheckBox
          Left = 24
          Top = 32
          Width = 250
          Height = 17
          Caption = 'Empresa (POST/PUT)'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object ChkSyncUsuario: TCheckBox
          Left = 24
          Top = 64
          Width = 250
          Height = 17
          Caption = 'Usu'#225'rios (POST/PUT)'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object ChkSyncVendedor: TCheckBox
          Left = 24
          Top = 96
          Width = 250
          Height = 17
          Caption = 'Vendedores (POST/PUT)'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object ChkSyncFormaPgto: TCheckBox
          Left = 24
          Top = 128
          Width = 250
          Height = 17
          Caption = 'Formas de Pagamento (POST/PUT)'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
        object ChkSyncClientes: TCheckBox
          Left = 24
          Top = 160
          Width = 250
          Height = 17
          Caption = 'Clientes (GET/POST/PUT)'
          Checked = True
          State = cbChecked
          TabOrder = 4
        end
        object ChkSyncProdutos: TCheckBox
          Left = 24
          Top = 192
          Width = 250
          Height = 17
          Caption = 'Produtos (POST)'
          TabOrder = 5
        end
        object ChkSyncPedidos: TCheckBox
          Left = 24
          Top = 224
          Width = 250
          Height = 17
          Caption = 'Pedidos / Or'#231'amentos (GET/POST/PUT)'
          Checked = True
          State = cbChecked
          TabOrder = 6
        end
        object BtnEnviarDados: TButton
          Left = 24
          Top = 272
          Width = 145
          Height = 33
          Caption = 'Enviar Dados'
          TabOrder = 7
          OnClick = BtnEnviarDadosClick
        end
        object BtnReceberDados: TButton
          Left = 175
          Top = 272
          Width = 145
          Height = 33
          Caption = 'Receber Dados'
          TabOrder = 8
          OnClick = BtnReceberDadosClick
        end
        object BtnResetEmpresa: TButton
          Left = 326
          Top = 272
          Width = 145
          Height = 33
          Caption = 'Reset Empresa (DELETE)'
          TabOrder = 9
          OnClick = BtnResetEmpresaClick
        end
        object BtnSincronizarAgora: TButton
          Left = 24
          Top = 311
          Width = 601
          Height = 40
          Caption = 'SINCRONIZAR AGORA (Envio + Recebimento)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 10
          OnClick = BtnSincronizarAgoraClick
        end
        object Panel1: TPanel
          Left = 24
          Top = 376
          Width = 601
          Height = 89
          BevelOuter = bvNone
          TabOrder = 11
          object ProgressBar1: TProgressBar
            Left = 0
            Top = 0
            Width = 601
            Height = 89
            Align = alClient
            TabOrder = 0
          end
        end
      end
    end
    object TabLogs: TTabSheet
      Caption = '3. Logs'
      ImageIndex = 2
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 692
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label6: TLabel
          Left = 16
          Top = 13
          Width = 98
          Height = 13
          Caption = #220'ltima Sincroniza'#231#227'o:'
        end
        object LblUltimaSync: TLabel
          Left = 120
          Top = 13
          Width = 73
          Height = 13
          Caption = 'Nunca'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlue
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object BtnLimparLog: TButton
          Left = 568
          Top = 8
          Width = 105
          Height = 25
          Caption = 'Limpar Log'
          TabOrder = 0
          OnClick = BtnLimparLogClick
        end
      end
      object MemoLog: TMemo
        Left = 0
        Top = 41
        Width = 692
        Height = 481
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
  end
  object TimerSync: TTimer
    Enabled = False
    Interval = 300000
    OnTimer = TimerSyncTimer
    Left = 584
    Top = 8
  end
  object TrayIcon1: TTrayIcon
    PopupMenu = PopupMenu1
    Visible = True
    OnDblClick = TrayIcon1DblClick
    Left = 632
    Top = 8
  end
  object PopupMenu1: TPopupMenu
    Left = 656
    Top = 40
    object MenuRestaurar: TMenuItem
      Caption = 'Restaurar Janela'
      OnClick = MenuRestaurarClick
    end
    object MenuSincronizar: TMenuItem
      Caption = 'Sincronizar Agora'
      OnClick = MenuSincronizarClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MenuPausar: TMenuItem
      Caption = 'Pausar Sincronismo'
      OnClick = MenuPausarClick
    end
    object MenuSair: TMenuItem
      Caption = 'Sair'
      OnClick = MenuSairClick
    end
  end
end
