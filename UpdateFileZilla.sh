#!/bin/bash
NEED_INSTALL=false # if not need install

while [ -n "$1" ]; do  
case $1 in
	-NEW_INSTALL) NEED_INSTALL=true; break;;
	-*) clear; echo "Error: 無此參數, 無法繼續執行"; exit 0;
esac
done
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

if ${NEED_INSTALL}; then
	if [ -z ${PATH_FILEZILLA} ]; then
		echo "Info: 自動指定預設安裝位置： /opt/FileZilla*/ .."
		PATH_FILEZILLA="/opt"
	else
		while ${BOOL_NEED_RESPONSE}
			do
				BOOL_NEED_RESPONSE=false
				read -r -p "Info: 偵測到您的系統已安裝 FileZilla, 是否直接更新就好 [yes/no] ? " response
				clear
				case $response in 
					[yY][eE][sS]|[yY]) 
					;;
					[nN][oO]|[nN])
						echo "Info: 自動指定預設安裝位置： /opt/FileZilla*/ .."
						PATH_FILEZILLA="/opt"
					;;
					*)  BOOL_NEED_RESPONSE=true
				esac
			done
	fi
else
	if [ -z ${PATH_FILEZILLA} ]; then
		echo "Error: 找不到您的 FileZilla 目錄, 無法繼續"
		sleep 3
		exit 0
	fi
fi

echo "Info: 正在檢查最新版本版號 .."
FIND_STRING="<p>The latest stable version of FileZilla Client is "
VERSION_FILEZILLA=`curl -s "https://filezilla-project.org/download.php?type=client" | grep "${FIND_STRING}" | sed -e "s/${FIND_STRING}//g;s/<\/p>//g"`
if [ -z ${VERSION_FILEZILLA} ]; then
	clear
	echo "Error: 無法取得 FileZilla 版本, 請再試一次"
	sleep 3
	exit 0
fi
echo "Info: 正在下載 ${VERSION_FILEZILLA} 版本 .."
wget -N -P /tmp http://jaist.dl.sourceforge.net/project/filezilla/FileZilla_Client/${VERSION_FILEZILLA}/FileZilla_${VERSION_FILEZILLA}_i586-linux-gnu.tar.bz2
FILENAME_FILEZILLA="FileZilla_${VERSION_FILEZILLA}_i586-linux-gnu.tar.bz2"
if [ ! -f /tmp/${FILENAME_FILEZILLA} ]; then 
	clear
	echo "Error: 無法取得 FileZilla 檔案, 請再試一次"
	sleep 3
	exit 0
fi
clear
echo "Info: 已下載 ${FILENAME_FILEZILLA} 檔案至 .. /tmp"

if [ "${NEED_INSTALL}" == "false" ]; then
	echo "Info: 正在刪除 ${PATH_FILEZILLA} 資料夾 /bin 、/share 與覆蓋檔案 .."
	sudo rm -r ${PATH_FILEZILLA}/bin ${PATH_FILEZILLA}/share
fi

if [ -z `echo "$PATH_FILEZILLA" | cut -f3 -d"/"` ]; then
	sudo tar -C ${PATH_FILEZILLA} -jxvf /tmp/${FILENAME_FILEZILLA}
else
	sudo tar -C `echo ${PATH_FILEZILLA} | sed -e "s/\/FileZilla[1-9]*//g"` -jxvf /tmp/${FILENAME_FILEZILLA}
fi

echo "Info: FileZilla 建置完成！！"
sleep 3
