#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

PROFILEDIR=$(cd $(dirname $(dirname $0)); pwd)
source ${PROFILEDIR}/nc3profile


#######################################
# 動作確認サイトの構築
#######################################

echo ""
echo "+----------------------------------------+"
echo " 動作確認サイトの構築($NC3VERSION)"
echo "+----------------------------------------+"

if [ ! -d $PKGDIR/$PROJECTNAME ]; then
	echo "$PKGDIR/$PROJECTNAMが存在しません。"
	exit 1
fi
if [ -d $CHKDIR-new ]; then
	execute "rm -Rf $CHKDIR-new"
fi

execute "cp -Rpf $PKGDIR/$PROJECTNAME $CHKDIR-new"

execute "mysql -u${DBUSER} -p${DBPASS} -e \"drop database if exists ${DBNAME}_new;\"" "no-exec"
mysql -u${DBUSER} -p${DBPASS} -e "drop database if exists ${DBNAME}_new;"


echo ""
echo "+----------------------------------------+"
echo " 前バージョンの動作確認サイトの構築($OLDVERSION)"
echo "+----------------------------------------+"

execute "cd $PKGDIR"

if [ -d NetCommons3-$OLDVERSION ]; then
	execute "rm -Rf NetCommons3-$OLDVERSION"
fi
if [ -f $OLDVERSION.zip ]; then
	execute "rm -f $OLDVERSION.zip"
fi

execute "wget $GITURL/$PROJECTNAME/archive/$OLDVERSION.zip"

execute "unzip $OLDVERSION.zip"
execute "rm -f $OLDVERSION.zip"

execute "cd NetCommons3-$OLDVERSION"
execute "${CMDCMPOSER} install --no-dev"
execute "rm -f app/tmp/logs/debug.log"
execute "rm -f app/tmp/cache/persistent/myapp_*"

if [ -d $CHKDIR-upd ]; then
	execute "rm -Rf $CHKDIR-upd"
fi

execute "cp -Rpf $PKGDIR/NetCommons3-$OLDVERSION $CHKDIR-upd"

execute "mysql -u${DBUSER} -p${DBPASS} -e \"drop database if exists ${DBNAME}_upd;\"" "no-exec"
mysql -u${DBUSER} -p${DBPASS} -e "drop database if exists ${DBNAME}_upd;"

#-- end --
