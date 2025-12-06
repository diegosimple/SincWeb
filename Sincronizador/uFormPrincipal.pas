unit uFormPrincipal;

{*******************************************************************************
  FORMULÁRIO PRINCIPAL DO SINCRONIZADOR

  Interface com 3 abas:
  1. Configuração da API
  2. O que Sincronizar
  3. Logs e Progresso

  Recursos:
  - Tray Icon
  - Timer para sincronização automática
  - Notificações balloon
  - Registro de inicialização do Windows

  Autor: Sistema FSVendas
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.Buttons,
  FireDAC.Comp.Client, Data.DB, Registry,
  uConfiguracao, uLogSistema, uSincronizacao;

type
  TFormPrincipal = class(TForm)
    pgcPrincipal: TPageControl;
    tsConfiguracao: TTabSheet;
    tsSincronizar: TTabSheet;
    tsLogs: TTabSheet;
    pnlRodape: TPanel;
    prgSincronizacao: TProgressBar;
    statusBar: TStatusBar;
    trayIconSincronizador: TTrayIcon;
    popupTray: TPopupMenu;
    mniAbrir: TMenuItem;
    mniSincronizarAgora: TMenuItem;
    N1: TMenuItem;
    mniSair: TMenuItem;
    tmrSincronizacao: TTimer;
    memoLogs: TMemo;
    pnlLogsAcoes: TPanel;
    btnLimparLog: TButton;
    chkSalvarLogsArquivo: TCheckBox;
    btnExportarLog: TButton;
    lblEndpoint: TLabel;
    edtEndpoint: TEdit;
    lblChaveAPI: TLabel;
    edtChaveAPI: TEdit;
    lblTempo: TLabel;
    spnTempo: TSpinEdit;
    lblQtdCelulares: TLabel;
    spnQtdCelulares: TSpinEdit;
    chkIniciarWindows: TCheckBox;
    chkMinimizarTray: TCheckBox;
    btnSalvarConfig: TButton;
    btnTestarConexao: TButton;
    lblStatusConexao: TLabel;
    grpEnviar: TGroupBox;
    chkEnviarEmpresa: TCheckBox;
    chkEnviarClientes: TCheckBox;
    chkEnviarProdutos: TCheckBox;
    chkEnviarPedidos: TCheckBox;
    grpReceber: TGroupBox;
    chkReceberClientes: TCheckBox;
    chkReceberPedidos: TCheckBox;
    pnlAcoes: TPanel;
    btnEnviarDados: TButton;
    btnReceberDados: TButton;
    btnResetarEmpresa: TButton;
    chkSincronizarImagens: TCheckBox;
    grpAutomatico: TGroupBox;
    chkSincAutoEnviar: TCheckBox;
    chkSincAutoReceber: TCheckBox;
    SaveDialogLog: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSalvarConfigClick(Sender: TObject);
    procedure btnTestarConexaoClick(Sender: TObject);
    procedure btnEnviarDadosClick(Sender: TObject);
    procedure btnReceberDadosClick(Sender: TObject);
    procedure btnResetarEmpresaClick(Sender: TObject);
    procedure btnLimparLogClick(Sender: TObject);
    procedure btnExportarLogClick(Sender: TObject);
    procedure mniAbrirClick(Sender: TObject);
    procedure mniSincronizarAgoraClick(Sender: TObject);
    procedure mniSairClick(Sender: TObject);
    procedure trayIconSincronizadorDblClick(Sender: TObject);
    procedure tmrSincronizacaoTimer(Sender: TObject);
    procedure chkSalvarLogsArquivoClick(Sender: TObject);
  private
    FConfig: TConfiguracao;
    FLogSistema: TLogSistema;
    FSincronizandoAgora: Boolean;

    procedure CarregarConfiguracoes;
    procedure SalvarConfiguracoes;
    procedure InicializarComponentes;
    procedure ConfigurarInicioWindows(AHabilitar: Boolean);
    procedure MinimizarParaTray;
    procedure RestaurarDaTray;
    procedure EnviarDadosSelecionados;
    procedure ReceberDadosSelecionados;
    procedure MostrarNotificacao(const ATitulo, AMensagem: string; ATipo: TLogTipo);
  public
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.dfm}

uses
  Udados, uSincronizadorApi;

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  FSincronizandoAgora := False;

  // Criar configuração
  FConfig := TConfiguracao.Create;

  // Criar sistema de logs
  FLogSistema := TLogSistema.Create(memoLogs, statusBar);

  // Carregar configurações
  CarregarConfiguracoes;

  // Inicializar componentes
  InicializarComponentes;

  FLogSistema.AdicionarLog('Sincronizador FSVendas iniciado', ltSistema);
  FLogSistema.AdicionarLog('Versão 1.0 - Build ' + FormatDateTime('yyyy-mm-dd', Now), ltInfo);
end;

procedure TFormPrincipal.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FLogSistema);
  FreeAndNil(FConfig);
end;

procedure TFormPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FConfig.GetMinimizarParaTray and (Application.MessageBox(
     'Deseja minimizar para a bandeja do sistema?',
     'Sincronizador',
     MB_YESNO + MB_ICONQUESTION) = IDYES) then
  begin
    MinimizarParaTray;
    Action := caNone;
  end;
end;

procedure TFormPrincipal.InicializarComponentes;
begin
  pgcPrincipal.ActivePageIndex := 0;
  prgSincronizacao.Position := 0;

  // Configurar memo de logs
  memoLogs.Clear;
  memoLogs.ReadOnly := True;
  memoLogs.ScrollBars := ssVertical;
  memoLogs.Font.Name := 'Courier New';
  memoLogs.Font.Size := 9;

  // Configurar timer
  tmrSincronizacao.Enabled := False;
  tmrSincronizacao.Interval := FConfig.GetTempoSincronizacao * 1000;

  // Configurar tray icon
  trayIconSincronizador.Visible := True;
  trayIconSincronizador.Hint := 'Sincronizador FSVendas';
  trayIconSincronizador.BalloonTitle := 'Sincronizador';
end;

procedure TFormPrincipal.CarregarConfiguracoes;
begin
  // Aba 1 - Configuração
  edtEndpoint.Text := FConfig.GetEndpoint;
  edtChaveAPI.Text := FConfig.GetChaveAPI;
  spnTempo.Value := FConfig.GetTempoSincronizacao;
  spnQtdCelulares.Value := FConfig.GetQtdCelulares;
  chkIniciarWindows.Checked := FConfig.GetIniciarComWindows;
  chkMinimizarTray.Checked := FConfig.GetMinimizarParaTray;

  // Aba 2 - Sincronização
  chkSincAutoEnviar.Checked := FConfig.GetAutoEnviar;
  chkSincAutoReceber.Checked := FConfig.GetAutoReceber;
  chkSincronizarImagens.Checked := FConfig.GetSincronizarImagens;

  // Aba 3 - Logs
  chkSalvarLogsArquivo.Checked := FConfig.GetSalvarLogsArquivo;
  if Assigned(FLogSistema) then
    FLogSistema.SalvarArquivo := chkSalvarLogsArquivo.Checked;
end;

procedure TFormPrincipal.SalvarConfiguracoes;
begin
  // Aba 1 - Configuração
  FConfig.SetEndpoint(edtEndpoint.Text);
  FConfig.SetChaveAPI(edtChaveAPI.Text);
  FConfig.SetTempoSincronizacao(spnTempo.Value);
  FConfig.SetQtdCelulares(spnQtdCelulares.Value);
  FConfig.SetIniciarComWindows(chkIniciarWindows.Checked);
  FConfig.SetMinimizarParaTray(chkMinimizarTray.Checked);

  // Aba 2 - Sincronização
  FConfig.SetAutoEnviar(chkSincAutoEnviar.Checked);
  FConfig.SetAutoReceber(chkSincAutoReceber.Checked);
  FConfig.SetSincronizarImagens(chkSincronizarImagens.Checked);

  // Aba 3 - Logs
  FConfig.SetSalvarLogsArquivo(chkSalvarLogsArquivo.Checked);

  // Configurar início com Windows
  ConfigurarInicioWindows(chkIniciarWindows.Checked);

  // Atualizar timer
  tmrSincronizacao.Interval := spnTempo.Value * 1000;
  tmrSincronizacao.Enabled := chkSincAutoEnviar.Checked or chkSincAutoReceber.Checked;
end;

procedure TFormPrincipal.btnSalvarConfigClick(Sender: TObject);
var
  LErro: string;
begin
  try
    LErro := FConfig.ValidarConfiguracao;
    if LErro <> '' then
    begin
      ShowMessage(LErro);
      Exit;
    end;

    SalvarConfiguracoes;
    FLogSistema.AdicionarLog('Configurações salvas com sucesso', ltSucesso);
    ShowMessage('Configurações salvas com sucesso!');
  except
    on E: Exception do
    begin
      FLogSistema.AdicionarLog('Erro ao salvar configurações: ' + E.Message, ltErro);
      ShowMessage('Erro ao salvar configurações: ' + E.Message);
    end;
  end;
end;

procedure TFormPrincipal.btnTestarConexaoClick(Sender: TObject);
var
  LSincApi: TSincronizadorApi;
  LToken: string;
  LCNPJ: string;
begin
  try
    lblStatusConexao.Caption := 'Testando...';
    lblStatusConexao.Font.Color := clBlue;
    Application.ProcessMessages;

    if not Assigned(Dados) or not Dados.qryEmpresa.Active then
      raise Exception.Create('Dados da empresa não carregados');

    LCNPJ := Dados.qryEmpresa.FieldByName('CNPJ').AsString;

    LSincApi := TSincronizadorApi.Create(Dados.Conexao, edtEndpoint.Text, LCNPJ, edtChaveAPI.Text);
    try
      LToken := LSincApi.ObterTokenDaApi(LCNPJ, edtChaveAPI.Text);
      if LToken <> '' then
      begin
        lblStatusConexao.Caption := 'Conexão OK!';
        lblStatusConexao.Font.Color := clGreen;
        FLogSistema.AdicionarLog('Teste de conexão: SUCESSO', ltSucesso);
        ShowMessage('Conexão estabelecida com sucesso!' + #13#10 + 'Token obtido.');
      end;
    finally
      LSincApi.Free;
    end;
  except
    on E: Exception do
    begin
      lblStatusConexao.Caption := 'Erro na conexão';
      lblStatusConexao.Font.Color := clRed;
      FLogSistema.AdicionarLog('Teste de conexão: FALHA - ' + E.Message, ltErro);
      ShowMessage('Erro ao testar conexão: ' + E.Message);
    end;
  end;
end;

procedure TFormPrincipal.EnviarDadosSelecionados;
var
  LControlador: TControladorSincronizacao;
begin
  if FSincronizandoAgora then
  begin
    ShowMessage('Sincronização já em andamento. Aguarde...');
    Exit;
  end;

  FSincronizandoAgora := True;
  btnEnviarDados.Enabled := False;
  btnReceberDados.Enabled := False;
  try
    FLogSistema.AdicionarLog('=== INICIANDO ENVIO DE DADOS ===', ltSistema);

    LControlador := TControladorSincronizacao.Create(Dados.Conexao, FConfig,
      FLogSistema, prgSincronizacao);
    try
      if chkEnviarEmpresa.Checked then
        LControlador.EnviarEmpresa;

      if chkEnviarClientes.Checked then
        LControlador.EnviarClientes;

      if chkEnviarProdutos.Checked then
        LControlador.EnviarProdutos(chkSincronizarImagens.Checked);

      FLogSistema.AdicionarLog('=== ENVIO CONCLUÍDO COM SUCESSO ===', ltSucesso);
      MostrarNotificacao('Envio Concluído', 'Dados enviados com sucesso!', ltSucesso);
    finally
      LControlador.Free;
    end;
  except
    on E: Exception do
    begin
      FLogSistema.AdicionarLog('ERRO NO ENVIO: ' + E.Message, ltErro);
      MostrarNotificacao('Erro', 'Falha no envio: ' + E.Message, ltErro);
    end;
  end;
  finally
    btnEnviarDados.Enabled := True;
    btnReceberDados.Enabled := True;
    FSincronizandoAgora := False;
    prgSincronizacao.Position := 0;
  end;
end;

procedure TFormPrincipal.ReceberDadosSelecionados;
var
  LControlador: TControladorSincronizacao;
begin
  if FSincronizandoAgora then
  begin
    ShowMessage('Sincronização já em andamento. Aguarde...');
    Exit;
  end;

  FSincronizandoAgora := True;
  btnEnviarDados.Enabled := False;
  btnReceberDados.Enabled := False;
  try
    FLogSistema.AdicionarLog('=== INICIANDO RECEBIMENTO DE DADOS ===', ltSistema);

    LControlador := TControladorSincronizacao.Create(Dados.Conexao, FConfig,
      FLogSistema, prgSincronizacao);
    try
      if chkReceberClientes.Checked then
        LControlador.ReceberClientes;

      if chkReceberPedidos.Checked then
        LControlador.ReceberPedidos;

      FLogSistema.AdicionarLog('=== RECEBIMENTO CONCLUÍDO COM SUCESSO ===', ltSucesso);
      MostrarNotificacao('Recebimento Concluído', 'Dados recebidos com sucesso!', ltSucesso);
    finally
      LControlador.Free;
    end;
  except
    on E: Exception do
    begin
      FLogSistema.AdicionarLog('ERRO NO RECEBIMENTO: ' + E.Message, ltErro);
      MostrarNotificacao('Erro', 'Falha no recebimento: ' + E.Message, ltErro);
    end;
  end;
  finally
    btnEnviarDados.Enabled := True;
    btnReceberDados.Enabled := True;
    FSincronizandoAgora := False;
    prgSincronizacao.Position := 0;
  end;
end;

procedure TFormPrincipal.btnEnviarDadosClick(Sender: TObject);
begin
  EnviarDadosSelecionados;
end;

procedure TFormPrincipal.btnReceberDadosClick(Sender: TObject);
begin
  ReceberDadosSelecionados;
end;

procedure TFormPrincipal.btnResetarEmpresaClick(Sender: TObject);
var
  LControlador: TControladorSincronizacao;
begin
  LControlador := TControladorSincronizacao.Create(Dados.Conexao, FConfig,
    FLogSistema, prgSincronizacao);
  try
    LControlador.ResetarEmpresa;
  finally
    LControlador.Free;
  end;
end;

procedure TFormPrincipal.btnLimparLogClick(Sender: TObject);
begin
  FLogSistema.LimparLog;
end;

procedure TFormPrincipal.btnExportarLogClick(Sender: TObject);
begin
  SaveDialogLog.FileName := 'SincronizadorLog_' + FormatDateTime('yyyy-mm-dd_hhnnss', Now) + '.txt';
  if SaveDialogLog.Execute then
  begin
    try
      FLogSistema.ExportarLog(SaveDialogLog.FileName);
      ShowMessage('Log exportado com sucesso!');
    except
      on E: Exception do
        ShowMessage('Erro ao exportar log: ' + E.Message);
    end;
  end;
end;

procedure TFormPrincipal.chkSalvarLogsArquivoClick(Sender: TObject);
begin
  FLogSistema.SalvarArquivo := chkSalvarLogsArquivo.Checked;
end;

procedure TFormPrincipal.tmrSincronizacaoTimer(Sender: TObject);
begin
  if FSincronizandoAgora then
    Exit;

  FLogSistema.AdicionarLog('[TIMER] Sincronização automática iniciada', ltSistema);

  if chkSincAutoEnviar.Checked then
    EnviarDadosSelecionados;

  if chkSincAutoReceber.Checked then
    ReceberDadosSelecionados;
end;

// ===== TRAY ICON =====

procedure TFormPrincipal.MinimizarParaTray;
begin
  Hide;
  WindowState := wsMinimized;
  trayIconSincronizador.Visible := True;
  trayIconSincronizador.BalloonHint := 'Sincronizador minimizado para a bandeja';
  trayIconSincronizador.ShowBalloonHint;
end;

procedure TFormPrincipal.RestaurarDaTray;
begin
  Show;
  WindowState := wsNormal;
  Application.BringToFront;
end;

procedure TFormPrincipal.trayIconSincronizadorDblClick(Sender: TObject);
begin
  RestaurarDaTray;
end;

procedure TFormPrincipal.mniAbrirClick(Sender: TObject);
begin
  RestaurarDaTray;
end;

procedure TFormPrincipal.mniSincronizarAgoraClick(Sender: TObject);
begin
  if chkSincAutoEnviar.Checked then
    EnviarDadosSelecionados;
  if chkSincAutoReceber.Checked then
    ReceberDadosSelecionados;
end;

procedure TFormPrincipal.mniSairClick(Sender: TObject);
begin
  if MessageDlg('Deseja realmente sair?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    Application.Terminate;
end;

procedure TFormPrincipal.MostrarNotificacao(const ATitulo, AMensagem: string; ATipo: TLogTipo);
begin
  trayIconSincronizador.BalloonTitle := ATitulo;
  trayIconSincronizador.BalloonHint := AMensagem;
  case ATipo of
    ltErro: trayIconSincronizador.BalloonFlags := bfError;
    ltAviso: trayIconSincronizador.BalloonFlags := bfWarning;
    ltSucesso, ltInfo: trayIconSincronizador.BalloonFlags := bfInfo;
  end;
  trayIconSincronizador.ShowBalloonHint;
end;

// ===== REGISTRO DO WINDOWS =====

procedure TFormPrincipal.ConfigurarInicioWindows(AHabilitar: Boolean);
var
  LReg: TRegistry;
begin
  LReg := TRegistry.Create(KEY_WRITE);
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    if LReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
    begin
      if AHabilitar then
        LReg.WriteString('SincronizadorFSVendas', Application.ExeName)
      else if LReg.ValueExists('SincronizadorFSVendas') then
        LReg.DeleteValue('SincronizadorFSVendas');
    end;
  finally
    LReg.Free;
  end;
end;

end.
