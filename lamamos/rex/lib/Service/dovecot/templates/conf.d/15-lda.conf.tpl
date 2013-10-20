##
## LDA specific settings (also used by LMTP)
##

# Address to use when sending rejection mails.
# Default is postmaster@<your domain>.
#postmaster_address =
<% if($variables->{postmaster_address}){ %>
postmaster_address = <%= $variables->{postmaster_address} %>
<% } %>

# Hostname to use in various parts of sent mails, eg. in Message-Id.
# Default is the system's real hostname.
#hostname =
<% if($variables->{hostname}){%>
hostname = <%= $variables->{hostname} %>
<% } %>

# If user is over quota, return with temporary failure instead of
# bouncing the mail.
#quota_full_tempfail = no

# Binary to use for sending mails.
#sendmail_path = /usr/sbin/sendmail

# Subject: header to use for rejection mails. You can use the same variables
# as for rejection_reason below.
#rejection_subject = Rejected: %s

# Human readable error message for rejection mails. You can use variables:
# %n = CRLF, %r = reason, %s = original subject, %t = recipient
#rejection_reason = Your message was automatically rejected:%n%r

# Delimiter character between local-part and detail in email address.
#recipient_delimiter = +

# Header where the original recipient address (SMTP's RCPT TO: address) is taken
# from if not available elsewhere. With dovecot-lda -a parameter overrides this.
# A commonly used header for this is X-Original-To.
#lda_original_recipient_header =

# Should saving a mail to a nonexistent mailbox automatically create it?
#lda_mailbox_autocreate = no

# Should automatically created mailboxes be also automatically subscribed?
#lda_mailbox_autosubscribe = no

protocol lda {
  # Space separated list of plugins to load (default is global mail_plugins).
  #mail_plugins = $mail_plugins
<% if($variables->{lda_mail_plugins}){ %>
  mail_plugins = <%= $variables->{lda_mail_plugins} %>
<% } %>
}
