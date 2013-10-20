#######################
# Parametres generaux #
#######################
# Nom de domaine de messagerie principal.
mydomain = martobre.fr
# Nom d'hote.
myhostname = serveur.martobre.fr
# Nom de domaine utilise pour les adresses incompletes.
myorigin = martobre.fr
 
# Activer l'ecoute IPv6.
inet_protocols = ipv4
 
# Les clients SMTP surs, qui auront plus de privileges
# (concretement, le droit d'utiliser ce serveur comme relais).
mynetworks = 127.0.0.0/8 [::1]/128 192.168.0.0/24
#mynetworks = 127.0.0.0/8, 164.60.87.201

################
# Serveur SMTP #
################
 
# Les noms de domaine pour lesquels on accepte le courrier.
mydestination = martobre.fr, serveur.martobre.fr, localhost, localhost.localdomain
# Si votre FAI ne vous permet pas de poster le courrier directement,
# utiliser son serveur SMTP comme relais en decommentant cette ligne.
relayhost =
 
#######################
# Distribution locale #
#######################
 
# Commande pour distribuer le courrier.
#mailbox_command = procmail -a "$EXTENSION"
mailbox_command = /usr/lib/dovecot/deliver
# Taille limite des BaL
mailbox_size_limit = 0
# Caractere separant le nom de destinataire d_un parametre additionnel
# (adresses « plussees », du type <untel+nawak@example.com> → <untel@example.com>)
recipient_delimiter = +



alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
virtual_alias_maps = hash:/etc/postfix/virtual


# TLS/SSL
smtpd_tls_security_level = may
smtpd_tls_loglevel = 1
smtpd_tls_cert_file = /ssl/certificat.crt
smtpd_tls_key_file = /ssl/certificat.key

<% if(defined $variables->{sasl_enabled}){ %>
# SASL
smtpd_sasl_auth_enable = yes
smtpd_sasl_local_domain = martobre.fr
smtpd_recipient_restrictions = permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination
smtpd_sasl_security_options = noanonymous
<% } %>


<% if(defined $variables->{spamassassin_enabled}){ %>
#spammassassin
spamassassin_destination_recipient_limit = 1
<% } %>
