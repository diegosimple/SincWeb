unit uSincronizadorApi;

interface

uses
  Vcl.Dialogs, System.SysUtils, System.Classes, System.JSON, System.NetEncoding,
  Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DApt, FireDAC.Comp.DataSet,
  IdHTTP, IdSSL, IdSSLOpenSSL , IdGlobal;

type
  TSincronizadorApi = class
  private
    FURLBase: string;
    FConexao: TFDConnection;
    vChaveGLobal : string;

    FHTTP: TIdHTTP;
    FSSL: TIdSSLIOHandlerSocketOpenSSL;

    function DataSetToJSONArray(ADataSet: TDataSet): TJSONArray;
    function AtualizarCodigoEmpresaLocal(AIdEmpresaLocal: Integer; ACodigoEmpresaRemoto: Integer): Boolean;
    function BlobToBase64(Field: TField): string;

    function BuildURL(const AResource: string): string;
    function DoRequest(const AMethod, AResource: string;
                       AJSONBody: TJSONObject;
                       out AStatusCode: Integer;
                       out AContent: string): Boolean;
    procedure PrepareAuthHeaders(const ApiKeyJWT : string ; ACodEmp:Integer );
  public
    LApiKeyJWT: string;
    constructor Create(AConexao: TFDConnection; const AURLBase ,LCNPJ, LChaveApi : string);
    destructor Destroy; override;

    function Sincronizar(const ACNPJ: string;
                         AIdEmpresaLocal: Integer;
                         ADataSet: TDataSet;
                         const AMethod: string;
                         const ARota: string): Boolean;

    function SincronizarEmpresa(const ACNPJ, AChaveApi: string;
                                              ACodigoWeb: Integer;
                                              ADadosEmpresa: TDataSet;
                                              AFormasPagamento: TDataSet;
                                              AUsuario: TDataSet;
                                              out ACodigoEmpresaRemoto: Integer): Boolean;

    function SincronizarProdutos(const ACNPJ: string;
                                              ACodigoEmpresa: Integer;
                                              AProdutosAtivos: TDataSet;
                                              AProdutosInativos: TDataSet;
                                              out ATotalSincronizados: Integer;
                                              out ATotalExcluidos: Integer): Boolean;

    function EnviarImagemProduto(const ACNPJ: string;
                                 ACodigoEmpresa: Integer;
                                 AProdutoID: Integer;
                                 AImagemStream: TMemoryStream): Boolean;

    function ObterTokenDaApi(const ACNPJ, AChaveLicenca: string): string;

   function BaixarPedidosPendentes(ACodigoEmpresa: Integer;
                                    out APedidos: TJSONArray): Boolean;

    function MarcarPedidoSincronizado(ACodigoEmpresa: Integer;
                                      ACodPedidoWeb: Integer;
                                      ACodigoLocal: Integer): Boolean;

    function BaixarClientes(ACodigoEmpresa: Integer;
                           AUltimaAtualizacao: TDateTime;
                           out AClientes: TJSONArray): Boolean;

  end;

implementation

{ TSincronizadorApi }


constructor TSincronizadorApi.Create(AConexao: TFDConnection;
  const AURLBase, LCNPJ, LChaveApi: string);

  var
  LMsg:string;
begin
  inherited Create;
  FConexao := AConexao;
  FURLBase := AURLBase;

  FHTTP := TIdHTTP.Create(nil);
  FHTTP.ReadTimeout := 30000;
  FHTTP.ConnectTimeout := 15000;
  FHTTP.HandleRedirects := True;
  FHTTP.Request.Accept := 'application/json';
  FHTTP.Request.AcceptCharset := 'utf-8';
  FHTTP.Request.UserAgent := 'ZeusPRO-Sync/1.0';
  FHTTP.Request.Connection := 'close';

  // Diz pro servidor: "não me mande gzip, nem deflate"
  FHTTP.Request.AcceptEncoding := 'identity';

//  try
//
//  if IdSSLOpenSSL.LoadOpenSSLLibrary then
//    begin
//      LMsg := 'SSL Carregado com Sucesso!' + #13#10#13#10;
//
//      // Tentar obter a versão
//      try
//        LMsg := LMsg + 'Versão OpenSSL: ' + OpenSSLVersion;
//      except
//        LMsg := LMsg + 'Versão: Não foi possível obter';
//      end;
//
//      ShowMessage(LMsg);
//    end
//    else
//    begin
//      ShowMessage('❌ ERRO ao carregar SSL!' + #13#10#13#10 +
//                  'Verifique se as DLLs estão na pasta do executável:' + #13#10 +
//                // ExtractFilePath(Application.ExeName) + #13#10#13#10 +
//                  'DLLs necessárias:' + #13#10 +
//                  '- libssl-1_1.dll' + #13#10 +
//                  '- libcrypto-1_1.dll' + #13#10 +
//                  'OU' + #13#10 +
//                  '- libeay32.dll' + #13#10 +
//                  '- ssleay32.dll');
//    end;
//  except
//    on E: Exception do
//      ShowMessage('❌ EXCEÇÃO ao testar SSL: ' + E.Message);
//  end;



  // Só use SSL se a URL for HTTPS
  if FURLBase.ToLower.StartsWith('https://') then
  begin
    FSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    FSSL.SSLOptions.Method := sslvTLSv1_2;
    FSSL.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    FHTTP.IOHandler := FSSL;
  end
  else
    FSSL := nil;

  vChaveGlobal := LChaveApi;
  LApiKeyJWT   := '';
end;


procedure TSincronizadorApi.PrepareAuthHeaders(const ApiKeyJWT : string ; ACodEmp:Integer );
begin
  FHTTP.Request.CustomHeaders.Clear;

  if ApiKeyJWT <> '' then
  begin
    FHTTP.Request.CustomHeaders.AddValue('Authorization', 'Bearer ' + ApiKeyJWT);
    FHTTP.Request.CustomHeaders.AddValue('X-API-Key', vChaveGLobal);
  end;
  if ACodEmp > 0 then
    FHTTP.Request.CustomHeaders.AddValue('X-CodEmp', ACodEmp.ToString);

end;

function TSincronizadorApi.ObterTokenDaApi(const ACNPJ, AChaveLicenca: string): string;
var
  LJSONEnvio, LJSONResp: TJSONObject;
  LStatusCode: Integer;
  LContent: string;
  LSuccess: Boolean;
  LMsg: string;
begin
  Result := '';

  LJSONEnvio := TJSONObject.Create;
  try
    LJSONEnvio.AddPair('cnpj', ACNPJ);
    LJSONEnvio.AddPair('chave', AChaveLicenca);

    // DEBUG: ver o JSON que o Delphi está mandando
  // ShowMessage(LJSONEnvio.ToJSON);

    if not DoRequest('POST', 'auth/token', LJSONEnvio, LStatusCode, LContent) then
    begin
      // AQUI JÁ TEMOS StatusCode e Content
      raise Exception.CreateFmt(
        'Falha HTTP ao obter token. StatusCode=%d, Resposta=%s',
        [LStatusCode, LContent]
      );
    end;

    if LContent.Trim = '' then
      raise Exception.Create('Resposta vazia da API /auth/token');

    LJSONResp := TJSONObject(TJSONObject.ParseJSONValue(LContent));
    if not Assigned(LJSONResp) then
      raise Exception.Create('Resposta não é JSON válido: ' + LContent);
    try
      // Ex.: {"success":true,"token":"xxx","empresa":{...}}
      if LJSONResp.TryGetValue<Boolean>('success', LSuccess) and (not LSuccess) then
      begin
        if not LJSONResp.TryGetValue<string>('error', LMsg) then
          LJSONResp.TryGetValue<string>('message', LMsg);
        raise Exception.Create('Erro na autenticação: ' + LMsg);
      end;

      if not LJSONResp.TryGetValue<string>('token', Result) then
        raise Exception.Create('Campo "token" não retornado pela API /auth/token');

      if Result.Trim = '' then
        raise Exception.Create('Token vazio retornado pela API /auth/token');

    finally
      LJSONResp.Free;
    end;
  finally
    LJSONEnvio.Free;
  end;
end;





destructor TSincronizadorApi.Destroy;
begin
  FreeAndNil(FHTTP);
  FreeAndNil(FSSL);
  inherited;
end;

function TSincronizadorApi.BuildURL(const AResource: string): string;
var
  Base, Res: string;
begin
  Base := FURLBase.Trim;
  Res  := AResource.Trim;

  while (Base <> '') and (Base.EndsWith('/')) do
    Delete(Base, Length(Base), 1);

  while (Res <> '') and (Res.StartsWith('/')) do
    Delete(Res, 1, 1);

  Result := Base + '/' + Res;
end;

function TSincronizadorApi.DoRequest(const AMethod, AResource: string;
                                     AJSONBody: TJSONObject;
                                     out AStatusCode: Integer;
                                     out AContent: string): Boolean;
var
  LURL: string;
  LBodyStream: TStringStream;
begin
  Result := False;
  AContent := '';
  AStatusCode := 0;

  LURL := BuildURL(AResource);

  try
    if SameText(AMethod, 'GET') then
    begin
      AContent := FHTTP.Get(LURL);
      AStatusCode := FHTTP.ResponseCode;
    end
    else if SameText(AMethod, 'POST') then
    begin
      LBodyStream := TStringStream.Create(AJSONBody.ToJSON, TEncoding.UTF8);
      try
        FHTTP.Request.ContentType := 'application/json; charset=utf-8';
        AContent := FHTTP.Post(LURL, LBodyStream);
        AStatusCode := FHTTP.ResponseCode;
      finally
        LBodyStream.Free;
      end;
    end
    else if SameText(AMethod, 'PUT') then
    begin
      LBodyStream := TStringStream.Create(AJSONBody.ToJSON, TEncoding.UTF8);
      try
        FHTTP.Request.ContentType := 'application/json; charset=utf-8';
        AContent := FHTTP.Put(LURL, LBodyStream);
        AStatusCode := FHTTP.ResponseCode;
      finally
        LBodyStream.Free;
      end;
    end
    else if SameText(AMethod, 'DELETE') then
    begin
      FHTTP.Delete(LURL);
      AStatusCode := FHTTP.ResponseCode;
      AContent := FHTTP.ResponseText;
    end
    else
      raise Exception.Create('Método HTTP não suportado: ' + AMethod);

    Result := AStatusCode in [200, 201, 204];
  except
    on E: EIdHTTPProtocolException do
    begin
      // aqui a resposta **veio do servidor**, só que com erro (4xx/5xx)
      AStatusCode := E.ErrorCode;
      AContent    := E.ErrorMessage; // aqui costuma vir o JSON da API
      Result := False;              // NÃO dá raise aqui
    end;
    on E: Exception do
    begin
      // erro local (timeout, DNS, etc)
      AStatusCode := -1;
      AContent    := 'Erro local: ' + E.Message;
      Result := False;
    end;
  end;
end;



function TSincronizadorApi.EnviarImagemProduto(const ACNPJ: string;
                                              ACodigoEmpresa: Integer;
                                              AProdutoID: Integer;
                                              AImagemStream: TMemoryStream): Boolean;
var
  LJSONEnvio: TJSONObject;
  LJSONResposta: TJSONObject;
  LStatus: Boolean;
  LMensagem: string;
  LImgBase64: string;
  LStatusCode: Integer;
  LContent: string;
  LValue: TJSONValue;
begin
  Result := False;

  if ACNPJ.Trim.IsEmpty then
    raise Exception.Create('CNPJ não informado');

  if vChaveGLobal.Trim.IsEmpty then
    raise Exception.Create('Chave da API não informada');

  if ACodigoEmpresa <= 0 then
    raise Exception.Create('Código da empresa inválido');

  if AProdutoID <= 0 then
    raise Exception.Create('ID do produto inválido');

  if not Assigned(AImagemStream) or (AImagemStream.Size = 0) then
    raise Exception.Create('Imagem não informada');

  // Converter imagem para Base64
  AImagemStream.Position := 0;
  LImgBase64 := TNetEncoding.Base64.EncodeBytesToString(AImagemStream.Memory, AImagemStream.Size);

  LJSONEnvio := TJSONObject.Create;
  try
    LJSONEnvio.AddPair('cnpj', ACNPJ);
    LJSONEnvio.AddPair('chave_api', vChaveGLobal);

    LJSONEnvio.AddPair('codemp', TJSONNumber.Create(ACodigoEmpresa));
    LJSONEnvio.AddPair('img1', LImgBase64);

    PrepareAuthHeaders(LApiKeyJWT, ACodigoEmpresa);

    if not DoRequest('PUT',
                     Format('produtos/%d/imagem', [AProdutoID]),
                     LJSONEnvio,
                     LStatusCode,
                     LContent) then
      raise Exception.CreateFmt('Erro HTTP %d ao enviar imagem', [LStatusCode]);


    LContent := Trim(LContent.Replace(#$FEFF, ''));

    LValue := TJSONObject.ParseJSONValue(LContent);

    if (not Assigned(LValue)) or (not (LValue is TJSONObject)) then
     raise Exception.Create('Resposta inválida da API ao enviar imagem ' + LContent);

     LJSONResposta := LValue as TJSONObject;

//    LJSONResposta := TJSONObject(TJSONObject.ParseJSONValue(LContent));
//
//    if not Assigned(LJSONResposta) then
//      raise Exception.Create('Resposta inválida da API ao enviar imagem');

    try
      if not LJSONResposta.TryGetValue<Boolean>('status', LStatus) then
        raise Exception.Create('Campo "status" não encontrado na resposta');

      if not LStatus then
      begin
        LJSONResposta.TryGetValue<string>('mensagem', LMensagem);
        raise Exception.Create('Erro da API: ' + LMensagem);
      end;

      Result := True;
    finally
      LJSONResposta.Free;
    end;
  finally
    LJSONEnvio.Free;
  end;
end;

function TSincronizadorApi.SincronizarEmpresa(const ACNPJ, AChaveApi: string;
                                              ACodigoWeb: Integer;
                                              ADadosEmpresa: TDataSet;
                                              AFormasPagamento: TDataSet;
                                              AUsuario: TDataSet;
                                              out ACodigoEmpresaRemoto: Integer): Boolean;
var
  LJSONEnvio: TJSONObject;
  LJSONDadosEmpresa: TJSONArray;
  LJSONFormasPgto: TJSONArray;
  LJSONUsuarios: TJSONArray;
  LJSONResposta: TJSONObject;
  LStatus: Boolean;
  LMensagem: string;
  LStatusCode: Integer;
  LContent: string;
begin
  Result := False;
  ACodigoEmpresaRemoto := 0;

  if ACNPJ.Trim.IsEmpty then
    raise Exception.Create('CNPJ não informado');

  if AChaveApi.Trim.IsEmpty then
    raise Exception.Create('Chave da API não informada');

  if not Assigned(ADadosEmpresa) then
    raise Exception.Create('Dados da empresa não informados');

  LJSONEnvio := TJSONObject.Create;
  try
    LJSONEnvio.AddPair('cnpj', ACNPJ);
    LJSONEnvio.AddPair('chave_api', AChaveApi);
    LJSONEnvio.AddPair('cweb', TJSONNumber.Create(ACodigoWeb));

    LJSONDadosEmpresa := DataSetToJSONArray(ADadosEmpresa);
    LJSONEnvio.AddPair('dados', LJSONDadosEmpresa);



    if Assigned(AFormasPagamento) and not AFormasPagamento.IsEmpty then
    begin
      LJSONFormasPgto := DataSetToJSONArray(AFormasPagamento);
      LJSONEnvio.AddPair('formas_pagamento', LJSONFormasPgto);
    end;

    if Assigned(AUsuario) and not AUsuario.IsEmpty then
    begin
      LJSONUsuarios := DataSetToJSONArray(AUsuario);
      LJSONEnvio.AddPair('usuario', LJSONUsuarios);
    end;

    PrepareAuthHeaders(LApiKeyJWT, ACodigoWeb);

    if not DoRequest('POST', 'empresa/sync', LJSONEnvio, LStatusCode, LContent) then
      raise Exception.CreateFmt('Erro HTTP %d ao sincronizar empresa', [LStatusCode]);

    LJSONResposta := TJSONObject(TJSONObject.ParseJSONValue(LContent));
    if not Assigned(LJSONResposta) then
      raise Exception.Create('Resposta inválida da API ao sincronizar empresa');

    try
      if not LJSONResposta.TryGetValue<Boolean>('status', LStatus) then
        raise Exception.Create('Campo "status" não encontrado na resposta');

      if not LStatus then
      begin
        LJSONResposta.TryGetValue<string>('mensagem', LMensagem);
        raise Exception.Create('Erro da API: ' + LMensagem);
      end;

      if not LJSONResposta.TryGetValue<Integer>('codigo_empresa', ACodigoEmpresaRemoto) then
        raise Exception.Create('Campo "codigo_empresa" não encontrado na resposta');

      Result := True;
    finally
      LJSONResposta.Free;
    end;
  finally
    LJSONEnvio.Free;
  end;
end;

function TSincronizadorApi.DataSetToJSONArray(ADataSet: TDataSet): TJSONArray;
var
  LJSONObject: TJSONObject;
  LField: TField;
  LBookmark: TBookmark;
begin
  Result := TJSONArray.Create;
  if not Assigned(ADataSet) then
    Exit;

  LBookmark := ADataSet.GetBookmark;
  ADataSet.DisableControls;
  try
    ADataSet.First;
    while not ADataSet.Eof do
    begin
      LJSONObject := TJSONObject.Create;
      try
        for LField in ADataSet.Fields do
        begin
          case LField.DataType of
            ftString, ftWideString, ftMemo, ftWideMemo:
              LJSONObject.AddPair(lowercase(LField.FieldName), LField.AsString);

            ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc:
              LJSONObject.AddPair(lowercase(LField.FieldName), TJSONNumber.Create(LField.AsInteger));

            ftFloat, ftCurrency, ftBCD, ftFMTBcd:
              LJSONObject.AddPair(lowercase(LField.FieldName), TJSONNumber.Create(LField.AsFloat));

            ftDate, ftTime, ftDateTime, ftTimeStamp:
              LJSONObject.AddPair(
               lowercase(LField.FieldName),
                FormatDateTime('yyyy-mm-dd hh:nn:ss', LField.AsDateTime)
              );

            ftBoolean:
              LJSONObject.AddPair(lowercase(LField.FieldName), TJSONBool.Create(LField.AsBoolean));

            ftBlob, ftOraBlob, ftGraphic, ftBytes, ftVarBytes, ftStream:
            begin
              if not LField.IsNull then
                LJSONObject.AddPair(lowercase(LField.FieldName), BlobToBase64(LField))
              else
                LJSONObject.AddPair(lowercase(LField.FieldName), TJSONNull.Create);
            end;
          else
            if not LField.IsNull then
              LJSONObject.AddPair(lowercase(LField.FieldName), LField.AsString);
          end;
        end;

        Result.AddElement(LJSONObject);
      except
        LJSONObject.Free;
        raise;
      end;

      ADataSet.Next;
    end;
  finally
    // volta pra posição original da consulta
    if (LBookmark <> nil) and ADataSet.BookmarkValid(LBookmark) then
      ADataSet.GotoBookmark(LBookmark);
    ADataSet.FreeBookmark(LBookmark);
    ADataSet.EnableControls;
  end;
end;


function TSincronizadorApi.BlobToBase64(Field: TField): string;
var
  MS: TMemoryStream;
begin
  Result := '';
  if Field.IsNull then
    Exit;

  MS := TMemoryStream.Create;
  try
    TBlobField(Field).SaveToStream(MS);
    MS.Position := 0;
    Result := TNetEncoding.Base64.EncodeBytesToString(MS.Memory, MS.Size);
  finally
    MS.Free;
  end;
end;

function TSincronizadorApi.AtualizarCodigoEmpresaLocal(AIdEmpresaLocal: Integer;
                                                       ACodigoEmpresaRemoto: Integer): Boolean;
var
  LQuery: TFDQuery;
begin
  Result := False;

  if not Assigned(FConexao) then
    raise Exception.Create('Conexão com banco de dados não configurada');

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConexao;
    LQuery.SQL.Text :=
      'UPDATE empresa ' +
      '   SET cweb = :codigo_remoto ' +
      ' WHERE codigo = :id_empresa';

    LQuery.ParamByName('codigo_remoto').AsInteger := ACodigoEmpresaRemoto;
    LQuery.ParamByName('id_empresa').AsInteger    := AIdEmpresaLocal;
    LQuery.ExecSQL;

    Result := LQuery.RowsAffected > 0;
  finally
    LQuery.Free;
  end;
end;

function TSincronizadorApi.Sincronizar(const ACNPJ: string;
                                       AIdEmpresaLocal: Integer;
                                       ADataSet: TDataSet;
                                       const AMethod: string;
                                       const ARota: string): Boolean;
var
  LJSONEnvio: TJSONObject;
  LJSONDados: TJSONArray;
  LJSONResposta: TJSONObject;
  LStatus: Boolean;
  LMensagem: string;
  LStatusCode: Integer;
  LContent: string;
begin
  Result := False;

  if ACNPJ.Trim.IsEmpty then
    raise Exception.Create('CNPJ não informado');

  if vChaveGLobal.Trim.IsEmpty then
    raise Exception.Create('Chave da API não informada');

  if AIdEmpresaLocal <= 0 then
    raise Exception.Create('ID da empresa inválido');

  if not Assigned(ADataSet) then
    raise Exception.Create('DataSet não informado');

  LJSONDados := DataSetToJSONArray(ADataSet);

  LJSONEnvio := TJSONObject.Create;
  try
    LJSONEnvio.AddPair('cnpj', ACNPJ);
    LJSONEnvio.AddPair('chave_api',vChaveGLobal);
    LJSONEnvio.AddPair('codemp', TJSONNumber.Create(AIdEmpresaLocal));

    if Pos('clientes', ARota) > 0 then
      LJSONEnvio.AddPair('clientes', LJSONDados)
    else if Pos('produtos', ARota) > 0 then
      LJSONEnvio.AddPair('produtos', LJSONDados)
    else
      LJSONEnvio.AddPair('dados', LJSONDados);

     PrepareAuthHeaders(LApiKeyJWT, AIdEmpresaLocal);

    if not DoRequest(AMethod, ARota, LJSONEnvio, LStatusCode, LContent) then
      raise Exception.CreateFmt('Erro HTTP %d na rota %s', [LStatusCode, ARota]);

    if LContent.Trim = '' then
    begin
      Result := True; // 204, por exemplo
      Exit;
    end;

    LJSONResposta := TJSONObject(TJSONObject.ParseJSONValue(LContent));
    if not Assigned(LJSONResposta) then
      raise Exception.Create('Resposta inválida da API na sincronização');

    try
      if not LJSONResposta.TryGetValue<Boolean>('status', LStatus) then
        raise Exception.Create('Campo STATUS não encontrado na API');

      if not LStatus then
      begin
        LJSONResposta.TryGetValue<string>('mensagem', LMensagem);
        raise Exception.Create('Erro API: ' + LMensagem);
      end;

      Result := True;
    finally
      LJSONResposta.Free;
    end;
  finally
    LJSONEnvio.Free;
  end;
end;

function TSincronizadorApi.SincronizarProdutos(const ACNPJ: string;
                                              ACodigoEmpresa: Integer;
                                              AProdutosAtivos: TDataSet;
                                              AProdutosInativos: TDataSet;
                                              out ATotalSincronizados: Integer;
                                              out ATotalExcluidos: Integer): Boolean;
var
  LJSONEnvio: TJSONObject;
  LJSONProdutos: TJSONArray;
  LJSONInativos: TJSONArray;
  LJSONResposta: TJSONObject;
  LStatus: Boolean;
  LMensagem: string;
  LStatusCode: Integer;
  LContent: string;
begin
  Result := False;
  ATotalSincronizados := 0;
  ATotalExcluidos := 0;

  if ACNPJ.Trim.IsEmpty then
    raise Exception.Create('CNPJ não informado');

  if vChaveGLobal.Trim.IsEmpty then
    raise Exception.Create('Chave da API não informada');

  if ACodigoEmpresa <= 0 then
    raise Exception.Create('Código da empresa inválido');

  if not Assigned(AProdutosAtivos) or AProdutosAtivos.IsEmpty then
    raise Exception.Create('Nenhum produto para sincronizar');

  LJSONEnvio := TJSONObject.Create;
  try
    LJSONEnvio.AddPair('cnpj', ACNPJ);
    LJSONEnvio.AddPair('chave_api', vChaveGLobal);
    LJSONEnvio.AddPair('codemp', TJSONNumber.Create(ACodigoEmpresa));

    LJSONProdutos := DataSetToJSONArray(AProdutosAtivos);
    LJSONEnvio.AddPair('produtos', LJSONProdutos);

    if Assigned(AProdutosInativos) and not AProdutosInativos.IsEmpty then
    begin
      LJSONInativos := TJSONArray.Create;
      AProdutosInativos.First;
      while not AProdutosInativos.Eof do
      begin
        LJSONInativos.AddElement(
          TJSONNumber.Create(AProdutosInativos.FieldByName('id').AsInteger)
        );
        AProdutosInativos.Next;
      end;
      LJSONEnvio.AddPair('produtos_inativos', LJSONInativos);
    end;

      PrepareAuthHeaders(LApiKeyJWT, ACodigoEmpresa);

    if not DoRequest('POST', 'produtos/sync', LJSONEnvio, LStatusCode, LContent) then
      raise Exception.CreateFmt('Erro HTTP %d ao sincronizar produtos', [LStatusCode]);

    LJSONResposta := TJSONObject(TJSONObject.ParseJSONValue(LContent));
    if not Assigned(LJSONResposta) then
      raise Exception.Create('Resposta inválida da API ao sincronizar produtos');

    try
      if not LJSONResposta.TryGetValue<Boolean>('status', LStatus) then
        raise Exception.Create('Campo "status" não encontrado na resposta');

      if not LStatus then
      begin
        LJSONResposta.TryGetValue<string>('mensagem', LMensagem);
        raise Exception.Create('Erro da API: ' + LMensagem);
      end;

      LJSONResposta.TryGetValue<Integer>('total_sincronizados', ATotalSincronizados);
      LJSONResposta.TryGetValue<Integer>('total_excluidos', ATotalExcluidos);

      Result := True;
    finally
      LJSONResposta.Free;
    end;
  finally
    LJSONEnvio.Free;
  end;
end;

 function TSincronizadorApi.BaixarPedidosPendentes(ACodigoEmpresa: Integer;
                                                  out APedidos: TJSONArray): Boolean;
var
  LJSONResposta: TJSONObject;
  LStatusCode: Integer;
  LContent: string;
  LSuccess: Boolean;
  LMensagem: string;
begin
  Result := False;
  APedidos := nil;

  if ACodigoEmpresa <= 0 then
    raise Exception.Create('Código da empresa inválido');

  if vChaveGLobal.Trim.IsEmpty then
    raise Exception.Create('Chave da API não informada');

  try
    PrepareAuthHeaders(LApiKeyJWT, ACodigoEmpresa);

    if not DoRequest('GET', 'pedidos/pendentes', nil, LStatusCode, LContent) then
      raise Exception.CreateFmt('Erro HTTP %d ao buscar pedidos pendentes', [LStatusCode]);

    if LContent.Trim = '' then
      raise Exception.Create('Resposta vazia da API ao buscar pedidos');

    LJSONResposta := TJSONObject(TJSONObject.ParseJSONValue(LContent));
    if not Assigned(LJSONResposta) then
      raise Exception.Create('Resposta inválida da API ao buscar pedidos');

    try
      if not LJSONResposta.TryGetValue<Boolean>('success', LSuccess) then
        raise Exception.Create('Campo "success" não encontrado na resposta');

      if not LSuccess then
      begin
        if not LJSONResposta.TryGetValue<string>('error', LMensagem) then
          LJSONResposta.TryGetValue<string>('message', LMensagem);
        raise Exception.Create('Erro da API: ' + LMensagem);
      end;

      // Extrair array de pedidos
      if LJSONResposta.TryGetValue<TJSONArray>('pedidos', APedidos) then
      begin
        // Clonar o array para evitar que seja destruído com LJSONResposta
        APedidos := TJSONArray(TJSONObject.ParseJSONValue(APedidos.ToJSON));
        Result := True;
      end
      else
        raise Exception.Create('Campo "pedidos" não encontrado na resposta');

    finally
      LJSONResposta.Free;
    end;
  except
    on E: Exception do
    begin
      if Assigned(APedidos) then
        FreeAndNil(APedidos);
      raise;
    end;
  end;
end;

function TSincronizadorApi.MarcarPedidoSincronizado(ACodigoEmpresa: Integer;
                                                   ACodPedidoWeb: Integer;
                                                   ACodigoLocal: Integer): Boolean;
var
  LJSONEnvio: TJSONObject;
  LJSONResposta: TJSONObject;
  LStatusCode: Integer;
  LContent: string;
  LSuccess: Boolean;
  LMensagem: string;
begin
  Result := False;

  if ACodigoEmpresa <= 0 then
    raise Exception.Create('Código da empresa inválido');

  if ACodPedidoWeb <= 0 then
    raise Exception.Create('Código do pedido web inválido');

  if vChaveGLobal.Trim.IsEmpty then
    raise Exception.Create('Chave da API não informada');

  LJSONEnvio := TJSONObject.Create;
  try
    LJSONEnvio.AddPair('codigo_local', TJSONNumber.Create(ACodigoLocal));

    PrepareAuthHeaders(LApiKeyJWT, ACodigoEmpresa);

    if not DoRequest('POST',
                     Format('pedidos/%d/sincronizado', [ACodPedidoWeb]),
                     LJSONEnvio,
                     LStatusCode,
                     LContent) then
      raise Exception.CreateFmt('Erro HTTP %d ao marcar pedido como sincronizado', [LStatusCode]);

    if LContent.Trim = '' then
    begin
      Result := True; // 204 No Content
      Exit;
    end;

    LJSONResposta := TJSONObject(TJSONObject.ParseJSONValue(LContent));
    if not Assigned(LJSONResposta) then
      raise Exception.Create('Resposta inválida da API');

    try
      if not LJSONResposta.TryGetValue<Boolean>('success', LSuccess) then
        raise Exception.Create('Campo "success" não encontrado na resposta');

      if not LSuccess then
      begin
        if not LJSONResposta.TryGetValue<string>('error', LMensagem) then
          LJSONResposta.TryGetValue<string>('message', LMensagem);
        raise Exception.Create('Erro da API: ' + LMensagem);
      end;

      Result := True;
    finally
      LJSONResposta.Free;
    end;
  finally
    LJSONEnvio.Free;
  end;
end;

function TSincronizadorApi.BaixarClientes(ACodigoEmpresa: Integer;
                                         AUltimaAtualizacao: TDateTime;
                                         out AClientes: TJSONArray): Boolean;
var
  LJSONResposta: TJSONObject;
  LStatusCode: Integer;
  LContent: string;
  LSuccess: Boolean;
  LMensagem: string;
  LURL: string;
begin
  Result := False;
  AClientes := nil;

  if ACodigoEmpresa <= 0 then
    raise Exception.Create('Código da empresa inválido');

  if vChaveGLobal.Trim.IsEmpty then
    raise Exception.Create('Chave da API não informada');

  try
    PrepareAuthHeaders(LApiKeyJWT, ACodigoEmpresa);

    // Montar URL com parâmetro last_mod se necessário
    LURL := 'clientes/download';
    if AUltimaAtualizacao > 0 then
      LURL := LURL + '?last_mod=' + FormatDateTime('yyyy-mm-dd hh:nn:ss', AUltimaAtualizacao);

    if not DoRequest('GET', LURL, nil, LStatusCode, LContent) then
      raise Exception.CreateFmt('Erro HTTP %d ao buscar clientes', [LStatusCode]);

    if LContent.Trim = '' then
      raise Exception.Create('Resposta vazia da API ao buscar clientes');

    LJSONResposta := TJSONObject(TJSONObject.ParseJSONValue(LContent));
    if not Assigned(LJSONResposta) then
      raise Exception.Create('Resposta inválida da API ao buscar clientes');

    try
      if not LJSONResposta.TryGetValue<Boolean>('success', LSuccess) then
        raise Exception.Create('Campo "success" não encontrado na resposta');

      if not LSuccess then
      begin
        if not LJSONResposta.TryGetValue<string>('error', LMensagem) then
          LJSONResposta.TryGetValue<string>('message', LMensagem);
        raise Exception.Create('Erro da API: ' + LMensagem);
      end;

      // Extrair array de clientes
      if LJSONResposta.TryGetValue<TJSONArray>('clientes', AClientes) then
      begin
        // Clonar o array para evitar que seja destruído com LJSONResposta
        AClientes := TJSONArray(TJSONObject.ParseJSONValue(AClientes.ToJSON));
        Result := True;
      end
      else
        raise Exception.Create('Campo "clientes" não encontrado na resposta');

    finally
      LJSONResposta.Free;
    end;
  except
    on E: Exception do
    begin
      if Assigned(AClientes) then
        FreeAndNil(AClientes);
      raise;
    end;
  end;
end;



end.

