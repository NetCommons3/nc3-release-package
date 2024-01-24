#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

PROFILEDIR=$(cd $(dirname $(dirname $0)); pwd)
source ${PROFILEDIR}/nc3profile


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
echo " リリースタグ付け($plugin:$NC3VERSION)"
echo "+----------------------------------------+"

if [ ! -d $WORKDIR/$plugin ]; then
	execute "cd $WORKDIR"
	execute "git clone $GITAUTHURL/$plugin.git"
fi
execute "cd $WORKDIR/$plugin"

tagDescribe=$(git describe --tags)
curTag=${tagDescribe%%-*}
curVersion=${curTag%.*}
curRev=${curTag##*.}

echo "tagDescribe=$tagDescribe, curTag=$curTag, curVersion=$curVersion"
echo ""

if [ ! "$curTag" = "$tagDescribe" -o ! "$curVersion" = "$NC3VERSION" ]; then
	if [ "$curVersion" = "$NC3VERSION" ]; then
		nextRev=$(expr $curRev + 1)
	else
		nextRev=0
	fi
	execute "git tag $NC3VERSION.$nextRev"
	execute "git push origin $NC3VERSION.$nextRev" "prod"
else
	echo "No change."
fi

#-- end --
