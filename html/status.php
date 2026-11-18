<?php
header('Content-Type: text/plain; charset=utf-8');
header('X-Powered-By: PHP/8.2.18');
header('Server: Apache/2.4.58 (Ubuntu) mod_php/8.2.18');

echo "===========================================\n";
echo "   PHP2Shell Enterprise Core Service v1.0   \n";
echo "===========================================\n";
echo "Host: " . ($_SERVER['HTTP_HOST'] ?? 'php2shell.dl') . "\n";
echo "Server Software: " . ($_SERVER['SERVER_SOFTWARE'] ?? 'Apache/2.4.58') . "\n";
echo "PHP Core Version: " . PHP_VERSION . "\n";
echo "PHP SAPI: " . php_sapi_name() . "\n";
echo "Zend Engine: " . zend_version() . "\n";
echo "System Time: " . date('Y-m-d H:i:s') . "\n";
echo "Health: OK (Memory Usage: " . round(memory_get_usage() / 1024 / 1024, 2) . " MB)\n";
echo "===========================================\n";
