unit u.Conexao;

interface
uses
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,

  System.SysUtils,
  System.IOUtils,
  System.Classes,
  System.IniFiles;

  type

  TConexao = class

  private
    FCaminhoINI  : string;
    FInifile  : TInifile;
    FDataBase : string;
    FProtocolo: string;
    FServidor : string;
    FPorta    : integer;
    FUsuario  : string;
    FSenha    : string;
    FDriverID : string;


  public

    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure PutArquivoINI;

    function GetConfigConnection(FDConn: TFDConnection): TFDConnection; virtual;


    Property CaminhoINI:       string                    read  FCaminhoINI     ;
    Property Inifile:          TInifile                  read  FInifile        ;
    Property DataBase:         string                    read  FDataBase       ;
    Property Protocolo:        string                    read  FProtocolo      ;
    Property Servidor:         string                    read  FServidor       ;
    Property Porta:            integer                   read  FPorta          ;
    Property Usuario:          string                    read  FUsuario        ;
    Property Senha:            string                    read  FSenha          ;
    Property DriverID :        string                    read  FDriverID       ;

const

  F5_CAMINHO_INI = '\ConexaoF5.ini';
  F2_CAMINHO_INI = '\Conexao.ini';

end;


implementation

{ TConexao }

constructor TConexao.Create(AOwner: TComponent);
begin
    inherited Create;
end;


destructor TConexao.Destroy;
begin

  inherited;
end;

function TConexao.GetConfigConnection(FDConn: TFDConnection): TFDConnection;
begin
  Result := FDConn;

  //FireBird5 F5_CAMINHO_INI
  //FireBird2.5 F2_CAMINHO_INI

  try
    FCaminhoINI := ExtractFileDir(ParamStr(0)) + '\config' + F5_CAMINHO_INI;

    // Cria o arquivo .ini com valores padrão se não existir
    if not FileExists(FCaminhoINI) then
      PutArquivoINI;

    // Agora lemos as configurações do arquivo
    FIniFile := TIniFile.Create(FCaminhoINI);
    try
      FDataBase := FIniFile.ReadString('Conexao', 'Database', FDataBase);
      FProtocolo := FIniFile.ReadString('Conexao', 'Protocol', FProtocolo);
      FServidor := FIniFile.ReadString('Conexao', 'Server', FServidor);
      FPorta := FIniFile.ReadInteger('Conexao', 'Porta', FPorta);
      FUsuario := FIniFile.ReadString('Conexao', 'User', FUsuario);
      FSenha := FIniFile.ReadString('Conexao', 'Pass', FSenha);
      FDriverID := FIniFile.ReadString('Conexao', 'DriverID', FDriverID);

      FDConn.Params.Clear;
      FDConn.Params.Add('Database=' + FDataBase);
      FDConn.Params.Add('Protocol=' + FProtocolo);
      FDConn.Params.Add('Server=' + FServidor);
      FDConn.Params.Add('Port=' + IntToStr(FPorta));
      FDConn.Params.Add('User_Name=' + FUsuario);
      FDConn.Params.Add('Password=' + FSenha);
      FDConn.Params.Add('DriverID=' + FDriverID);

    finally
      FIniFile.Free;
    end;
  except
    on E: Exception do
      raise Exception.Create('Error: ' + E.Message);
  end;
end;

procedure TConexao.PutArquivoINI;
var
  FCaminhoINI: string;
  FIniFile: TIniFile;
begin
  // Grava o arquivo .ini
  FCaminhoINI := ExtractFileDir(ParamStr(0)) + '\config' + F5_CAMINHO_INI;
  // Verifica se o arquivo não existe e cria se necessário
  if not FileExists(FCaminhoINI) then
  begin
    FIniFile := TIniFile.Create(FCaminhoINI);
    try
      // Configuração padrão ou valores iniciais
      FIniFile.WriteString('Conexao',                 'Database'                , 'D:\delph\ERPZeus\install\BD\DADOSHM.FDB');
      FIniFile.WriteString('Conexao',                 'Protocol'                , 'TCPIP');
      FIniFile.WriteString('Conexao',                 'Server'                  , '127.0.0.1');
      FIniFile.WriteInteger('Conexao',                'Porta'                   , 3050);
      FIniFile.WriteString('Conexao',                 'User'                    , 'SYSDBA');
      FIniFile.WriteString('Conexao',                 'Pass'                    , 'masterkey');
      FIniFile.WriteString('Conexao',                 'DriverID'                , 'FB');
    finally
      FIniFile.Free;
    end;
  end;

  // Agora lemos as configurações do arquivo
  FIniFile := TIniFile.Create(FCaminhoINI);
  try
    FIniFile.ReadString('Conexao'               , 'Database', FDataBase);
    FIniFile.ReadString('Conexao'               , 'Protocol', FProtocolo);
    FIniFile.ReadString('Conexao'               , 'Server', FServidor);
    FIniFile.ReadInteger('Conexao'              , 'Porta', FPorta);
    FIniFile.ReadString('Conexao'               , 'User', FUsuario);
    FIniFile.ReadString('Conexao'               , 'Pass', FSenha);
   FIniFile.ReadString('Conexao'                , 'DriverID', FDriverID);
  finally
    FIniFile.Free;
  end;
end;


end.
