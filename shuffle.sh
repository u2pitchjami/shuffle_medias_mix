#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 5	                                     #
#									                                         #
#	NOM: u2pitchjami						                                 #
#									                                         #
#							  					                             #
#									                                         #
#	DATE: 08/09/2024	           				                             #
#									                                         #
#	BUT: Script shuffle Videos					                 		     #
#									                                         #
############################################################################## 
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source ${SCRIPT_DIR}/.config.cfg

rm -r ${OUTPUT}*
touch "${LOG}"
echo -e "${BOLD}[`date`] - Démarrage du programme${NC}" | tee -a "${LOG}"
echo | tee -a "${LOG}"
echo -e "Sauvegarde des stats..." | tee -a "${LOG}"
tar -czf ${DIRSAV_STATS}${BACKUP_STATS}.tar.gz ${STATS}
echo -e "Sauvegarde compressée: \e[32m${BACKUP_STATS}.tar.gz\e[0m\n" | tee -a "${LOG}"
echo -e "sauvegarde réalisée" | tee -a "${LOG}"
sleep 3
clear
if [ ! -z $1 ]
	then
	OPTION=$(echo $1 | tr '[:upper:]' '[:lower:]')
	if [ $OPTION == "all" ]
		then
		echo -e "${BOLD}[`date`] - Mode All activé${NC}" | tee -a "${LOG}"
	else
		echo "variable inconnue, mode normal activé"
		OPTION="normal"
	fi
	sleep 3
	clear
fi	
echo
choix_template() {
#######CHOIX DU TEMPLATE#######
echo -e "${SAISPAS}${BOLD}Choisis un Template :${NC}"
m=1
	for TEMPLATE in "${DOSSIERTEMPLATE}"*
	do
		TEMPLATENOM=$(echo $TEMPLATE | rev | cut -d "/" -f1 | rev) 
		echo ""$m") $TEMPLATENOM"
		declare POS${m}=$TEMPLATE
		m=$(expr $m + 1 )
	done
read REPONSE
REPONSE=$(echo POS$REPONSE)
REPONSE="${!REPONSE}"
NBDIR=$(cat "${REPONSE}" | wc -l) #nb dossiers dans le template choisi
NBFILES="0" #nb fichiers dans le template choisi
REPONSENOM=$(echo $REPONSE | rev | cut -d "/" -f1 | rev)
echo -e "${SAISPAS}${BOLD}Template choisi : $REPONSENOM${NC}"
echo "[`date`] - Template choisi : $REPONSENOM" >> "${LOG}"
echo -e "${BOLD}--> $NBDIR scènes et $NBFILES fichiers au total${NC}"
if [ -z $EXPRESS ]
	then
	controle_scenes
else
	traitement
fi
}
controle_scenes() {
NBMIN=0
NBMAX=0
NBMINMOY=0
NBMAXMOY=0
	#FILTRES
	echo -e "${BOLD}Création des filtres${NC}"
	for ((z=1 ;z<=$NBDIR ;z++))
        do
		NOMSCENE=$(cat "${REPONSE}" | head -$z | tail +$z | cut -d ";" -f2 | rev | cut -d "/" -f1 | rev)
        if [[ ! -f ${SCRIPT_DIR}/TEMP/filtre_doss1 ]]
            then
            touch ${SCRIPT_DIR}/TEMP/filtre_doss1
        fi
        cat ${SCRIPT_DIR}/TEMP/filtre_doss1 > ${SCRIPT_DIR}/TEMP/filtre_doss2
        cat ${STATSSCENES}${NOMSCENE}.csv | tail +2 | cut -d ";" -f2 | uniq >> ${SCRIPT_DIR}/TEMP/filtre_doss2
        cat ${SCRIPT_DIR}/TEMP/filtre_doss2 | sort | uniq > ${SCRIPT_DIR}/TEMP/filtre_doss1
        
        if [[ ! -f ${SCRIPT_DIR}/TEMP/filtre_reso1 ]]
            then
            touch ${SCRIPT_DIR}/TEMP/filtre_reso1
        fi
        cat ${SCRIPT_DIR}/TEMP/filtre_reso1 > ${SCRIPT_DIR}/TEMP/filtre_reso2
        cat ${STATSSCENES}${NOMSCENE}.csv | tail +2 | cut -d ";" -f4 | uniq >> ${SCRIPT_DIR}/TEMP/filtre_reso2
        cat ${SCRIPT_DIR}/TEMP/filtre_reso2 | sort | uniq > ${SCRIPT_DIR}/TEMP/filtre_reso1
		NBFILTRERESO=$(cat ${SCRIPT_DIR}/TEMP/filtre_reso1 | wc -l)
        
        if [[ ! -f ${SCRIPT_DIR}/TEMP/filtre_fps1 ]]
            then
            touch ${SCRIPT_DIR}/TEMP/filtre_fps1
        fi
        cat ${SCRIPT_DIR}/TEMP/filtre_fps1 > ${SCRIPT_DIR}/TEMP/filtre_fps2
        cat ${STATSSCENES}${NOMSCENE}.csv | tail +2 | cut -d ";" -f8 | uniq >> ${SCRIPT_DIR}/TEMP/filtre_fps2
        cat ${SCRIPT_DIR}/TEMP/filtre_fps2 | sort | uniq > ${SCRIPT_DIR}/TEMP/filtre_fps1
        NBFILTREFPS=$(cat ${SCRIPT_DIR}/TEMP/filtre_fps1 | wc -l)
	done
	echo -e "${SAISPAS}${BOLD}Souhaites tu appliquer des filtres sur ce template ? (y ou N) :${NC}"
	read REPFILTRE
	REPFILTRE=${REPFILTRE:-n}
                    if [ $REPFILTRE == "y" ]
                    then
					echo "nb reso"
					cat ${SCRIPT_DIR}/TEMP/filtre_reso1 | wc -l
                    echo -e "${BOLD}Quel dossier ? ${NC} (default: *)"
					read REPFILTREDOSS
					REPFILTREDOSS=${REPFILTREDOSS:-*}
					REPFILTREDOSS=$(echo "*${REPFILTREDOSS}*")
					if [ $NBFILTRERESO -gt "2" ]
					then
					echo -e "${BOLD}Quelle résolution ? ${NC} (default: 1920)"
					read REPFILTRERESO
					fi
					REPFILTRERESO=${REPFILTRERESO:-1920}
					REPFILTRERESO=$(echo "${REPFILTRERESO}")
					if [ $NBFILTREFPS -gt "2" ]
					then
					echo -e "${BOLD}Nombre d'images secondes (fps) ? ${NC} (default: 60)"
					read REPFILTREFPS
					fi
					REPFILTREFPS=${REPFILTRERFPS:-60}
					REPFILTREFPS=$(echo "${REPFILTREFPS}")
					
                    echo -e "${BOLD}Filtres sélectionnés : $REPFILTREDOSS ; $REPFILTRERESO ; $REPFILTREFPS${NC}" | tee -a "${LOGS}"
                    else
                    echo "Aucun filtre sélectionné" | tee -a "${LOGS}"
                    fi
					sleep 3
					clear
	for ((a=1 ;a<=$NBDIR ;a++))
        do
		NBMINDOS=$(cat "${REPONSE}" | head -$a | tail +$a | cut -d ";" -f3 | cut -d "-" -f1)
		NBMAXDOS=$(cat "${REPONSE}" | head -$a | tail +$a | cut -d ";" -f3 | cut -d "-" -f2)
		NBMIN=$(expr $NBMIN + $NBMINDOS )
		NBMAX=$(expr $NBMAX + $NBMAXDOS )
		SCENE=$(cat "${REPONSE}" | head -$a | tail +$a | cut -d ";" -f2 )
		SCENEORIGINALE=$(cat "${REPONSE}" | head -$a | tail +$a | cut -d ";" -f2 | rev | cut -d "/" -f1 | rev)
		NUMSCENE=$(cat "${REPONSE}" | head -$a | tail +$a | cut -d ";" -f1)		
		if [ $REPFILTRE == "y" ]
            then
			NBFICHIERSORI=$(grep -e ";${REPFILTREDOSS};" ${STATSSCENES}${SCENEORIGINALE}.csv | grep -e ";${REPFILTRERESO};" | grep -e ";${REPFILTREFPS};" | wc -l)
			if [ $NBFICHIERSORI -eq "0" ]
				then
				NBFICHIERSORI=$(grep -e "^${SCENEORIGINALE}" ${STATSSCENES}general.csv | cut -d ";" -f2)
			fi
		else
			NBFICHIERSORI=$(grep -e "^${SCENEORIGINALE}" ${STATSSCENES}general.csv | cut -d ";" -f2)
		fi
		DUREEORI=$(grep -e "^${SCENEORIGINALE}" ${STATSSCENES}general.csv | cut -d ";" -f3)
		DUREEMOYORI=$(grep -e "^${SCENEORIGINALE}" ${STATSSCENES}general.csv | cut -d ";" -f4)
		NBFILES=$(expr $NBFILES + $NBFICHIERSORI )
		DUREEORIMIN=$(expr $DUREEORI / 60 )
		DUREEMOYORIMIN=$(expr $DUREEMOYORI / 60 )
		DUREEMOYMINDOSS=$(expr $NBMINDOS \* $DUREEMOYORI )
		
		DUREEMOYMAXDOSS=$(expr $NBMAXDOS \* $DUREEMOYORI )
		NBMINMOY=$(expr $NBMINMOY + $DUREEMOYMINDOSS )
		NBMAXMOY=$(expr $NBMAXMOY + $DUREEMOYMAXDOSS )
		#echo -e "${BOLD}$SCENEORIGINALE - $NBFICHIERSORI fichiers - d'une durée totale de $DUREEORIMIN mins - moyenne $DUREEMOYORI sec ${NC}"
		#echo -e "${BOLD}Donc une durée de la scène entre $DUREEMOYMINDOSS et $DUREEMOYMAXDOSS secondes ${NC}"
		
	
	done
	NBMINMOY=$(expr $NBMINMOY / 60 )
	NBMAXMOY=$(expr $NBMAXMOY / 60 )
	echo
	echo -e "${BOLD}--> $NBDIR scènes et $NBFILES fichiers au total${NC}"
	echo "Il y aura au total entre $NBMIN et $NBMAX fichiers par cycle"
	echo "Soit une durée comprise entre $NBMINMOY et $NBMAXMOY minutes pour un cycle de ce template"
	traitement
	
}
traitement() {
#######CHOIX DU NB DE CYCLES#######
echo -e "${BOLD}Choix du nombre de cycles (entre 1 et ...)${NC}"
read NBCYCLE
if [ -z $EXPRESS ]
	then
	NBMINTOTAL=$(expr $NBMIN \* $NBCYCLE )
	NBMAXTOTAL=$(expr $NBMAX \* $NBCYCLE )
	NBMINMOY=$(expr $NBMINMOY \* $NBCYCLE )
	NBMAXMOY=$(expr $NBMAXMOY \* $NBCYCLE )
	echo "$NBCYCLE cycles, donc au total entre $NBMINTOTAL et $NBMAXTOTAL fichiers pour une durée entre $NBMINMOY et $NBMAXMOY minutes"
	sleep 3
fi
sleep 3
	for ((e=1; e<=$NBCYCLE; e++))
	do
		#######TRAITEMENT DES SCENES DU TEMPLATE#######
		for ((c=1; c<=$NBDIR; c++))
		do
			DN1=$(cat "${REPONSE}" | head -$c | tail +$c | cut -d ";" -f2 ) #scene du template
			DN2=$(echo $DN1 | rev | cut -d "/" -f1 | rev) #nom DN1 pour affichage
			#NBDIRTEMPLATE=$(find "${DN1}"/* -maxdepth 0 -type d -name "$DOSSORT" -prune -o -name "*" -print | wc -l)
			if [ $REPFILTRE == "y" ]
				then
				NBFILES1=$(grep -e ";${REPFILTREDOSS};" ${STATSSCENES}${DN2}.csv | grep -e ";${REPFILTRERESO};" | grep -e ";${REPFILTREFPS};" | wc -l)
				
				if [ $NBFILES1 -eq "0" ]; then
					NBDIRTEMPLATE=$(grep "^${DN2}" ${STATSSCENES}general.csv | cut -d ";" -f5 )
					NBFILES1=$(grep "^${DN2}" ${STATSSCENES}general.csv | cut -d ";" -f2 )
					else
					NBDIRTEMPLATE="1"
				fi
			else
				NBDIRTEMPLATE=$(grep "^${DN2}" ${STATSSCENES}general.csv | cut -d ";" -f5 )
				NBFILES1=$(grep "^${DN2}" ${STATSSCENES}general.csv | cut -d ";" -f2 )
			fi
			

			echo | tee -a "${LOG}"
			echo -e "${SAISPAS}${BOLD}[`date`] - $DN2${NC}" | tee -a "${LOG}"
			POUR=$((NBFILES1 *100 / NBFILES))
			echo "nombre de fichiers pour ce dossier : $NBFILES1, soit $POUR% du total"
			NB3=$(cat "${REPONSE}" | head -$c | tail +$c | cut -d ";" -f3| cut -d "-" -f1)
			NB4=$(cat "${REPONSE}" | head -$c | tail +$c | cut -d ";" -f3| cut -d "-" -f2)
			NBALE=$(shuf -i $NB3-$NB4 -n 1)
				for ((f=1; f<=$NBALE; f++))
				do
				#######TRAITEMENT DES VIDEOS DE LA SCENE#######
				if [ $REPFILTRE == "y" ]
					then
					NBFILES1=$(grep -e ";${REPFILTREDOSS};" ${STATSSCENES}${DN2}.csv | grep -e ";${REPFILTRERESO};" | grep -e ";${REPFILTREFPS};" | wc -l)
						if [ $NBFILES1 -eq "0" ]
							then
							echo "Aucun fichier avec les filtres définis"
							NBFILES1=$(grep -e ";${REPFILTRERESO};" ${STATSSCENES}${DN2}.csv | grep -e ";${REPFILTREFPS};" | wc -l)
							grep -e ";${REPFILTRERESO};" ${STATSSCENES}${DN2}.csv | grep -e ";${REPFILTREFPS};" | cut -d ";" -f 9 >> "${SCRIPT_DIR}/TEMP/${DN2}TEMP" 
							if [ $NBFILES1 -eq "0" ]
							then
							cat ${STATSSCENES}${DN2}.csv | tail +2 | cut -d ";" -f 9 >> "${SCRIPT_DIR}/TEMP/${DN2}TEMP"
							fi
						else
							grep -e ";${REPFILTREDOSS};" ${STATSSCENES}${DN2}.csv | grep -e ";${REPFILTRERESO};" | grep -e ";${REPFILTREFPS};" | cut -d ";" -f 9 >> "${SCRIPT_DIR}/TEMP/${DN2}TEMP"
						fi
					VIDEO=$(shuf -n 1 "${SCRIPT_DIR}/TEMP/${DN2}TEMP")	
				else
					if [ "$OPTION" == "all" ]
						then
						cat ${STATSSCENES}${DN2}.csv | tail +2 | cut -d ";" -f 9 >> "${SCRIPT_DIR}/TEMP/${DN2}TEMP"
						VIDEO=$(shuf -n 1 "${SCRIPT_DIR}/TEMP/${DN2}TEMP")
					else
						NUMALEDN3=$(shuf -i 1-$NBDIRTEMPLATE -n 1)
						DN4=$(cat ${STATSSCENES}${DN2}.csv | cut -d ";" -f 2 | tail +2 | uniq | head -$NUMALEDN3 | tail +$NUMALEDN3 )
						grep -e ";${DN4};" ${STATSSCENES}${DN2}.csv | cut -d ";" -f9 >> "${SCRIPT_DIR}/TEMP/${DN2}-${DN4}TEMP"
						VIDEO=$(shuf -n 1 "${SCRIPT_DIR}/TEMP/${DN2}-${DN4}TEMP")
					fi
				fi
				echo "$VIDEO" >> ${SCRIPT_DIR}/TEMP/TEMP2
				VIDEONOM=$(echo "$VIDEO" | rev | cut -d "/" -f1 | rev)
				DOSSSCENE=$(echo "$VIDEO" | rev | cut -d "/" -f2 | rev)
				echo -e "${BOLD}Source : $DOSSSCENE ${NC}" | tee -a "${LOG}"
				echo "Video : $VIDEONOM" |tee -a "${LOG}"
				done
		done
	done
echo | tee -a "${LOG}"	
echo -e "${SAISPAS}[`date`] - ${BOLD}Export des fichiers${NC}" | tee -a "${LOG}"
NBTOT=$(cat ${SCRIPT_DIR}/TEMP/TEMP2 | wc -l)
	for ((d=1; d<=$NBTOT; d++))
	do
		#######TRAITEMENT DE LA NUMEROTATION#######
		NBCAR=$(echo $d | wc -m)
		if [ $NBCAR = 2 ]
			then
			E="00$d"
		elif [ $NBCAR = 3 ]
			then
			E="0$d"
		else
			E="$d"
		fi
		#######EXPORT DES FICHIERS#######
		NOMFICHIERORI=$(cat ${SCRIPT_DIR}/TEMP/TEMP2 | head -$d | tail +$d )
		NOMFICHIEREXPORT=$(cat ${SCRIPT_DIR}/TEMP/TEMP2 | head -$d | tail +$d | rev | cut -d"/" -f1 | rev)
		NOMSOUSSCENEEXPORT=$(cat ${SCRIPT_DIR}/TEMP/TEMP2 | head -$d | tail +$d | rev | cut -d"/" -f2 | rev)
		NOMSCENEEXPORT=$(cat ${SCRIPT_DIR}/TEMP/TEMP2 | head -$d | tail +$d | rev | cut -d"/" -f3 | rev)
		ORISCENE=$(readlink -f "$NOMFICHIERORI")
		SCENEORI=$(echo "$ORISCENE" | rev | cut -d"/" -f3 | rev)
		
		
		echo "${E}-${NOMSCENEEXPORT}-${NOMFICHIEREXPORT} ..." | tee -a "${LOG}"
		cat ${SCRIPT_DIR}/TEMP/TEMP2 | head -$d | tail +$d | xargs -I {} cp {} "${OUTPUT}${E}-${NOMSCENEEXPORT}-${NOMFICHIEREXPORT}"
		if [[ -f "${OUTPUT}${E}-${NOMSCENEEXPORT}-${NOMFICHIEREXPORT}" ]]
 			then
			echo -e "${GREEN}Export OK${NC}" | tee -a "${LOG}"
			echo "file '${OUTPUT}${E}-${NOMSCENEEXPORT}-${NOMFICHIEREXPORT}'" >> ${SCRIPT_DIR}/TEMP/TEMPMERGE
			if [ -z $MERGEOK ]
				then
				COMPARE=$(grep -e "^${NOMFICHIEREXPORT}" ${STATSSCENES}${SCENEORI}.csv | cut -d";" -f3,4,5,8 )
				MERGEOK="1"
			else
				COMPARE2=$(grep -e "^${NOMFICHIEREXPORT}" ${STATSSCENES}${SCENEORI}.csv | cut -d";" -f3,4,5,8 )
				if [[ $MERGEOK -eq "0" || $COMPARE != $COMPARE2 ]]
					then
					MERGEOK="0"
					echo -e "${BOLD}Fichiers différents, fusion automatique impossible ${NC}"
				fi
			fi
		else
			echo -e "${RED}Echec de l'export !!!!${NC}" | tee -a "${LOG}"
		fi
		
		#fi
		if [[ ! -f ${STATS}template.csv ]]
 			then
			touch ${STATS}template.csv
			echo "template;nb;date_last" >> ${STATS}template.csv
		fi
		NUMEXIST=$(echo "$NOMFICHIEREXPORT" | rev | cut -d"/" -f1 | cut -d"." -f2 | cut -c1-6 | rev)
		#echo "numexist $NUMEXIST"
        FILEEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}")
		#echo "FILEEXIST $FILEEXIST"
            if [ -n "$FILEEXIST" ]
                then
                echo -e "id $NUMEXIST existant" | tee -a "${LOGREG}"
				
                NOMEXIST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f2 )
		
			
				EXPORT2=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f1,2,3,4,5,6 )
				EXPORTNB=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f7 )
				EXPORTNBPLUS=$(expr $EXPORTNB + 1 )
				#sed -i "s:"$FILEEXIST":"$EXPORT2";"$EXPORTNBPLUS":" ${RECAP}
				#sed -i ""$NUMLINE"s|$|$EXPORTNBPLUS|" ${RECAP}
				#MODIFRECAP=$(awk -v var="$NUMEXIST" -v var2="$EXPORTNBPLUS" -F ";" '$1 == var {sub($8, 1); print}' ${RECAP})
				sed -i "/^"$NUMEXIST"/d" "${RECAP}"
                echo ""$EXPORT2";"$EXPORTNBPLUS"" >> "${RECAP}"
				EXPORTNBTEST=$(grep -e "^${NUMEXIST}" "${RECAP}" | cut -d ";" -f7 )
				if [ $EXPORTNBTEST -eq $EXPORTNBPLUS ]
					then
					echo -e "${GREEN}INCREMENTATION OK ${NC}" | tee -a "${LOGREG}"
					else
					echo -e "${RED}ECHEC DE L'INCREMENTATION !!! ${NC}" | tee -a "${LOGREG}"
				fi
		else
			echo -e "${RED}fichier inconnu !!! ${NC}" | tee -a "${LOGREG}"
		fi
	done
echo -e "[`date`] - ${BOLD}Export terminé${NC}"	| tee -a "${LOG}"
	TEMPLATEIN=$(grep -e "^${REPONSENOM}" ${STATS}template.csv)
    if [[ -n $TEMPLATEIN ]]
		then
		TEMPLATENB=$(grep -e "^${REPONSENOM}" ${STATS}template.csv | cut -d ";" -f2 )
		TEMPLATENBPLUS=$(expr $TEMPLATENB + 1 )
		
		sed -i "s/"$TEMPLATEIN"/"$REPONSENOM";"$TEMPLATENBPLUS";"$DATE"/" ${STATS}template.csv
	else
		echo "${REPONSENOM};1;${DATE}" >> ${STATS}template.csv
	fi

DUREEOUTPUTTOTAL=0
NBFICHIERSOUTPUT=$(find $OUTPUT* -iname "*.mp4" | wc -l)
for ((y=1; y<=$NBFICHIERSOUTPUT; y++))
do
	NUMFICHIEROUTPUT=$(find $OUTPUT* -iname "*.mp4" | head -$y | tail +$y)
	DUREEOUTPUT=$(ffprobe -v quiet -of csv=p=0 -show_entries format=duration "$NUMFICHIEROUTPUT")
	DUREEOUTPUTTOTAL=$(echo "($DUREEOUTPUTTOTAL + $DUREEOUTPUT) /1 " |bc)
done
DUREEOUTPUTTOTALMINUTES=$(expr $DUREEOUTPUTTOTAL / 60 )

if [[ $MERGEOK -eq "1" ]]
	then
	echo -e "${BOLD}${SAISPAS}[`date`] - Fichiers compatibles, démarrage de la fusion${NC}" | tee -a "${LOG}"
	echo -e "${BOLD}${GREEN} $NBFICHIERSOUTPUT fichiers pour une durée de $DUREEOUTPUTTOTALMINUTES minutes${NC}" | tee -a "${LOG}"
	MERGECOUNT=$(find "$MERGE"/* -type f -iname "${REPONSENOM}*" | wc -l)
	MERGECOUNT=$(expr $MERGECOUNT + 1 )
	ffmpeg -f concat -safe 0 -i ${SCRIPT_DIR}/TEMP/TEMPMERGE -c copy "${MERGE}/${REPONSENOM}-${MERGECOUNT}.mp4"
	echo
	echo -e "${BOLD}${GREEN}[`date`] - Fusion terminée de $NBFICHIERSOUTPUT fichiers \n d'une durée de $DUREEOUTPUTTOTALMINUTES minutes${NC}" | tee -a "${LOG}"
	echo -e "${BOLD}Fichier ${REPONSENOM}-${MERGECOUNT}.mp4 placé dans le dossier Merge... Enjoy ;-)${NC}" | tee -a "${LOG}"
	else
	echo
	echo -e "${BOLD}${RED}[`date`] - Fusion impossible${NC}" | tee -a "${LOG}"
	echo -e "${BOLD}$NBFICHIERSOUTPUT fichiers pour une durée totale de $DUREEOUTPUTTOTALMINUTES minutes${NC}" |tee -a "${LOG}"
	echo -e "Fichiers disponibles dans le dossier Output... ;-)${NC}" | tee -a "${LOG}"
	fi
rm -r ${SCRIPT_DIR}/TEMP
}
choix_template