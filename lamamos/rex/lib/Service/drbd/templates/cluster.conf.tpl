cluster:
        node_count = 2
        name = ocfs2_drbd0

node:
        number = 0
        cluster = ocfs2_drbd0
        ip_port = 7777
        ip_address = <%= $variables->{firstServIP} %>
        name = <%= $variables->{firstServHostName} %>

node:
        number = 1
        cluster = ocfs2_drbd0
        ip_port = 7777
        ip_address = <%= $variables->{SeconServIP} %>
        name = <%= $variables->{SeconServHostName} %>

