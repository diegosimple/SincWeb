unit SINC.Services.UsuarioService;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  SINC.Model.Usuario, SINC.Provider.ConexaoBD;

type
  TUsuarioService = class
  private
    FConexao: TConexaoBD;
  public
    constructor Create;
    destructor Destroy; override;
    function BuscarPorCodigo(ACodigo: Integer): TUsuario;
    function ListarParaEnvio: TObjectList<TUsuario>;
    procedure SalvarOuAtualizar(AUsuario: TUsuario);
    function Existe(ACodigo: Integer): Boolean;
    function ProximoCodigo: Integer;
  end;

implementation

constructor TUsuarioService.Create;
begin
  inherited;
  FConexao := TConexaoBD.GetInstance;
end;

destructor TUsuarioService.Destroy;
begin
  inherited;
end;

function TUsuarioService.BuscarPorCodigo(ACodigo: Integer): TUsuario;
var
  Qry: TFDQuery;
begin
  Result := nil;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM USUARIOS WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      Result := TUsuario.Create;
      Result.FromDataSet(Qry);
    end;
  finally
    Qry.Free;
  end;
end;

function TUsuarioService.ListarParaEnvio: TObjectList<TUsuario>;
var
  Qry: TFDQuery;
  Usuario: TUsuario;
begin
  Result := TObjectList<TUsuario>.Create(True);
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM USUARIOS WHERE (FLAG IS NULL OR FLAG = '''') ORDER BY CODIGO';
    Qry.Open;
    while not Qry.Eof do
    begin
      Usuario := TUsuario.Create;
      Usuario.FromDataSet(Qry);
      Result.Add(Usuario);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TUsuarioService.SalvarOuAtualizar(AUsuario: TUsuario);
var
  Qry: TFDQuery;
begin
  if not Assigned(AUsuario) then
    raise Exception.Create('Usuário não pode ser nulo');

  Qry := FConexao.NovaQuery;
  try
    FConexao.IniciarTransacao;
    try
      if Existe(AUsuario.Codigo) then
      begin
        Qry.SQL.Text := 'UPDATE USUARIOS SET SENHA = :SENHA, HIERARQUIA = :HIERARQUIA, ' +
          'ECAIXA = :ECAIXA, SUPERVISOR = :SUPERVISOR, ATIVO = :ATIVO, ' +
          'FK_VENDEDOR = :FK_VENDEDOR, LOGIN = :LOGIN, FLAG = :FLAG ' +
          'WHERE CODIGO = :CODIGO';
      end
      else
      begin
        if AUsuario.Codigo = 0 then
          AUsuario.Codigo := ProximoCodigo;

        Qry.SQL.Text := 'INSERT INTO USUARIOS (CODIGO, SENHA, HIERARQUIA, ECAIXA, SUPERVISOR, ' +
          'ATIVO, FK_VENDEDOR, LOGIN, FLAG) VALUES (:CODIGO, :SENHA, :HIERARQUIA, ' +
          ':ECAIXA, :SUPERVISOR, :ATIVO, :FK_VENDEDOR, :LOGIN, :FLAG)';
      end;

      Qry.ParamByName('CODIGO').AsInteger := AUsuario.Codigo;
      Qry.ParamByName('SENHA').AsString := AUsuario.Senha;
      Qry.ParamByName('HIERARQUIA').AsInteger := AUsuario.Hierarquia;
      Qry.ParamByName('ECAIXA').AsString := AUsuario.ECaixa;
      Qry.ParamByName('SUPERVISOR').AsString := AUsuario.Supervisor;
      Qry.ParamByName('ATIVO').AsString := AUsuario.Ativo;
      Qry.ParamByName('FK_VENDEDOR').AsInteger := AUsuario.FKVendedor;
      Qry.ParamByName('LOGIN').AsString := AUsuario.Login;
      Qry.ParamByName('FLAG').AsString := AUsuario.Flag;

      Qry.ExecSQL;
      FConexao.CommitTransacao;
    except
      on E: Exception do
      begin
        FConexao.RollbackTransacao;
        raise Exception.Create('Erro ao salvar usuário: ' + E.Message);
      end;
    end;
  finally
    Qry.Free;
  end;
end;

function TUsuarioService.Existe(ACodigo: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT CODIGO FROM USUARIOS WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    Result := not Qry.IsEmpty;
  finally
    Qry.Free;
  end;
end;

function TUsuarioService.ProximoCodigo: Integer;
var
  Qry: TFDQuery;
begin
  Result := 1;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT MAX(CODIGO) AS MAXIMO FROM USUARIOS';
    Qry.Open;
    if not Qry.FieldByName('MAXIMO').IsNull then
      Result := Qry.FieldByName('MAXIMO').AsInteger + 1;
  finally
    Qry.Free;
  end;
end;

end.
