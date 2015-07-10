#!/bin/bash
tail -n 3000 /var/log/apache2/*.access.log | awk '{print $2}' | sort |  uniq -c | sort -n

# apache log format should be vhost_combined (debian)
# LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
