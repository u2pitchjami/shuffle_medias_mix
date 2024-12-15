#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 3.1	                                     #
#									                                         #
#	NOM: u2pitchjami						                                 #
#									                                         #
#							  					                             #
#									                                         #
#	DATE: 13/12/2024	           				                             #
#									                                         #
#	BUT: Script de regroupement et renommage de fichiers		             #
#									                                         #
############################################################################## 
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source ${SCRIPT_DIR}/.config.cfg
#set -e
if [ ! -f $RECAP ];	then
	touch $RECAP
	echo "id;nom;scene;control;date;last_change;nbexport" >> $RECAP
fi
if [ ! -d $DOSLOG ]; then
	mkdir $DOSLOG
fi

echo | tee -a "${LOGREG}"
echo -e "${TITRE}Sauvegarde des stats...${NC}" | tee -a "${LOGREG}"
tar -czf ${DIRSAV_STATS}${BACKUP_STATS}.tar.gz ${STATS}
echo -e "Sauvegarde compressée: \e[32m${BACKUP_STATS}.tar.gz\e[0m\n" | tee -a "${LOGREG}"
echo -e "${GREEN}sauvegarde réalisée${NC}" | tee -a "${LOGREG}"
echo
echo
##########################CONTROLE SI OPTION "NB CARACT" ACTIVE################
if [ ! -z $1 ]; then
	OPTION=$(echo $1 | tr '[:upper:]' '[:lower:]')
	if [[ $OPTION =~ ^[0-9]+$ ]]; then
		echo -e "${BIGTITRE}[`date`] - Mode NB Caractères activé à $OPTION ${NC}" | tee -a "${LOGREG}"
    else
		echo "variable inconnue, mode normal activé"
        echo -e "${BIGTITRE}[`date`] - variable inconnue, mode normal activé ${NC}" | tee -a "${LOGREG}"
        echo -e "${BIGTITRE}Délimiteurs : $DELIM1 $DELIM2 $DELIM3 $DELIM4 $DELIM5 ${NC}" | tee -a "${LOGREG}"
		OPTION="normal"
	fi
else
OPTION="normal"
echo -e "${BIGTITRE}Délimiteurs : $DELIM1 $DELIM2 $DELIM3 $DELIM4 $DELIM5${NC}" | tee -a "${LOGREG}"
fi
#############################################################################

###########################TRAITEMENT DOSSIER ATRIER GENERAL##################################
echo -e "${BIGTITRE}[`date`] - Vérification de la présence de fichiers dans le dossier ATRAITER Général ${NC}" | tee -a "${LOGREG}"
NBFILESATRIERGEN=$(find "${DOSSORTGEN}" -type f | wc -l)
if [[ "$NBFILESATRIERGEN" -gt "0" ]]; then
    echo -e "${BOLD} ${NBFILESATRIERGEN} fichier(s) à trier ${NC}" | tee -a "${LOGREG}"
    for FILEATRIERGEN in "${DOSSORTGEN}"*
    do
        #echo "FILEATRIERGEN $FILEATRIERGEN"
        NOMFILEATRIERGEN=$(echo "$FILEATRIERGEN" | rev | cut -d"/" -f1 | rev )
        POSDELIMATRIERGEN=$(echo "$FILEATRIERGEN" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIMATRIERGEN" '{print index($0, var)}')
        POSDELIMATRIERGEN=$(expr $POSDELIMATRIERGEN + 3 )
        WHATSCENE=$(echo "$FILEATRIERGEN" | rev | cut -d"/" -f1 | rev | cut -c"${POSDELIMATRIERGEN}"- | cut -d "-" -f 1 )
        WHATSCENEEXIST=$(find "${BASE}" -maxdepth 1 -type d -iname "*-${WHATSCENE}" )
        if [[ -z "$WHATSCENEEXIST" ]]; then
            echo -e "${BOLD}${RED}Scene : ${WHATSCENE} inconnu pour le fichier ${NOMFILEATRIERGEN} \n intervention manuelle nécessaire${NC}" | tee -a "${LOGREG}"
        else
            DOSSWHATSCENEEXIST=$(find "${WHATSCENEEXIST}" -maxdepth 1 -type d -iname "${DOSSORT}" )
            mv "${FILEATRIERGEN}" "${DOSSWHATSCENEEXIST}/${NOMFILEATRIERGEN}"
        fi
    done
    echo -e "${BOLD}Tri terminé !! \n Passons à la suite... ${NC}" | tee -a "${LOGREG}"
    echo
else
    echo -e "${BOLD}Aucun fichier à trier \n Passons à la suite... ${NC}" | tee -a "${LOGREG}"
    echo
fi






#Variables pour les stats de fin
COUNTFILE="0"
COUNTFILEFAIL="0"
###########################TRAITEMENT DOSSIERS ATRAITER##################################
############################### RENOMMAGE ##############################################################
#compte le nombre de dossier atrier existant
NBDOSS=$(find "${BASE}" -mindepth 1 -maxdepth 2 -type d -iname "*trier" | wc -l | sort -d)
echo -e "${BOLD}[`date`] - Démarrage du script de classement, $NBDOSS dossiers à checker ${NC}" | tee -a "${LOGREG}"
for ((o=1; o<=$NBDOSS; o++))
do
    DOSS=$(find "${BASE}" -mindepth 1 -maxdepth 2 -type d -iname "*trier" | sort -d | head -$o | tail +$o )
    DOSSIER2=$(dirname "$DOSS")
    DOSSIER3=$(echo "$DOSSIER2/divers")
    SCENE=$(echo "$DOSS" | rev | cut -d "/" -f 2 | rev )

    NBDOSSVIDES=$(find "${BASE}${SCENE}" -name "${DOSSORT}" -prune -o -type d -empty -print | wc -l)
    if [ $NBDOSSVIDES -ge "1" ]; then
        echo -e "${PURPLE}Suppression de $NBDOSSVIDES dossiers vides ${NC}" | tee -a "${LOGREG}"
        find "${BASE}${SCENE}" -name "${DOSSORT}" -prune -o -type d -empty -print -exec rmdir {} +
        
    fi    

    if [ ! -d $DOSSIER3 ]; then
   	    mkdir $DOSSIER3
    fi
   
    NBFILESDOSS=$(find "${DOSS}" -type f | wc -l 2> /dev/null )
    echo -e "${BIGTITRE}[`date`] - Traitement du dossier $DOSS ${NC}" | tee -a "${LOGREG}"
    #echo "dossier de rangement divers $DOSSIER3"
    ###########################TRAITEMENT DES FICHIERS ATRAITER
    if [ $NBFILESDOSS -gt "0" ]; then
       
        echo -e "${BOLD}$NBFILESDOSS fichiers à renommer ${NC}" | tee -a "${LOGREG}"
        
        for FILE in "${DOSS}"/*
        do
            NOMFILE=$(echo $FILE | rev | cut -d "/" -f 1 | rev)
            
            NUMEXIST=$(echo "$FILE" | rev | cut -d"/" -f1 | cut -d"." -f2 | cut -c1-6 | rev)
            #echo "numexist $NUMEXIST"
            FILEEXIST=$(grep -c "^${NUMEXIST}" "${RECAP}")
            if [[ $OPTION =~ ^[0-9]+$ ]]; then
                POSDELIM=$OPTION
            else
                
                #echo "POSDELIM $POSDELIM"
                ###########################TESTE LA POSITION DES POINTS DE RUPTURES
                                
                if [[ $NUMEXIST =~ ^[0-9]+$ && $FILEEXIST -gt "0" ]]; then
                    POSDELIM=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | wc -m )
                    POSDELIM=$(expr $POSDELIM - 11 )
                    
                else
                    POSDELIM=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | wc -m )
                    POSDELIM=$(expr $POSDELIM - 6 )
                    
                fi

                #echo "delim1 $DELIM1"
                POSDELIM1=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIM1" '{print index($0, var)}')
                POSDELIM1=$(expr $POSDELIM1 - 1 )
                #echo "POSDELIM1 $POSDELIM1"
                #echo "POSDELIM1 $POSDELIM1"
                if [[ $POSDELIM1 -lt $POSDELIM && $POSDELIM1 -gt "0" ]]; then
                POSDELIM=$POSDELIM1
                #echo "POSDELIM $POSDELIM"
                fi
                    
                   # echo "delim2 $DELIM2"
                POSDELIM2=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIM2" '{print index($0, var)}')
                POSDELIM2=$(expr $POSDELIM2 - 1 )
               # echo "POSDELIM2 $POSDELIM2"
                if [[ $POSDELIM2 -lt $POSDELIM && $POSDELIM2 -gt "0" ]]; then
                        POSDELIM=$POSDELIM2
                      #echo "POSDELIM $POSDELIM"
                fi
                #echo "delim2 $DELIM3"
                POSDELIM3=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIM3" '{print index($0, var)}')
                POSDELIM3=$(expr $POSDELIM3 - 1 )
                #echo "POSDELIM3 $POSDELIM3"
                if [[ $POSDELIM3 -lt $POSDELIM && $POSDELIM3 -gt "0" ]]; then
                        POSDELIM=$POSDELIM3
                        #echo "POSDELIM $POSDELIM"
                fi
                #echo "delim2 $DELIM4"
                POSDELIM4=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIM4" '{print index($0, var)}')
                POSDELIM4=$(expr $POSDELIM4 - 1 )
                #echo "POSDELIM4 $POSDELIM4"
                if [[ $POSDELIM4 -lt $POSDELIM && $POSDELIM4 -gt "0" ]]; then
                        POSDELIM=$POSDELIM4
                        #echo "POSDELIM $POSDELIM"
                fi
                   # echo "delim2 $DELIM5"
                POSDELIM5=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | awk -v var="$DELIM5" '{print index($0, var)}')
                POSDELIM5=$(expr $POSDELIM5 - 1 )
                #echo "POSDELIM4 $POSDELIM4"
                if [[ $POSDELIM5 -lt $POSDELIM && $POSDELIM5 -gt "0" ]]; then
                        POSDELIM=$POSDELIM5
                        #echo "POSDELIM $POSDELIM"
                fi
                if [[ $POSDELIM -lt "2" ]]; then
                        POSDELIM=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | wc -m )
                        POSDELIM=$(expr $POSDELIM - 10 )
                fi
            fi
            #############################################################################################    
            #echo | tee -a "${LOGREG}"
            echo -e "${BOLD}${BLUE}[`date`] - Fichier : $NOMFILE ${NC}" | tee -a "${LOGREG}"
            ###########################CONTROLE SI FICHIER EXISTANT
            
            #echo "FILExist $FILEEXIST"
            if [ $FILEEXIST -gt "0" ]; then
                echo -e "id $NUMEXIST existant ... " | tee -a "${LOGREG}"
                NBFILEEXIST=$(find ${BASE}* -name "${DOSSORT}" -prune -o -type f -iname "*${NUMEXIST}*" -print | wc -l)
                
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
            ###########################PROCESS DE RECHERCHES D'OCCURENCES ET RENOMMAGE DES FICHIERS
            TESTFILE=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | sed -e 's/[^A-Za-z0-9-]/ /g' | cut -c$POSDELIM-$POSDELIM | tr -s ' ' )
            #echo "dernier caractère $TESTFILE"
            if [[ $TESTFILE == ['!'@#\$%^\&*()_+-' '] ]]
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
            
            #######TRAITEMENT DE LA NUMEROTATION#######
            if [ $FILEEXIST -gt "0" ]; then
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
            NOMEXIST3=$(grep -e "^${E}" "${RECAP}" | cut -d ";" -f 2)
            if [ "${NOMEXIST3}" == "${CREAFILE} ${E}.${EXTENSION}" ]; then
                echo -e "Pas besoin de renommer"
            else
                echo -e "${PURPLE}Renommé : ${DOSS}/${CREAFILE} ${E}.${EXTENSION}${NC}"
                mv "$FILE" "${DOSS}/${CREAFILE} ${E}.${EXTENSION}"

                if [ $FILEEXIST -gt "0" ]; then
                    sed -i "/^"$NUMEXIST"/d" "${RECAP}"
                    echo ""$E";"$CREAFILE" "$E"."$EXTENSION";"$SCENE";"$CONTROLEXIST";"$DATEEXIST";"$DATE";"$NBEXPORTEXIST"" >> ${RECAP}
                    NOMEXIST2=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f 2)
                    if [ "$NOMEXIST2" == "$CREAFILE $E.$EXTENSION" ]; then
                        echo -e "${GREEN}Fichier recap modifié ${NC}" | tee -a "${LOGREG}"
                    else
                        echo -e "${RED}ANOMALIE LORS DE LA MODIFICATION DU FICHIER RECAP !!! ${NC}" | tee -a "${LOGREG}"
                    fi
                else    
                    echo ""$E";"$CREAFILE" "$E"."$EXTENSION";"$SCENE";pending;"$DATE";"$DATE";0" >> ${RECAP}
                    NOMEXIST2=$(grep -e "^${E}" "${RECAP}" | cut -d ";" -f 2)
                    if [ "$NOMEXIST2" == "$CREAFILE $E.$EXTENSION" ]; then
                        echo -e "${GREEN}Fichier ajouté au recap ${NC}" | tee -a "${LOGREG}"
                    else
                        echo -e "${RED}ANOMALIE LORS DE L'AJOUT DU FICHIER RECAP !!! ${NC}" | tee -a "${LOGREG}"
                    fi
                fi
            fi
           
        done
        NBFILESDOSS3=$(find "${DOSSIER3}" -type f | wc -l 2> /dev/null )
        if [ $NBFILESDOSS3 -gt "0" ]; then
            mv ${DOSSIER3}/* $DOSS
            echo -e "${BOLD}$NBFILESDOSS fichiers à déplacer + $NBFILESDOSS3 fichiers divers à retester  ${NC}" | tee -a "${LOGREG}"
        else
            echo -e "${BOLD}$NBFILESDOSS fichiers à déplacer ${NC}" | tee -a "${LOGREG}"
        fi

        for FILE in "${DOSS}"/*
        do
            NOMFILE=$(echo $FILE | rev | cut -d "/" -f 1 | rev)
            COUNTFILE=$(expr $COUNTFILE + 1 )
            NUMEXIST=$(echo "$FILE" | rev | cut -d"/" -f1 | cut -d"." -f2 | cut -c1-6 | rev)
            FILEEXIST=$(grep -c "^${NUMEXIST}" "${RECAP}")
           
            #############################################################################################    
            echo -e "${BOLD}${BLUE}[`date`] - Fichier : $NOMFILE ${NC}" | tee -a "${LOGREG}"
            ###########################CONTROLE SI FICHIER EXISTANT
                      
            if [ $FILEEXIST -gt "0" ]; then
                #echo -e "id $NUMEXIST existant" | tee -a "${LOGREG}"
                NOMEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f2 )
                SCENEEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f3 )
                CONTROLEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f4 )
                DATEEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f5 )
                NBEXPORTEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f7 )

                POSDELIM=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | wc -m )
                POSDELIM=$(expr $POSDELIM - 12 )
                
                TESTFILE=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | cut -c$POSDELIM-$POSDELIM | tr -s ' ' )
                
                    if [[ $TESTFILE == ['!'@#\$%^\&*()_+-' '] ]]; then
                        POSDELIM=$(expr $POSDELIM - 1 )
                        
                    fi
                NOMFILENEW=$(echo "$FILE" | rev | cut -d"/" -f1 | rev | cut -c1-$POSDELIM )
                CHAR=" - "
                NBCHAR=$(echo "${NOMFILENEW}" | awk -F "${CHAR}" '{ print (length > 0 ? NF - 1 : 0) }' )

                if [[ $NBCHAR -gt "0" ]]; then
                    #echo "char $CHAR"
                    #echo "file $FILE"
                    POSCHAR=$(echo "$NOMFILENEW" | awk -v var="$CHAR" '{print index($0, var)}')
                    #echo "poschar $POSCHAR"
                    POSCHAR1=$(expr $POSCHAR - 1 )
                    POSCHAR2=$(expr $POSCHAR + 3 )
                    POSCHAR3=$(echo "$NOMFILENEW" | cut -d "-" -f "2,3" | awk -v var="$CHAR" '{print index($0, var)}')
                    POSCHAR3=$(expr $POSCHAR3 + 3 )
                    #echo "poschar1-2 $POSCHAR1 - $POSCHAR2"
                    FILE11=$(echo "$NOMFILENEW" | cut -c1-$POSCHAR1 )
                    #echo "file11 $FILE11"
                    FILE12=$(echo "$NOMFILENEW" | cut -c$POSCHAR2-$POSDELIM )
                    #echo "file12 $FILE12"
                    FILE13=$(echo "$NOMFILENEW" | cut -d "-" -f "2,3" | cut -c$POSCHAR3- )
                    #echo "file13 $FILE13"
                    CHERCHE1=$(find "${DOSS}"/* -type f -iname "*${FILE11}*" | wc -l)
                    CHERCHE2=$(find "${DOSS}"/* -type f -iname "*${FILE12}*" | wc -l)
                    CHERCHE3=$(find "${DOSS}"/* -type f -iname "*${FILE13}*" | wc -l)
                    
                    
                    if [[ -d "${DOSSIER2}/${FILE11}" || $CHERCHE1 -gt "${NBMIN}" ]]; then
                        
                        CREADOSS=$FILE11
                        CHERCHE=$CHERCHE1
                    elif [[ -d "${DOSSIER2}/${FILE12}" || $CHERCHE2 -gt "${NBMIN}" ]]; then
                        
                        CREADOSS=$FILE12
                        CHERCHE=$CHERCHE2
                    elif [[ -d "${DOSSIER2}/${FILE13}" || $CHERCHE3 -gt "${NBMIN}" ]]; then
                        
                        CREADOSS=$FILE13
                        CHERCHE=$CHERCHE3
                    fi
                else
                CREADOSS="${NOMFILENEW}"
                fi
                
             
                if [ -d "${DOSSIER2}/${CREADOSS}" ]; then
                    #NUMFILE0=$(find "${DOSSIER2}/${CREADOSS}"/* -type f | wc -l)
                    mv "$FILE" "${DOSSIER2}/${CREADOSS}/${NOMEXIST}" 2> >(tee -a $LOGREG)
                    if [[ $? -eq "0" ]]; then
                        echo -e "${PURPLE}Dossier cible ${CREADOSS} existant : déplacement du fichier ${NC}" | tee -a "${LOGREG}"
                    else
                        echo -e "${BOLD}${RED}ECHEC du déplacement du fichier ${NC}" | tee -a "${LOGREG}"
                        COUNTFILEFAIL=$(expr $COUNTFILEFAIL + 1 )
                    fi
                else 
                    CHERCHE=$(find "${DOSS}"/* -type f -iname "*${CREADOSS}*" | wc -l)
                    

                    if [ $CHERCHE -gt "${NBMIN}" ]; then
                        mkdir "${DOSSIER2}/${CREADOSS}" #2> >(tee -a $LOGREG)
                        mv "$FILE" "${DOSSIER2}/${CREADOSS}/${NOMEXIST}" 2> >(tee -a $LOGREG)
                        if [[ $? -eq "0" ]]; then
                            echo -e "${PURPLE}Dossier cible ${CREADOSS} inexistant : création du dossier et déplacement du fichier ($CHERCHE occurences) ${NC}" | tee -a "${LOGREG}"
                        else
                            echo -e "${BOLD}${RED}ECHEC du déplacement du fichier ${NC}" | tee -a "${LOGREG}"
                            COUNTFILEFAIL=$(expr $COUNTFILEFAIL + 1 )
                        fi
                    else
                        if [ -d "$DOSSIER3" ]; then
                            mv "$FILE" "$DOSSIER3/${NOMEXIST}" 2> >(tee -a $LOGREG)
                            if [[ $? -eq "0" ]]; then
                                echo -e "${PURPLE}trop peu d'occurences déplacement du fichier dans le dossier Divers ${NC}" | tee -a "${LOGREG}"
                            else
                                echo -e "${BOLD}${RED}ECHEC du déplacement du fichier ${NC}" | tee -a "${LOGREG}"
                                COUNTFILEFAIL=$(expr $COUNTFILEFAIL + 1 )
                            fi
                        else
                            mkdir "$DOSSIER3" 2> >(tee -a $LOGREG)
                            mv "$FILE" "$DOSSIER3/${NOMEXIST}" 2> >(tee -a $LOGREG)
                            if [[ $? -eq "0" ]]; then
                                echo -e "${PURPLE}trop peu d'occurences déplacement du fichier et création du dossier Divers ${NC}" | tee -a "${LOGREG}"
                            else
                                echo -e "${BOLD}${RED}ECHEC du déplacement du fichier  ${NC}" | tee -a "${LOGREG}"
                                COUNTFILEFAIL=$(expr $COUNTFILEFAIL + 1 )
                            fi
                        fi  
                    fi
                fi
            else
                echo -e  "${BOLD}${RED}Fichier inconnu, problème lors du renommage ${NC}"    
            fi
        done            
    
    else
        echo -e "${BOLD}aucun fichier à traiter pour ce dossier ${NC}" | tee -a "${LOGREG}"
    fi
    echo
    NBDOSSVIDES=$(find "${BASE}${SCENE}" -name "${DOSSORT}" -prune -o -type d -empty -print | wc -l)
    if [ $NBDOSSVIDES -ge "1" ]; then
        echo -e "${PURPLE}Suppression de $NBDOSSVIDES dossiers vides ${NC}" | tee -a "${LOGREG}"
        find "${BASE}${SCENE}" -name "${DOSSORT}" -prune -o -type d -empty -print -exec rmdir {} +
        
    fi    
done
echo "[`date`] - C'est fini $COUNTFILE fichiers traités" | tee -a "${LOGREG}"
echo -e "${BOLD}${RED}$COUNTFILEFAIL fichiers en anomalies${NC}" | tee -a "${LOGREG}"  