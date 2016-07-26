#!/bin/sh -x

ACTION=$1

DNSSERVER="${DNSSERVER:=8.8.8.8}"

DATADIR="${DATADIR:=/data}"

SERVER="${SERVER:=false}"

[ -n "${CLIENTIP}" ] && CLIENTIP=${ADVERTISEIP}

[ -n "${ADVERTISEIP}" ] && ADVERTISEIP="-advertise ${ADVERTISEIP}"

[ -n "${DATACENTER}" ] && DATACENTER="-dc ${DATACENTER}"

[ -n "${NAME}" ] && NAME="-node ${NAME}"


GetFirstIP(){
	firstip="$(ip add show eth0 |awk '/inet / { print $2 }'|cut -d "/" -f1)"
}


StartConsulAsServer(){
	GetFirstIP
	[ ! -f ${DATADIR} ] && mkdir -p ${DATADIR}
	SERVER="-server -bootstrap "
	CMD="/apps/consul agent ${ADVERTISEIP} ${NAME} ${SERVER} ${DATACENTER}\
	-data-dir=${DATADIR} -client ${CLIENTIP} -recursor=${DNSSERVER}"


	echo "CMD: ${CMD}"
	${CMD}

}

case $ACTION in
	start|START)
		[ "$SERVER" = "true" ] && StartConsulAsServer
	;;

	*)
		exec "$@"
	;;

esac
