#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

PROFILEDIR=$(cd $(dirname $0); pwd)
source ${PROFILEDIR}/nc3profile

if [ "${MODE}" = "" ]; then
	#MODE=prod; export MODE
	MODE=test; export MODE
fi

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
echo $NC3VERSION
echo $DOCKERVERSION
echo $OLDVER_CABINET_KEY
echo $OLDVERSION

execute "composer update"

echo ""
echo "################################"
echo "# バージョンアップ"
echo "################################"

PLUGIN_NAME=`ls $MASTERDIR/app/Plugin`
UPD_TAG_PLUGINS=""

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

		count=$(expr $count + 1)

		surplus=$(( $count % 16 ))
		if [ "$surplus" = "0" ]; then
			# 初回と16件毎にDockerイメージを作り直す
			# Dockerイメージの作成
			execute "cd $CURDIR"
			execute "bash -l $CURDIR/shells/createDockerTag.sh" "prod"
			execute "cd $CURDIR"
			revision=$(expr $revision + 1)
			# waiting 720秒
			waiting 3 10
		fi

		echo ""
		echo "*****************************************"
		echo " 対象プラグイン($plugin)"
		echo "*****************************************"

		# 最新のプラグインを取得
		if [ -d $WORKDIR/$plugin ]; then
			execute "rm -Rf $WORKDIR/$plugin"
		fi
		execute "cd $WORKDIR"
		execute "git clone $GITAUTHURL/$plugin.git"

		# 現バージョンの確認。更新する必要がなければ無視する
		execute "cd $WORKDIR/$plugin"

		tagDescribe=$(git describe --tags)
		curTag=${tagDescribe%%-*}
		curVersion=${curTag%.*}

		echo "tagDescribe=$tagDescribe, curTag=$curTag, curVersion=$curVersion"

		if [ "$curTag" = "$tagDescribe" -a "$curVersion" = "$NC3VERSION" ]; then
			count=$(expr $count - 1)
			echo ""
			echo "Skip $plugin"
			echo ""
			execute "cd $CURDIR"
			continue
		fi

		UPD_TAG_PLUGINS="$UPD_TAG_PLUGINS $plugin"

		# バージョンの変更
		execute "cd $CURDIR"
		execute "bash -l $CURDIR/shells/changeVersion.sh $plugin" "force"
		execute "cd $CURDIR"

		if [ "$plugin" = "Questionnaires" -o "$plugin" = "Quizzes" -o "$plugin" = "Registrations" ]; then
			# waiting 960秒
			waiting 48 20
		else
			# waiting 300秒
			waiting 30 10

			surplus=$(( $count % 5 ))
			if [ "$surplus" = "0" ]; then
				# waiting 30秒
				waiting 30 10
			fi
		fi
	esac
done

# waiting 100秒
waiting 10 10

echo "################################"
echo "# リリースタグ付け"
echo "################################"

UPD_TAG_PLUGINS="`echo $UPD_TAG_PLUGINS`"
for plugin in ${UPD_TAG_PLUGINS}
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
		execute "bash -l $CURDIR/shells/createReleaseTag.sh $plugin" "force"
		execute "cd $CURDIR"
	esac
done

# waiting 100秒
waiting 15 10

# 最後にDockerイメージを作成する
execute "cd $CURDIR"
execute "bash -l $CURDIR/shells/createDockerTag.sh" "prod"
execute "cd $CURDIR"

echo "##################################"
echo "# End Shell(`date '+%y-%m-%d %H:%M:%S'`)   #"
echo "##################################"
echo ""
#-- end --
