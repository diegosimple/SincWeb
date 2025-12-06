<?php
/**
 * ===========================================
 *  BOOTSTRAP PRINCIPAL (API PRD)
 *  - CORS
 *  - Autoload seguro
 *  - Try/Catch global
 *  - Router externo
 *  - Logs de auditoria
 * ===========================================
 */

ini_set('memory_limit', '512M'); // PRD-safe
ini_set('max_execution_time', '300');
set_time_limit(300);

// ---------- Carregar Configurações ----------
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/Database.php';

// Autoload Composer (JWT, libs, etc.)
if (file_exists(__DIR__ . '/vendor/autoload.php')) {
    require_once __DIR__ . '/vendor/autoload.php';
}

// ---------- CORS ----------
header("Access-Control-Allow-Origin: " . CORS_ALLOW_ORIGIN);
header("Access-Control-Allow-Methods: " . CORS_ALLOW_METHODS);
header("Access-Control-Allow-Headers: " . CORS_ALLOW_HEADERS);
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ---------- LOG GLOBAL ----------
require_once __DIR__ . '/utils/AuditLog.php';
AuditLog::logRequest();

// ---------- ROTEAMENTO ----------
try {
    require_once __DIR__ . '/routes.php';

} catch (Throwable $e) {

    AuditLog::logError($e->getMessage(), [
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ]);

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erro interno do servidor',
        'message' => ENVIRONMENT === 'dev' ? $e->getMessage() : null
    ]);
}
