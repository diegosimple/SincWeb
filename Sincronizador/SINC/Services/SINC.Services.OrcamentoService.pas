unit SINC.Services.OrcamentoService;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  SINC.Model.Orcamento, SINC.Provider.ConexaoBD;

type
  TOrcamentoService = class
  private
    FConexao: TConexaoBD;
  public
    constructor Create;
    destructor Destroy; override;
    function BuscarPorCodigo(ACodigo: Integer): TOrcamento;
    function ListarParaEnvio: TObjectList<TOrcamento>;
    procedure SalvarOuAtualizar(AOrcamento: TOrcamento);
    function Existe(ACodigo: Integer): Boolean;
    function ProximoCodigo: Integer;
  end;

implementation

constructor TOrcamentoService.Create;
begin
  inherited;
  FConexao := TConexaoBD.GetInstance;
end;

destructor TOrcamentoService.Destroy;
begin
  inherited;
end;

function TOrcamentoService.BuscarPorCodigo(ACodigo: Integer): TOrcamento;
var
  Qry: TFDQuery;
begin
  Result := nil;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM ORCAMENTO WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      Result := TOrcamento.Create;
      Result.FromDataSet(Qry);
    end;
  finally
    Qry.Free;
  end;
end;

function TOrcamentoService.ListarParaEnvio: TObjectList<TOrcamento>;
var
  Qry: TFDQuery;
  Orcamento: TOrcamento;
begin
  Result := TObjectList<TOrcamento>.Create(True);
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM ORCAMENTO WHERE (CODIGO_WEB IS NULL OR CODIGO_WEB = 0) ORDER BY CODIGO';
    Qry.Open;
    while not Qry.Eof do
    begin
      Orcamento := TOrcamento.Create;
      Orcamento.FromDataSet(Qry);
      Result.Add(Orcamento);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TOrcamentoService.SalvarOuAtualizar(AOrcamento: TOrcamento);
var
  Qry: TFDQuery;
begin
  if not Assigned(AOrcamento) then
    raise Exception.Create('Orçamento não pode ser nulo');

  Qry := FConexao.NovaQuery;
  try
    FConexao.IniciarTransacao;
    try
      if Existe(AOrcamento.Codigo) then
      begin
        Qry.SQL.Text := 'UPDATE ORCAMENTO SET DATA = :DATA, FKVENDEDOR = :FKVENDEDOR, ' +
          'FK_CLIENTE = :FK_CLIENTE, CLIENTE = :CLIENTE, TELEFONE = :TELEFONE, CELULAR = :CELULAR, ' +
          'ENDERECO = :ENDERECO, NUMERO = :NUMERO, BAIRRO = :BAIRRO, CIDADE = :CIDADE, UF = :UF, ' +
          'CEP = :CEP, CNPJ = :CNPJ, FORMA_PAGAMENTO = :FORMA_PAGAMENTO, SITUACAO = :SITUACAO, ' +
          'TOTAL = :TOTAL, SUBTOTAL = :SUBTOTAL, DESCONTO = :DESCONTO, CODIGO_WEB = :CODIGO_WEB, ' +
          'FK_FPG = :FK_FPG WHERE CODIGO = :CODIGO';
      end
      else
      begin
        if AOrcamento.Codigo = 0 then
          AOrcamento.Codigo := ProximoCodigo;

        Qry.SQL.Text := 'INSERT INTO ORCAMENTO (CODIGO, DATA, FKVENDEDOR, FK_CLIENTE, CLIENTE, ' +
          'TELEFONE, CELULAR, ENDERECO, NUMERO, BAIRRO, CIDADE, UF, CEP, CNPJ, FORMA_PAGAMENTO, ' +
          'SITUACAO, TOTAL, SUBTOTAL, DESCONTO, CODIGO_WEB, FK_FPG, FKEMPRESA) ' +
          'VALUES (:CODIGO, :DATA, :FKVENDEDOR, :FK_CLIENTE, :CLIENTE, :TELEFONE, :CELULAR, ' +
          ':ENDERECO, :NUMERO, :BAIRRO, :CIDADE, :UF, :CEP, :CNPJ, :FORMA_PAGAMENTO, :SITUACAO, ' +
          ':TOTAL, :SUBTOTAL, :DESCONTO, :CODIGO_WEB, :FK_FPG, :FKEMPRESA)';

        Qry.ParamByName('FKEMPRESA').AsInteger := AOrcamento.FKEmpresa;
      end;

      Qry.ParamByName('CODIGO').AsInteger := AOrcamento.Codigo;
      Qry.ParamByName('DATA').AsDate := AOrcamento.Data;
      Qry.ParamByName('FKVENDEDOR').AsInteger := AOrcamento.FKVendedor;
      Qry.ParamByName('FK_CLIENTE').AsInteger := AOrcamento.FKCliente;
      Qry.ParamByName('CLIENTE').AsString := AOrcamento.Cliente;
      Qry.ParamByName('TELEFONE').AsString := AOrcamento.Telefone;
      Qry.ParamByName('CELULAR').AsString := AOrcamento.Celular;
      Qry.ParamByName('ENDERECO').AsString := AOrcamento.Endereco;
      Qry.ParamByName('NUMERO').AsString := AOrcamento.Numero;
      Qry.ParamByName('BAIRRO').AsString := AOrcamento.Bairro;
      Qry.ParamByName('CIDADE').AsString := AOrcamento.Cidade;
      Qry.ParamByName('UF').AsString := AOrcamento.UF;
      Qry.ParamByName('CEP').AsString := AOrcamento.CEP;
      Qry.ParamByName('CNPJ').AsString := AOrcamento.CNPJ;
      Qry.ParamByName('FORMA_PAGAMENTO').AsString := AOrcamento.FormaPagamento;
      Qry.ParamByName('SITUACAO').AsString := AOrcamento.Situacao;
      Qry.ParamByName('TOTAL').AsFloat := AOrcamento.Total;
      Qry.ParamByName('SUBTOTAL').AsFloat := AOrcamento.SubTotal;
      Qry.ParamByName('DESCONTO').AsFloat := AOrcamento.Desconto;
      Qry.ParamByName('CODIGO_WEB').AsInteger := AOrcamento.CodigoWeb;
      Qry.ParamByName('FK_FPG').AsInteger := AOrcamento.FKFPG;

      Qry.ExecSQL;
      FConexao.CommitTransacao;
    except
      on E: Exception do
      begin
        FConexao.RollbackTransacao;
        raise Exception.Create('Erro ao salvar orçamento: ' + E.Message);
      end;
    end;
  finally
    Qry.Free;
  end;
end;

function TOrcamentoService.Existe(ACodigo: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT CODIGO FROM ORCAMENTO WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    Result := not Qry.IsEmpty;
  finally
    Qry.Free;
  end;
end;

function TOrcamentoService.ProximoCodigo: Integer;
var
  Qry: TFDQuery;
begin
  Result := 1;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT MAX(CODIGO) AS MAXIMO FROM ORCAMENTO';
    Qry.Open;
    if not Qry.FieldByName('MAXIMO').IsNull then
      Result := Qry.FieldByName('MAXIMO').AsInteger + 1;
  finally
    Qry.Free;
  end;
end;

end.
