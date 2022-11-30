#!/bin/bash
# Vacia de la papelera de Alfresco elementos antiguos
# JM Vilarino
# 7/11/2016

USER=admin
PASS=bHij2b23
ALFRESCOURL=http://10.147.122.30/alfresco # clon 7.2
ALFRESCOURL=http://10.147.122.27/alfresco # clon 5.1

####################################################################################################################################################################

>>empty_trash.log
{
echo "$(date  +'%Y-%m-%d %H:%M:%S')| Obtener ticket ..."
ticket=$(curl -X POST -s -k -H "Content-Type: application/json" -d "{'username':'$USER','password':'$PASS'}" ${ALFRESCOURL}/s/api/login | grep ticket | cut -d\" -f4)
echo "$(date  +'%Y-%m-%d %H:%M:%S')| Ticket: ${ticket}"
if [ "$ticket" == "" ]; then
	echo "Error, no se ha obtenido el ticket"
	exit
fi

OUTFILE=.empty_trash.cont.txt
last=""
[ -e $OUTFILE ] && last=$(cat $OUTFILE)
if [ "$last" == "" ]; then
	last=1
fi
cont=1
while read line; do
	if [ $cont -ge $last -a "$(echo $line | grep -v '\-\-\-\-\-\-\-\-' | grep  '.*\-.*\-.*\-.*\-.*')" != "" ]; then
		id=$(echo $line | sed -e 's/\r//g' | sed -e 's/\n//g')
		echo "$(date  +'%Y-%m-%d %H:%M:%S')| $cont | Borrar elemento de la papelera: ${id}"
		curl -X DELETE -s -k --output /dev/null "${ALFRESCOURL}/s/api/archive/archive/SpacesStore/${id}?alf_ticket=${ticket}"
	else
		echo "$(date  +'%Y-%m-%d %H:%M:%S')| $cont | se omite $line"
	fi
	((cont+=1))
	echo $cont > $OUTFILE
done < archivednodes.log


} 2>&1 | tee -a empty_trash.log

#
# Consulta en oracle
#
#SET DEFINE OFF
#SET ECHO OFF
#SET SERVEROUTPUT OFF
#SET TERMOUT OFF
#SET VERIFY OFF
#SET FEEDBACK OFF
#SET PAGESIZE 10000
#SET ARRAYSIZE 5000
#REM SET HEAD OFF
#SET LINE 500
#spool archivednodes.log;
#SELECT childNode.uuid
#FROM alf_child_assoc assoc
#JOIN alf_node parentNode ON (parentNode.id = assoc.parent_node_id)
#JOIN alf_store parentStore ON (parentStore.id = parentNode.store_id)
#JOIN alf_node childNode ON (childNode.id = assoc.child_node_id)
#JOIN alf_store childStore ON (childStore.id   = childNode.store_id)
#WHERE qname_localname='archivedItem'
#AND parentNode.id = (SELECT root_node_id FROM alf_store WHERE protocol ='archive' and identifier ='SpacesStore');
#spool off;

#
# Consulta en PostgreSQL 
#
#  psql -p 5432 -h tcls13pa -d alfresco5mock_bd -U postgres
#\copy ( SELECT childNode.uuid FROM alf_child_assoc assoc JOIN alf_node parentNode ON (parentNode.id = assoc.parent_node_id) JOIN alf_store parentStore ON (parentStore.id = parentNode.store_id) JOIN alf_node childNode ON (childNode.id = assoc.child_node_id)  JOIN alf_store childStore ON (childStore.id   = childNode.store_id)  WHERE qname_localname='archivedItem' AND parentNode.id = (SELECT root_node_id FROM alf_store WHERE protocol ='archive' and identifier ='SpacesStore') ) To '/tmp/archivednodes.log' With CSV DELIMITER ',' HEADER 

