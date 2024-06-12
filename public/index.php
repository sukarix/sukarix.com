<?php

declare(strict_types=1);

use Application\Application;

if (PHP_SAPI === 'cli') {
    parse_str(str_replace('/?', '', $argv[1]), $_GET);
}

if (!empty($_GET) && array_key_exists('statera', $_GET)) {
    require_once __DIR__ . '/statera/index.php';

    exit;
}

// Change to application directory to execute the code
chdir(realpath(dirname(__DIR__) . DIRECTORY_SEPARATOR . 'app'));

// load composer autoload
require_once '../vendor/autoload.php';

$app = new Application();
$app->start();
