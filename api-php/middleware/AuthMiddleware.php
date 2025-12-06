<?php
// Garantir que o autoload está carregado
if (file_exists(__DIR__ . '/../vendor/autoload.php')) {
    require_once __DIR__ . '/../vendor/autoload.php';
}

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class AuthMiddleware {

    /**
     * Helper para logs (sempre ativo para debug)
     */
    private static function debugLog($message) {
        error_log('[AuthMiddleware] ' . $message);
    }

    /**
     * Autentica o usuário através do token JWT
     */
    public static function authenticate() {
        self::debugLog('=== AuthMiddleware::authenticate INICIO ===');
        self::debugLog('REQUEST_URI: ' . $_SERVER['REQUEST_URI']);
        self::debugLog('REQUEST_METHOD: ' . $_SERVER['REQUEST_METHOD']);
        
        // Função auxiliar para pegar headers (compatibilidade com diferentes servidores)
        $getHeaders = function() {
            if (function_exists('getallheaders')) {
                return getallheaders();
            }
            $headers = [];
            foreach ($_SERVER as $name => $value) {
                if (substr($name, 0, 5) == 'HTTP_') {
                    $headers[str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))))] = $value;
                }
            }
            return $headers;
        };

        $headers = $getHeaders();
        self::debugLog('Headers recebidos: ' . json_encode($headers));

        // Normalizar headers para lowercase para busca case-insensitive
        $headersLower = array_change_key_case($headers, CASE_LOWER);
        self::debugLog('Headers lowercase: ' . json_encode(array_keys($headersLower)));

        if (!isset($headersLower['authorization']) && !isset($headersLower['x-api-key'])) {
            error_log('AuthMiddleware: Token não fornecido');
            self::unauthorized('Token não fornecido');
        }

        $codemp = null;
        $jwtToken = null;
        $apiKey = null;

        // Tentar pegar API Key do header X-API-Key primeiro (case insensitive)
        if (isset($headersLower['x-api-key'])) {
            $apiKey = $headersLower['x-api-key'];
            self::debugLog('API Key extraída do X-API-Key');
        }

        // Tentar pegar token JWT do header Authorization (Bearer) - case insensitive
        // Só processar se não tiver API Key ou se o token parecer ser um JWT válido
        if (isset($headersLower['authorization'])) {
            $authHeader = $headersLower['authorization'];
            self::debugLog('Authorization header: ' . substr($authHeader, 0, 30) . '...');
            if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
                $potentialToken = $matches[1];
                // Verificar se parece ser um JWT (tem 3 partes separadas por ponto)
                if (substr_count($potentialToken, '.') === 2) {
                    $jwtToken = $potentialToken;
                    self::debugLog('JWT Token extraído do Bearer (formato válido)');
                } else {
                    // Se não parece JWT e não tem API Key, usar como API Key
                    if (!$apiKey) {
                        $apiKey = $potentialToken;
                        self::debugLog('Token do Bearer usado como API Key (não é JWT)');
                    } else {
                        self::debugLog('Ignorando Bearer token (não é JWT e já tem API Key)');
                    }
                }
            }
        }

        // Buscar código da empresa do query parameter ou header
        self::debugLog('Buscando CodEmp...');
        self::debugLog('$_GET: ' . json_encode($_GET));
        
        if (isset($_GET['codemp'])) {
            $codemp = (int)$_GET['codemp'];
            self::debugLog('CodEmp encontrado em $_GET: ' . $codemp);
        } elseif (isset($headersLower['x-codemp'])) {
            $codemp = (int)$headersLower['x-codemp'];
            self::debugLog('CodEmp encontrado em x-codemp: ' . $codemp);
        } elseif (isset($headers['X-CodEmp'])) {
            $codemp = (int)$headers['X-CodEmp'];
            self::debugLog('CodEmp encontrado em X-CodEmp: ' . $codemp);
        } elseif (isset($headers['X-Codemp'])) {
            $codemp = (int)$headers['X-Codemp'];
            self::debugLog('CodEmp encontrado em X-Codemp: ' . $codemp);
        }

        // Validar autenticação
        try {
            $db = Database::getInstance()->getConnection();

            // Se tem JWT Token, validar JWT
            if ($jwtToken) {
                self::debugLog('Validando JWT Token...');
                
                try {
                    $decoded = JWT::decode($jwtToken, new Key(JWT_SECRET, JWT_ALGORITHM));
                    $decodedArray = (array) $decoded;
                    
                    self::debugLog('JWT decodificado: ' . json_encode($decodedArray));
                    
                    // Extrair codEmp do JWT ou usar o do header
                    $codempFromJwt = $decodedArray['codEmp'] 
                        ?? $decodedArray['codemp'] 
                        ?? $decodedArray['cod_emp'] 
                        ?? null;
                    if ($codempFromJwt) {
                        $codemp = (int)$codempFromJwt;
                        self::debugLog('CodEmp extraído do JWT: ' . $codemp);
                    }
                    
                    if (!$codemp) {
                        if (self::allowsCodempOptional()) {
                            self::debugLog('CodEmp ausente, rota permite seguir apenas com JWT válido');
                            $GLOBALS['cod_emp'] = 0;
                            $GLOBALS['token_validated'] = true;
                            $GLOBALS['auth_payload'] = $decodedArray;
                            return true;
                        }

                        error_log('AuthMiddleware: CodEmp não encontrado no JWT nem nos headers');
                        self::unauthorized('Código da empresa não informado');
                    }
                    
                    // Verificar empresa
                    $stmt = $db->prepare("
                        SELECT codemp, `key`, ativo_sf
                        FROM empresas
                        WHERE codemp = :codemp
                        LIMIT 1
                    ");
                    $stmt->execute(['codemp' => $codemp]);
                    $empresa = $stmt->fetch(PDO::FETCH_ASSOC);

                    if (!$empresa) {
                        error_log('AuthMiddleware: Empresa não encontrada para codemp: ' . $codemp);
                        self::unauthorized('Empresa não encontrada');
                    }

                    // Verificar se empresa está ativa
                    if ($empresa['ativo_sf'] != 1) {
                        error_log('AuthMiddleware: Empresa não ativa: ' . $codemp);
                        self::unauthorized('Empresa não está ativa');
                    }
                    
                    // Se também tem API Key, validar que corresponde
                    if ($apiKey) {
                        $keyBanco = $empresa['key'] ?? null;
                        if (empty($keyBanco)) {
                            error_log('AuthMiddleware: Token não configurado para empresa: ' . $codemp);
                            self::unauthorized('Token não configurado para esta empresa');
                        }
                        if ($apiKey !== $keyBanco) {
                            error_log('AuthMiddleware: API Key inválida para empresa: ' . $codemp);
                            self::unauthorized('API Key inválida para esta empresa');
                        }
                    }
                    
                    // JWT válido
                    $GLOBALS['user_id'] = $decodedArray['id'] ?? null;
                    $GLOBALS['cod_emp'] = $codemp;
                    $GLOBALS['token_validated'] = true;
                    $GLOBALS['auth_payload'] = $decodedArray;
                    
                    self::debugLog('SUCCESS: JWT válido para empresa: ' . $codemp);
                    self::debugLog('=== AuthMiddleware::authenticate FIM ===');
                    return true;
                    
                } catch (Exception $e) {
                    error_log('AuthMiddleware: Erro ao decodificar JWT: ' . $e->getMessage());
                    self::unauthorized('Token JWT inválido ou expirado');
                }
            }
            
            // Se não tem JWT mas tem API Key, validar API Key
            if ($apiKey) {
                self::debugLog('Validando API Key...');
                
                if (!$codemp) {
                    error_log('AuthMiddleware: CodEmp não encontrado para validação de API Key');
                    self::unauthorized('Código da empresa não informado');
                }
                
                // Buscar empresa e validar API Key
                $stmt = $db->prepare("
                    SELECT codemp, `key`, ativo_sf
                    FROM empresas
                    WHERE codemp = :codemp
                    LIMIT 1
                ");
                $stmt->execute(['codemp' => $codemp]);
                $empresa = $stmt->fetch(PDO::FETCH_ASSOC);

                if (!$empresa) {
                    error_log('AuthMiddleware: Empresa não encontrada para codemp: ' . $codemp);
                    self::unauthorized('Empresa não encontrada');
                }

                // Verificar se empresa está ativa
                if ($empresa['ativo_sf'] != 1) {
                    error_log('AuthMiddleware: Empresa não ativa: ' . $codemp);
                    self::unauthorized('Empresa não está ativa');
                }

                // Verificar se empresa tem token configurado
                $keyBanco = $empresa['key'] ?? null;

                if (empty($keyBanco)) {
                    error_log('AuthMiddleware: Token não configurado para empresa: ' . $codemp);
                    self::unauthorized('Token não configurado para esta empresa');
                }

                // Comparar API Key enviada com o campo key do banco
                if ($apiKey !== $keyBanco) {
                    error_log('AuthMiddleware: API Key inválida para empresa: ' . $codemp);
                    self::debugLog('API Key recebida: ' . substr($apiKey, 0, 10) . '...');
                    self::debugLog('API Key do banco: ' . substr($keyBanco, 0, 10) . '...');
                    self::unauthorized('API Key inválida para esta empresa');
                }
                
                // API Key válida
                $GLOBALS['cod_emp'] = $codemp;
                $GLOBALS['token_validated'] = true;
                
                self::debugLog('SUCCESS: API Key válida para empresa: ' . $codemp);
                self::debugLog('=== AuthMiddleware::authenticate FIM ===');
                return true;
            }
            
            // Se não tem nem JWT nem API Key
            error_log('AuthMiddleware: Token não fornecido (nem JWT nem API Key)');
            self::unauthorized('Token não fornecido. Envie Authorization Bearer (JWT) ou X-API-Key');

        } catch (Exception $e) {
            error_log('AuthMiddleware EXCEPTION: ' . $e->getMessage());
            self::unauthorized('Erro ao validar token: ' . $e->getMessage());
        }
    }

    /**
     * Determina se a rota/método atual permitem continuar sem codemp
     */
    private static function allowsCodempOptional() {
        $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
        $uri = $_SERVER['REQUEST_URI'] ?? '/';
        $uri = strtok($uri, '?');
        $uri = str_replace(['/api-php', '/public', '/api'], '', $uri);
        if ($uri === '') {
            $uri = '/';
        }

        $allowMap = [
            'POST:/empresa',
            'POST:/empresa/sync',
        ];

        $signature = strtoupper($method) . ':' . $uri;
        $isAllowed = in_array($signature, $allowMap, true);
        if ($isAllowed) {
            self::debugLog('allowsCodempOptional: rota liberada -> ' . $signature);
        }
        return $isAllowed;
    }

    /**
     * Retorna resposta de não autorizado
     */
    private static function unauthorized($message = 'Não autorizado') {
        error_log('AuthMiddleware UNAUTHORIZED: ' . $message);
        http_response_code(401);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => false,
            'error' => $message
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    /**
     * Retorna o ID do usuário autenticado
     */
    public static function getUserId() {
        return $GLOBALS['user_id'] ?? null;
    }

    /**
     * Retorna o código da empresa do usuário autenticado
     */
    public static function getCodEmp() {
        return $GLOBALS['cod_emp'] ?? null;
    }
}