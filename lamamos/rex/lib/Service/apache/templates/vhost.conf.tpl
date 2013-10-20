# ************************************
# Vhost template managed by (R)?ex
# ************************************

<VirtualHost *:<%= $variables->{port} %>>
  ServerName <%= $variables->{server_name} %>
<% if(defined $variables->{server_admin}) { %>
  ServerAdmin <%= $variables->{server_admin} %>
<% } %>

  DocumentRoot <%= $variables->{docroot} %>

# the directoryes of the web site
<% if(defined $variables->{directories}){ %>
  <% foreach(@{$variables->{directories}}){ %>
  <Directory <%= $_->{path} %>>
    AllowOverride <%= $_->{allow_override} || 'None' %>
    Order <%= $_->{order} || 'allow,deny' %>
    Allow from <%= $_->{allow_from} || 'all' %>
  </Directory>
  <% } %>
<% }else{ %>
  <Directory <%= $variables->{docroot} %>>
    AllowOverride None
    Order allow,deny
    Allow from all
  </Directory>
<% } %>

# the redirections
<% if(defined $variables->{redirections}){ %>
  <% for(keys $variables->{redirections}){ %>
  Redirect <%= $_ %> <%= $variables->{redirections}->{$_} %>
  <% } %>
<% } %>

<% if(defined $variables->{redirections_match}){ %>
  <% for(keys $variables->{redirections_match}){ %>
  RedirectMatch <%= $_ %> <%= $variables->{redirections_match}->{$_} %>
  <% } %>
<% } %>

# the ssl part
<% if( $variables->{ssl} ) { %>
  SSLEngine on
  SSLCertificateFile	<%= $variables->{ssl_cert} %>
  SSLCertificateKeyFile	<%= $variables->{ssl_key} %>
  SSLCACertificatePath	<%= $variables->{ssl_cert_dir} %>
  <FilesMatch "\.(cgi|shtml|phtml|php)$">
    SSLOptions +StdEnvVars
  </FilesMatch>
<% } %>
</VirtualHost>
