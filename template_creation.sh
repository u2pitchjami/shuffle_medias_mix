#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 2                                        #
#									                                         #
#	NOM: BEUGNET							                                 #
#									                                         #
#	PRENOM: Thierry							                                 #
#									                                         #
#	DATE: 01/07/2024	           				                             #
#									                                         #
#	BUT: création de template pour shuffle                       		     #
#									                                         #
############################################################################## 

source ./.config.cfg
	if [ ! -d $DOSLOG ]; then
		mkdir $DOSLOG
	fi

touch "${LOGS}"

creation() {
echo -e "${SAISPAS}${BOLD}[`date`] - Création d'un nouveau Template ${NC}" | tee -a "${LOGS}"
REPONSE=1
n=0
echo "nom du nouveau template (sans espace)"
read NOM
touch "${DOSSIERTEMPLATE}/${NOM}"
echo
echo -e "[`date`] - ${BOLD}Template "$NOM" créé ${NC}" | tee -a "${LOGS}"
echo | tee -a "${LOGS}"
until [ $REPONSE -eq 0 ]
do
    m=1
    for DOSS in "${BASE}"*
    do
        DOSS1=$(echo $DOSS | rev | cut -d"/" -f1 | rev | cut -d"-" -f2)
        DOSS4STATS=$(echo $DOSS | rev | cut -d"/" -f1 | rev | cut -d"-" -f1,2)
        NBFILES=$(grep -e "^${DOSS4STATS}" ${STATSSCENES}general.csv | cut -d ";" -f2)
        NBDOSS=$(grep -e "^${DOSS4STATS}" ${STATSSCENES}general.csv | cut -d ";" -f5)
        DUREEORI=$(grep -e "^${DOSS4STATS}" ${STATSSCENES}general.csv | cut -d ";" -f3)
        DUREEORIMIN=$(expr $DUREEORI / 60 )
		DUREEMOYORI=$(grep -e "^${DOSS4STATS}" ${STATSSCENES}general.csv | cut -d ";" -f4) 
        echo -e ""$m") ${BOLD}$DOSS1${NC} - $NBDOSS dossiers $NBFILES fichiers - $DUREEORIMIN minutes - $DUREEMOYORI secs en moyenne"
        declare BAS${m}=$DOSS
        declare NOM${m}=$DOSS1
        m=$(expr $m + 1 )
    done
    echo "0)Quitter"
	read REPONSE
	REPONSEDOSS=$(echo BAS$REPONSE)
	REPONSEDOSS="${!REPONSEDOSS}"
    NOMDOSS=$(echo NOM$REPONSE)
	NOMDOSS="${!NOMDOSS}"
    if [ $REPONSE -ne 0 ]
        then
        n=$(expr $n + 1 )
        NBCAR=$(echo $n | wc -m)
        if [ $NBCAR = 2 ]
            then
            E="00$n"
        elif [ $NBCAR = 3 ]
            then
            E="0$n"
        else
            E="$n"
        fi
        echo "choisis le min et le max de videos sous la forme 1-2"
        read SELECTION
        echo "${E};${REPONSEDOSS};${SELECTION}" >> ${DOSSIERTEMPLATE}/${NOM}
        
        echo "[`date`] - Création de la scène : ${E}-${NOMDOSS}-${SELECTION}" | tee -a "${LOGS}"
    fi
done
menu
}
modification() {
menu     
}
copier() {
REPONSE=1
n=0
echo -e "${SAISPAS}${BOLD}Quel template souhaites tu copier ?${NC}"
    until [ $REPONSE -eq 0 ]
    do
        m=1
        for DOSS in "${DOSSIERTEMPLATE}"*
        do
            DOSS1=$(echo $DOSS) 
            echo ""$m") $DOSS1"
            declare BAS${m}=$DOSS
            declare NOM${m}=$DOSS1
            m=$(expr $m + 1 )
        done
        echo "0)Quitter"
        read REPONSE
        REPONSEDOSS=$(echo BAS$REPONSE)
        REPONSEDOSS="${!REPONSEDOSS}"
        NOMDOSS=$(echo NOM$REPONSE)
        NOMDOSS="${!NOMDOSS}"
        if [ $REPONSE -ne 0 ]
            then
            echo "[`date`] - Demande de copie du template : $NOMDOSS" | tee -a "${LOGS}"
            echo
            echo -e "${BOLD}Sous quel nom souhaites tu copier ce template ?${NC}"
            read SELECTION
            
            touch "${DOSSIERTEMPLATE}/${SELECTION}"
            
            echo "[`date`] - Template copié sous le nom ${SELECTION}" | tee -a "${LOGS}"
        fi
    done
menu    
}
supprimer() {
REPONSE=1
n=0
echo -e "${SAISPAS}${BOLD}Quel template souhaites tu supprimer ?${NC}"
    until [ $REPONSE -eq 0 ]
    do
    m=1
        for DOSS in "${DOSSIERTEMPLATE}"*
        do
        DOSS1=$(echo $DOSS) 
        echo ""$m") $DOSS1"
        declare BAS${m}=$DOSS
        declare NOM${m}=$DOSS1
        m=$(expr $m + 1 )
        done
            echo "0)Quitter"
            read REPONSE
            REPONSEDOSS=$(echo BAS$REPONSE)
            REPONSEDOSS="${!REPONSEDOSS}"
            NOMDOSS=$(echo NOM$REPONSE)
            NOMDOSS="${!NOMDOSS}"
                if [ $REPONSE -ne 0 ]
                then
                echo "[`date`] - Demande de suppression du template : ${NOMDOSS}" | tee -a "${LOGS}"
                echo
                echo -e "${BOLD}tu confirmes ? le template sera complètement supprimé (y ou n)${NC}"
                read SELECTION
                    if [ $SELECTION == "y" ]
                    then
                    rm -r ${NOMDOSS}
                    echo "[`date`] - opération confirmée par l'utilisateur, template supprimé" | tee -a "${LOGS}"
                    else
                    echo "[`date`] - opération annulée" | tee -a "${LOGS}"
                    fi
                fi
    done
menu  
}
visu() {
   menu  
}
menu() {

echo -e "${SAISPAS}${BOLD}Que souhaites tu faire ?${NC}"
echo "1) - Créer un template"
echo "2) - Modifier un template"
echo "3) - Copier un template"
echo "4) - Supprimer un template"
echo "5) - Visualiser un template"
echo "6) - Quitter"
read MENU

case $MENU in

1)
    creation
    ;;
2)
    modification
    ;;
3)
    copier
    ;;
4)
    supprimer
    ;;
5)
    visu
    ;;
6)
    quitter
    ;;
esac
}

quitter() {
echo "c'est fini bisous" | tee -a "${LOGS}"
}

menu