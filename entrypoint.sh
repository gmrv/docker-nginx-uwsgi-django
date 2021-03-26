#/bin/bash

echo "uwsgi running..."
uwsgi --ini /etc/uwsgi/sites/firstsite.ini
uwsgi --ini /etc/uwsgi/sites/secondsite.ini

echo "nginx starting..."
service nginx start
#nginx -t
#nginx -s reload

python -m http.server 1111 --bind 0.0.0.0