#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 1.3	                                     #
#									                                         #
#	NOM: u2pitchjami						                                 #
#									                                         #
#							  					                             #
#									                                         #
#	DATE: 24/10/2024	           				                             #
#									                                         #
#	BUT: Contrôle intégrité des fichiers + durée                 		     #
#									                                         #
############################################################################## 
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source ${SCRIPT_DIR}/.config.cfg
###########################CONTROLE DOSSIERS##################################
#contrôle la présence d'un dossier Stats sinon création
if [ ! -d $STATS ]
	then
	mkdir $STATS
fi
#contrôle la présence d'un dossier Logs sinon création
if [ ! -d $DOSLOG ]
	then
	mkdir $DOSLOG
fi
#contrôle la présence d'un dossier TEMP sinon suppression puis création
if [ -d ${SCRIPT_DIR}/TEMP ]
	then
	rm -r ${SCRIPT_DIR}/TEMP
fi
mkdir ${SCRIPT_DIR}/TEMP
rm ${STATSSCENES}filtre*
echo | tee -a "${LOGSCHECK}"
echo -e "${TITRE}Sauvegarde des stats...${NC}" | tee -a "${LOGSCHECK}"
tar -czf ${DIRSAV_STATS}${BACKUP_STATS}.tar.gz ${STATS}
echo -e "Sauvegarde compressée: \e[32m${BACKUP_STATS}.tar.gz\e[0m\n" | tee -a "${LOGSCHECK}"
echo -e "${GREEN}sauvegarde réalisée${NC}" | tee -a "${LOGSCHECK}"
#############################################################################
##########################CONTROLE SI OPTION "COMPLET" ACTIVE################
if [ ! -z $1 ]
	then
	OPTION=$(echo $1 | tr '[:upper:]' '[:lower:]')
	if [ $OPTION == "complet" ]
		then
		echo -e "${BIGTITRE}[`date`] - Mode Complet activé${NC}" | tee -a "${LOGSCHECK}"
        rm "$STATSSCENES"*
        echo -e "${BOLD}${PURPLE}[`date`] - Suppression des fichiers stats scenes${NC}" | tee -a "${LOGSCHECK}"
	elif [ $OPTION == "stats" ]
        then
        echo -e "${BIGTITRE}[`date`] - Mode Stats activé${NC}" | tee -a "${LOGSCHECK}"
        rm "$STATSSCENES"*
        echo -e "${BOLD}[`date`] - Réinitialisation des stats sans contrôle des fichiers{NC}" | tee -a "${LOGSCHECK}"
    else
		echo "variable inconnue, mode normal activé"
		OPTION="normal"
	fi
else
OPTION="normal"
fi
#############################################################################
##########################CONTROLE SCENES####################################
for SCENES in "${BASE}"*
	do 
    NOMSCENE=$(echo $SCENES | rev | cut -d "/" -f1 | rev )
    XY=0
    echo -e "${BIGTITRE}[`date`] - $NOMSCENE${NC}" | tee -a "${LOGSCHECK}"
    if [[ -f ${STATSSCENES}${NOMSCENE}.csv ]]
        then
        ##########################CONTROLE FICHIERS MODIFIES
        echo -e "${BOLD}${TITRE}Contrôle la présence de fichiers nouveaux ou modifiés ${NC}" | tee -a "${LOGSCHECK}"
        cat "${STATSSCENES}${NOMSCENE}.csv" | rev | cut -d";" -f2 | rev | sort -d >> ${SCRIPT_DIR}/TEMP/${NOMSCENE}1
        sed -i "/^fps/d" ${SCRIPT_DIR}/TEMP/${NOMSCENE}1
        sed -i "/^path/d" ${SCRIPT_DIR}/TEMP/${NOMSCENE}1
        find "${SCENES}"/* -path $DOSSORT -prune -o -type f -iname "*.mp4" -print | sort -d >> ${SCRIPT_DIR}/TEMP/${NOMSCENE}2
        SCENEMODIF=$(diff -biw ${SCRIPT_DIR}/TEMP/${NOMSCENE}1 ${SCRIPT_DIR}/TEMP/${NOMSCENE}2 | grep '^<\|>' | wc -l)
        if [[ $SCENEMODIF -ge "1" ]]
            then
            echo -e "${BOLD}$SCENEMODIF fichiers modifiés ${NC}" | tee -a "${LOGSCHECK}"
            NBSORTIE=$(diff -biw ${SCRIPT_DIR}/TEMP/${NOMSCENE}1 ${SCRIPT_DIR}/TEMP/${NOMSCENE}2 | grep '^<' | wc -l)
            NBENTRE=$(diff -biw ${SCRIPT_DIR}/TEMP/${NOMSCENE}1 ${SCRIPT_DIR}/TEMP/${NOMSCENE}2 | grep '^>' | wc -l)
            ##########################CONTROLE FICHIERS OUT
            if [ $NBSORTIE -ge "1" ]
                then
                echo -e "${RED}$NBSORTIE fichiers sorties ${NC}" | tee -a "${LOGSCHECK}" 
                for ((x=1; x<=$NBSORTIE; x++))
                    do
                    SUPNBSORTIE=$(diff -biw ${SCRIPT_DIR}/TEMP/${NOMSCENE}1 ${SCRIPT_DIR}/TEMP/${NOMSCENE}2 | grep '^<' | head -$x | tail +$x | rev | cut -d"/" -f1 | rev )
                    SCENEOUT=$(grep -c "^${SUPNBSORTIE}" "${STATSSCENES}${NOMSCENE}.csv" | cut -d ";" -f 1)
                    NUMEXIST=$(echo "$SUPNBSORTIE" | rev | cut -d"." -f2 | cut -c1-6 | rev)
                    if [ "$SCENEOUT" -gt "0" ]
                        then
                        echo "${PURPLE}$SUPNBSORTIE Fichier répertorié, suppression des stats en cours ${NC}"
                        sed -i "/$NUMEXIST/d" "${STATSSCENES}${NOMSCENE}.csv"
                        SCENEOUT=$(grep -c "^${SUPNBSORTIE}" "${STATSSCENES}${NOMSCENE}.csv" | cut -d ";" -f 1)
                        
                        if [ $SCENEOUT -eq "0" ]
                            then
                            echo -e "${GREEN} $SUPNBSORTIE Suppression des stats réalisée ${NC}" | tee -a "${LOGSCHECK}"
                            else
                            echo -e "${RED} $SUPNBSORTIE Echec lors de la suppression des stats ${NC}" | tee -a "${LOGSCHECK}"
                            
                        fi
                        else
                        echo "${RED}$SUPNBSORTIE Fichier non répertorié, aucune suppression ${NC}" | tee -a "${LOGSCHECK}"
                    fi
                    done
            fi    
            ##########################CONTROLE FICHIERS IN
            if [ $NBENTRE -ge "1" ]
                then
                echo -e "${GREEN}$NBENTRE nouveaux fichiers ${NC}" | tee -a "${LOGSCHECK}"
                for ((o=1; o<=$NBENTRE; o++))
                do
                    NOMENTRE=$(diff -biw ${SCRIPT_DIR}/TEMP/${NOMSCENE}1 ${SCRIPT_DIR}/TEMP/${NOMSCENE}2 | grep '^>' | cut -c 3- | head -$o | tail +$o)
                    echo "$NOMENTRE" >> ${SCRIPT_DIR}/TEMP/${NOMSCENE}3
                   
                done
            fi
        else
            echo -e "${BOLD}[`date`] - Aucun fichier modifié ${NC}" | tee -a "${LOGSCHECK}"
        fi
        echo | tee -a "${LOGSCHECK}"
    fi





        if [[ ! -f ${STATSSCENES}${NOMSCENE}.csv || $SCENEMODIF -ge "1" ]]
        then                
        	ANO=0
            if [[ -e "${STATSSCENES}general.csv" ]]
                then
                
                SCENEIN=$(grep -e "^${NOMSCENE}" ${STATSSCENES}general.csv)
                if [[ -n $SCENEIN ]]
                    then
                    sed -i "/^"$NOMSCENE"/d" ${STATSSCENES}general.csv
                fi
            else
                touch ${STATSSCENES}general.csv
                echo "scene;nb;time;avg_time;nb_doss" >> ${STATSSCENES}general.csv
            fi
            
            if [[ $OPTION == "complet" || ! -f ${STATSSCENES}${NOMSCENE}.csv ]]
                then
                echo -e "${TITRE}[`date`] - Contrôle total de la scène${NC}" | tee -a "${LOGSCHECK}"
                NBFICHIERS=$(find $SCENES/* -path $DOSSORT -prune -o -type f -iname "*.mp4" -print | wc -l)
                else
                echo -e "${TITRE}Contrôle des fichiers ajoutés à la scène${NC}" | tee -a "${LOGSCHECK}"
                NBFICHIERS=$(echo $NBENTRE)
            fi
            #echo "nbfichiers $NBFICHIERS"
            for ((p=1; p<=NBFICHIERS; p++))
            do
                    if [[ $OPTION == "complet" || ! -f ${STATSSCENES}${NOMSCENE}.csv || $XY -ge "1" ]]
                        then
                        if [[ ! -f ${STATSSCENES}${NOMSCENE}.csv ]]
                            then
                            XY=$(expr $XY + 1 )
                            touch ${STATSSCENES}${NOMSCENE}.csv
                            echo "nom;doss;codec;width;height;time;bitrate;fps;path;date" >> ${STATSSCENES}${NOMSCENE}.csv
                        fi
                        NUMFICHIER=$(find $SCENES/* -path $DOSSORT -prune -o -type f -iname "*.mp4" -print | head -$p | tail +$p)
                        #echo "numfichier $NUMFICHIER"
                    else
                    NOMENTRE=$(cat ${SCRIPT_DIR}/TEMP/${NOMSCENE}3 |  head -$p | tail +$p)
                    NUMFICHIER=$(echo "$NOMENTRE")
                fi
                NOMFICHIER=$(echo "$NUMFICHIER" | rev | cut -d"/" -f1 | rev)
                SOUSSCENE=$(echo "$NUMFICHIER" | rev | cut -d"/" -f2 | rev)
                echo -e "${PURPLE}Contrôle du  fichier : "$NOMFICHIER"${NC}" | tee -a "${LOGSCHECK}"
                NUMEXIST=$(echo "$NOMFICHIER" | rev | cut -d"." -f2 | cut -c1-6 | rev)
                RECAPOK=$(grep -c "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f 1)
                
                if [[ $NUMEXIST =~ ^[0-9]+$ && $RECAPOK -gt "0" ]]
                    then
                    CONTROLOK=$(grep "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f 4)
                    
                    if [[ $CONTROLOK == "OK" || $OPTION == "stats" ]]
                        then
                        
                        TESTERREUR="0"
                        else
                        TESTERREUR=$(ffmpeg -v quiet -i "$NUMFICHIER" -f null -; echo $?)
                        TESTERREUR=$(printf "%.0f\n" "$TESTERREUR")
                        
                    fi
                    if [ $TESTERREUR -gt "0" ]
                        then
                        echo -e "${BOLD}${RED}[`date`] - Anomalie détectée sur le fichier${NC}" | tee -a "${LOGSCHECK}"
                        ANO=$(expr $ANO + 1 )
                        if [ ! -d "${DOSANOMALIES}${NOMSCENE}/${SOUSSCENE}" ]
                            then
                            mkdir -p "${DOSANOMALIES}${NOMSCENE}/${SOUSSCENE}"
                        fi
                        mv "$NUMFICHIER" "${DOSANOMALIES}${NOMSCENE}/${SOUSSCENE}/${NOMFICHIER}"
                        
                        MODIFRECAP=$(awk -v var="$NUMEXIST" -F ";" '$1 == var {sub($4, "FAIL"); print}' ${RECAP})
                        sed -i "/^"$NUMEXIST"/d" "${RECAP}"
                        echo "$MODIFRECAP" >> "${RECAP}"
                        echo -e "${BOLD}fichier déplacé dans le dossier ANOMALIES ${NC}" | tee -a "${LOGSCHECK}"
                        else
                        MODIFRECAP=$(awk -v var="$NUMEXIST" -F ";" '$1 == var {sub($4, "OK"); print}' ${RECAP})
                        sed -i "/^"$NUMEXIST"/d" "${RECAP}"
                        echo "$MODIFRECAP" >> "${RECAP}"
                        DATASTATS=$(ffprobe -v quiet -select_streams v:0 -show_entries format=bit_rate,duration -show_entries stream=codec_name,width,height -of default=noprint_wrappers=1:nokey=1 "$NUMFICHIER" | xargs | tr ' ' ';')
                        FPS=$(ffmpeg -i "$NUMFICHIER" 2>&1 | sed -n "s/.*, \(.*\) tbr.*/\1/p")
                        
                        SCENEIN=$(grep -c "^${NOMFICHIER}" "${STATSSCENES}${NOMSCENE}.csv" | cut -d ";" -f 1)
                        if [ "$SCENEIN" -gt "0" ]
                            then
                            
                            echo -e "${PURPLE}Occurence présente dans les stats, remplacement en cours${NC}"             
                            sed -i "/^'$NOMFICHIER'/d" "${STATSSCENES}${NOMSCENE}.csv"
                            SCENEIN2=$(grep -e "^${NOMFICHIER}" "${STATSSCENES}${NOMSCENE}.csv" | cut -d ";" -f 1)
                            if [ -z $SCENEIN2 ]
                                then
                                echo "${NOMFICHIER};${SOUSSCENE};${DATASTATS};${FPS};${NUMFICHIER};${DATE}" >> "${STATSSCENES}${NOMSCENE}.csv"
                                echo -e "${GREEN}Remplacement des stats ok ${NC} --> ${DATASTATS};${FPS}" | tee -a "${LOGSCHECK}"
                                else
                                echo -e "${RED}$NOMFICHIER Echec du remplacement !!!! ${NC}" | tee -a "${LOGSCHECK}"
                                #echo "sed -i "/^"$SUPNBSORTIE"/d" "${STATS}${NOMSCENE}.csv""
                            fi
                            else
                            
                            echo "${NOMFICHIER};${SOUSSCENE};${DATASTATS};${FPS};${NUMFICHIER};${DATE}" >> "${STATSSCENES}${NOMSCENE}.csv"
                            echo -e "${GREEN}Stats ajoutées ${NC} --> ${DATASTATS};${FPS}" | tee -a "${LOGSCHECK}"
                        fi
                    fi
                    else
                    echo -e "${BOLD}${RED}Fichier : "$NOMFICHIER" inconnu ou mal nommé !!!!${NC}" | tee -a "${LOGSCHECK}"
                    echo -e "${BOLD}Recommencer le script d'intégration${NC}" | tee -a "${LOGSCHECK}"
                    DOSSATRI=$(find "${BASE}${NOMSCENE}/" -mindepth 1 -maxdepth 2 -type d -iname "*trier" )
                    #echo "${BASE}${NOMSCENE}/*    ${NOMFICHIER}"
                    #echo "dosatri $DOSSATRI"
                    mv "$NUMFICHIER" "${DOSSATRI}/${NOMFICHIER}"
                    DEPLACOK=$(find "${DOSSATRI}" -name "${NOMFICHIER}" | wc -l)
                    if [ "$DEPLACOK" -gt "0" ]
                        then
                        echo -e "${GREEN}Fichier déplacé dans le dossier atrier de la scène${NC}" | tee -a "${LOGSCHECK}"
                        else
                        echo -e "${BOLD}${RED}Anomalie lors du déplacement !!${NC}" | tee -a "${LOGSCHECK}"
                    fi
                fi
                echo | tee -a "${LOGSCHECK}"
                done
                if [[ ! -f ${STATSSCENES}general.csv ]]
            then
            touch ${STATSSCENES}general.csv
            echo "scene;nb;time;avg_time;nb_doss" >> ${STATSSCENES}general.csv
            fi
        #NBFICHIERS=$(find $SCENES/* -path $DOSSORT -prune -o -type f -iname "*.mp4" -print | wc -l)
        NBFICHIERS=$(wc -l ${STATSSCENES}${NOMSCENE}.csv | awk '{print $1-1 " " $2}' | cut -d " " -f1)
        NBDOSS=$(cat ${STATSSCENES}${NOMSCENE}.csv | tail -n +2 | cut -d ";" -f 2 | uniq | cut -d " " -f1 | wc -l )
        #echo "nbdoss $NBDOSS"
        #NBDOSS=$(wc -l ${STATSSCENES}${NOMSCENE}.csv | cut -d ";" -f 2 | uniq | awk '{print $1-1 " " $2}' | cut -d " " -f1 )
        DUREETOTALE=$(awk -F';' '{ sum += $6 } END { print sum }' "${STATSSCENES}${NOMSCENE}.csv")
        DUREEMOYENNE=$(expr $DUREETOTALE / $NBFICHIERS )
        echo "${NOMSCENE};${NBFICHIERS};${DUREETOTALE};${DUREEMOYENNE};${NBDOSS}" >> ${STATSSCENES}general.csv
        echo -e "${PURPLE}Données injectées dans le fichier de stats générales  ${NC}" | tee -a "${LOGSCHECK}"

        
        fi
        echo -e "${BLUE}Contrôle du fichier stats ${NC}" | tee -a "${LOGSCHECK}"
        NBFICHIERS=$(find $SCENES/* -path $DOSSORT -prune -o -type f -iname "*.mp4" -print | wc -l)
        NBLIGNESTATS=$(cat "${STATSSCENES}${NOMSCENE}.csv" | wc -l)
        NBLIGNESTATS=$(expr $NBLIGNESTATS - 1 )
        if [ $NBFICHIERS -eq $NBLIGNESTATS ]; then
        echo -e "${GREEN}${BOLD}Fichier OK !!!! ${NC}" | tee -a "${LOGSCHECK}"
        elif [ $NBFICHIERS -gt $NBLIGNESTATS ]
        then
        echo -e "${BOLD}${RED}ANOMALIE !!! Plus de fichiers que de lignes !!!! ${NC}" | tee -a "${LOGSCHECK}"
        elif [ $NBLIGNESTATS -gt $NBFICHIERS ]
        then
        echo -e "${BOLD}${RED}ANOMALIE !!! Plus de lignes que de fichiers !!!! ${NC}" | tee -a "${LOGSCHECK}"
        fi
        echo | tee -a "${LOGSCHECK}"
        
    done
    echo "[`date`] - C'est fini bisous" | tee -a "${LOGSCHECK}"
    
rm -r ${SCRIPT_DIR}/TEMP