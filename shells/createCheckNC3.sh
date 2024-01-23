#!/bin/bash

####################################
# 環境変数（必要に応じで変更する）
####################################

PROFILEDIR=$(cd $(dirname $(dirname $0)); pwd)
source ${PROFILEDIR}/nc3profile

if [ ! -d $PKGDIR/$PROJECTNAME ]; then
	echo "$PKGDIR/$PROJECTNAMが存在しません。"
	exit 1
fi
if [ -d $CHKDIR-new ]; then
	execute "rm -Rf $CHKDIR-new"
fi


if [ -d $PKGDIR/NetCommons3-$OLDVERSION ]; then
	execute "rm -Rf $PKGDIR/NetCommons3-$OLDVERSION"
fi
if [ -d $PKGDIR/$OLDVERSION ]; then
	execute "rm -Rf $PKGDIR/$OLDVERSION"
fi
#if [ -f $OLDVERSION.zip ]; then
#	execute "rm -f $OLDVERSION.zip"
#fi


#######################################
# 動作確認サイトの構築
#######################################

echo ""
echo "+----------------------------------------+"
echo " 動作確認サイトの構築($NC3VERSION)"
echo "+----------------------------------------+"

execute "cp -Rpf $PKGDIR/$PROJECTNAME $CHKDIR-new"

execute "mysql -u${DBUSER} -p${DBPASS} -e \"drop database if exists ${DBNAME}_new;\"" "no-exec"
mysql -u${DBUSER} -p${DBPASS} -e "drop database if exists ${DBNAME}_new;"

echo ""
echo "+----------------------------------------+"
echo " 前バージョンの動作確認サイトの構築($OLDVERSION)"
echo "+----------------------------------------+"

execute "cd $PKGDIR"

if [ ! -f $OLDVERSION.zip ]; then
	execute "wget -q -O $OLDVERSION.zip https://www.netcommons.org/cabinets/cabinet_files/download/50/${OLDVER_CABINET_KEY}?frame_id=63"
fi

execute "unzip $OLDVERSION.zip -d $OLDVERSION" "no-exec"
unzip $OLDVERSION.zip -d $OLDVERSION > /dev/null
execute "rm -f $OLDVERSION.zip"

execute "mv $OLDVERSION/NetCommons3 ./NetCommons3-$OLDVERSION"

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
