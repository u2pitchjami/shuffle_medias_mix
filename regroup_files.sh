#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 2.1	                                     #
#									                                         #
#	NOM: u2pitchjami						                                 #
#									                                         #
#							  					                             #
#									                                         #
#	DATE: 24/10/2024	           				                             #
#									                                         #
#	BUT: Script de regroupement et renommage de fichiers		             #
#									                                         #
############################################################################## 
source ./.config.cfg
#set -e
if [ ! -f $RECAP ]
	then
	touch $RECAP
	echo "id;nom;scene;control;date;last_change;nbexport" >> $RECAP
fi

if [ ! -d $DOSLOG ]
	then
	mkdir $DOSLOG
fi
echo | tee -a "${LOG}"
echo -e "Sauvegarde des stats..." | tee -a "${LOG}"
tar -czf ${DIRSAV_STATS}${BACKUP_STATS}.tar.gz ${STATS}
echo -e "Sauvegarde compressée: \e[32m${BACKUP_STATS}.tar.gz\e[0m\n" | tee -a "${LOG}"
echo -e "sauvegarde réalisée" | tee -a "${LOG}"
##########################CONTROLE SI OPTION "NB CARACT" ACTIVE################
if [ ! -z $1 ]
	then
	OPTION=$(echo $1 | tr '[:upper:]' '[:lower:]')
	if [[ $OPTION =~ ^[0-9]+$ ]]
		then
		echo -e "${SAISPAS}${BOLD}[`date`] - Mode NB Caractères activé à $OPTION ${NC}" | tee -a "${LOG}"
        else
		echo "variable inconnue, mode normal activé"
        echo -e "${SAISPAS}${BOLD}[`date`] - variable inconnue, mode normal activé ${NC}" | tee -a "${LOG}"
        echo -e "${SAISPAS}${BOLD}Délimiteurs : $DELIM1 $DELIM2 $DELIM3 $DELIM4 $DELIM5 ${NC}" | tee -a "${LOG}"
		OPTION="normal"
	fi
    else
OPTION="normal"
echo -e "${SAISPAS}${BOLD}Délimiteurs : $DELIM1 $DELIM2 $DELIM3 $DELIM4 $DELIM5${NC}" | tee -a "${LOG}"
fi
#############################################################################
###########################TRAITEMENT DOSSIER ATRIER GENERAL##################################
echo -e "${SAISPAS}${BOLD}[`date`] - Vérification de la présence de fichiers dans le dossier ATRAITER Général ${NC}" | tee -a "${LOG}"
NBFILESATRIERGEN=$(find "${DOSSORTGEN}" -type f | wc -l)
if [[ "$NBFILESATRIERGEN" -gt "0" ]]; then
    echo -e "${BOLD} ${NBFILESATRIERGEN} fichier(s) à trier ${NC}" | tee -a "${LOG}"
    for FILEATRIERGEN in "${DOSSORTGEN}"*
    do
        #echo "FILEATRIERGEN $FILEATRIERGEN"
        NOMFILEATRIERGEN=$(echo "$FILEATRIERGEN" | rev | cut -d"/" -f1 | rev)
        POSDELIMATRIERGEN=$(echo "$FILEATRIERGEN" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIMATRIERGEN" '{print index($0, var)}')
        POSDELIMATRIERGEN=$(expr $POSDELIMATRIERGEN + 2 )
        WHATSCENE=$(echo "$FILEATRIERGEN" | rev | cut -d"/" -f1 | rev | cut -c"${POSDELIMATRIERGEN}"- | cut -d "-" -f 1 )
        WHATSCENEEXIST=$(find "${BASE}" -maxdepth 1 -type d -iname "*-${WHATSCENE}" )
        if [[ -z "$WHATSCENEEXIST" ]]; then
            echo -e "${BOLD}${RED}Scene : ${WHATSCENE} inconnu pour le fichier ${NOMFILEATRIERGEN} \n intervention manuelle nécessaire${NC}" | tee -a "${LOG}"
        else
            DOSSWHATSCENEEXIST=$(find "${WHATSCENEEXIST}" -maxdepth 1 -type d -iname "${DOSSORT}" )
            mv "${FILEATRIERGEN}" "${DOSSWHATSCENEEXIST}/${NOMFILEATRIERGEN}"
        fi
    done
    echo -e "${BOLD}Tri terminé !! \n Passons à la suite... ${NC}" | tee -a "${LOG}"
    echo
else
    echo -e "${BOLD}Aucun fichier à trier \n Passons à la suite... ${NC}" | tee -a "${LOG}"
    echo
fi



#Variables pour les stats de fin
COUNTFILE="0"
COUNTFILEFAIL="0"
###########################TRAITEMENT DOSSIERS ATRAITER##################################
#compte le nombre de dossier atrier existant
NBDOSS=$(find "${BASE}" -mindepth 1 -maxdepth 2 -type d -iname "*trier" | wc -l | sort -d)
echo -e "${BOLD}[`date`] - Démarrage du script de classement, $NBDOSS dossiers à checker ${NC}" | tee -a "${LOGREG}"
for ((o=1; o<=$NBDOSS; o++))
do
    DOSS=$(find "${BASE}" -mindepth 1 -maxdepth 2 -type d -iname "*trier" | head -$o | tail +$o | sort -d )
    DOSSIER2=$(dirname "$DOSS")
    DOSSIER3=$(echo "$DOSSIER2/divers")
    if [ ! -d $DOSSIER3 ]
	then
   	mkdir $DOSSIER3
    fi
    SCENE=$(echo "$DOSS" | rev | cut -d "/" -f 2 | rev )
    NBFILESDOSS=$(find "${DOSS}" -type f | wc -l 2> /dev/null )
    echo -e "${SAISPAS}${BOLD}[`date`] - Traitement du dossier $DOSS ${NC}" | tee -a "${LOGREG}"
    #echo "dossier de rangement divers $DOSSIER3"
    ###########################TRAITEMENT DES FICHIERS ATRAITER
    if [ $NBFILESDOSS -gt "0" ]
        then
        NBFILESDOSS3=$(find "${DOSSIER3}" -type f | wc -l 2> /dev/null )
        if [ $NBFILESDOSS3 -gt "0" ]
        then
        mv ${DOSSIER3}/* $DOSS
        echo -e "${BOLD}$NBFILESDOSS fichiers à traiter + $NBFILESDOSS3 fichiers divers à retester  ${NC}" | tee -a "${LOGREG}"
        else
        echo -e "${BOLD}$NBFILESDOSS fichiers à traiter ${NC}" | tee -a "${LOGREG}"
        fi
        for FILE in "${DOSS}"/*
        do
            NOMFILE=$(echo $FILE | rev | cut -d "/" -f 1 | rev)
            COUNTFILE=$(expr $COUNTFILE + 1 )
            NUMEXIST=$(echo "$FILE" | rev | cut -d"/" -f1 | cut -d"." -f2 | cut -c1-6 | rev)
            #echo "numexist $NUMEXIST"
            FILEEXIST=$(grep -c "^${NUMEXIST}" "${RECAP}")
            if [[ $OPTION =~ ^[0-9]+$ ]]
		        then
                POSDELIM=$OPTION
                else
                
                #echo "POSDELIM $POSDELIM"
                ###########################TESTE LA POSITION DU POINT DES RUPTURES
                                
                if [[ $NUMEXIST =~ ^[0-9]+$ && $FILEEXIST -gt "0" ]]
                    then
                POSDELIM=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | wc -m )
                        POSDELIM=$(expr $POSDELIM - 11 )
                #echo "POSDELIM $POSDELIM"
                else
                POSDELIM=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | wc -m )
                        POSDELIM=$(expr $POSDELIM - 6 )
                #echo "POSDELIM $POSDELIM"
                fi

                #echo "delim1 $DELIM1"
                POSDELIM1=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIM1" '{print index($0, var)}')
                POSDELIM1=$(expr $POSDELIM1 - 1 )
                #echo "POSDELIM1 $POSDELIM1"
                #echo "POSDELIM1 $POSDELIM1"
                if [[ $POSDELIM1 -lt $POSDELIM && $POSDELIM1 -gt "0" ]]
                        then
                POSDELIM=$POSDELIM1
                #echo "POSDELIM $POSDELIM"
                fi
                    
                   # echo "delim2 $DELIM2"
                POSDELIM2=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIM2" '{print index($0, var)}')
                POSDELIM2=$(expr $POSDELIM2 - 1 )
               # echo "POSDELIM2 $POSDELIM2"
                if [[ $POSDELIM2 -lt $POSDELIM && $POSDELIM2 -gt "0" ]]
                        then
                        POSDELIM=$POSDELIM2
                      #echo "POSDELIM $POSDELIM"
                    fi
                #echo "delim2 $DELIM3"
                POSDELIM3=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIM3" '{print index($0, var)}')
                POSDELIM3=$(expr $POSDELIM3 - 1 )
                #echo "POSDELIM3 $POSDELIM3"
                if [[ $POSDELIM3 -lt $POSDELIM && $POSDELIM3 -gt "0" ]]
                        then
                        POSDELIM=$POSDELIM3
                        #echo "POSDELIM $POSDELIM"
                    fi
                #echo "delim2 $DELIM4"
                POSDELIM4=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIM4" '{print index($0, var)}')
                POSDELIM4=$(expr $POSDELIM4 - 1 )
                #echo "POSDELIM4 $POSDELIM4"
                if [[ $POSDELIM4 -lt $POSDELIM && $POSDELIM4 -gt "0" ]]
                        then
                        POSDELIM=$POSDELIM4
                        #echo "POSDELIM $POSDELIM"
                    fi
                   # echo "delim2 $DELIM5"
                POSDELIM5=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIM5" '{print index($0, var)}')
                POSDELIM5=$(expr $POSDELIM5 - 1 )
                #echo "POSDELIM4 $POSDELIM4"
                if [[ $POSDELIM5 -lt $POSDELIM && $POSDELIM5 -gt "0" ]]
                        then
                        POSDELIM=$POSDELIM5
                        #echo "POSDELIM $POSDELIM"
                    fi
                if [[ $POSDELIM -lt "2" ]]
                        then
                        POSDELIM=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | wc -m )
                        POSDELIM=$(expr $POSDELIM - 10 )
                    fi
            fi
            #############################################################################################    
            echo | tee -a "${LOGREG}"
            echo "[`date`] - Fichier : $NOMFILE" | tee -a "${LOGREG}"
            ###########################CONTROLE SI FICHIER EXISTANT
            
            #echo "FILExist $FILEEXIST"
            if [ $FILEEXIST -gt "0" ]
                then
                echo -e "id $NUMEXIST existant" | tee -a "${LOGREG}"
                NBFILEEXIST=$(find ${BASE}/* -name "${DOSSORT}" -prune -o -iname "*${NUMEXIST}*" -print | wc -l)
                if [ $NBFILEEXIST -gt "1" ]; then
                    echo -e "${RED}$NBFILEEXIST fichiers avec le même id !!!${NC}" | tee -a "${LOGREG}"
                    echo -e "Je renomme donc celui ci"
                    FILEEXIST=0
                    else
                    NOMEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f2 )
                    SCENEEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f3 )
                    CONTROLEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f4 )
                    DATEEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f5 )
                    NBEXPORTEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f7 )
                fi
            fi
            EXTENSION=$(echo "$FILE" | rev | cut -d"." -f1 | rev)
            ###########################PROSSESS DE RECHERCHES D'OCCURENCES ET RENOMMAGE DES FICHIERS
            TESTFILE=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | sed -e 's/[^A-Za-z0-9-]/ /g' | cut -c$POSDELIM-$POSDELIM | tr -s ' ' )
            #echo "dernier caractère $TESTFILE"
            if [[ $TESTFILE == ['!'@#\$%^\&*()_+-] ]]
                then
                POSDELIM=$(expr $POSDELIM - 1 )
                #echo "nouvelle position $TESTPOSDIGIT"
            fi 
            #echo "testposdigit (final) $TESTPOSDIGIT"
            FILE1=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | cut -c1-$POSDELIM )
            CREADOSS0=$(echo "$FILE" | rev | cut -d"/" -f1 | rev |  sed -e 's/[^A-Za-z0-9-]/ /g' | cut -c1-$POSDELIM | tr -s ' ' |  tr '[:upper:]' '[:lower:]')
            CREADOSS=$(echo "$CREADOSS0" | tr -s ' ')
            CREADOSS=( $CREADOSS )
            #permet de mettre en majuscule la 1ère lettre de chaque mot
            CREADOSS=$(echo "${CREADOSS[@]^}")
            CREAFILE=$CREADOSS
            #echo "nom pour recherche $FILE1"
            #echo "nom du dossier et du nouveau fichier : $CREADOSS"
            CHAR=" - "
            NBCHAR=$(echo "${CREADOSS}" | awk -F "${CHAR}" '{ print (length > 0 ? NF - 1 : 0) }' )
            #NBCHAR=$(awk -v var="$CHAR" '/var/ {count++} END {print count}' "${CREADOSS}")
            #NBCHAR=$(grep -c "${CHAR}" "${CREADOSS}")
            #echo "numchar $NBCHAR"
           
            #######TRAITEMENT DE LA NUMEROTATION#######
            if [ $FILEEXIST -gt "0" ]
                then
                E="$NUMEXIST"
                else
                NBLINERECAP=$(cat "$RECAP" | wc -l)
                if [ $NBLINERECAP -eq "1" ]
                    then
                    NUMFILE=1
                    else
                NUMFILE0=$(cat "$RECAP" | cut -d ";" -f 1 | sort -n | tail -1)
                NUMFILE=$(expr $NUMFILE0 + 1 )
                fi
                NBCAR=$(echo $NUMFILE | wc -m)
                if [ $NBCAR = 2 ]
                    then
                    E="00000$NUMFILE"
                    elif [ $NBCAR = 3 ]
                    then
                    E="0000$NUMFILE"
                    elif [ $NBCAR = 4 ]
                    then
                    E="000$NUMFILE"
                    elif [ $NBCAR = 5 ]
                    then
                    E="00$NUMFILE"
                    elif [ $NBCAR = 6 ]
                    then
                    E="0$NUMFILE"
                    else
                    E="$NUMFILE"
                fi
            fi
            #echo "dossier2 $DOSSIER2"
            #echo "${DOSSIER2}/${CREADOSS}/"
            ###########################DEPLACEMENT AVEC RENOMMAGE###############################################
            ##########################SI DOSSIER EXISTE DEJA
            if [[ $NBCHAR -gt "0" ]]
                then
                POSCHAR=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | awk -v var="$CHAR" '{print index($0, var)}')
                POSCHAR1=$(expr $POSCHAR - 1 )
                POSCHAR2=$(expr $POSCHAR + 3 )
                echo "poschar1-2 $POSCHAR1 - $POSCHAR2"
                FILE11=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | cut -c1-$POSCHAR1 )
                #echo "file11 $FILE11"
                FILE12=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | cut -c$POSCHAR2-$POSDELIM )
                #echo "file12 $FILE12"
                CHERCHE1=$(find "${DOSS}"/* -type f -iname "*${FILE11}*" | wc -l)
                CHERCHE2=$(find "${DOSS}"/* -type f -iname "*${FILE12}*" | wc -l)
                CREADOSS01=$(echo "$FILE11" | sed -e 's/[^A-Za-z0-9-]/ /g' | tr -s ' ' |  tr '[:upper:]' '[:lower:]')
                CREADOSS1=$(echo "$CREADOSS01" | tr -s ' ')
                CREADOSS1=( $CREADOSS1 )
                CREADOSS1=$(echo "${CREADOSS1[@]^}")
                CREADOSS02=$(echo "$FILE12" | sed -e 's/[^A-Za-z0-9-]/ /g' | tr -s ' ' |  tr '[:upper:]' '[:lower:]')
                CREADOSS2=$(echo "$CREADOSS02" | tr -s ' ')
                CREADOSS2=( $CREADOSS2 )
                CREADOSS2=$(echo "${CREADOSS2[@]^}")
                if [[ -d "${DOSSIER2}/${FILE11}" || $CHERCHE1 -gt "1" ]]
                    then
                    CREADOSS=$CREADOSS1
                    FILE1=$FILE11
                    elif [[ -d "${DOSSIER2}/${FILE12}" || $CHERCHE2 -gt "1" ]]
                    then
                    CREADOSS=$CREADOSS2
                    FILE1=$FILE12
                    
                fi
            fi

            if [ -d "${DOSSIER2}/${CREADOSS}" ]
                then
                #NUMFILE0=$(find "${DOSSIER2}/${CREADOSS}"/* -type f | wc -l)
                mv "$FILE" "${DOSSIER2}/${CREADOSS}/${CREAFILE} ${E}.${EXTENSION}" 2> >(tee -a $LOGREG)
                if [ -f "${DOSSIER2}/${CREADOSS}/${CREAFILE} ${E}.${EXTENSION}" ]
                    then
                    echo "Dossier cible ${CREADOSS} existant : déplacement du fichier ${CREAFILE} ${E}.${EXTENSION}" | tee -a "${LOGREG}"
                else
                    echo -e "${BOLD}${RED}ECHEC du déplacement du fichier ${CREAFILE} ${E}.${EXTENSION} ${NC}" | tee -a "${LOGREG}"
                    COUNTFILEFAIL=$(expr $COUNTFILEFAIL + 1 )
                fi
            else 
                CHERCHE=$(find "${DOSS}"/* -type f -iname "*${FILE1}*" | wc -l)
                #echo "${CHERCHE} occurences pour la base du fichier $FILE1" | tee -a "${LOGREG}"
                if [ $CHERCHE -gt "1" ]
                    then
                    mkdir "${DOSSIER2}/${CREADOSS}" 2> >(tee -a $LOGREG)
                    mv "$FILE" "${DOSSIER2}/${CREADOSS}/${CREAFILE} ${E}.${EXTENSION}" 2> >(tee -a $LOGREG)
                    if [ -f "${DOSSIER2}/${CREADOSS}/${CREAFILE} ${E}.${EXTENSION}" ]
                        then
                        echo "Dossier cible ${CREADOSS} inexistant : création du dossier et déplacement du fichier ${CREAFILE} ${E}.${EXTENSION} ($CHERCHE occurences)" | tee -a "${LOGREG}"
                    else
                        echo -e "${BOLD}${RED}ECHEC du déplacement du fichier ${CREAFILE} ${E}.${EXTENSION} ${NC}" | tee -a "${LOGREG}"
                        COUNTFILEFAIL=$(expr $COUNTFILEFAIL + 1 )
                    fi
                else
                    if [ -d "$DOSSIER3" ]
                        then
                        mv "$FILE" "$DOSSIER3/${CREAFILE} ${E}.${EXTENSION}" 2> >(tee -a $LOGREG)
                            if [ -f "${DOSSIER3}/${CREAFILE} ${E}.${EXTENSION}" ]
                                then
                                echo "trop peu d'occurences déplacement du fichier ${CREAFILE} ${E}.${EXTENSION} dans le dossier Divers" | tee -a "${LOGREG}"
                            else
                                echo -e "${BOLD}${RED}ECHEC du déplacement du fichier ${CREAFILE} ${E}.${EXTENSION} ${NC}" | tee -a "${LOGREG}"
                                COUNTFILEFAIL=$(expr $COUNTFILEFAIL + 1 )
                            fi
                    else
                        mkdir "$DOSSIER3" 2> >(tee -a $LOGREG)
                        mv "$FILE" "$DOSSIER3/${CREAFILE} ${E}.${EXTENSION}" 2> >(tee -a $LOGREG)
                        if [ -f "${DOSSIER3}/${CREAFILE} ${E}.${EXTENSION}" ]
                            then
                            echo "trop peu d'occurences déplacement du fichier ${CREAFILE} ${E}.${EXTENSION} dans et création du dossier Divers" | tee -a "${LOGREG}"
                        else
                            echo -e "${BOLD}${RED}ECHEC du déplacement du fichier ${CREAFILE} ${E}.${EXTENSION} ${NC}" | tee -a "${LOGREG}"
                            COUNTFILEFAIL=$(expr $COUNTFILEFAIL + 1 )
                        fi
                    fi  
                fi
            fi
            if [ $FILEEXIST -gt "0" ]
                then
                #sed -i 's/"$NUMEXIST";"$NOMEXIST";"$SCENEEXIST";"$DATEEXIST";"$NBEXPORTEXIST"/"$NUMEXIST";"$CREADOSS""$E"."$EXTENSION";"$SCENE";"$DATEEXIST";"$NBEXPORTEXIST"/g' ${STATS}${RECAP}.csv
                sed -i "/^"$NUMEXIST"/d" "${RECAP}"
                echo ""$E";"$CREAFILE" "$E"."$EXTENSION";"$SCENE";"$CONTROLEXIST";"$DATEEXIST";"$DATE";"$NBEXPORTEXIST"" >> ${RECAP}
                NOMEXIST2=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f 2)
                #echo "  sed -i 's/"$NUMEXIST";"$NOMEXIST";"$SCENEEXIST";"$DATEEXIST";"$NBEXPORTEXIST"/"$NUMEXIST";"$CREADOSS""$E"."$EXTENSION";"$SCENE";"$DATEEXIST";"$NBEXPORTEXIST"/g' ${STATS}${RECAP}.csv"
                #echo "NOMEXIST $NOMEXIST NOMEXIST2 $NOMEXIST2"
                if [ "$NOMEXIST2" == "$CREAFILE $E.$EXTENSION" ]
                    then
                    echo -e "${GREEN}Fichier recap modifié ${NC}" | tee -a "${LOGREG}"
                    else
                    echo -e "${RED}ANOMALIE LORS DE LA MODIFICATION DU FICHIER RECAP !!! ${NC}" | tee -a "${LOGREG}"
                fi
                else
                echo ""$E";"$CREAFILE" "$E"."$EXTENSION";"$SCENE";pending;"$DATE";"$DATE";0" >> ${RECAP}
                NOMEXIST2=$(grep -e "^${E}" "${RECAP}" | cut -d ";" -f 2)
                if [ "$NOMEXIST2" == "$CREAFILE $E.$EXTENSION" ]
                    then
                    echo -e "${GREEN}Fichier ajouté au recap ${NC}" | tee -a "${LOGREG}"
                    else
                    echo -e "${RED}ANOMALIE LORS DE L'AJOUT DU FICHIER RECAP !!! ${NC}" | tee -a "${LOGREG}"
                fi
            fi
          
        done

        else
        echo -e "${BOLD}aucun fichier à traiter pour ce dossier ${NC}" | tee -a "${LOGREG}"
    fi
    echo
     NBDOSSVIDES=$(find "${BASE}${SCENE}" -name "${DOSSORT}" -prune -o -type d -empty -print | wc -l)
            if [ $NBDOSSVIDES -ge "1" ]
                then
                echo "Suppression de $NBDOSSVIDES dossiers vides" | tee -a "${LOGREG}"
                find "${BASE}${SCENE}" -name "${DOSSORT}" -prune -o -type d -empty -print -exec rmdir {} \;
                echo "test"
            fi    
done
echo "[`date`] - C'est fini $COUNTFILE fichiers traités" | tee -a "${LOGREG}"
echo -e "${BOLD}${RED}$COUNTFILEFAIL fichiers en anomalies${NC}" | tee -a "${LOGREG}"  