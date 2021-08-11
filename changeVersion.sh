#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

. ./nc3profile

#######################################
# バージョンの変更
#######################################

plugin=$1
if [ "${plugin}" = "" ]; then
	echo "プラグインを指定してください。"
	exit 1
fi

echo ""
echo "+----------------------------------------+"
echo " バージョンの変更($plugin:$NC3VERSION)"
echo "+----------------------------------------+"

if [ ! -d $WORKDIR/$plugin ]; then
	execute "cd $WORKDIR"
	execute "git clone $GITAUTHURL/$plugin.git"
fi
execute "cd $WORKDIR/$plugin"

execute "echo \"$NC3VERSION\" > VERSION.txt" "no-exec"
echo "$NC3VERSION" > VERSION.txt
echo ""

execute "git add VERSION.txt"

execute "git commit -m\"change: Version number to $NC3VERSION\"" "no-exec"
git commit -m"change: Version number to $NC3VERSION"
echo ""

execute "git push"

#-- end --
