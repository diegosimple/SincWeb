unit SINC.Services.VendedorService;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  SINC.Model.Vendedor, SINC.Provider.ConexaoBD;

type
  TVendedorService = class
  private
    FConexao: TConexaoBD;
  public
    constructor Create;
    destructor Destroy; override;
    function BuscarPorCodigo(ACodigo: Integer): TVendedor;
    function ListarParaEnvio: TObjectList<TVendedor>;
    procedure SalvarOuAtualizar(AVendedor: TVendedor);
    function Existe(ACodigo: Integer): Boolean;
    function ProximoCodigo: Integer;
  end;

implementation

constructor TVendedorService.Create;
begin
  inherited;
  FConexao := TConexaoBD.GetInstance;
end;

destructor TVendedorService.Destroy;
begin
  inherited;
end;

function TVendedorService.BuscarPorCodigo(ACodigo: Integer): TVendedor;
var
  Qry: TFDQuery;
begin
  Result := nil;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM VENDEDORES WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      Result := TVendedor.Create;
      Result.FromDataSet(Qry);
    end;
  finally
    Qry.Free;
  end;
end;

function TVendedorService.ListarParaEnvio: TObjectList<TVendedor>;
var
  Qry: TFDQuery;
  Vendedor: TVendedor;
begin
  Result := TObjectList<TVendedor>.Create(True);
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM VENDEDORES WHERE ATIVO = ''S'' ORDER BY CODIGO';
    Qry.Open;
    while not Qry.Eof do
    begin
      Vendedor := TVendedor.Create;
      Vendedor.FromDataSet(Qry);
      Result.Add(Vendedor);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TVendedorService.SalvarOuAtualizar(AVendedor: TVendedor);
var
  Qry: TFDQuery;
begin
  if not Assigned(AVendedor) then
    raise Exception.Create('Vendedor não pode ser nulo');

  Qry := FConexao.NovaQuery;
  try
    FConexao.IniciarTransacao;
    try
      if Existe(AVendedor.Codigo) then
      begin
        Qry.SQL.Text := 'UPDATE VENDEDORES SET NOME = :NOME, CMA = :CMA, CMP = :CMP, ' +
          'ATIVO = :ATIVO, EMPRESA = :EMPRESA, FLAG = :FLAG WHERE CODIGO = :CODIGO';
      end
      else
      begin
        if AVendedor.Codigo = 0 then
          AVendedor.Codigo := ProximoCodigo;

        Qry.SQL.Text := 'INSERT INTO VENDEDORES (CODIGO, NOME, CMA, CMP, ATIVO, EMPRESA, FLAG) ' +
          'VALUES (:CODIGO, :NOME, :CMA, :CMP, :ATIVO, :EMPRESA, :FLAG)';
      end;

      Qry.ParamByName('CODIGO').AsInteger := AVendedor.Codigo;
      Qry.ParamByName('NOME').AsString := AVendedor.Nome;
      Qry.ParamByName('CMA').AsFloat := AVendedor.CMA;
      Qry.ParamByName('CMP').AsFloat := AVendedor.CMP;
      Qry.ParamByName('ATIVO').AsString := AVendedor.Ativo;
      Qry.ParamByName('EMPRESA').AsInteger := AVendedor.Empresa;
      Qry.ParamByName('FLAG').AsString := AVendedor.Flag;

      Qry.ExecSQL;
      FConexao.CommitTransacao;
    except
      on E: Exception do
      begin
        FConexao.RollbackTransacao;
        raise Exception.Create('Erro ao salvar vendedor: ' + E.Message);
      end;
    end;
  finally
    Qry.Free;
  end;
end;

function TVendedorService.Existe(ACodigo: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT CODIGO FROM VENDEDORES WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    Result := not Qry.IsEmpty;
  finally
    Qry.Free;
  end;
end;

function TVendedorService.ProximoCodigo: Integer;
var
  Qry: TFDQuery;
begin
  Result := 1;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT MAX(CODIGO) AS MAXIMO FROM VENDEDORES';
    Qry.Open;
    if not Qry.FieldByName('MAXIMO').IsNull then
      Result := Qry.FieldByName('MAXIMO').AsInteger + 1;
  finally
    Qry.Free;
  end;
end;

end.
