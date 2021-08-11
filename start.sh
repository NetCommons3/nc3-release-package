#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

. ./nc3profile

#######################################
# 既にあるディレクトリ・ファイルの削除
#######################################

echo ""
echo "##################################"
echo "# Start Shell(`date '+%y-%m-%d %H:%M:%S'`) #"
echo "##################################"
echo ""

execute "cd $CURDIR"

if [ ! -d $WORKDIR ]; then
	execute "mkdir $WORKDIR"
fi

if [ ! -d $PKGDIR ]; then
	execute "mkdir $PKGDIR"
fi

################################
# githubから最新のソースを取得
################################

if [ -d $MASTERDIR ]; then
	execute "rm -Rf $MASTERDIR"
fi

if [ ! -d $MASTERDIR ]; then
	execute "git clone $GITAUTHURL/$PROJECTNAME"
fi
execute "cd $PROJECTNAME"

execute "composer update"


################################
# リリースタグ付け作業
################################

PLUGIN_NAME=`ls $MASTERDIR/app/Plugin`

for plugin in ${PLUGIN_NAME}
do
	case "${plugin}" in
		"empty" ) continue ;;
		"BoostCake" ) continue ;;
		"DebugKit" ) continue ;;
		"HtmlPurifier" ) continue ;;
		"nbproject" ) continue ;;
		"Migrations" ) continue ;;
		"MobileDetect" ) continue ;;
		"Sandbox" ) continue ;;
		"TinyMCE" ) continue ;;
		"Upload" ) continue ;;
		* )

		# 最新のプラグインを取得
		if [ -d $WORKDIR/$plugin ]; then
			execute "rm -Rf $WORKDIR/$plugin"
		fi
		execute "cd $WORKDIR"
		execute "git clone $GITAUTHURL/$plugin.git"
		execute "cd $CURDIR"

		# バージョンの変更
		execute "bash $CURDIR/changeVersion.sh $plugin"
		execute "cd $CURDIR"

		# リリースタグ付け
		execute "bash $CURDIR/createReleaseTag.sh $plugin"
		execute "cd $CURDIR"
	esac
done

for ((i=0; i<10; i++)); do
	echo -n "."
	sleep 10
done
echo ""
echo ""

# .githubディレクトリの追加
execute "bash $CURDIR/addGithubAction.sh NetCommons3"
execute "cd $CURDIR"

# composer.lockファイルを作り直す
execute "bash $CURDIR/createComposerLock.sh"
execute "cd $CURDIR"

for ((i=0; i<10; i++)); do
	echo -n "."
	sleep 10
done
echo ""
echo ""

# NetCommons3パッケージの作成
execute "bash $CURDIR/createNC3Package.sh"
execute "cd $CURDIR"

for ((i=0; i<10; i++)); do
	echo -n "."
	sleep 10
done
echo ""
echo ""

# 動作確認サイトの構築
execute "bash $CURDIR/createCheckNC3.sh"
execute "cd $CURDIR"


echo "##################################"
echo "# End Shell(`date '+%y-%m-%d %H:%M:%S'`)   #"
echo "##################################"
echo ""
#-- end --
