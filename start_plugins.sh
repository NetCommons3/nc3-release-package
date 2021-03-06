#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

PROFILEDIR=$(cd $(dirname $0); pwd)
source ${PROFILEDIR}/nc3profile

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
# バージョンアップ
################################

PLUGIN_NAME=`ls $MASTERDIR/app/Plugin`

revision=0
count=0

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

		surplus=$(( $count % 16 ))
		if [ "$surplus" = "0" ]; then
			# 初回と16件毎にDockerイメージを作り直す
			# Dockerイメージの作成
			execute "cd $CURDIR"
			execute "bash $CURDIR/shells/createDockerTag.sh $revision"
			execute "cd $CURDIR"
			revision=$(expr $revision + 1)
			# waiting 720秒
			waiting 72 10
		fi

		count=$(expr $count + 1)

		# 最新のプラグインを取得
		if [ -d $WORKDIR/$plugin ]; then
			execute "rm -Rf $WORKDIR/$plugin"
		fi
		execute "cd $WORKDIR"
		execute "git clone $GITAUTHURL/$plugin.git"
		execute "cd $CURDIR"

		# バージョンの変更
		execute "bash $CURDIR/shells/changeVersion.sh $plugin"
		execute "cd $CURDIR"

		if [ "$plugin" = "Questionnaires" -o "$plugin" = "Quizzes" -o "$plugin" = "Registrations" ]; then
			# waiting 960秒
			waiting 48 20
		else
			# waiting 250秒
			waiting 25 10
		fi

	esac
done

# waiting 100秒
waiting 10 10


################################
# リリースタグ付け
################################

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

		# リリースタグ付け
		execute "bash $CURDIR/shells/createReleaseTag.sh $plugin"
		execute "cd $CURDIR"
	esac
done

# waiting 100秒
waiting 15 10

# 最後にDockerイメージを作成する
execute "cd $CURDIR"
execute "bash $CURDIR/shells/createDockerTag.sh $revision"
execute "cd $CURDIR"

echo "##################################"
echo "# End Shell(`date '+%y-%m-%d %H:%M:%S'`)   #"
echo "##################################"
echo ""
#-- end --
