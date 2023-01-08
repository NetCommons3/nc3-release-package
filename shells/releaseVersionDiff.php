<?php
/**
 * これは、githubの前回リリースした(releaseタグ)から変更があったプラグインを抽出するプログラムである。
 *
 * ### Usage
 *
 * php releaseVersionDiff.php \
 *      (前回リリースしたcomposer.lockファイル) \
 *      (最新のcomposer.lockファイル) \
 *      (フォーマット:space,csv,tab,plugin) \
 *      (除外するプラグイン:カンマ区切り)
 *
 * ### Argument
 *
 * - 前回リリースしたcomposer.lockファイル
 * - 最新のcomposer.lockファイル
 * - フォーマット:space,csv,tab,plugin
 *      - space・・・`(パッケージ名)+「:」+「バージョン」`をスペースで区切って返す。
 *        e.g) netcommons/blocks:3.3.5.1
 *      - csv・・・カンマ区切りで返す
 *      - tab・・・タブ区切りで返す
 *      - plugin・・・プラグイン名をスペース区切りで返す
 * - 除外するプラグイン:カンマ区切り
 */

/**
 * 引数チェック
 */
if (empty($argv) || count($argv) < 4) {
    error(
        '引数が足りません。',
        [
            '[Usage]',
            'php releaseVersionDiff.php' .
                ' (前回リリースしたcomposer.lockファイル)' .
                ' (最新のcomposer.lockファイル)' .
                ' (フォーマット:space,csv,tab,plugin)' .
                ' (除外するプラグイン:カンマ区切り)',
        ]
    );
}

$oldComposerLock = $argv[1];
$newComposerLock = $argv[2];
$format = $argv[3];
$exnorePluigns = explode(',', ($argv[4] ?? ''));

$oldPackages = readComposerLock($oldComposerLock);
$newPackages = readComposerLock($newComposerLock);
$diffPackages = checkVersions($oldPackages, $newPackages, $exnorePluigns);
if (count($diffPackages) === 0) {
    exit(0);
}

$header = [
    'plugin',
    'name',
    'old_version',
    'old_reference',
    'new_version',
    'new_reference',
    'created',
];
switch ($format) {
    case 'csv':
        echo implode(',', $header) . PHP_EOL;
        break;
    case 'tab':
        echo implode("\t", $header) . PHP_EOL;
        break;
}

foreach ($diffPackages as $package) {
    switch ($format) {
        case 'csv':
            echo implode(',', $package) . PHP_EOL;
            break;
        case 'tab':
            echo implode("\t", $package) . PHP_EOL;
            break;
        case 'plugin':
            echo $package['plugin'] . ' ';
            break;
        default: //space
            echo $package['name'] . ':' . $package['new_version'] . ' ';
    }
}
echo PHP_EOL;

exit(0);

/////////////////////////////////////////////////////////////////

/**
 * エラーを出力する関数
 *
 * @param string $message
 * @param $options
 * @return void
 */
function error(string $message, $options = [])
{
    echo "[Error]\n[31m" . $message . "[0m\n\n";
    if ($options) {
        foreach ($options as $option) {
            echo $option . "\n";
        }
        echo "\n";
    }
    exit(1);
}

/**
 * composer.lockファイルを読みこむ
 *
 * @param string $filePath
 * @return array
 */
function readComposerLock(string $filePath)
{
    if (! file_exists($filePath)) {
        error(sprintf('ファイルが存在しません。[%s]', $filePath));
    }

    /** @var resource|false $handle */
    $handle = fopen($filePath, 'r');
    if (! $handle) {
        error(sprintf('ファイルが読み込めません。[%s]', $filePath));
    }
    $contents = fread($handle, filesize($filePath));
    $composerLock = json_decode($contents, true);
    fclose($handle);

    if (!$composerLock || !isset($composerLock['packages'])) {
        error(sprintf('composer lockファイルのフォーマットが正しくありません。[%s]', $filePath));
    }

    $packages = $composerLock['packages'];

    $result = [];
    foreach ($packages as $package) {
        if (!isset($package['source']['url']) || !isset($package['version'])) {
            continue;
        }

        $url = $package['source']['url'];
        $reg = "/(.*)(?:\.([^.]+$))/";
        preg_match($reg, basename($url), $retArr);
        $pluginName = $retArr[1];
        $version = $package['version'];
        if ($version === 'dev-master') {
            $version = 'master';
        }

        if (preg_match('/NetCommons3/', $url)) {
            $result[$pluginName] = [
                'name' => $package['name'],
                'version' => $version,
                'reference' => $package['source']['reference'] ?? null,
            ];
        }
    }

    return $result;
}

/**
 * バージョンのチェックを行う
 *
 * @param array $oldPackages
 * @param array $newPackages
 * @param array $exnorePluigns
 * @return array
 */
function checkVersions(array $oldPackages, array $newPackages, array $exnorePluigns)
{
    $result = [];

    foreach ($newPackages as $plugin => $package) {
        if (in_array($plugin, $exnorePluigns, true)) {
            continue;
        }
        if (!isset($oldPackages[$plugin])) {
            $result[$plugin] = [
                'plugin' => $plugin,
                'name' => $package['name'],
                'old_version' => null,
                'old_reference' => null,
                'new_version' => $package['version'],
                'new_reference' => $package['reference'],
                'created' => 'New',
            ];
        } elseif ($oldPackages[$plugin]['reference'] !== $package['reference']) {
            $result[$plugin] = [
                'plugin' => $plugin,
                'name' => $package['name'],
                'old_version' => $oldPackages[$plugin]['version'],
                'old_reference' => $oldPackages[$plugin]['reference'],
                'new_version' => $package['version'],
                'new_reference' => $package['reference'],
                'created' => 'Update',
            ];
        }
    }

    return $result;
}
