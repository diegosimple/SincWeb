unit SINC.Provider.ConexaoBD;

{*******************************************************************************
  SINC - Provider de Conexão com Banco de Dados Firebird

  Responsável por gerenciar a conexão com o banco de dados local via FireDAC

  Recursos:
  - Singleton para garantir única instância da conexão
  - Configuração via arquivo INI
  - Criação de queries com FieldByName obrigatório
  - Suporte a transações

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.IniFiles,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB;

type
  TConexaoBD = class
  private
    class var FInstance: TConexaoBD;
    FConnection: TFDConnection;
    FIniFile: string;

    constructor CreatePrivate;
    procedure ConfigurarConexao;
    procedure CarregarConfiguracao;

  public
    destructor Destroy; override;

    class function GetInstance: TConexaoBD;
    class procedure ReleaseInstance;

    function NovaQuery: TFDQuery;
    function GetConnection: TFDConnection;
    procedure IniciarTransacao;
    procedure CommitTransacao;
    procedure RollbackTransacao;
    function Conectado: Boolean;
    procedure Conectar;
    procedure Desconectar;

    property Connection: TFDConnection read GetConnection;
  end;

implementation

{ TConexaoBD }

constructor TConexaoBD.CreatePrivate;
begin
  inherited Create;

  FIniFile := ExtractFilePath(ParamStr(0)) + 'Sincronizador.ini';
  FConnection := TFDConnection.Create(nil);

  ConfigurarConexao;
  CarregarConfiguracao;
end;

destructor TConexaoBD.Destroy;
begin
  if Assigned(FConnection) then
  begin
    if FConnection.Connected then
      FConnection.Connected := False;
    FreeAndNil(FConnection);
  end;

  inherited;
end;

class function TConexaoBD.GetInstance: TConexaoBD;
begin
  if not Assigned(FInstance) then
    FInstance := TConexaoBD.CreatePrivate;

  Result := FInstance;
end;

class procedure TConexaoBD.ReleaseInstance;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

procedure TConexaoBD.ConfigurarConexao;
begin
  FConnection.DriverName := 'FB';
  FConnection.Params.Clear;

  // Parâmetros padrão do Firebird
  FConnection.Params.Add('DriverID=FB');
  FConnection.Params.Add('CharacterSet=WIN1252');
  FConnection.Params.Add('Protocol=TCPIP');
  FConnection.Params.Add('SQLDialect=3');

  // Pool de conexões
  FConnection.ResourceOptions.AutoConnect := True;
  FConnection.ResourceOptions.KeepConnection := True;

  // Configurações de performance
  FConnection.FetchOptions.Mode := fmAll;
  FConnection.FetchOptions.RecordCountMode := cmVisible;
  FConnection.UpdateOptions.LockWait := True;

  FConnection.LoginPrompt := False;
end;

procedure TConexaoBD.CarregarConfiguracao;
var
  Ini: TIniFile;
  Servidor: string;
  Porta: Integer;
  Database: string;
  Usuario: string;
  Senha: string;
begin
  if not FileExists(FIniFile) then
    raise Exception.Create('Arquivo de configuração não encontrado: ' + FIniFile);

  Ini := TIniFile.Create(FIniFile);
  try
    // Lê configurações do banco de dados
    Servidor := Ini.ReadString('BANCO_DADOS', 'Servidor', 'localhost');
    Porta := Ini.ReadInteger('BANCO_DADOS', 'Porta', 3050);
    Database := Ini.ReadString('BANCO_DADOS', 'Database', '');
    Usuario := Ini.ReadString('BANCO_DADOS', 'Usuario', 'SYSDBA');
    Senha := Ini.ReadString('BANCO_DADOS', 'Senha', 'masterkey');

    if Database = '' then
      raise Exception.Create('Caminho do banco de dados não configurado no INI');

    // Configura a string de conexão
    FConnection.Params.Values['Server'] := Servidor;
    FConnection.Params.Values['Port'] := IntToStr(Porta);
    FConnection.Params.Values['Database'] := Database;
    FConnection.Params.Values['User_Name'] := Usuario;
    FConnection.Params.Values['Password'] := Senha;

  finally
    Ini.Free;
  end;
end;

function TConexaoBD.NovaQuery: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FConnection;

  // Garante que a conexão esteja ativa
  if not FConnection.Connected then
    Conectar;
end;

function TConexaoBD.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

procedure TConexaoBD.IniciarTransacao;
begin
  if not FConnection.InTransaction then
    FConnection.StartTransaction;
end;

procedure TConexaoBD.CommitTransacao;
begin
  if FConnection.InTransaction then
    FConnection.Commit;
end;

procedure TConexaoBD.RollbackTransacao;
begin
  if FConnection.InTransaction then
    FConnection.Rollback;
end;

function TConexaoBD.Conectado: Boolean;
begin
  Result := FConnection.Connected;
end;

procedure TConexaoBD.Conectar;
begin
  if not FConnection.Connected then
  begin
    try
      FConnection.Connected := True;
    except
      on E: Exception do
        raise Exception.Create('Erro ao conectar ao banco de dados: ' + E.Message);
    end;
  end;
end;

procedure TConexaoBD.Desconectar;
begin
  if FConnection.Connected then
    FConnection.Connected := False;
end;

initialization

finalization
  TConexaoBD.ReleaseInstance;

end.
