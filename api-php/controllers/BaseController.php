<?php
/**
 * controllers/BaseController.php
 * Classe base para todos os controllers
 */

abstract class BaseController
{
    protected $db;

    /**
     * Obtém conexão com banco de dados
     */
    protected function getDb(): PDO
    {
        if (!$this->db) {
            $this->db = Database::getInstance()->getConnection();
        }
        return $this->db;
    }

    /**
     * Obtém codemp do header X-CodEmp
     */
    protected function getCodempFromHeaders(): ?int
    {
        $headers = getallheaders();
        return isset($headers['X-CodEmp']) ? (int)$headers['X-CodEmp'] : null;
    }

    /**
     * Obtém codemp da URL (?codemp=123)
     */
    protected function getCodempFromQuery(): ?int
    {
        return isset($_GET['codemp']) ? (int)$_GET['codemp'] : null;
    }

    /**
     * Obtém codemp (tenta header primeiro, depois query string)
     */
    protected function getCodemp(): ?int
    {
        // Tenta header primeiro
        $codemp = $this->getCodempFromHeaders();
        
        // Se não tiver no header, tenta query string
        if (!$codemp) {
            $codemp = $this->getCodempFromQuery();
        }
        
        // Fallback para variável global (compatibilidade)
        if (!$codemp && isset($GLOBALS['cod_emp'])) {
            $codemp = (int)$GLOBALS['cod_emp'];
        }
        
        return $codemp;
    }

    /**
     * Lê JSON do corpo da requisição
     */
    protected function getJsonInput(): array
    {
        $json = file_get_contents('php://input');
        return json_decode($json, true) ?? [];
    }

    /**
     * Envia resposta de sucesso
     */
    protected function sendSuccess($data = [], int $code = 200): void
    {
        http_response_code($code);
        header('Content-Type: application/json');
        
        // Se já tem o formato correto, mantém
        if (is_array($data) && isset($data['success'])) {
            echo json_encode($data);
        } else {
            // Adiciona success: true
            echo json_encode(['success' => true] + (is_array($data) ? $data : ['data' => $data]));
        }
        exit;
    }

    /**
     * Envia resposta de erro
     */
    protected function sendError(string $message, int $code = 400, $details = null): void
    {
        http_response_code($code);
        header('Content-Type: application/json');
        
        $response = [
            'success' => false,
            'error' => $message
        ];
        
        if ($details !== null) {
            $response['message'] = $details;
        }
        
        echo json_encode($response);
        exit;
    }

    /**
     * Log apenas em desenvolvimento
     */
    protected function devLog(string $message, $data = null): void
    {
        if (defined('ENVIRONMENT') && ENVIRONMENT === 'dev') {
            error_log($message);
            if ($data !== null) {
                error_log(json_encode($data));
            }
        }
    }
}