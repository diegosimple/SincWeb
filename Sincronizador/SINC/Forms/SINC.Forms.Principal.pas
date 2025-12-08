unit SINC.Forms.Principal;

{*******************************************************************************
  SINC - Form Principal

  Interface com 3 abas:
  - Configuração
  - Sincronização
  - Logs

  Recursos:
  - Timer de sincronização automática
  - Tray Icon (ícone na bandeja)
  - Sistema de logs
  - Progress bar

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus, System.IniFiles,
  SINC.Orquestracao.Sincronizador, SINC.API.SincronizadorApi;

type
  TFormPrincipalSINC = class(TForm)
    PageControl1: TPageControl;
    TabConfig: TTabSheet;
    TabSync: TTabSheet;
    TabLogs: TTabSheet;

    // ABA 1 - Configuração
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    EdtEndpoint: TEdit;
    EdtChaveAPI: TEdit;
    EdtTempoSync: TEdit;
    EdtQtdCelulares: TEdit;
    ChkIniciarWindows: TCheckBox;
    ChkMinimizarTray: TCheckBox;
    BtnSalvarConfig: TButton;
    BtnTestarConexao: TButton;

    // ABA 2 - Sincronização
    GroupBox2: TGroupBox;
    ChkSyncEmpresa: TCheckBox;
    ChkSyncUsuario: TCheckBox;
    ChkSyncVendedor: TCheckBox;
    ChkSyncFormaPgto: TCheckBox;
    ChkSyncClientes: TCheckBox;
    ChkSyncProdutos: TCheckBox;
    ChkSyncPedidos: TCheckBox;
    BtnEnviarDados: TButton;
    BtnReceberDados: TButton;
    BtnResetEmpresa: TButton;
    BtnSincronizarAgora: TButton;
    Panel1: TPanel;
    Label5: TLabel;
    LblStatus: TLabel;
    ProgressBar1: TProgressBar;

    // ABA 3 - Logs
    MemoLog: TMemo;
    BtnLimparLog: TButton;
    Panel2: TPanel;
    Label6: TLabel;
    LblUltimaSync: TLabel;

    // Timer e Tray
    TimerSync: TTimer;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    MenuRestaurar: TMenuItem;
    MenuSincronizar: TMenuItem;
    N1: TMenuItem;
    MenuPausar: TMenuItem;
    MenuSair: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure BtnSalvarConfigClick(Sender: TObject);
    procedure BtnTestarConexaoClick(Sender: TObject);
    procedure BtnEnviarDadosClick(Sender: TObject);
    procedure BtnReceberDadosClick(Sender: TObject);
    procedure BtnSincronizarAgoraClick(Sender: TObject);
    procedure BtnResetEmpresaClick(Sender: TObject);
    procedure BtnLimparLogClick(Sender: TObject);

    procedure TimerSyncTimer(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure MenuRestaurarClick(Sender: TObject);
    procedure MenuSincronizarClick(Sender: TObject);
    procedure MenuPausarClick(Sender: TObject);
    procedure MenuSairClick(Sender: TObject);

  private
    FSincronizador: TSincronizador;
    FIniFile: string;
    FTimerAtivo: Boolean;

    procedure CarregarConfiguracao;
    procedure SalvarConfiguracao;
    procedure AdicionarLog(const AMsg: string);
    procedure AtualizarStatus(const AMsg: string);
    procedure ConfigurarTimer;
    procedure MinimizarParaTray;
    procedure RestaurarDaTray;

  public
    { Public declarations }
  end;

var
  FormPrincipalSINC: TFormPrincipalSINC;

implementation

{$R *.dfm}

procedure TFormPrincipalSINC.FormCreate(Sender: TObject);
begin
  FIniFile := ExtractFilePath(ParamStr(0)) + 'Sincronizador.ini';
  FTimerAtivo := True;

  FSincronizador := TSincronizador.Create;
  FSincronizador.OnLog := AdicionarLog;

  CarregarConfiguracao;
  ConfigurarTimer;

  AdicionarLog('Sistema SINC iniciado');
  AtualizarStatus('Aguardando...');
end;

procedure TFormPrincipalSINC.FormDestroy(Sender: TObject);
begin
  FSincronizador.Free;
end;

procedure TFormPrincipalSINC.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ChkMinimizarTray.Checked then
  begin
    Action := caNone;
    MinimizarParaTray;
  end
  else
  begin
    if MessageDlg('Deseja realmente sair do sistema?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      Action := caFree
    else
      Action := caNone;
  end;
end;

procedure TFormPrincipalSINC.CarregarConfiguracao;
var
  Ini: TIniFile;
begin
  if not FileExists(FIniFile) then
    Exit;

  Ini := TIniFile.Create(FIniFile);
  try
    EdtEndpoint.Text := Ini.ReadString('API', 'Endpoint', '');
    EdtChaveAPI.Text := Ini.ReadString('API', 'ChaveAPI', '');
    EdtTempoSync.Text := Ini.ReadString('SYNC', 'TempoSegundos', '300');
    EdtQtdCelulares.Text := Ini.ReadString('CONFIG', 'QtdCelulares', '5');

    ChkIniciarWindows.Checked := Ini.ReadBool('CONFIG', 'IniciarComWindows', False);
    ChkMinimizarTray.Checked := Ini.ReadBool('CONFIG', 'MinimizarParaTray', True);

    ChkSyncEmpresa.Checked := Ini.ReadBool('SYNC_ITEMS', 'Empresa', True);
    ChkSyncUsuario.Checked := Ini.ReadBool('SYNC_ITEMS', 'Usuario', True);
    ChkSyncVendedor.Checked := Ini.ReadBool('SYNC_ITEMS', 'Vendedor', True);
    ChkSyncFormaPgto.Checked := Ini.ReadBool('SYNC_ITEMS', 'FormaPagamento', True);
    ChkSyncClientes.Checked := Ini.ReadBool('SYNC_ITEMS', 'Clientes', True);
    ChkSyncProdutos.Checked := Ini.ReadBool('SYNC_ITEMS', 'Produtos', False);
    ChkSyncPedidos.Checked := Ini.ReadBool('SYNC_ITEMS', 'Pedidos', True);
  finally
    Ini.Free;
  end;
end;

procedure TFormPrincipalSINC.SalvarConfiguracao;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FIniFile);
  try
    Ini.WriteString('API', 'Endpoint', EdtEndpoint.Text);
    Ini.WriteString('API', 'ChaveAPI', EdtChaveAPI.Text);
    Ini.WriteString('SYNC', 'TempoSegundos', EdtTempoSync.Text);
    Ini.WriteString('CONFIG', 'QtdCelulares', EdtQtdCelulares.Text);

    Ini.WriteBool('CONFIG', 'IniciarComWindows', ChkIniciarWindows.Checked);
    Ini.WriteBool('CONFIG', 'MinimizarParaTray', ChkMinimizarTray.Checked);

    Ini.WriteBool('SYNC_ITEMS', 'Empresa', ChkSyncEmpresa.Checked);
    Ini.WriteBool('SYNC_ITEMS', 'Usuario', ChkSyncUsuario.Checked);
    Ini.WriteBool('SYNC_ITEMS', 'Vendedor', ChkSyncVendedor.Checked);
    Ini.WriteBool('SYNC_ITEMS', 'FormaPagamento', ChkSyncFormaPgto.Checked);
    Ini.WriteBool('SYNC_ITEMS', 'Clientes', ChkSyncClientes.Checked);
    Ini.WriteBool('SYNC_ITEMS', 'Produtos', ChkSyncProdutos.Checked);
    Ini.WriteBool('SYNC_ITEMS', 'Pedidos', ChkSyncPedidos.Checked);

    ShowMessage('Configuração salva com sucesso!');
    ConfigurarTimer;
  finally
    Ini.Free;
  end;
end;

procedure TFormPrincipalSINC.ConfigurarTimer;
var
  Segundos: Integer;
begin
  Segundos := StrToIntDef(EdtTempoSync.Text, 300);
  TimerSync.Interval := Segundos * 1000; // Converte para milissegundos
  TimerSync.Enabled := FTimerAtivo;
end;

procedure TFormPrincipalSINC.AdicionarLog(const AMsg: string);
begin
  MemoLog.Lines.Add(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - ' + AMsg);
  MemoLog.Perform(EM_SCROLLCARET, 0, 0); // Auto-scroll
  Application.ProcessMessages;
end;

procedure TFormPrincipalSINC.AtualizarStatus(const AMsg: string);
begin
  LblStatus.Caption := AMsg;
  Application.ProcessMessages;
end;

procedure TFormPrincipalSINC.BtnSalvarConfigClick(Sender: TObject);
begin
  SalvarConfiguracao;
end;

procedure TFormPrincipalSINC.BtnTestarConexaoClick(Sender: TObject);
var
  API: TSincronizadorApi;
begin
  AtualizarStatus('Testando conexão...');
  ProgressBar1.Position := 50;

  try
    API := TSincronizadorApi.Create;
    try
      if API.TestarConexao then
      begin
        ShowMessage('Conexão OK!');
        AdicionarLog('Teste de conexão: SUCESSO');
      end
      else
      begin
        ShowMessage('Falha na conexão!');
        AdicionarLog('Teste de conexão: FALHA');
      end;
    finally
      API.Free;
    end;
  finally
    ProgressBar1.Position := 0;
    AtualizarStatus('Aguardando...');
  end;
end;

procedure TFormPrincipalSINC.BtnEnviarDadosClick(Sender: TObject);
begin
  AtualizarStatus('Enviando dados...');
  ProgressBar1.Position := 25;

  try
    if ChkSyncEmpresa.Checked then
      FSincronizador.EnviarEmpresa;
    ProgressBar1.Position := 35;

    if ChkSyncUsuario.Checked then
      FSincronizador.EnviarUsuarios;
    ProgressBar1.Position := 50;

    if ChkSyncVendedor.Checked then
      FSincronizador.EnviarVendedores;
    ProgressBar1.Position := 65;

    if ChkSyncFormaPgto.Checked then
      FSincronizador.EnviarFormasPagamento;
    ProgressBar1.Position := 80;

    if ChkSyncClientes.Checked then
      FSincronizador.EnviarPessoas;
    ProgressBar1.Position := 90;

    if ChkSyncPedidos.Checked then
      FSincronizador.EnviarOrcamentos;
    ProgressBar1.Position := 100;

    ShowMessage('Envio concluído!');
    LblUltimaSync.Caption := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
  finally
    ProgressBar1.Position := 0;
    AtualizarStatus('Aguardando...');
  end;
end;

procedure TFormPrincipalSINC.BtnReceberDadosClick(Sender: TObject);
begin
  AtualizarStatus('Recebendo dados...');
  ProgressBar1.Position := 25;

  try
    if ChkSyncClientes.Checked then
      FSincronizador.ReceberClientes;
    ProgressBar1.Position := 50;

    if ChkSyncFormaPgto.Checked then
      FSincronizador.ReceberFormasPagamento;
    ProgressBar1.Position := 75;

    if ChkSyncPedidos.Checked then
      FSincronizador.ReceberPedidosWeb;
    ProgressBar1.Position := 100;

    ShowMessage('Recebimento concluído!');
    LblUltimaSync.Caption := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
  finally
    ProgressBar1.Position := 0;
    AtualizarStatus('Aguardando...');
  end;
end;

procedure TFormPrincipalSINC.BtnSincronizarAgoraClick(Sender: TObject);
begin
  AtualizarStatus('Sincronizando...');
  PageControl1.ActivePage := TabLogs;

  try
    FSincronizador.SincronizarTudo;
    LblUltimaSync.Caption := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
  finally
    AtualizarStatus('Aguardando...');
  end;
end;

procedure TFormPrincipalSINC.BtnResetEmpresaClick(Sender: TObject);
begin
  if MessageDlg('Tem certeza que deseja RESETAR a empresa na API?' + #13#10 +
                'Esta ação irá APAGAR todos os dados da empresa na nuvem!',
                mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    FSincronizador.ResetEmpresaNaAPI;
  end;
end;

procedure TFormPrincipalSINC.BtnLimparLogClick(Sender: TObject);
begin
  MemoLog.Clear;
  AdicionarLog('Log limpo');
end;

procedure TFormPrincipalSINC.TimerSyncTimer(Sender: TObject);
begin
  AdicionarLog('Iniciando sincronização automática...');
  BtnSincronizarAgoraClick(nil);
end;

procedure TFormPrincipalSINC.MinimizarParaTray;
begin
  Hide;
  WindowState := wsMinimized;
  TrayIcon1.Visible := True;
  TrayIcon1.BalloonTitle := 'SINC';
  TrayIcon1.BalloonHint := 'Sincronizador minimizado na bandeja';
  TrayIcon1.ShowBalloonHint;
end;

procedure TFormPrincipalSINC.RestaurarDaTray;
begin
  Show;
  WindowState := wsNormal;
  Application.BringToFront;
  TrayIcon1.Visible := False;
end;

procedure TFormPrincipalSINC.TrayIcon1DblClick(Sender: TObject);
begin
  RestaurarDaTray;
end;

procedure TFormPrincipalSINC.MenuRestaurarClick(Sender: TObject);
begin
  RestaurarDaTray;
end;

procedure TFormPrincipalSINC.MenuSincronizarClick(Sender: TObject);
begin
  BtnSincronizarAgoraClick(nil);
end;

procedure TFormPrincipalSINC.MenuPausarClick(Sender: TObject);
begin
  FTimerAtivo := not FTimerAtivo;
  TimerSync.Enabled := FTimerAtivo;

  if FTimerAtivo then
  begin
    MenuPausar.Caption := 'Pausar Sincronismo';
    AdicionarLog('Sincronismo automático ATIVADO');
  end
  else
  begin
    MenuPausar.Caption := 'Retomar Sincronismo';
    AdicionarLog('Sincronismo automático PAUSADO');
  end;
end;

procedure TFormPrincipalSINC.MenuSairClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.
