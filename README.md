# リリースパッケージを作成するシェル

## 手順

### 1. 全プラグインのテストを実行し、エラーになっていないか確認(任意)

下記を参考。

[https://github.com/NetCommons3/nc3app-docker#ローカルで全プラグインのテストを実行する](https://github.com/NetCommons3/nc3app-docker#%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%AB%E3%81%A7%E5%85%A8%E3%83%97%E3%83%A9%E3%82%B0%E3%82%A4%E3%83%B3%E3%81%AE%E3%83%86%E3%82%B9%E3%83%88%E3%82%92%E5%AE%9F%E8%A1%8C%E3%81%99%E3%82%8B)



### 2. 設定ファイル(nc3profile)を修正


````
 9   NC3VERSION="3.3.4" export NC3VERSION
10   OLDVERSION="3.3.3" export OLDVERSION
11   DOCKERVERSION="1.0" export DOCKERVERSION
12
13   GITAUTH="(Github ID):(Github PW)"
・・・
29
30   CHKDIR=/var/www/NetCommons3/release_check/$PKGNAME; export CHKDIR
31
````

※(Github PW)は、githubのアクセストークンを使用してください。<br>
　githubのアクセストークンは[Personal Access Tokens](https://github.com/settings/tokens)のページから生成することができます。


### 3. 各プラグインにリリースタグを付ける(6時間程度かかる)

````
cd nc3-release-package
bash start_plugins.sh
````


### 4. 本体にリリースタグを付ける

※これを実行すると先生にもGithubから通知がいくため、速やかに5以降を行う

````
cd nc3-release-package
bash start_app.sh
````

#### ※手動でnc3app-dockerのバージョンをアップする

https://github.com/NetCommons3/nc3app-docker

### 5. SeleniumIDEでブラウザテストを行う

#### 5-1) 動作確認用の環境を構築する

````
cd nc3-release-package
bash shells/createCheckNC3.sh
````

#### 5-2) nc3ReleaseCheck.sideをSeleniumIDEで起動する

SeleniumIDEは、ChromeやFirefoxのアドオンでインストールできます。<br>
<br>
<a href="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-1.png">
<img src="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-1.png" width="320px">
</a><br>

#### 5-3) SeleniumIDEの「00.環境変数」を適宜修正する

<a href="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-2.png">
<img src="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-2.png" width="320px">
</a><br>

#### 5-4) SeleniumIDEのTest suites「01-新規インストール」を実行する

<a href="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-3.png">
<img src="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-3.png" width="320px">
</a><br>

※テスト中、Wysiwygのテストで画像を挿入するステップがあります。(下記の画像の参照)<br>
画像挿入は、自動ではできないため、手動で画像を選択してください。<br>

<a href="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-4.png">
<img src="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-4.png" width="320px">
</a><br>

#### 5-5) SeleniumIDEのTest suites「02-前verインストール」を実行する

<a href="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-5.png">
<img src="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-5.png" width="320px">
</a><br>

※5-4)同様に、テスト中、Wysiwygのテストで画像を挿入するステップがあります。
画像挿入は、手動で画像を選択してください。<br>

#### 5-6) 新verのパッケージを前verの動作確認環境にコピーする

````
cd nc3-release-package
bash shells/updateCheckNC3.sh
````

#### 5-7) SeleniumIDEのTest suites「03-前verからアップグレード」を実行する

<a href="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-6.png">
<img src="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/SeleniumIDE-6.png" width="320px">
</a><br>

※5-4)同様に、テスト中、Wysiwygのテストで画像を挿入するステップがあります。
画像挿入は、手動で画像を選択してください。<br>


### 6. Githubの完了ラベルにリリースラベルを付与し、closeする

#### 6-1) リリースラベルを作成する

<a href="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/github-1.png">
<img src="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/github-1.png" width="320px">
</a><br>

#### 6-2) リリースラベルを付与する

<a href="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/github-2.png">
<img src="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/github-2.png" width="320px">
</a><br>


#### 6-3) 完了ラベルをcloseする

<a href="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/github-3.png">
<img src="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/github-3.png" width="320px">
</a><br>


### 7. NC3公式サイトにパッケージをアップロードし、お知らせに投稿する

#### 7-1) nc3-release-package/packageディレクトリにあるNetCommons-3.x.x.zipファイルをキャビネットに上げる

https://www.netcommons.org/NetCommons3/download#!#frame-63

<a href="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/nc3-org-1.png">
<img src="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/nc3-org-1.png" width="320px">
</a><br>


#### 7-2) ダウンロードページのお知らせを修正する

https://www.netcommons.org/NetCommons3/download#!#frame-82

<a href="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/nc3-org-2.png">
<img src="https://raw.githubusercontent.com/NetCommons3/nc3-release-package/main/img/nc3-org-2.png" width="320px">
</a><br>


#### 7-3) ニュースに投稿する

https://www.netcommons.org/news

※記事の内容は、過去記事を参照


#### 7-4) 各ページのリンクを確認する
