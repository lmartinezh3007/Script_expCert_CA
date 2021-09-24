# Alienvault plugin
# Author: JUSI (Jefatura de Unidad de Seguridad Informatica) CENACE
# Plugin hillstone-ips id:20211 version: 0.0.1
# Last modification: 2021-02-07 
#
# Plugin Selection Info:
# hillstone:IPS:-
#
# END-HEADER
#
# Description:
#
#
#

[DEFAULT]
plugin_id=20211


[config]
type=detector
enable=yes

source=log
location=/var/log/alienvault/devices/10.71.108.3/10.71.108.3.log
create_file=false

process=
start=no
stop=no
startup=
shutdown=



#########################
#         RULES         #
#########################

[0001 - corero-ips - Rule 1]
event_type=event
#precheck=
regexp="(?P<Syslog_date>\d+-\d+-\d+\s\d+:\d+:\d+),\s(?P<Type>\w*@\w*):\s(?P<Severity>\w*)!\s\w+\s(?P<IP_Source>\d+.\d+.\d+.\d+):(?P<Port_Source>\d+)(?P<Interface>\(\w*/\d+\))\s\w+\s(?P<IP_Destination>\d+.\d+.\d+.\d+):(?P<Port_Destination>\d+)(?P<Eternet>\(\w*/\d+\)),\s\w*\s\w*:\s(?P<Treat_name>\w*\s\w*\s\w*\s\w*\s\w*\s\(\w*-\w*-\w*\)),\s\w*\s\w*:\s(?P<Threat_type>\w*),\s\w*\s\w*:\s(?P<Threat_subtype>\w*\s\w*).\s\w*/\w*:\s(?P<Protocol>\w*),\s\w*:\s\w*,\s\w*,\s\w*:\s\w*,\s\w*\s\w*:\s\d+,\s\w*:\s\w*-\w*,\s\w*\s\w*:\s(?P<Treat_severity>\w*)"
date={normalize_date($sys_date)}
plugin_sid={$sid}
device={resolv($device)}
src_ip={resolv($src_ip)}
dst_ip={resolv($dst_ip)}
src_port={$src_port}
dst_port={$dst_port}
protocol={$protocol}
userdata1={$id}
userdata2={$pt}
userdata3={$disp}
userdata4={$ckt}
userdata5={$type}
userdata6={$code}
userdata7={$src}
userdata8={$attack_id}
