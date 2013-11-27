global { usage-count no; }
common { syncer { rate 100M; } }
resource r0 {
        protocol C;

	handlers {

		pri-on-incon-degr "/usr/lib/drbd/notify-pri-on-incon-degr.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
		pri-lost-after-sb "/usr/lib/drbd/notify-pri-lost-after-sb.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
		local-io-error "/usr/lib/drbd/notify-io-error.sh; /usr/lib/drbd/notify-emergency-shutdown.sh; echo o > /proc/sysrq-trigger ; halt -f";
		fence-peer "/usr/lib/drbd/crm-fence-peer.sh";
	}

	disk{

		#fencing resource-and-stonith;
		#on-io-error detach;
	}

	net{

		#we don't allow two primaries for the begining of the installation
		#allow-two-primaries yes;


		#si la connection est idle on attendra ping-int secondes avant d envoyer un packet keep-alive
		ping-int 10;
		#timeout avant de considerer l autre noeud mort. en dixieme de secondes
		timeout 60;
		#tente de ce connecter a un autre noeud pendant ce temps en secondes.
		connect-int 10;
		#temps avant d abandoner le connection en attente de reception keep-alive. en dixieme de secondes.
		ping-timeout 5;



		after-sb-0pri discard-least-changes;
		after-sb-1pri consensus;
		after-sb-2pri call-pri-lost-after-sb;

		# Si le rôle du serveur est incompatible avec la resynchronisation des ressources : déconnexion
		#rr-conflict disconnect;


                cram-hmac-alg sha1;
		data-integrity-alg md5;
                shared-secret "<%= $variables->{drbdSharedSecret} %>";
	}





	startup {
		#attend ce temps en seconde pour l autre noeud au lancement du systeme
		wfc-timeout 15;
		#pareil temps d attente, mais si on est dans un cas degrade (un seul noeud la deniere fois)
		degr-wfc-timeout 60;
		#pareil mais en cas de outdated
		outdated-wfc-timeout 2;

		#We don't allow the fact of becomming a primari for now (at the begining of the install)
		#allow-two-primaries yes;
        }
        on <%= $variables->{firstServHostName} %> {
                device /dev/drbd0;
                disk <%= $variables->{ddName} %>;
                address <%= $variables->{firstServIP} %>:7788;
                meta-disk internal;
        }
        on <%= $variables->{SeconServHostName} %> {
                device /dev/drbd0;
                disk <%= $variables->{ddName} %>;
                address <%= $variables->{SeconServIP} %>:7788;
                meta-disk internal;
        }
}
