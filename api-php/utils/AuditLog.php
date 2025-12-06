<?php
class AuditLog
{
    private static $logPath = __DIR__ . '/../logs/';
    private static $logFile = 'audit.log';

    private static function ensureDirectoryExists()
    {
        if (!is_dir(self::$logPath)) {
            mkdir(self::$logPath, 0777, true);
        }
    }

    public static function logRequest()
    {
        self::ensureDirectoryExists();

        $data = [
            'timestamp' => date('Y-m-d H:i:s'),
            'ip'        => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
            'method'    => $_SERVER['REQUEST_METHOD'],
            'uri'       => $_SERVER['REQUEST_URI'],
            'headers'   => function_exists('getallheaders') ? getallheaders() : [],
            'payload'   => file_get_contents('php://input'),
        ];

        self::write($data);
    }

    public static function logError($message, $extra = [])
    {
        self::ensureDirectoryExists();

        $data = [
            'timestamp' => date('Y-m-d H:i:s'),
            'type'      => 'ERROR',
            'message'   => $message,
            'extra'     => $extra
        ];

        self::write($data);
    }

    private static function write($data)
    {
        $line = json_encode($data, JSON_UNESCAPED_UNICODE) . PHP_EOL;
        file_put_contents(self::$logPath . self::$logFile, $line, FILE_APPEND);
    }
}
