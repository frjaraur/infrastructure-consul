#!/bin/sh -x

ACTION=$1

DNSSERVER="${DNSSERVER:=8.8.8.8}"

DATADIR="${DATADIR:=/data}"

SERVER="${SERVER:=false}"

CLIENTIP="${CLIENTIP:=0.0.0.0}"


CLIENTIP="-client ${CLIENTIP}"

[ -n "${ADVERTISEIP}" ] && ADVERTISEIP="-advertise ${ADVERTISEIP}"

[ -n "${DATACENTER}" ] && DATACENTER="-dc ${DATACENTER}"

[ -n "${NAME}" ] && NAME="-node ${NAME}"

[ -n "${DNSSERVER}" ] && DNSSERVER="-recursor=${DNSSERVER}"

if [ -n "${MASTERIP}" ]
then
	if [ $(echo ${MASTERIP}|grep -c ",") -ne 0 ]
	then
		MASTERIPS="$(echo ${MASTERIP}|sed -e "s/,/ /g")"
		for IP in ${MASTERIPS}
		do
			TMPJOIN="-retry-join ${MASTERIP} ${TMPJOIN}"
		done
			JOIN=${TMPJOIN}
	else
		JOIN="-retry-join ${MASTERIP}"
	fi
fi

GetFirstIP(){
	firstip="$(ip add show eth0 |awk '/inet / { print $2 }'|cut -d "/" -f1)"
}


StartConsulAsServer(){
	GetFirstIP
	[ ! -f ${DATADIR} ] && mkdir -p ${DATADIR}
	SERVER="-server"
	[ ! -n "${MASTERIP}" ] && SERVER="${SERVER} -bootstrap "
	CMD="/apps/consul agent ${JOIN} ${ADVERTISEIP} ${NAME} ${SERVER} ${DATACENTER}\
	-data-dir=${DATADIR} ${CLIENTIP} ${DNSSERVER}"


	echo "CMD: ${CMD}"
	${CMD}

}

StartConsulAsAgent(){
	GetFirstIP
	[ ! -f ${DATADIR} ] && mkdir -p ${DATADIR}

	CMD="/apps/consul agent ${JOIN} ${ADVERTISEIP} ${NAME} ${DATACENTER}\
	-data-dir=${DATADIR} ${CLIENTIP} ${DNSSERVER}"

	echo "CMD: ${CMD}"
	${CMD}

}


case $ACTION in
	start|START)
		[ "$SERVER" = "true" ] && StartConsulAsServer && exit 0

	;;

	*)
		exec "$@"
	;;

esac
