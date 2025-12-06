<?php
/**
 * Configurações da API ConectivaSF
 *
 * Configure aqui os dados do seu servidor MySQL em nuvem
 */

// ========================================
// CONFIGURAÇÕES DO BANCO DE DADOS (MySQL em Nuvem)
// ========================================
define('DB_HOST', 'localhost');  // Host do MySQL
define('DB_NAME', 'conectiva_mob');               // Nome do banco (conforme nuvemdb.sql)
define('DB_USER', 'root');                 // Usuário
define('DB_PASS', '');                   // Senha
define('DB_CHARSET', 'utf8mb4');
define('DB_PORT', '3306');

// ========================================
// JWT - AUTENTICAÇÃO
// ========================================
define('JWT_SECRET', 'zMHz6YGp4VBMYA52ziWzJihwvPP1jDio');
define('JWT_ALGORITHM', 'HS256');
define('JWT_EXPIRES_IN', 604800); // 7 dias em segundos

// ========================================
// CONFIGURAÇÕES DA API
// ========================================
define('API_VERSION', '1.0.0');
define('TIMEZONE', 'America/Sao_Paulo');

// ========================================
// CORS - Permitir acesso do app mobile
// ========================================
define('CORS_ALLOW_ORIGIN', '*'); // Em produção, coloque o domínio específico
define('CORS_ALLOW_METHODS', 'GET, POST, PUT, DELETE, OPTIONS');
define('CORS_ALLOW_HEADERS', 'Content-Type, Authorization, X-Requested-With, X-API-Key, X-CodEmp');

// ========================================
// AMBIENTE (dev ou production)
// ========================================
define('ENVIRONMENT', 'production'); // Altere para 'dev' durante desenvolvimento


// ========================================
// OUTRAS CONFIGURAÇÕES
// ========================================
date_default_timezone_set(TIMEZONE);

// Error Reporting baseado no ambiente
if (ENVIRONMENT === 'production') {
    error_reporting(0);
    ini_set('display_errors', 0);
    ini_set('log_errors', 1);
    ini_set('error_log', __DIR__ . '/../logs/error.log');
} else {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    ini_set('log_errors', 1);
    ini_set('error_log', __DIR__ . '/../logs/error.log');
}
