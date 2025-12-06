unit uConfiguracao;

{*******************************************************************************
  UNIT DE CONFIGURAÇÃO DO SINCRONIZADOR

  Responsável por:
  - Gerenciar arquivo Sincronizador.ini
  - Salvar/Carregar configurações da API
  - Controlar timestamps de sincronização
  - Configurações de sistema (tray, auto-start, etc)

  Autor: Sistema FSVendas
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.IniFiles, System.Classes;

type
  TConfiguracao = class
  private
    FIniFile: TIniFile;
    FCaminhoArquivo: string;

    function GetCaminhoPadrao: string;
  public
    constructor Create; overload;
    constructor Create(const ACaminho: string); overload;
    destructor Destroy; override;

    // ===== API =====
    function GetEndpoint: string;
    procedure SetEndpoint(const AValue: string);

    function GetChaveAPI: string;
    procedure SetChaveAPI(const AValue: string);

    function GetTempoSincronizacao: Integer;
    procedure SetTempoSincronizacao(AValue: Integer);

    function GetQtdCelulares: Integer;
    procedure SetQtdCelulares(AValue: Integer);

    // ===== SISTEMA =====
    function GetIniciarComWindows: Boolean;
    procedure SetIniciarComWindows(AValue: Boolean);

    function GetMinimizarParaTray: Boolean;
    procedure SetMinimizarParaTray(AValue: Boolean);

    function GetSalvarLogsArquivo: Boolean;
    procedure SetSalvarLogsArquivo(AValue: Boolean);

    // ===== SINCRONIZAÇÃO =====
    function GetAutoEnviar: Boolean;
    procedure SetAutoEnviar(AValue: Boolean);

    function GetAutoReceber: Boolean;
    procedure SetAutoReceber(AValue: Boolean);

    function GetSincronizarImagens: Boolean;
    procedure SetSincronizarImagens(AValue: Boolean);

    // ===== TIMESTAMPS =====
    function GetUltimoEnvio(const AEntidade: string): TDateTime;
    procedure SetUltimoEnvio(const AEntidade: string; AData: TDateTime);

    function GetUltimoRecebimento(const AEntidade: string): TDateTime;
    procedure SetUltimoRecebimento(const AEntidade: string; AData: TDateTime);

    // ===== UTILITÁRIOS =====
    procedure LimparTimestamps;
    function ValidarConfiguracao: string; // Retorna mensagem de erro ou ''

    property CaminhoArquivo: string read FCaminhoArquivo;
  end;

implementation

uses
  Winapi.Windows, Vcl.Forms;

{ TConfiguracao }

constructor TConfiguracao.Create;
begin
  Create(GetCaminhoPadrao);
end;

constructor TConfiguracao.Create(const ACaminho: string);
begin
  inherited Create;
  FCaminhoArquivo := ACaminho;
  FIniFile := TIniFile.Create(FCaminhoArquivo);
end;

destructor TConfiguracao.Destroy;
begin
  FreeAndNil(FIniFile);
  inherited;
end;

function TConfiguracao.GetCaminhoPadrao: string;
begin
  Result := ExtractFilePath(Application.ExeName) + 'Sincronizador.ini';
end;

// ===== API =====

function TConfiguracao.GetEndpoint: string;
begin
  Result := FIniFile.ReadString('API', 'Endpoint', 'https://api.fsvendas.com.br/api');
end;

procedure TConfiguracao.SetEndpoint(const AValue: string);
begin
  FIniFile.WriteString('API', 'Endpoint', Trim(AValue));
end;

function TConfiguracao.GetChaveAPI: string;
begin
  Result := FIniFile.ReadString('API', 'ChaveAPI', '');
end;

procedure TConfiguracao.SetChaveAPI(const AValue: string);
begin
  FIniFile.WriteString('API', 'ChaveAPI', Trim(AValue));
end;

function TConfiguracao.GetTempoSincronizacao: Integer;
begin
  Result := FIniFile.ReadInteger('API', 'TempoSincronizacao', 300); // 5 minutos
  if Result < 30 then
    Result := 30; // Mínimo 30 segundos
end;

procedure TConfiguracao.SetTempoSincronizacao(AValue: Integer);
begin
  if AValue < 30 then
    AValue := 30;
  FIniFile.WriteInteger('API', 'TempoSincronizacao', AValue);
end;

function TConfiguracao.GetQtdCelulares: Integer;
begin
  Result := FIniFile.ReadInteger('API', 'QtdCelulares', 5);
end;

procedure TConfiguracao.SetQtdCelulares(AValue: Integer);
begin
  FIniFile.WriteInteger('API', 'QtdCelulares', AValue);
end;

// ===== SISTEMA =====

function TConfiguracao.GetIniciarComWindows: Boolean;
begin
  Result := FIniFile.ReadBool('SISTEMA', 'IniciarComWindows', False);
end;

procedure TConfiguracao.SetIniciarComWindows(AValue: Boolean);
begin
  FIniFile.WriteBool('SISTEMA', 'IniciarComWindows', AValue);
end;

function TConfiguracao.GetMinimizarParaTray: Boolean;
begin
  Result := FIniFile.ReadBool('SISTEMA', 'MinimizarParaTray', True);
end;

procedure TConfiguracao.SetMinimizarParaTray(AValue: Boolean);
begin
  FIniFile.WriteBool('SISTEMA', 'MinimizarParaTray', AValue);
end;

function TConfiguracao.GetSalvarLogsArquivo: Boolean;
begin
  Result := FIniFile.ReadBool('SISTEMA', 'SalvarLogsArquivo', False);
end;

procedure TConfiguracao.SetSalvarLogsArquivo(AValue: Boolean);
begin
  FIniFile.WriteBool('SISTEMA', 'SalvarLogsArquivo', AValue);
end;

// ===== SINCRONIZAÇÃO =====

function TConfiguracao.GetAutoEnviar: Boolean;
begin
  Result := FIniFile.ReadBool('SINCRONIZACAO', 'AutoEnviar', False);
end;

procedure TConfiguracao.SetAutoEnviar(AValue: Boolean);
begin
  FIniFile.WriteBool('SINCRONIZACAO', 'AutoEnviar', AValue);
end;

function TConfiguracao.GetAutoReceber: Boolean;
begin
  Result := FIniFile.ReadBool('SINCRONIZACAO', 'AutoReceber', False);
end;

procedure TConfiguracao.SetAutoReceber(AValue: Boolean);
begin
  FIniFile.WriteBool('SINCRONIZACAO', 'AutoReceber', AValue);
end;

function TConfiguracao.GetSincronizarImagens: Boolean;
begin
  Result := FIniFile.ReadBool('SINCRONIZACAO', 'SincronizarImagens', False);
end;

procedure TConfiguracao.SetSincronizarImagens(AValue: Boolean);
begin
  FIniFile.WriteBool('SINCRONIZACAO', 'SincronizarImagens', AValue);
end;

// ===== TIMESTAMPS =====

function TConfiguracao.GetUltimoEnvio(const AEntidade: string): TDateTime;
var
  LDataStr: string;
begin
  LDataStr := FIniFile.ReadString('ULTIMO_ENVIO', AEntidade, '');
  if LDataStr = '' then
    Result := 0
  else
    try
      Result := StrToDateTime(LDataStr);
    except
      Result := 0;
    end;
end;

procedure TConfiguracao.SetUltimoEnvio(const AEntidade: string; AData: TDateTime);
begin
  if AData = 0 then
    FIniFile.DeleteKey('ULTIMO_ENVIO', AEntidade)
  else
    FIniFile.WriteString('ULTIMO_ENVIO', AEntidade, DateTimeToStr(AData));
end;

function TConfiguracao.GetUltimoRecebimento(const AEntidade: string): TDateTime;
var
  LDataStr: string;
begin
  LDataStr := FIniFile.ReadString('ULTIMO_RECEBIMENTO', AEntidade, '');
  if LDataStr = '' then
    Result := 0
  else
    try
      Result := StrToDateTime(LDataStr);
    except
      Result := 0;
    end;
end;

procedure TConfiguracao.SetUltimoRecebimento(const AEntidade: string; AData: TDateTime);
begin
  if AData = 0 then
    FIniFile.DeleteKey('ULTIMO_RECEBIMENTO', AEntidade)
  else
    FIniFile.WriteString('ULTIMO_RECEBIMENTO', AEntidade, DateTimeToStr(AData));
end;

// ===== UTILITÁRIOS =====

procedure TConfiguracao.LimparTimestamps;
begin
  FIniFile.EraseSection('ULTIMO_ENVIO');
  FIniFile.EraseSection('ULTIMO_RECEBIMENTO');
end;

function TConfiguracao.ValidarConfiguracao: string;
var
  LEndpoint, LChave: string;
begin
  Result := '';

  LEndpoint := Trim(GetEndpoint);
  if LEndpoint = '' then
  begin
    Result := 'Endpoint da API não configurado';
    Exit;
  end;

  if not (LEndpoint.ToLower.StartsWith('http://') or
          LEndpoint.ToLower.StartsWith('https://')) then
  begin
    Result := 'Endpoint inválido (deve iniciar com http:// ou https://)';
    Exit;
  end;

  LChave := Trim(GetChaveAPI);
  if LChave = '' then
  begin
    Result := 'Chave API não configurada';
    Exit;
  end;

  if GetTempoSincronizacao < 30 then
  begin
    Result := 'Tempo mínimo de sincronização é 30 segundos';
    Exit;
  end;
end;

end.
