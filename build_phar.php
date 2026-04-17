<?php

function addPathToPhar(Phar $phar, string $sourcePath, string $localPath): void
{
    if (is_file($sourcePath)) {
        $phar->addFile($sourcePath, $localPath);
        return;
    }

    if (!is_dir($sourcePath)) {
        throw new RuntimeException("Path not found: $sourcePath");
    }

    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($sourcePath, FilesystemIterator::SKIP_DOTS)
    );

    foreach ($iterator as $file) {
        if (!$file->isFile()) {
            continue;
        }

        $fullPath = $file->getPathname();
        $relativePath = $localPath . '/' . ltrim(substr($fullPath, strlen($sourcePath)), DIRECTORY_SEPARATOR);
        $phar->addFile($fullPath, $relativePath);
    }
}

$pharFile = __DIR__ . '/miaplicacion.phar';
$runtimeIncludeList = [
    'index.php',
    'print.php',
    'printers.php',
    'unifont.hex',
    'vendor',
];

if (file_exists($pharFile)) {
    unlink($pharFile);
}

$phar = new Phar($pharFile, 0, basename($pharFile));
$phar->startBuffering();

foreach ($runtimeIncludeList as $path) {
    addPathToPhar($phar, __DIR__ . '/' . $path, $path);
}

$phar->setStub("#!/usr/bin/env php\n" . $phar->createDefaultStub('index.php'));
$phar->stopBuffering();
chmod($pharFile, 0755);

echo "Archivo Phar creado (whitelist): $pharFile\n";
