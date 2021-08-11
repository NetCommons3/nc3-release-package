#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

. ./nc3profile

#######################################
# .githubディレクトリの追加
#######################################

plugin=$1
if [ "${plugin}" = "" ]; then
	echo "プラグインを指定してください。"
	exit 1
fi

echo ""
echo "+--------------------------------------------------+"
echo " .githubディレクトリの追加($plugin:$NC3VERSION)"
echo "    @see https://github.com/NetCommons3/NetCommons3/issues/1619"
echo "+--------------------------------------------------+"

if [ ! -d $WORKDIR/$plugin ]; then
	execute "cd $WORKDIR"
	execute "git clone $GITAUTHURL/$plugin.git"
fi
execute "cd $WORKDIR/$plugin"

if [ ! -d .github ]; then
	execute "cp -R $CURDIR/.github ./"
	execute "git add .github"

	execute "git commit -m\"add: releaseタグ付けのgithub actionを追加\"" "no-exec"
	git commit -m"add: releaseタグ付けのgithub actionを追加" -m"https://github.com/NetCommons3/NetCommons3/issues/1619"
	echo ""

	execute "git push"
else
	echo ".githbuディレクトリは存在しています。"
fi

#-- end --
