<VirtualHost *:80>
ServerName <%= $variables->{vhostAddress} %>
DocumentRoot /var/www/lists/
ErrorLog /var/log/apache2/lists-error.log
CustomLog /var/log/apache2/lists-access.log combined

<Directory /var/lib/mailman/archives/>
    Options FollowSymLinks
    AllowOverride None
</Directory>

<Directory /usr/lib/cgi-bin/mailman/>
    AllowOverride None
    Options ExecCGI
    AddHandler cgi-script .cgi
    Order allow,deny
    Allow from all
</Directory>
<Directory /var/lib/mailman/archives/public/>
    Options FollowSymlinks
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>
<Directory /usr/share/images/mailman/>
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>


Alias /pipermail/ /var/lib/mailman/archives/public/
Alias /images/mailman/ /usr/share/images/mailman/
ScriptAlias /admin /usr/lib/cgi-bin/mailman/admin
ScriptAlias /admindb /usr/lib/cgi-bin/mailman/admindb
ScriptAlias /confirm /usr/lib/cgi-bin/mailman/confirm
ScriptAlias /create /usr/lib/cgi-bin/mailman/create
ScriptAlias /edithtml /usr/lib/cgi-bin/mailman/edithtml
ScriptAlias /listinfo /usr/lib/cgi-bin/mailman/listinfo
ScriptAlias /options /usr/lib/cgi-bin/mailman/options
ScriptAlias /private /usr/lib/cgi-bin/mailman/private
ScriptAlias /rmlist /usr/lib/cgi-bin/mailman/rmlist
ScriptAlias /roster /usr/lib/cgi-bin/mailman/roster
ScriptAlias /subscribe /usr/lib/cgi-bin/mailman/subscribe
ScriptAlias /mailman/ /usr/lib/cgi-bin/mailman/
ScriptAlias / /usr/lib/cgi-bin/mailman/listinfo
</VirtualHost>

