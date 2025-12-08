unit SINC.Model.Empresa;

{*******************************************************************************
  SINC - Model Empresa

  Representa a entidade EMPRESA do banco de dados local

  Autor: Sistema SINC
  Data: 2025-12-06
*******************************************************************************}

interface

uses
  System.SysUtils, System.JSON, FireDAC.Comp.Client, Data.DB;

type
  TEmpresa = class
  private
    FCodigo: Integer;
    FFantasia: string;
    FRazao: string;
    FTipo: string;
    FCNPJ: string;
    FIE: string;
    FIM: string;
    FEndereco: string;
    FNumero: string;
    FComplemento: string;
    FBairro: string;
    FCidade: string;
    FUF: string;
    FCEP: string;
    FFone: string;
    FFax: string;
    FSite: string;
    FFundacao: TDate;
    FUsuCad: Integer;
    FUsuAtu: Integer;
    FNSerie: string;
    FCSenha: string;
    FNTerm: string;
    FCRT: Integer;
    FEmail: string;
    FFlag: string;
    FUsarSistemaWeb: string;
    FCadastroWeb: string;
    FCWEB: Integer;

  public
    constructor Create;
    destructor Destroy; override;

    procedure FromDataSet(AQry: TFDQuery);
    procedure FromJSON(AJSON: TJSONObject);
    function ToJSON: TJSONObject;
    procedure Salvar; // Chama o Service

    // Propriedades
    property Codigo: Integer read FCodigo write FCodigo;
    property Fantasia: string read FFantasia write FFantasia;
    property Razao: string read FRazao write FRazao;
    property Tipo: string read FTipo write FTipo;
    property CNPJ: string read FCNPJ write FCNPJ;
    property IE: string read FIE write FIE;
    property IM: string read FIM write FIM;
    property Endereco: string read FEndereco write FEndereco;
    property Numero: string read FNumero write FNumero;
    property Complemento: string read FComplemento write FComplemento;
    property Bairro: string read FBairro write FBairro;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write FUF;
    property CEP: string read FCEP write FCEP;
    property Fone: string read FFone write FFone;
    property Fax: string read FFax write FFax;
    property Site: string read FSite write FSite;
    property Fundacao: TDate read FFundacao write FFundacao;
    property UsuCad: Integer read FUsuCad write FUsuCad;
    property UsuAtu: Integer read FUsuAtu write FUsuAtu;
    property NSerie: string read FNSerie write FNSerie;
    property CSenha: string read FCSenha write FCSenha;
    property NTerm: string read FNTerm write FNTerm;
    property CRT: Integer read FCRT write FCRT;
    property Email: string read FEmail write FEmail;
    property Flag: string read FFlag write FFlag;
    property UsarSistemaWeb: string read FUsarSistemaWeb write FUsarSistemaWeb;
    property CadastroWeb: string read FCadastroWeb write FCadastroWeb;
    property CWEB: Integer read FCWEB write FCWEB;
  end;

implementation

uses
  SINC.Services.EmpresaService;

{ TEmpresa }

constructor TEmpresa.Create;
begin
  inherited;
  FCodigo := 0;
  FFantasia := '';
  FRazao := '';
  FTipo := '';
  FCNPJ := '';
  FIE := '';
  FIM := '';
  FEndereco := '';
  FNumero := '';
  FComplemento := '';
  FBairro := '';
  FCidade := '';
  FUF := '';
  FCEP := '';
  FFone := '';
  FFax := '';
  FSite := '';
  FFundacao := Now;
  FUsuCad := 0;
  FUsuAtu := 0;
  FNSerie := '';
  FCSenha := '';
  FNTerm := '';
  FCRT := 0;
  FEmail := '';
  FFlag := '';
  FUsarSistemaWeb := 'N';
  FCadastroWeb := 'N';
  FCWEB := 0;
end;

destructor TEmpresa.Destroy;
begin
  inherited;
end;

procedure TEmpresa.FromDataSet(AQry: TFDQuery);
begin
  if AQry.IsEmpty then
    Exit;

  // SEMPRE usando FieldByName conforme especificação
  FCodigo := AQry.FieldByName('CODIGO').AsInteger;
  FFantasia := AQry.FieldByName('FANTASIA').AsString;
  FRazao := AQry.FieldByName('RAZAO').AsString;
  FTipo := AQry.FieldByName('TIPO').AsString;
  FCNPJ := AQry.FieldByName('CNPJ').AsString;
  FIE := AQry.FieldByName('IE').AsString;

  if not AQry.FieldByName('IM').IsNull then
    FIM := AQry.FieldByName('IM').AsString;

  FEndereco := AQry.FieldByName('ENDERECO').AsString;

  if not AQry.FieldByName('NUMERO').IsNull then
    FNumero := AQry.FieldByName('NUMERO').AsString;

  if not AQry.FieldByName('COMPLEMENTO').IsNull then
    FComplemento := AQry.FieldByName('COMPLEMENTO').AsString;

  FBairro := AQry.FieldByName('BAIRRO').AsString;
  FCidade := AQry.FieldByName('CIDADE').AsString;
  FUF := AQry.FieldByName('UF').AsString;
  FCEP := AQry.FieldByName('CEP').AsString;
  FFone := AQry.FieldByName('FONE').AsString;

  if not AQry.FieldByName('FAX').IsNull then
    FFax := AQry.FieldByName('FAX').AsString;

  if not AQry.FieldByName('SITE').IsNull then
    FSite := AQry.FieldByName('SITE').AsString;

  FFundacao := AQry.FieldByName('FUNDACAO').AsDateTime;
  FUsuCad := AQry.FieldByName('USU_CAD').AsInteger;

  if not AQry.FieldByName('USU_ATU').IsNull then
    FUsuAtu := AQry.FieldByName('USU_ATU').AsInteger;

  FNSerie := AQry.FieldByName('NSERIE').AsString;
  FCSenha := AQry.FieldByName('CSENHA').AsString;

  if not AQry.FieldByName('NTERM').IsNull then
    FNTerm := AQry.FieldByName('NTERM').AsString;

  if not AQry.FieldByName('CRT').IsNull then
    FCRT := AQry.FieldByName('CRT').AsInteger;

  if not AQry.FieldByName('EMAIL').IsNull then
    FEmail := AQry.FieldByName('EMAIL').AsString;

  if not AQry.FieldByName('FLAG').IsNull then
    FFlag := AQry.FieldByName('FLAG').AsString;

  if not AQry.FieldByName('USAR_SISTEMA_WEB').IsNull then
    FUsarSistemaWeb := AQry.FieldByName('USAR_SISTEMA_WEB').AsString;

  if not AQry.FieldByName('CADASTRO_WEB').IsNull then
    FCadastroWeb := AQry.FieldByName('CADASTRO_WEB').AsString;

  if not AQry.FieldByName('CWEB').IsNull then
    FCWEB := AQry.FieldByName('CWEB').AsInteger;
end;

procedure TEmpresa.FromJSON(AJSON: TJSONObject);
begin
  if not Assigned(AJSON) then
    Exit;

  if AJSON.TryGetValue<Integer>('codigo', FCodigo) then;
  if AJSON.TryGetValue<string>('fantasia', FFantasia) then;
  if AJSON.TryGetValue<string>('razao', FRazao) then;
  if AJSON.TryGetValue<string>('tipo', FTipo) then;
  if AJSON.TryGetValue<string>('cnpj', FCNPJ) then;
  if AJSON.TryGetValue<string>('ie', FIE) then;
  if AJSON.TryGetValue<string>('im', FIM) then;
  if AJSON.TryGetValue<string>('endereco', FEndereco) then;
  if AJSON.TryGetValue<string>('numero', FNumero) then;
  if AJSON.TryGetValue<string>('complemento', FComplemento) then;
  if AJSON.TryGetValue<string>('bairro', FBairro) then;
  if AJSON.TryGetValue<string>('cidade', FCidade) then;
  if AJSON.TryGetValue<string>('uf', FUF) then;
  if AJSON.TryGetValue<string>('cep', FCEP) then;
  if AJSON.TryGetValue<string>('fone', FFone) then;
  if AJSON.TryGetValue<string>('fax', FFax) then;
  if AJSON.TryGetValue<string>('site', FSite) then;
  if AJSON.TryGetValue<Integer>('usu_cad', FUsuCad) then;
  if AJSON.TryGetValue<Integer>('usu_atu', FUsuAtu) then;
  if AJSON.TryGetValue<string>('nserie', FNSerie) then;
  if AJSON.TryGetValue<string>('csenha', FCSenha) then;
  if AJSON.TryGetValue<string>('nterm', FNTerm) then;
  if AJSON.TryGetValue<Integer>('crt', FCRT) then;
  if AJSON.TryGetValue<string>('email', FEmail) then;
  if AJSON.TryGetValue<string>('flag', FFlag) then;
  if AJSON.TryGetValue<string>('usar_sistema_web', FUsarSistemaWeb) then;
  if AJSON.TryGetValue<string>('cadastro_web', FCadastroWeb) then;
  if AJSON.TryGetValue<Integer>('cweb', FCWEB) then;
end;

function TEmpresa.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('codigo', TJSONNumber.Create(FCodigo));
  Result.AddPair('fantasia', FFantasia);
  Result.AddPair('razao', FRazao);
  Result.AddPair('tipo', FTipo);
  Result.AddPair('cnpj', FCNPJ);
  Result.AddPair('ie', FIE);
  Result.AddPair('im', FIM);
  Result.AddPair('endereco', FEndereco);
  Result.AddPair('numero', FNumero);
  Result.AddPair('complemento', FComplemento);
  Result.AddPair('bairro', FBairro);
  Result.AddPair('cidade', FCidade);
  Result.AddPair('uf', FUF);
  Result.AddPair('cep', FCEP);
  Result.AddPair('fone', FFone);
  Result.AddPair('fax', FFax);
  Result.AddPair('site', FSite);
  Result.AddPair('fundacao', FormatDateTime('yyyy-mm-dd', FFundacao));
  Result.AddPair('usu_cad', TJSONNumber.Create(FUsuCad));
  Result.AddPair('usu_atu', TJSONNumber.Create(FUsuAtu));
  Result.AddPair('nserie', FNSerie);
  Result.AddPair('csenha', FCSenha);
  Result.AddPair('nterm', FNTerm);
  Result.AddPair('crt', TJSONNumber.Create(FCRT));
  Result.AddPair('email', FEmail);
  Result.AddPair('flag', FFlag);
  Result.AddPair('usar_sistema_web', FUsarSistemaWeb);
  Result.AddPair('cadastro_web', FCadastroWeb);
  Result.AddPair('cweb', TJSONNumber.Create(FCWEB));
end;

procedure TEmpresa.Salvar;
var
  Service: TEmpresaService;
begin
  Service := TEmpresaService.Create;
  try
    Service.SalvarOuAtualizar(Self);
  finally
    Service.Free;
  end;
end;

end.
