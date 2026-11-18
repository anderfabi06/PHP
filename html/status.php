<?php
header('Content-Type: text/plain; charset=utf-8');

$server_software = $_SERVER['SERVER_SOFTWARE'] ?? 'Apache/2.4.52 (Ubuntu)';

echo "===========================================\n";
echo "   PHP2Shell Enterprise Core Service v1.0   \n";
echo "===========================================\n";
echo "Host: " . ($_SERVER['HTTP_HOST'] ?? 'php2shell.dl') . "\n";
echo "Server Software: " . $server_software . "\n";
echo "PHP Core Version: " . PHP_VERSION . "\n";
echo "PHP SAPI: " . php_sapi_name() . "\n";
echo "Zend Engine: " . zend_version() . "\n";
echo "System Time: " . date('Y-m-d H:i:s') . "\n";
echo "Health: OK (Memory Usage: " . round(memory_get_usage() / 1024 / 1024, 2) . " MB)\n";
echo "===========================================\n";
