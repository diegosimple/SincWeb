unit SINC.Services.OrcamentoItemService;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  SINC.Model.OrcamentoItem, SINC.Provider.ConexaoBD;

type
  TOrcamentoItemService = class
  private
    FConexao: TConexaoBD;
  public
    constructor Create;
    destructor Destroy; override;
    function BuscarPorCodigo(ACodigo: Integer): TOrcamentoItem;
    function ListarPorOrcamento(ACodigoOrcamento: Integer): TObjectList<TOrcamentoItem>;
    procedure SalvarOuAtualizar(AOrcamentoItem: TOrcamentoItem);
    function Existe(ACodigo: Integer): Boolean;
    function ProximoCodigo: Integer;
  end;

implementation

constructor TOrcamentoItemService.Create;
begin
  inherited;
  FConexao := TConexaoBD.GetInstance;
end;

destructor TOrcamentoItemService.Destroy;
begin
  inherited;
end;

function TOrcamentoItemService.BuscarPorCodigo(ACodigo: Integer): TOrcamentoItem;
var
  Qry: TFDQuery;
begin
  Result := nil;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM ORCAMENTO_ITEM WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      Result := TOrcamentoItem.Create;
      Result.FromDataSet(Qry);
    end;
  finally
    Qry.Free;
  end;
end;

function TOrcamentoItemService.ListarPorOrcamento(ACodigoOrcamento: Integer): TObjectList<TOrcamentoItem>;
var
  Qry: TFDQuery;
  Item: TOrcamentoItem;
begin
  Result := TObjectList<TOrcamentoItem>.Create(True);
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM ORCAMENTO_ITEM WHERE FK_ORCAMENTO = :FK_ORCAMENTO ORDER BY ITEM';
    Qry.ParamByName('FK_ORCAMENTO').AsInteger := ACodigoOrcamento;
    Qry.Open;
    while not Qry.Eof do
    begin
      Item := TOrcamentoItem.Create;
      Item.FromDataSet(Qry);
      Result.Add(Item);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TOrcamentoItemService.SalvarOuAtualizar(AOrcamentoItem: TOrcamentoItem);
var
  Qry: TFDQuery;
begin
  if not Assigned(AOrcamentoItem) then
    raise Exception.Create('Item do Orçamento não pode ser nulo');

  Qry := FConexao.NovaQuery;
  try
    FConexao.IniciarTransacao;
    try
      if Existe(AOrcamentoItem.Codigo) then
      begin
        Qry.SQL.Text := 'UPDATE ORCAMENTO_ITEM SET FK_ORCAMENTO = :FK_ORCAMENTO, FK_PRODUTO = :FK_PRODUTO, ' +
          'QTD = :QTD, PRECO = :PRECO, TOTAL = :TOTAL, ITEM = :ITEM, DESCONTO = :DESCONTO, ' +
          'DESCRICAO = :DESCRICAO WHERE CODIGO = :CODIGO';
      end
      else
      begin
        if AOrcamentoItem.Codigo = 0 then
          AOrcamentoItem.Codigo := ProximoCodigo;

        Qry.SQL.Text := 'INSERT INTO ORCAMENTO_ITEM (CODIGO, FK_ORCAMENTO, FK_PRODUTO, QTD, PRECO, ' +
          'TOTAL, ITEM, DESCONTO, DESCRICAO) VALUES (:CODIGO, :FK_ORCAMENTO, :FK_PRODUTO, :QTD, ' +
          ':PRECO, :TOTAL, :ITEM, :DESCONTO, :DESCRICAO)';
      end;

      Qry.ParamByName('CODIGO').AsInteger := AOrcamentoItem.Codigo;
      Qry.ParamByName('FK_ORCAMENTO').AsInteger := AOrcamentoItem.FKOrcamento;
      Qry.ParamByName('FK_PRODUTO').AsInteger := AOrcamentoItem.FKProduto;
      Qry.ParamByName('QTD').AsFloat := AOrcamentoItem.Qtd;
      Qry.ParamByName('PRECO').AsFloat := AOrcamentoItem.Preco;
      Qry.ParamByName('TOTAL').AsFloat := AOrcamentoItem.Total;
      Qry.ParamByName('ITEM').AsInteger := AOrcamentoItem.Item;
      Qry.ParamByName('DESCONTO').AsFloat := AOrcamentoItem.Desconto;
      Qry.ParamByName('DESCRICAO').AsString := AOrcamentoItem.Descricao;

      Qry.ExecSQL;
      FConexao.CommitTransacao;
    except
      on E: Exception do
      begin
        FConexao.RollbackTransacao;
        raise Exception.Create('Erro ao salvar item do orçamento: ' + E.Message);
      end;
    end;
  finally
    Qry.Free;
  end;
end;

function TOrcamentoItemService.Existe(ACodigo: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT CODIGO FROM ORCAMENTO_ITEM WHERE CODIGO = :CODIGO';
    Qry.ParamByName('CODIGO').AsInteger := ACodigo;
    Qry.Open;
    Result := not Qry.IsEmpty;
  finally
    Qry.Free;
  end;
end;

function TOrcamentoItemService.ProximoCodigo: Integer;
var
  Qry: TFDQuery;
begin
  Result := 1;
  Qry := FConexao.NovaQuery;
  try
    Qry.SQL.Text := 'SELECT MAX(CODIGO) AS MAXIMO FROM ORCAMENTO_ITEM';
    Qry.Open;
    if not Qry.FieldByName('MAXIMO').IsNull then
      Result := Qry.FieldByName('MAXIMO').AsInteger + 1;
  finally
    Qry.Free;
  end;
end;

end.
