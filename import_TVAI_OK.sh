#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 1                                      #
#									                                         #
#	NOM: BEUGNET							                                 #
#									                                         #
#	PRENOM: Thierry							                                 #
#									                                         #
#	DATE: 14/11/2024	           				                             #
#									                                         #
#	BUT:                  		     #
#									                                         #
############################################################################## 
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source ${SCRIPT_DIR}/.config.cfg

LOG=${DOSLOG}/${DATE}-import_TVAI_OK.txt
if [ ! -d $DOSLOG ]
	then
	mkdir $DOSLOG
fi
touch "$LOG"

echo -e "[`date`] - Vérification de la présence de fichiers dans le dossier TVAI_OK" | tee -a "${LOG}"
NBFILESATRIERGEN=$(find "${DOSSIER_MOUNT}" -type f | wc -l)
if [[ "$NBFILESATRIERGEN" -gt "0" ]]; then
    echo -e "${NBFILESATRIERGEN} fichier(s) à trier" | tee -a "${LOG}"
    for FILEATRIERGEN in "${DOSSIER_MOUNT}"*
    do
        
        NOMFILEATRIERGEN=$(echo "$FILEATRIERGEN" | rev | cut -d"/" -f1 | rev)
        #TAILLE1=$(du -s "$FILEATRIERGEN" | cut -d "/" -f1)
        #echo "$TAILLE1"
        #sleep 20
        #TAILLE2=$(du -s "$FILEATRIERGEN" | cut -d "/" -f1)
       # echo "$TAILLE2"
        #if [[ "$TAILLE1" = "$TAILLE2" ]]; then
            mv "${FILEATRIERGEN}" "${DOSSIER_ATRIER}/${NOMFILEATRIERGEN}" #2> /dev/null
            
            if [[ $? -eq "0" ]]; then
            echo -e "${NOMFILEATRIERGEN} déplacé" | tee -a "${LOG}"
            else
            rm "${DOSSIER_ATRIER}/${NOMFILEATRIERGEN}"
            echo -e "${NOMFILEATRIERGEN} en cours d'utilisation \n au suivant..." | tee -a "${LOG}"
            fi
        #while [ -n "$(lsof "$FILEATRIERGEN")" ]
        #do
         #   sleep 120
       # done
        #else
         #   echo -e "${NOMFILEATRIERGEN} en cours d'utilisation \n au suivant..." | tee -a "${LOG}"

       # fi
    done
    echo -e "Tri terminé !!" | tee -a "${LOG}"
    echo
else
    echo -e "Aucun fichier à trier \n Passons à la suite... " | tee -a "${LOG}"
    echo
fi