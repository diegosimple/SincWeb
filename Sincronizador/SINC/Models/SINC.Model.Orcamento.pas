unit SINC.Model.Orcamento;

{*******************************************************************************
  SINC - Model Orcamento

  Representa a entidade ORCAMENTO do banco de dados local

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.JSON, FireDAC.Comp.Client, Data.DB;

type
  TOrcamento = class
  private
    FCodigo: Integer;
    FData: TDate;
    FFKVendedor: Integer;
    FFKCliente: Integer;
    FCliente: string;
    FTelefone: string;
    FCelular: string;
    FEndereco: string;
    FNumero: string;
    FBairro: string;
    FCidade: string;
    FUF: string;
    FCNPJ: string;
    FFormaPagamento: string;
    FValidade: Integer;
    FObs: string;
    FSituacao: string;
    FTotal: Double;
    FCEP: string;
    FFKEmpresa: Integer;
    FSubTotal: Double;
    FPercentual: Double;
    FDesconto: Double;
    FCodigoWeb: Integer;
    FNControle: Integer;
    FFKTransp: Integer;
    FFKFPG: Integer;
    FNumeroWhatsapp: string;

  public
    constructor Create;
    destructor Destroy; override;

    procedure FromDataSet(AQry: TFDQuery);
    procedure FromJSON(AJSON: TJSONObject);
    function ToJSON: TJSONObject;
    procedure Salvar;

    property Codigo: Integer read FCodigo write FCodigo;
    property Data: TDate read FData write FData;
    property FKVendedor: Integer read FFKVendedor write FFKVendedor;
    property FKCliente: Integer read FFKCliente write FFKCliente;
    property Cliente: string read FCliente write FCliente;
    property Telefone: string read FTelefone write FTelefone;
    property Celular: string read FCelular write FCelular;
    property Endereco: string read FEndereco write FEndereco;
    property Numero: string read FNumero write FNumero;
    property Bairro: string read FBairro write FBairro;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write FUF;
    property CNPJ: string read FCNPJ write FCNPJ;
    property FormaPagamento: string read FFormaPagamento write FFormaPagamento;
    property Validade: Integer read FValidade write FValidade;
    property Obs: string read FObs write FObs;
    property Situacao: string read FSituacao write FSituacao;
    property Total: Double read FTotal write FTotal;
    property CEP: string read FCEP write FCEP;
    property FKEmpresa: Integer read FFKEmpresa write FFKEmpresa;
    property SubTotal: Double read FSubTotal write FSubTotal;
    property Percentual: Double read FPercentual write FPercentual;
    property Desconto: Double read FDesconto write FDesconto;
    property CodigoWeb: Integer read FCodigoWeb write FCodigoWeb;
    property NControle: Integer read FNControle write FNControle;
    property FKTransp: Integer read FFKTransp write FFKTransp;
    property FKFPG: Integer read FFKFPG write FFKFPG;
    property NumeroWhatsapp: string read FNumeroWhatsapp write FNumeroWhatsapp;
  end;

implementation

uses
  SINC.Services.OrcamentoService;

{ TOrcamento }

constructor TOrcamento.Create;
begin
  inherited;
  FCodigo := 0;
  FData := Date;
  FFKVendedor := 0;
  FFKCliente := 0;
  FCliente := '';
  FTelefone := '';
  FCelular := '';
  FEndereco := '';
  FNumero := '';
  FBairro := '';
  FCidade := '';
  FUF := '';
  FCNPJ := '';
  FFormaPagamento := '';
  FValidade := 0;
  FObs := '';
  FSituacao := 'A';
  FTotal := 0;
  FCEP := '';
  FFKEmpresa := 0;
  FSubTotal := 0;
  FPercentual := 0;
  FDesconto := 0;
  FCodigoWeb := 0;
  FNControle := 0;
  FFKTransp := 0;
  FFKFPG := 0;
  FNumeroWhatsapp := '';
end;

destructor TOrcamento.Destroy;
begin
  inherited;
end;

procedure TOrcamento.FromDataSet(AQry: TFDQuery);
begin
  if AQry.IsEmpty then
    Exit;

  FCodigo := AQry.FieldByName('CODIGO').AsInteger;

  if not AQry.FieldByName('DATA').IsNull then
    FData := AQry.FieldByName('DATA').AsDateTime;

  if not AQry.FieldByName('FKVENDEDOR').IsNull then
    FFKVendedor := AQry.FieldByName('FKVENDEDOR').AsInteger;

  if not AQry.FieldByName('FK_CLIENTE').IsNull then
    FFKCliente := AQry.FieldByName('FK_CLIENTE').AsInteger;

  if not AQry.FieldByName('CLIENTE').IsNull then
    FCliente := AQry.FieldByName('CLIENTE').AsString;

  if not AQry.FieldByName('TELEFONE').IsNull then
    FTelefone := AQry.FieldByName('TELEFONE').AsString;

  if not AQry.FieldByName('CELULAR').IsNull then
    FCelular := AQry.FieldByName('CELULAR').AsString;

  if not AQry.FieldByName('ENDERECO').IsNull then
    FEndereco := AQry.FieldByName('ENDERECO').AsString;

  if not AQry.FieldByName('NUMERO').IsNull then
    FNumero := AQry.FieldByName('NUMERO').AsString;

  if not AQry.FieldByName('BAIRRO').IsNull then
    FBairro := AQry.FieldByName('BAIRRO').AsString;

  if not AQry.FieldByName('CIDADE').IsNull then
    FCidade := AQry.FieldByName('CIDADE').AsString;

  if not AQry.FieldByName('UF').IsNull then
    FUF := AQry.FieldByName('UF').AsString;

  if not AQry.FieldByName('CNPJ').IsNull then
    FCNPJ := AQry.FieldByName('CNPJ').AsString;

  if not AQry.FieldByName('FORMA_PAGAMENTO').IsNull then
    FFormaPagamento := AQry.FieldByName('FORMA_PAGAMENTO').AsString;

  if not AQry.FieldByName('VALIDADE').IsNull then
    FValidade := AQry.FieldByName('VALIDADE').AsInteger;

  if not AQry.FieldByName('OBS').IsNull then
    FObs := AQry.FieldByName('OBS').AsString;

  if not AQry.FieldByName('SITUACAO').IsNull then
    FSituacao := AQry.FieldByName('SITUACAO').AsString;

  if not AQry.FieldByName('TOTAL').IsNull then
    FTotal := AQry.FieldByName('TOTAL').AsFloat;

  if not AQry.FieldByName('CEP').IsNull then
    FCEP := AQry.FieldByName('CEP').AsString;

  if not AQry.FieldByName('FKEMPRESA').IsNull then
    FFKEmpresa := AQry.FieldByName('FKEMPRESA').AsInteger;

  if not AQry.FieldByName('SUBTOTAL').IsNull then
    FSubTotal := AQry.FieldByName('SUBTOTAL').AsFloat;

  if not AQry.FieldByName('PERCENTUAL').IsNull then
    FPercentual := AQry.FieldByName('PERCENTUAL').AsFloat;

  if not AQry.FieldByName('DESCONTO').IsNull then
    FDesconto := AQry.FieldByName('DESCONTO').AsFloat;

  if not AQry.FieldByName('CODIGO_WEB').IsNull then
    FCodigoWeb := AQry.FieldByName('CODIGO_WEB').AsInteger;

  if not AQry.FieldByName('NCONTROLE').IsNull then
    FNControle := AQry.FieldByName('NCONTROLE').AsInteger;

  if not AQry.FieldByName('FK_TRANSP').IsNull then
    FFKTransp := AQry.FieldByName('FK_TRANSP').AsInteger;

  if not AQry.FieldByName('FK_FPG').IsNull then
    FFKFPG := AQry.FieldByName('FK_FPG').AsInteger;

  if not AQry.FieldByName('NUMERO_WHATSAPP').IsNull then
    FNumeroWhatsapp := AQry.FieldByName('NUMERO_WHATSAPP').AsString;
end;

procedure TOrcamento.FromJSON(AJSON: TJSONObject);
begin
  if not Assigned(AJSON) then
    Exit;

  if AJSON.TryGetValue<Integer>('codigo', FCodigo) then;
  if AJSON.TryGetValue<Integer>('fkvendedor', FFKVendedor) then;
  if AJSON.TryGetValue<Integer>('fk_cliente', FFKCliente) then;
  if AJSON.TryGetValue<string>('cliente', FCliente) then;
  if AJSON.TryGetValue<string>('telefone', FTelefone) then;
  if AJSON.TryGetValue<string>('celular', FCelular) then;
  if AJSON.TryGetValue<string>('endereco', FEndereco) then;
  if AJSON.TryGetValue<string>('numero', FNumero) then;
  if AJSON.TryGetValue<string>('bairro', FBairro) then;
  if AJSON.TryGetValue<string>('cidade', FCidade) then;
  if AJSON.TryGetValue<string>('uf', FUF) then;
  if AJSON.TryGetValue<string>('cnpj', FCNPJ) then;
  if AJSON.TryGetValue<string>('forma_pagamento', FFormaPagamento) then;
  if AJSON.TryGetValue<Integer>('validade', FValidade) then;
  if AJSON.TryGetValue<string>('obs', FObs) then;
  if AJSON.TryGetValue<string>('situacao', FSituacao) then;
  if AJSON.TryGetValue<Double>('total', FTotal) then;
  if AJSON.TryGetValue<string>('cep', FCEP) then;
  if AJSON.TryGetValue<Integer>('fkempresa', FFKEmpresa) then;
  if AJSON.TryGetValue<Double>('subtotal', FSubTotal) then;
  if AJSON.TryGetValue<Double>('percentual', FPercentual) then;
  if AJSON.TryGetValue<Double>('desconto', FDesconto) then;
  if AJSON.TryGetValue<Integer>('codigo_web', FCodigoWeb) then;
  if AJSON.TryGetValue<Integer>('ncontrole', FNControle) then;
  if AJSON.TryGetValue<Integer>('fk_transp', FFKTransp) then;
  if AJSON.TryGetValue<Integer>('fk_fpg', FFKFPG) then;
  if AJSON.TryGetValue<string>('numero_whatsapp', FNumeroWhatsapp) then;
end;

function TOrcamento.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('codigo', TJSONNumber.Create(FCodigo));
  Result.AddPair('data', FormatDateTime('yyyy-mm-dd', FData));
  Result.AddPair('fkvendedor', TJSONNumber.Create(FFKVendedor));
  Result.AddPair('fk_cliente', TJSONNumber.Create(FFKCliente));
  Result.AddPair('cliente', FCliente);
  Result.AddPair('telefone', FTelefone);
  Result.AddPair('celular', FCelular);
  Result.AddPair('endereco', FEndereco);
  Result.AddPair('numero', FNumero);
  Result.AddPair('bairro', FBairro);
  Result.AddPair('cidade', FCidade);
  Result.AddPair('uf', FUF);
  Result.AddPair('cnpj', FCNPJ);
  Result.AddPair('forma_pagamento', FFormaPagamento);
  Result.AddPair('validade', TJSONNumber.Create(FValidade));
  Result.AddPair('obs', FObs);
  Result.AddPair('situacao', FSituacao);
  Result.AddPair('total', TJSONNumber.Create(FTotal));
  Result.AddPair('cep', FCEP);
  Result.AddPair('fkempresa', TJSONNumber.Create(FFKEmpresa));
  Result.AddPair('subtotal', TJSONNumber.Create(FSubTotal));
  Result.AddPair('percentual', TJSONNumber.Create(FPercentual));
  Result.AddPair('desconto', TJSONNumber.Create(FDesconto));
  Result.AddPair('codigo_web', TJSONNumber.Create(FCodigoWeb));
  Result.AddPair('ncontrole', TJSONNumber.Create(FNControle));
  Result.AddPair('fk_transp', TJSONNumber.Create(FFKTransp));
  Result.AddPair('fk_fpg', TJSONNumber.Create(FFKFPG));
  Result.AddPair('numero_whatsapp', FNumeroWhatsapp);
end;

procedure TOrcamento.Salvar;
var
  Service: TOrcamentoService;
begin
  Service := TOrcamentoService.Create;
  try
    Service.SalvarOuAtualizar(Self);
  finally
    Service.Free;
  end;
end;

end.
