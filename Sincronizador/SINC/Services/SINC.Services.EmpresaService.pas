unit SINC.Services.EmpresaService;

{*******************************************************************************
  SINC - Service Empresa

  Camada de serviço para operações de banco de dados da entidade EMPRESA
  SEMPRE usando FieldByName conforme especificação

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  SINC.Model.Empresa, SINC.Provider.ConexaoBD;

type
  TEmpresaService = class
  private
    FConexao: TConexaoBD;

  public
    constructor Create;
    destructor Destroy; override;

    function BuscarPorCodigo(ACodigo: Integer): TEmpresa;
    function ListarParaEnvio: TObjectList<TEmpresa>;
    function ListarTodos: TObjectList<TEmpresa>;
    procedure SalvarOuAtualizar(AEmpresa: TEmpresa);
    procedure Deletar(ACodigo: Integer);
    function Existe(ACodigo: Integer): Boolean;
    function ProximoCodigo: Integer;
  end;

implementation

{ TEmpresaService }

constructor TEmpresaService.Create;
begin
  inherited;
  FConexao := TConexaoBD.GetInstance;
end;

destructor TEmpresaService.Destroy;
begin
  inherited;
end;

function TEmpresaService.BuscarPorCodigo(ACodigo: Integer): TEmpresa;
var
  Qry: TFDQuery;
begin
  Result := nil;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM EMPRESA WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;

    if not Qry.IsEmpty then
    begin
      Result := TEmpresa.Create;
      Result.FromDataSet(Qry);
    end;

  finally
    Qry.Free;
  end;
end;

function TEmpresaService.ListarParaEnvio: TObjectList<TEmpresa>;
var
  Qry: TFDQuery;
  Empresa: TEmpresa;
begin
  Result := TObjectList<TEmpresa>.Create(True);
  Qry := FConexao.NovaQuery;
  try
    // Busca empresas que precisam ser sincronizadas (sem FLAG ou FLAG vazio)
    Qry.SQL.Text := 'SELECT * FROM EMPRESA WHERE (FLAG IS NULL OR FLAG = '''') ORDER BY CODIGO';
    Qry.Open;

    while not Qry.Eof do
    begin
      Empresa := TEmpresa.Create;
      Empresa.FromDataSet(Qry);
      Result.Add(Empresa);
      Qry.Next;
    end;

  finally
    Qry.Free;
  end;
end;

function TEmpresaService.ListarTodos: TObjectList<TEmpresa>;
var
  Qry: TFDQuery;
  Empresa: TEmpresa;
begin
  Result := TObjectList<TEmpresa>.Create(True);
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM EMPRESA ORDER BY CODIGO';
    Qry.Open;

    while not Qry.Eof do
    begin
      Empresa := TEmpresa.Create;
      Empresa.FromDataSet(Qry);
      Result.Add(Empresa);
      Qry.Next;
    end;

  finally
    Qry.Free;
  end;
end;

procedure TEmpresaService.SalvarOuAtualizar(AEmpresa: TEmpresa);
var
  Qry: TFDQuery;
begin
  if not Assigned(AEmpresa) then
    raise Exception.Create('Empresa não pode ser nula');

  Qry := FConexao.NovaQuery;
  try
    FConexao.IniciarTransacao;
    try
      if Existe(AEmpresa.Codigo) then
      begin
        // UPDATE usando FieldByName
        Qry.SQL.Text := 'UPDATE EMPRESA SET ' +
          'FANTASIA = :FANTASIA, ' +
          'RAZAO = :RAZAO, ' +
          'TIPO = :TIPO, ' +
          'CNPJ = :CNPJ, ' +
          'IE = :IE, ' +
          'IM = :IM, ' +
          'ENDERECO = :ENDERECO, ' +
          'NUMERO = :NUMERO, ' +
          'COMPLEMENTO = :COMPLEMENTO, ' +
          'BAIRRO = :BAIRRO, ' +
          'CIDADE = :CIDADE, ' +
          'UF = :UF, ' +
          'CEP = :CEP, ' +
          'FONE = :FONE, ' +
          'FAX = :FAX, ' +
          'SITE = :SITE, ' +
          'EMAIL = :EMAIL, ' +
          'FLAG = :FLAG, ' +
          'USAR_SISTEMA_WEB = :USAR_SISTEMA_WEB, ' +
          'CADASTRO_WEB = :CADASTRO_WEB, ' +
          'CWEB = :CWEB ' +
          'WHERE CODIGO = :CODIGO';
      end
      else
      begin
        // INSERT usando FieldByName
        if AEmpresa.Codigo = 0 then
          AEmpresa.Codigo := ProximoCodigo;

        Qry.SQL.Text := 'INSERT INTO EMPRESA (' +
          'CODIGO, FANTASIA, RAZAO, TIPO, CNPJ, IE, IM, ' +
          'ENDERECO, NUMERO, COMPLEMENTO, BAIRRO, CIDADE, UF, CEP, ' +
          'FONE, FAX, SITE, FUNDACAO, USU_CAD, NSERIE, CSENHA, ' +
          'EMAIL, FLAG, USAR_SISTEMA_WEB, CADASTRO_WEB, CWEB) ' +
          'VALUES (' +
          ':CODIGO, :FANTASIA, :RAZAO, :TIPO, :CNPJ, :IE, :IM, ' +
          ':ENDERECO, :NUMERO, :COMPLEMENTO, :BAIRRO, :CIDADE, :UF, :CEP, ' +
          ':FONE, :FAX, :SITE, :FUNDACAO, :USU_CAD, :NSERIE, :CSENHA, ' +
          ':EMAIL, :FLAG, :USAR_SISTEMA_WEB, :CADASTRO_WEB, :CWEB)';

        Qry.ParamByName('FUNDACAO').AsDate := AEmpresa.Fundacao;
        Qry.ParamByName('USU_CAD').AsInteger := AEmpresa.UsuCad;
        Qry.ParamByName('NSERIE').AsString := AEmpresa.NSerie;
        Qry.ParamByName('CSENHA').AsString := AEmpresa.CSenha;
      end;

      // Parâmetros comuns (INSERT e UPDATE)
      Qry.ParamByName('CODIGO').AsInteger := AEmpresa.Codigo;
      Qry.ParamByName('FANTASIA').AsString := AEmpresa.Fantasia;
      Qry.ParamByName('RAZAO').AsString := AEmpresa.Razao;
      Qry.ParamByName('TIPO').AsString := AEmpresa.Tipo;
      Qry.ParamByName('CNPJ').AsString := AEmpresa.CNPJ;
      Qry.ParamByName('IE').AsString := AEmpresa.IE;
      Qry.ParamByName('IM').AsString := AEmpresa.IM;
      Qry.ParamByName('ENDERECO').AsString := AEmpresa.Endereco;
      Qry.ParamByName('NUMERO').AsString := AEmpresa.Numero;
      Qry.ParamByName('COMPLEMENTO').AsString := AEmpresa.Complemento;
      Qry.ParamByName('BAIRRO').AsString := AEmpresa.Bairro;
      Qry.ParamByName('CIDADE').AsString := AEmpresa.Cidade;
      Qry.ParamByName('UF').AsString := AEmpresa.UF;
      Qry.ParamByName('CEP').AsString := AEmpresa.CEP;
      Qry.ParamByName('FONE').AsString := AEmpresa.Fone;
      Qry.ParamByName('FAX').AsString := AEmpresa.Fax;
      Qry.ParamByName('SITE').AsString := AEmpresa.Site;
      Qry.ParamByName('EMAIL').AsString := AEmpresa.Email;
      Qry.ParamByName('FLAG').AsString := AEmpresa.Flag;
      Qry.ParamByName('USAR_SISTEMA_WEB').AsString := AEmpresa.UsarSistemaWeb;
      Qry.ParamByName('CADASTRO_WEB').AsString := AEmpresa.CadastroWeb;
      Qry.ParamByName('CWEB').AsInteger := AEmpresa.CWEB;

      Qry.ExecSQL;
      FConexao.CommitTransacao;

    except
      on E: Exception do
      begin
        FConexao.RollbackTransacao;
        raise Exception.Create('Erro ao salvar empresa: ' + E.Message);
      end;
    end;

  finally
    Qry.Free;
  end;
end;

procedure TEmpresaService.Deletar(ACodigo: Integer);
var
  Qry: TFDQuery;
begin
  Qry := FConexao.NovaQuery;
  try
    FConexao.IniciarTransacao;
    try
      Qry.SQL.Text := 'DELETE FROM EMPRESA WHERE CODIGO = :CODIGO';
      Qry.ParamByName('CODIGO').AsInteger := ACodigo;
      Qry.ExecSQL;

      FConexao.CommitTransacao;

    except
      on E: Exception do
      begin
        FConexao.RollbackTransacao;
        raise Exception.Create('Erro ao deletar empresa: ' + E.Message);
      end;
    end;

  finally
    Qry.Free;
  end;
end;

function TEmpresaService.Existe(ACodigo: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT CODIGO FROM EMPRESA WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;

    Result := not Qry.IsEmpty;

  finally
    Qry.Free;
  end;
end;

function TEmpresaService.ProximoCodigo: Integer;
var
  Qry: TFDQuery;
begin
  Result := 1;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT MAX(CODIGO) AS MAXIMO FROM EMPRESA';
    Qry.Open;

    if not Qry.FieldByName('MAXIMO').IsNull then
      Result := Qry.FieldByName('MAXIMO').AsInteger + 1;

  finally
    Qry.Free;
  end;
end;

end.
