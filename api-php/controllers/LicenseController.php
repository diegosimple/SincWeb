<?php
// Garantir que o autoload está carregado
if (file_exists(__DIR__ . '/../vendor/autoload.php')) {
    require_once __DIR__ . '/../vendor/autoload.php';
}

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class LicenseController {

    public function validateLicense() {
        // Sempre logar (não apenas em dev) para debug
        error_log('[validateLicense] === INÍCIO ===');
        error_log('[validateLicense] Timestamp: ' . date('Y-m-d H:i:s'));
        
        // Garantir que os headers estão corretos
        header('Content-Type: application/json; charset=utf-8');
        
        try {
            $rawInput = file_get_contents('php://input');
            error_log('[validateLicense] Input recebido (primeiros 100 chars): ' . substr($rawInput, 0, 100));
            
            $data = json_decode($rawInput, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                error_log('[validateLicense] ERRO JSON: ' . json_last_error_msg());
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'JSON inválido: ' . json_last_error_msg()
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }
            
            error_log('[validateLicense] Dados decodificados: ' . json_encode($data));

            if (!isset($data['cnpj']) || empty($data['cnpj'])) {
                error_log('[validateLicense] ERRO: CNPJ não fornecido');
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error' => 'CNPJ é obrigatório'
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }

            error_log('[validateLicense] Iniciando conexão com banco...');
            $db = Database::getInstance()->getConnection();
            error_log('[validateLicense] Conexão com banco estabelecida');
            
            $cnpj = preg_replace('/[^0-9]/', '', $data['cnpj']); // Remove formatação
            error_log('[validateLicense] CNPJ limpo: ' . $cnpj);

            // Consultar empresa pelo CNPJ
            error_log('[validateLicense] Executando query no banco...');
            $stmt = $db->prepare("
                SELECT codemp, nomefantasia, razaosocial, cnpj, ativo_sf, qtd_lic_sf
                FROM empresas
                WHERE REPLACE(REPLACE(REPLACE(cnpj, '.', ''), '/', ''), '-', '') = :cnpj
                LIMIT 1
            ");

            $stmt->execute(['cnpj' => $cnpj]);
            $empresa = $stmt->fetch();
            error_log('[validateLicense] Query executada');
            
            if ($empresa) {
                error_log('[validateLicense] Empresa encontrada - CodEmp: ' . $empresa['codemp'] . ', Ativo: ' . $empresa['ativo_sf'] . ', Licenças: ' . $empresa['qtd_lic_sf']);
            } else {
                error_log('[validateLicense] Empresa NÃO encontrada para CNPJ: ' . $cnpj);
            }

            if (!$empresa) {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'error' => 'Empresa não encontrada com o CNPJ informado'
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }

            // Verificar se a empresa está ativa
            if ($empresa['ativo_sf'] != 1) {
                error_log('[validateLicense] ERRO: Empresa não está ativa');
                http_response_code(403);
                echo json_encode([
                    'success' => false,
                    'error' => 'Empresa não está ativa no sistema'
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }

            // Verificar se há licenças disponíveis
            if ($empresa['qtd_lic_sf'] <= 0) {
                error_log('[validateLicense] ERRO: Sem licenças disponíveis');
                http_response_code(403);
                echo json_encode([
                    'success' => false,
                    'error' => 'Não há licenças disponíveis para esta empresa',
                    'qtd_lic_sf' => $empresa['qtd_lic_sf']
                ], JSON_UNESCAPED_UNICODE);
                exit;
            }

            // Decrementar quantidade de licenças
            error_log('[validateLicense] Decrementando licenças...');
            $novaQtdLic = $empresa['qtd_lic_sf'] - 1;
            
            $stmtUpdate = $db->prepare("
                UPDATE empresas
                SET qtd_lic_sf = :qtd_lic_sf
                WHERE codemp = :codemp
            ");

            $stmtUpdate->execute([
                'qtd_lic_sf' => $novaQtdLic,
                'codemp' => $empresa['codemp']
            ]);
            error_log('[validateLicense] Licenças decrementadas com sucesso');

            // Resposta de sucesso
            http_response_code(200);
            $response = [
                'success' => true,
                'message' => 'Licença validada e liberada com sucesso',
                'empresa' => [
                    'codemp' => (int)$empresa['codemp'],
                    'nomefantasia' => $empresa['nomefantasia'],
                    'razaosocial' => $empresa['razaosocial'],
                    'cnpj' => $empresa['cnpj'],
                    'qtd_lic_sf' => (int)$novaQtdLic,
                    'qtd_lic_sf_anterior' => (int)$empresa['qtd_lic_sf']
                ]
            ];
            
            error_log('[validateLicense] Resposta de sucesso: ' . json_encode($response));
            error_log('[validateLicense] Enviando resposta...');
            
            echo json_encode($response, JSON_UNESCAPED_UNICODE);
            error_log('[validateLicense] Resposta enviada com sucesso');
            error_log('[validateLicense] === FIM (SUCESSO) ===');
            exit; // Garantir que para a execução

        } catch (Exception $e) {
            // SEMPRE logar erros (não apenas em dev)
            error_log('[validateLicense] === ERRO EXCEPTION ===');
            error_log('[validateLicense] Mensagem: ' . $e->getMessage());
            error_log('[validateLicense] Arquivo: ' . $e->getFile());
            error_log('[validateLicense] Linha: ' . $e->getLine());
            error_log('[validateLicense] Stack trace: ' . $e->getTraceAsString());
            
            http_response_code(500);
            $errorResponse = [
                'success' => false,
                'error' => 'Erro ao validar licença',
                'message' => (defined('ENVIRONMENT') && ENVIRONMENT === 'dev') ? $e->getMessage() : 'Erro interno do servidor'
            ];
            
            error_log('[validateLicense] Enviando resposta de erro: ' . json_encode($errorResponse));
            echo json_encode($errorResponse, JSON_UNESCAPED_UNICODE);
            error_log('[validateLicense] === FIM (ERRO) ===');
            exit; // Garantir que para a execução
        } catch (Error $e) {
            // Capturar erros fatais também
            error_log('[validateLicense] === ERRO FATAL ===');
            error_log('[validateLicense] Mensagem: ' . $e->getMessage());
            error_log('[validateLicense] Arquivo: ' . $e->getFile());
            error_log('[validateLicense] Linha: ' . $e->getLine());
            
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Erro fatal ao validar licença',
                'message' => (defined('ENVIRONMENT') && ENVIRONMENT === 'dev') ? $e->getMessage() : 'Erro interno do servidor'
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
    }

    public function login()
{
    header('Content-Type: application/json; charset=utf-8');

    try {
        $data = json_decode(file_get_contents('php://input'), true) ?? [];

        // 1) Validação de entrada
        if (empty($data['cnpj']) || empty($data['chave'])) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'error'   => 'CNPJ e chave são obrigatórios'
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        $cnpj  = $data['cnpj'];
        $chave = $data['chave'];

        // 2) Buscar empresa
        $db = Database::getInstance()->getConnection();

        $stmt = $db->prepare("
            SELECT
                codemp,
                nomefantasia,
                razaosocial AS razao_social,
                cnpj,
                `key` AS chave_licenca
            FROM empresas
            WHERE cnpj = :cnpj
            LIMIT 1
        ");

        $stmt->execute([
            'cnpj' => $cnpj,
        ]);

        $empresa = $stmt->fetch(PDO::FETCH_ASSOC);

        // ============================
        // CASO 1: NÃO EXISTE EMPRESA AINDA → CRIAR
        // ============================
        if (!$empresa) {
            // Ajuste estes valores padrão conforme sua regra
            $stmtIns = $db->prepare("
                INSERT INTO empresas (
                    codemp,
                    nomefantasia,
                    razaosocial,
                    cnpj,
                    `key`
                )
                VALUES (
                    :codemp,
                    :nomefantasia,
                    :razao_social,
                    :cnpj,
                    :chave_licenca
                )
            ");

            $stmtIns->execute([
                'codemp'        => 0,
                'nomefantasia'  => '',            // ou o nome da empresa se você tiver
                'razao_social'  => '',            // idem
                'cnpj'          => $cnpj,
                'chave_licenca' => $chave,
            ]);

            // Recarrega a empresa recém criada
            $stmt->execute(['cnpj' => $cnpj]);
            $empresa = $stmt->fetch(PDO::FETCH_ASSOC);

        } else {
            // ============================
            // CASO 2: JÁ EXISTE EMPRESA → VALIDAR CHAVE
            // ============================
            if ($chave !== $empresa['chave_licenca']) {
                http_response_code(401);
                echo json_encode([
                    'success' => false,
                    'error'   => 'Chave/licença inválida'
                ], JSON_UNESCAPED_UNICODE);
                return;
            }
        }

        // 4) Montar payload do JWT
        $payload = [
            'codemp' => (int)$empresa['codemp'],
            'cnpj'   => $empresa['cnpj'],
            'iat'    => time(),
            'exp'    => time() + (24 * 60 * 60), // 24h
        ];

        $token = JWT::encode($payload, JWT_SECRET, JWT_ALGORITHM);

        // 5) Retornar OK
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'token'   => $token,
            'empresa' => [
                'codemp' => (int)$empresa['codemp'],
                'nome'   => $empresa['nomefantasia'] ?? $empresa['razao_social'] ?? '',
                'cnpj'   => $empresa['cnpj']
            ]
        ], JSON_UNESCAPED_UNICODE);

    } catch (Exception $e) {
        error_log('Auth login error: ' . $e->getMessage() . ' at ' . $e->getFile() . ':' . $e->getLine());

        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error'   => 'Erro ao fazer login',
            'message' => (defined('ENVIRONMENT') && ENVIRONMENT === 'dev')
                ? $e->getMessage()
                : 'Erro interno do servidor'
        ], JSON_UNESCAPED_UNICODE);
    }
}



    public function tokenSimple()
    {
        header('Content-Type: application/json; charset=utf-8');

        try {
            error_log('[tokenSimple] INICIO: ' . date('Y-m-d H:i:s'));
            $rawInput = file_get_contents('php://input');
            error_log('[tokenSimple] Payload: ' . json_encode($rawInput));
            $data = json_decode($rawInput, true) ?? [];
          

            // 1) Validação básica
            if (empty($data['cnpj']) || empty($data['chave'])) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'error'   => 'CNPJ e chave são obrigatórios'
                ], JSON_UNESCAPED_UNICODE);
                return;
            }

            $cnpj  = $data['cnpj'];
            $chave = $data['chave'];

            // se quiser, limpa CNPJ (opcional)
            // $cnpjLimpo = preg_replace('/[^0-9]/', '', $cnpj);

            // 2) Montar payload do JWT (SEM BANCO)
            $payload = [
                'cnpj'  => $cnpj,              // ou $cnpjLimpo, se preferir
                'codemp'=> 0,                  // 0 ou null, pois ainda não existe
                'hash'  => hash('sha256', $cnpj . '|' . $chave),
                'iat'   => time(),
                'exp'   => time() + (24 * 60 * 60), // 24h
            ];

            $token = JWT::encode($payload, JWT_SECRET, JWT_ALGORITHM);

            // 3) Retorno simples
            http_response_code(200);
            echo json_encode([
                'success' => true,
                'token'   => $token,
                'empresa' => [
                    'codemp' => 0,
                    'cnpj'   => $cnpj
                ]
            ], JSON_UNESCAPED_UNICODE);

        } catch (Exception $e) {
            error_log('Auth tokenSimple error: ' . $e->getMessage() . ' at ' . $e->getFile() . ':' . $e->getLine());

            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error'   => 'Erro ao gerar token',
                'message' => (defined('ENVIRONMENT') && ENVIRONMENT === 'dev')
                    ? $e->getMessage()
                    : 'Erro interno do servidor'
            ], JSON_UNESCAPED_UNICODE);
        }
    }
    


}

