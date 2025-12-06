<?php
class SyncController
{
    public function downloadBatch($codemp = null)
    {
        // === CONFIGURAÇÕES CRÍTICAS ===
        @ini_set('memory_limit', '512M');
        @ini_set('max_execution_time', 300);
        @set_time_limit(300);
        @ini_set('output_buffering', 'Off');
        @ini_set('zlib.output_compression', 'Off');
        
        // Headers para manter conexão aberta (prevenir Network Error no mobile)
        if (!headers_sent()) {
            header('Connection: keep-alive');
            header('Keep-Alive: timeout=300, max=100');
        }
        
        @ini_set('implicit_flush', 1);
        
        // Limpar TODOS os buffers
        while (@ob_end_clean());
        
        error_log('[SYNC] === INICIO downloadBatch ===');
        
        try {
            // Parâmetros
            $codemp  = $codemp ?? ($_GET['codemp'] ?? null);
            $type    = $_GET['type'] ?? null;
            $offset  = max(0, (int)($_GET['offset'] ?? 0));
            $limit   = min(500, max(1, (int)($_GET['limit'] ?? 100)));

            error_log("[SYNC] codemp=$codemp, type=$type, offset=$offset, limit=$limit");

            // Validações
            if (!$codemp) {
                return $this->respond(['success' => false, 'error' => 'codemp obrigatório'], 400);
            }
            
            if (!$type) {
                return $this->respond(['success' => false, 'error' => 'type obrigatório'], 400);
            }

            $validTypes = ['usuarios', 'clientes', 'produtos', 'planosPagamento'];
            if (!in_array($type, $validTypes)) {
                return $this->respond(['success' => false, 'error' => 'Tipo inválido'], 400);
            }

            // Conexão
            $db = Database::getInstance()->getConnection();
            $codemp = (int) $codemp;

            // Definir SQL por tipo
            $sqls = [
                'usuarios' => [
                    'table' => 'usuarios',
                    'sql' => "SELECT id AS Id, nome AS Nome, email AS Email, senha AS Senha_mobile, 
                              codemp AS CodEmp, last_mod AS Last_mod,
                              Desconto_Padrao, Permite_Desconto, Tipo_Desconto
                              FROM usuarios WHERE codemp = :codEmp ORDER BY id LIMIT :limit OFFSET :offset"
                ],
                'clientes' => [
                    'table' => 'clientes',
                    'sql' => "SELECT codigo AS Codigo, razao_nome AS Razao_Nome, apelido_fantasia AS Apelido_Fantasia,
                              cpf_cnpj AS Cpf_Cnpj, cidade AS Cidade, uf AS UF, fone AS Fone, celular AS Celular,
                              cli_obs AS Cli_Obs, endereco, endereco_numero, Complemento, bairro, cep,
                              codemp AS CodEmp, codigo AS cweb, last_mod AS Last_mod
                              FROM clientes WHERE codemp = :codEmp ORDER BY codigo LIMIT :limit OFFSET :offset"
                ],
                'produtos' => [
                    'table' => 'produtos',
                    'sql' => "SELECT id AS Codigo, mercadoria AS Descricao, referencia AS Referencia,
                              ean AS Codigo_Barras, preco AS Preco_Venda, estoque AS Estoque_Atual,
                              um AS Unidade, img1 AS Foto, codemp AS CodEmp, last_mod AS Last_mod
                              FROM produtos WHERE codemp = :codEmp ORDER BY id LIMIT :limit OFFSET :offset"
                ],
                'planosPagamento' => [
                    'table' => 'condpgto',
                    'sql' => "SELECT id AS Codigo, descricao AS Descricao, parcelas AS Parcelas,
                              codemp AS CodEmp, last_mod AS Last_mod
                              FROM condpgto WHERE codemp = :codEmp ORDER BY id LIMIT :limit OFFSET :offset"
                ]
            ];

            $config = $sqls[$type];
            $total = $this->countTable($db, $config['table'], $codemp);
            
            error_log("[SYNC] Total de {$type}: {$total}");

            // Executar query
            $stmt = $db->prepare($config['sql']);
            $stmt->bindValue(':codEmp', $codemp, PDO::PARAM_INT);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            $stmt->execute();

            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $dataCount = count($data);
//aqui esta em testes nada certo ainda
            if ($type === 'produtos') {
                foreach ($data as &$row) {
                    if (!empty($row['Foto'])) {
                        $row['Foto'] = base64_encode($row['Foto']);
                    }
                }
                unset($row);
            }
            
            error_log("[SYNC] Buscados: {$dataCount} registros");

            // SANITIZAR
            foreach ($data as &$row) {
                foreach ($row as $key => &$value) {
                    if (is_string($value)) {
                        $value = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/u', '', $value);
                        if (!mb_check_encoding($value, 'UTF-8')) {
                            $value = mb_convert_encoding($value, 'UTF-8', 'UTF-8');
                        }
                    }
                }
            }
            unset($row, $value);

            // Resposta
            $response = [
                'success' => true,
                'type'    => $type,
                'offset'  => $offset,
                'limit'   => $limit,
                'total'   => $total,
                'hasMore' => ($offset + $dataCount) < $total,
                'data'    => $data
            ];
            
            error_log("[SYNC] Enviando resposta: {$dataCount} registros, hasMore=" . ($response['hasMore'] ? 'true' : 'false'));
            
            return $this->respond($response, 200);

        } catch (Exception $e) {
            error_log('[SYNC] ERRO: ' . $e->getMessage());
            error_log('[SYNC] Stack: ' . $e->getTraceAsString());
            return $this->respond(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }

    private function countTable($db, $table, $codemp)
    {
        try {
            $stmt = $db->prepare("SELECT COUNT(*) AS total FROM {$table} WHERE codemp = :cod");
            $stmt->execute(['cod' => $codemp]);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            $total = (int)($result['total'] ?? 0);
            error_log("[SYNC] Count {$table}: {$total}");
            return $total;
        } catch (Exception $e) {
            error_log("[SYNC] Erro count {$table}: " . $e->getMessage());
            return 0;
        }
    }

    private function respond($data, $code = 200)
    {
        // Limpar TUDO
        while (@ob_end_clean());
        
        // Status
        http_response_code($code);
        
        // Headers MÍNIMOS
        header('Content-Type: application/json; charset=utf-8');
        header('Cache-Control: no-cache, no-store, must-revalidate');
        header('Pragma: no-cache');
        header('Expires: 0');
        
        // JSON com flags corretas
        $json = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        
        if ($json === false) {
            $error = json_last_error_msg();
            error_log('[SYNC] ERRO ao gerar JSON: ' . $error);
            
            // Tentar simplificar dados
            if (isset($data['data'])) {
                error_log('[SYNC] Tentando limpar dados...');
                foreach ($data['data'] as &$item) {
                    foreach ($item as $k => &$v) {
                        if (is_string($v)) {
                            $v = mb_convert_encoding($v, 'UTF-8', 'UTF-8');
                        }
                    }
                }
                $json = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            }
            
            if ($json === false) {
                $json = json_encode(['success' => false, 'error' => 'Erro JSON: ' . $error]);
            }
        }
        
        $size = strlen($json);
        error_log("[SYNC] JSON gerado: {$size} bytes");
        
        // Content-Length OBRIGATÓRIO
        header('Content-Length: ' . $size);
        
        // Enviar
        echo $json;
        
        // Flush
        if (function_exists('fastcgi_finish_request')) {
            fastcgi_finish_request();
        } else {
            flush();
        }
        
        exit(0);
    }
}