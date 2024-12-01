#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 1	                                     #
#									                                         #
#	NOM: u2pitchjami						                                 #
#									                                         #
#							  					                             #
#									                                         #
#	DATE: 25/15/2024	           				                             #
#									                                         #
#	BUT: Script de qui replace les fichiers dans atrier pour regroup         #
#									                                         #
############################################################################## 
source ./.config.cfg
#set -e
if [ ! -f $RECAP ];	then
	touch $RECAP
	echo "id;nom;scene;control;date;last_change;nbexport" >> $RECAP
fi
if [ ! -d $DOSLOG ]; then
	mkdir $DOSLOG
fi

echo | tee -a "${LOG}"
echo -e "Sauvegarde des stats..." | tee -a "${LOG}"
tar -czf ${DIRSAV_STATS}${BACKUP_STATS}.tar.gz ${STATS}
echo -e "Sauvegarde compressée: \e[32m${BACKUP_STATS}.tar.gz\e[0m\n" | tee -a "${LOG}"
echo -e "sauvegarde réalisée" | tee -a "${LOG}"
REPONSE=1
until [ $REPONSE -eq 0 ]
do
    m=1
    for DOSS in "${BASE}"*
    do
        DOSS1=$(echo $DOSS | rev | cut -d"/" -f1 | rev | cut -d"-" -f2)
        DOSS4STATS=$(echo $DOSS | rev | cut -d"/" -f1 | rev | cut -d"-" -f1,2)
        NBFILES=$(grep -e "^${DOSS4STATS}" ${STATSSCENES}general.csv | cut -d ";" -f2)
        NBDOSS=$(grep -e "^${DOSS4STATS}" ${STATSSCENES}general.csv | cut -d ";" -f5)
        
        echo -e ""$m") ${BOLD}$DOSS1${NC} - $NBDOSS dossiers $NBFILES fichiers"
        declare BAS${m}=$DOSS
        declare NOM${m}=$DOSS1
        m=$(expr $m + 1 )
    done
    echo "Z)All"
    echo "0)Quitter"
	read REPONSE
	REPONSEDOSS=$(echo BAS$REPONSE)
	REPONSEDOSS="${!REPONSEDOSS}"
    NOMDOSS=$(echo NOM$REPONSE)
	NOMDOSS="${!NOMDOSS}"

    if [[ $REPONSE == "Z" ]]; then
        for DOSSS in "${BASE}"*
        do
        echo "[`date`] - Reset total enclenché" | tee -a "${LOGS}"
        DOSSATRIER=$(find "${DOSSS}" -maxdepth 1 -type d -iname "${DOSSORT}")
        find "${DOSSS}" -iname "${DOSSORT}" -prune -o -type f -print -exec mv -v {} "${DOSSATRIER}" \;
        
        echo "[`date`] - Reset ${DOSSS} OK" | tee -a "${LOGS}"
        NBDOSSVIDES=$(find "${DOSSS}" -name "${DOSSORT}" -prune -o -type d -empty -print | wc -l)
            if [ $NBDOSSVIDES -ge "1" ]; then
                echo "Suppression de $NBDOSSVIDES dossiers vides" | tee -a "${LOGREG}"
                find "${DOSSS}" -name "${DOSSORT}" -prune -o -type d -empty -print -exec rmdir {} \; 2> /dev/null
                
            fi    
        sleep 2
        echo
        done
    elif [ $REPONSE -ne 0 ]; then
        echo "[`date`] - Reset du dossier ${NOMDOSS} enclenché" | tee -a "${LOGS}"
        DOSSSCENE=$(find "${BASE}" -maxdepth 1 -type d -iname "*${NOMDOSS}*")
        DOSSATRIER=$(find "${DOSSSCENE}" -maxdepth 1 -type d -iname "${DOSSORT}")
        find "${DOSSSCENE}" -iname "${DOSSORT}" -prune -o -type f -print -exec mv -v {} "${DOSSATRIER}" \;
        
        echo "[`date`] - Reset ${NOMDOSS} OK" | tee -a "${LOGS}"
        NBDOSSVIDES=$(find "${DOSSSCENE}" -name "${DOSSORT}" -prune -o -type d -empty -print | wc -l)
            if [ $NBDOSSVIDES -ge "1" ]
                then
                echo "Suppression de $NBDOSSVIDES dossiers vides" | tee -a "${LOGREG}"
                find "${DOSSSCENE}" -name "${DOSSORT}" -prune -o -type d -empty -print -exec rmdir {} \; 2> /dev/null
                
            fi    
        sleep 2
        echo
    fi
done
echo
echo "C'est fini bisous" | tee -a "${LOGS}"