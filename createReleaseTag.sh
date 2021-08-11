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
echo " リリースタグ付け($plugin:$NC3VERSION.0)"
echo "+----------------------------------------+"

if [ ! -d $WORKDIR/$plugin ]; then
	execute "cd $WORKDIR"
	execute "git clone $GITAUTHURL/$plugin.git"
fi
execute "cd $WORKDIR/$plugin"

execute "git tag $NC3VERSION.0"
execute "git push origin $NC3VERSION.0"

#-- end --
