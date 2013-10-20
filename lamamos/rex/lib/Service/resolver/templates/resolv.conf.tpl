domain <%= $variables->{domain_name} %>
search <%= join(" ", @{$variables->{search_path}}); %>

<% foreach(@{$variables->{name_servers}}){ %>nameserver <%= $_ %>
<% } %>
