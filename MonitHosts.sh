#!/bin/bash

#Variaveis globais
opc=""
bkgdef=6
linha=`ls -l $0|head -n1`
tot_hosts=$#

#Inicio
if [ $tot_hosts -eq 0 ]
then
    echo "`tput rev;tput bold;tput setaf 6`Favor digitar pelo menos um host.`tput sgr0`"
    echo "Exemplo : $0 www.google.com"
    exit 0
fi

ctrl="echo $@"
nota="** Total de host = $tot_hosts **"
pass_hosts=$tot_hosts

#Zera o array de interrupções
for ctd_arr in `seq 1 $pass_hosts`
do
    ctd_queda[$ctd_arr]=0
done

clear
echo 
echo "`tput rev;tput bold;tput setaf 6`Monitoramento de Hosts`tput sgr0`"
echo `tput bold;tput setaf 6`$nota`tput sgr0`
while [ -z $opc ]
do
    for host_info in `eval "$ctrl"`
    do
        ctd_ver=0
        for tstping in {1..4}
        do
            if ping -c1 -w1 `echo $host_info|cut -d":" -f2` 1> /dev/null
            then
                ctd_ver=$((ctd_ver + 1))
            fi
        done
        if [ $ctd_ver -gt 2 ]
        then
            if [ "${stathost[$pass_hosts]}" = "1" ]
            then
                ctd_queda[$pass_hosts]=$((ctd_queda[$pass_hosts] + 1))
                stathost[$pass_hosts]="0"
            fi
            statcolr=3
            statbkg=6
            statmsg="Host ativo  "
        else
            statcolr=6
            statbkg=1
            statmsg="Host inativo"
            stathost[$pass_hosts]="1"
        fi
        nom_host=`echo $host_info|cut -d":" -f1`
        if [ $pass_hosts -eq $tot_hosts ]
        then
            tput cup 4 0
            tput bold
            tput setaf 6
            echo " Hora atual `date +'%H:%M:%S %p'`"
            tput sgr0
            tput setab $bkgdef
            tput setaf 0
            printf '_%.0s' {1..38}
            printf '\n'
        fi
        printf '|%-19s %15s |\n' "`tput setaf 0`$nom_host" "=>`tput bold;tput setaf $statcolr;tput setab $statbkg` $statmsg (${ctd_queda[$pass_hosts]}) `tput sgr0;tput setab $bkgdef;tput setaf 0`"
        pass_hosts=$((pass_hosts - 1))
        if [ $pass_hosts -eq 0 ]
        then
            tput setaf 0
            printf '_%.0s' {1..38}
            printf '\n'
            tput sgr0
            pass_hosts=$tot_hosts
        fi
    done
    echo
    echo "`tput bold;tput setaf 6`>>>Pressione qualquer tecla para sair<<<`tput sgr0`"
    read -rsn1 -t 5 opc
done
