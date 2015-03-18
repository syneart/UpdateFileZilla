#!/bin/bash
clear
echo "Info: 更新檔案資料庫 以及 覆蓋檔案需要權限, 請先輸入密碼 .."
sudo -v
if [ $? -eq 1 ]; then
	clear
	echo "Error: 未輸入正確密碼, 無法繼續執行"
	sleep 3
	exit 0
fi
clear
echo "Info: 正在更新檔案資料庫, 請稍後 .."
sudo updatedb
PATH_FILEZILLA=`whereis filezilla | sed -e "s/.*:[ ]*//g;s/\/bin\/filezilla//g"`
if [ -z $PATH_FILEZILLA ]; then
	clear
	echo "Error: 找不到您的 FileZilla 目錄, 無法繼續"
	sleep 3
	exit 0
fi
echo "Info: 正在檢查最新版本版號 .."
FIND_STRING="<p>The latest stable version of FileZilla Client is "
VERSION_FILEZILLA=`curl -s "https://filezilla-project.org/download.php?type=client" | grep "${FIND_STRING}" | sed -e "s/${FIND_STRING}//g;s/<\/p>//g"`
if [ -z $VERSION_FILEZILLA ]; then
	clear
	echo "Error: 無法取得 FileZilla 版本, 請再試一次"
	sleep 3
	exit 0
fi
echo "Info: 正在下載 ${VERSION_FILEZILLA} 版本 .."
wget -m -P /tmp http://jaist.dl.sourceforge.net/project/filezilla/FileZilla_Client/${VERSION_FILEZILLA}/FileZilla_${VERSION_FILEZILLA}_i586-linux-gnu.tar.bz2
FILENAME_FILEZILLA="FileZilla_${VERSION_FILEZILLA}_i586-linux-gnu.tar.bz2"
if [ !-f /tmp/${FILENAME_FILEZILLA} ]; then 
	clear
	echo "Error: 無法取得 FileZilla 檔案, 請再試一次"
	sleep 3
	exit 0
fi
clear
echo "Info: 已下載 ${FILENAME_FILEZILLA} 檔案至 .. /tmp"
echo "Info: 正在刪除 ${PATH_FILEZILLA} 資料夾與覆蓋檔案 .."
sudo rm -r $PATH_FILEZILLA/bin $PATH_FILEZILLA/share
if [ -z `echo "$PATH_FILEZILLA" | cut -f3 -d"/"` ]; then
	sudo tar -C $PATH_FILEZILLA -jxvf /tmp/${FILENAME_FILEZILLA}
else
	sudo tar -C `echo $PATH_FILEZILLA | sed -e "s/\/FileZilla[1-9]*//g"` -jxvf /tmp/${FILENAME_FILEZILLA}
fi
echo "Info: 完成！！"
sleep 3
