#!/bin/bash


####################################
# 環境変数（必要に応じで変更する）
####################################

. ./nc3profile

#######################################
# NetCommons3パッケージの作成
#######################################

echo ""
echo "+----------------------------------------+"
echo " NetCommons3パッケージの作成($NC3VERSION)"
echo "+----------------------------------------+"

execute "cd $PKGDIR"

if [ -d $PROJECTNAME ]; then
	execute "rm -Rf $PROJECTNAME"
fi
if [ -d $GITZIPFILE ]; then
	execute "rm -Rf $GITZIPFILE"
fi
if [ -f $NC3VERSION.zip ]; then
	execute "rm -f $NC3VERSION.zip"
fi

execute "wget $GITURL/$PROJECTNAME/archive/$NC3VERSION.zip"

if [ ! -f $NC3VERSION.zip ]; then
	echo "$NC3VERSION.zipファイルが存在しません"
	exit 1
fi

execute "unzip $NC3VERSION.zip"
execute "rm -f $NC3VERSION.zip"
execute "mv $GITZIPFILE $PROJECTNAME"

execute "cd $PROJECTNAME"
execute "${CMDCMPOSER} install --no-dev"
execute "rm -f app/tmp/logs/debug.log"
execute "rm -f app/tmp/cache/persistent/myapp_*"

execute "cd $PKGDIR"
execute "zip -r $ZIPFILE.zip $PROJECTNAME"


#-- end --
