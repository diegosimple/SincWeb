unit SINC.Services.PessoaService;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  SINC.Model.Pessoa, SINC.Provider.ConexaoBD;

type
  TPessoaService = class
  private
    FConexao: TConexaoBD;
  public
    constructor Create;
    destructor Destroy; override;
    function BuscarPorCodigo(AEmpresa, ACodigo: Integer): TPessoa;
    function BuscarPorCodigoWeb(ACodigoWeb: Integer): TPessoa;
    function ListarParaEnvio: TObjectList<TPessoa>;
    procedure SalvarOuAtualizar(APessoa: TPessoa);
    function Existe(AEmpresa, ACodigo: Integer): Boolean;
    function ProximoCodigo(AEmpresa: Integer): Integer;
  end;

implementation

constructor TPessoaService.Create;
begin
  inherited;
  FConexao := TConexaoBD.GetInstance;
end;

destructor TPessoaService.Destroy;
begin
  inherited;
end;

function TPessoaService.BuscarPorCodigo(AEmpresa, ACodigo: Integer): TPessoa;
var
  Qry: TFDQuery;
begin
  Result := nil;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM PESSOA WHERE EMPRESA = :EMPRESA AND CODIGO = :CODIGO';
    Qry.ParamByName('EMPRESA').AsInteger := AEmpresa;
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      Result := TPessoa.Create;
      Result.FromDataSet(Qry);
    end;
  finally
    Qry.Free;
  end;
end;

function TPessoaService.BuscarPorCodigoWeb(ACodigoWeb: Integer): TPessoa;
var
  Qry: TFDQuery;
begin
  Result := nil;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM PESSOA WHERE CODIGO_WEB = :CODIGO_WEB';
    Qry.ParamByName('CODIGO_WEB').AsInteger := ACodigoWeb;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      Result := TPessoa.Create;
      Result.FromDataSet(Qry);
    end;
  finally
    Qry.Free;
  end;
end;

function TPessoaService.ListarParaEnvio: TObjectList<TPessoa>;
var
  Qry: TFDQuery;
  Pessoa: TPessoa;
begin
  Result := TObjectList<TPessoa>.Create(True);
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM PESSOA WHERE CLI = ''S'' AND (FLAG IS NULL OR FLAG = '''') ORDER BY EMPRESA, CODIGO';
    Qry.Open;
    while not Qry.Eof do
    begin
      Pessoa := TPessoa.Create;
      Pessoa.FromDataSet(Qry);
      Result.Add(Pessoa);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TPessoaService.SalvarOuAtualizar(APessoa: TPessoa);
var
  Qry: TFDQuery;
begin
  if not Assigned(APessoa) then
    raise Exception.Create('Pessoa não pode ser nula');

  Qry := FConexao.NovaQuery;
  try
    FConexao.IniciarTransacao;
    try
      if Existe(APessoa.Empresa, APessoa.Codigo) then
      begin
        Qry.SQL.Text := 'UPDATE PESSOA SET TIPO = :TIPO, CNPJ = :CNPJ, IE = :IE, FANTASIA = :FANTASIA, ' +
          'RAZAO = :RAZAO, ENDERECO = :ENDERECO, NUMERO = :NUMERO, COMPLEMENTO = :COMPLEMENTO, ' +
          'BAIRRO = :BAIRRO, MUNICIPIO = :MUNICIPIO, UF = :UF, CEP = :CEP, ' +
          'FONE1 = :FONE1, CELULAR1 = :CELULAR1, EMAIL1 = :EMAIL1, CLI = :CLI, ATIVO = :ATIVO, ' +
          'CODIGO_WEB = :CODIGO_WEB, FLAG = :FLAG, WHATSAPP = :WHATSAPP ' +
          'WHERE EMPRESA = :EMPRESA AND CODIGO = :CODIGO';
      end
      else
      begin
        if APessoa.Codigo = 0 then
          APessoa.Codigo := ProximoCodigo(APessoa.Empresa);

        Qry.SQL.Text := 'INSERT INTO PESSOA (EMPRESA, CODIGO, TIPO, CNPJ, IE, FANTASIA, RAZAO, ' +
          'ENDERECO, NUMERO, COMPLEMENTO, BAIRRO, MUNICIPIO, UF, CEP, FONE1, CELULAR1, EMAIL1, ' +
          'FORN, FUN, CLI, FAB, TRAN, ADM, ATIVO, DT_CADASTRO, CODIGO_WEB, FLAG, WHATSAPP) ' +
          'VALUES (:EMPRESA, :CODIGO, :TIPO, :CNPJ, :IE, :FANTASIA, :RAZAO, :ENDERECO, :NUMERO, ' +
          ':COMPLEMENTO, :BAIRRO, :MUNICIPIO, :UF, :CEP, :FONE1, :CELULAR1, :EMAIL1, ' +
          ':FORN, :FUN, :CLI, :FAB, :TRAN, :ADM, :ATIVO, :DT_CADASTRO, :CODIGO_WEB, :FLAG, :WHATSAPP)';

        Qry.ParamByName('FORN').AsString := APessoa.Forn;
        Qry.ParamByName('FUN').AsString := APessoa.Fun;
        Qry.ParamByName('FAB').AsString := APessoa.Fab;
        Qry.ParamByName('TRAN').AsString := APessoa.Tran;
        Qry.ParamByName('ADM').AsString := APessoa.Adm;
        Qry.ParamByName('DT_CADASTRO').AsDate := APessoa.DtCadastro;
      end;

      Qry.ParamByName('EMPRESA').AsInteger := APessoa.Empresa;
      Qry.ParamByName('CODIGO').AsInteger := APessoa.Codigo;
      Qry.ParamByName('TIPO').AsString := APessoa.Tipo;
      Qry.ParamByName('CNPJ').AsString := APessoa.CNPJ;
      Qry.ParamByName('IE').AsString := APessoa.IE;
      Qry.ParamByName('FANTASIA').AsString := APessoa.Fantasia;
      Qry.ParamByName('RAZAO').AsString := APessoa.Razao;
      Qry.ParamByName('ENDERECO').AsString := APessoa.Endereco;
      Qry.ParamByName('NUMERO').AsString := APessoa.Numero;
      Qry.ParamByName('COMPLEMENTO').AsString := APessoa.Complemento;
      Qry.ParamByName('BAIRRO').AsString := APessoa.Bairro;
      Qry.ParamByName('MUNICIPIO').AsString := APessoa.Municipio;
      Qry.ParamByName('UF').AsString := APessoa.UF;
      Qry.ParamByName('CEP').AsString := APessoa.CEP;
      Qry.ParamByName('FONE1').AsString := APessoa.Fone1;
      Qry.ParamByName('CELULAR1').AsString := APessoa.Celular1;
      Qry.ParamByName('EMAIL1').AsString := APessoa.Email1;
      Qry.ParamByName('CLI').AsString := APessoa.Cli;
      Qry.ParamByName('ATIVO').AsString := APessoa.Ativo;
      Qry.ParamByName('CODIGO_WEB').AsInteger := APessoa.CodigoWeb;
      Qry.ParamByName('FLAG').AsString := APessoa.Flag;
      Qry.ParamByName('WHATSAPP').AsString := APessoa.Whatsapp;

      Qry.ExecSQL;
      FConexao.CommitTransacao;
    except
      on E: Exception do
      begin
        FConexao.RollbackTransacao;
        raise Exception.Create('Erro ao salvar pessoa: ' + E.Message);
      end;
    end;
  finally
    Qry.Free;
  end;
end;

function TPessoaService.Existe(AEmpresa, ACodigo: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT CODIGO FROM PESSOA WHERE EMPRESA = :EMPRESA AND CODIGO = :CODIGO';
    Qry.ParamByName('EMPRESA').AsInteger := AEmpresa;
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    Result := not Qry.IsEmpty;
  finally
    Qry.Free;
  end;
end;

function TPessoaService.ProximoCodigo(AEmpresa: Integer): Integer;
var
  Qry: TFDQuery;
begin
  Result := 1;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT MAX(CODIGO) AS MAXIMO FROM PESSOA WHERE EMPRESA = :EMPRESA';
    Qry.ParamByName('EMPRESA').AsInteger := AEmpresa;
    Qry.Open;
    if not Qry.FieldByName('MAXIMO').IsNull then
      Result := Qry.FieldByName('MAXIMO').AsInteger + 1;
  finally
    Qry.Free;
  end;
end;

end.
