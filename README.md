# リリースパッケージを作成するシェル

## s-nakajima/MyShellへの追加方法

MyShell/composer.jsonに下記を追加
~~~~
"repositories": [
    {"type": "vcs", "url": "https://(Githubアカウント):(Githubパスワード)@github.com/s-nakajima/MyShell-nc3Release.git"}
],
~~~~

下記のコマンドを実行
~~~~
cd /var/www/MyShell
composer require s-nakajima/nc3-release:@dev
~~~~
