FROM python:3.7
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
    && apt-get -y dist-upgrade \
    && apt-get install -y nginx
    
WORKDIR /webapp
COPY ./requirements.txt /webapp    
RUN pip install --upgrade pip
RUN pip install -r /webapp/requirements.txt  

RUN pip install uwsgi 

# Copy existing django projects
#
COPY ./firstsite /webapp/firstsite
WORKDIR /webapp/firstsite
RUN python manage.py collectstatic --noinput

COPY ./secondsite /webapp/secondsite
WORKDIR /webapp/secondsite
RUN python manage.py collectstatic --noinput

# uWSGI configuration
#
RUN mkdir -p /etc/uwsgi/sites
COPY ./uwsgi-config/firstsite.ini /etc/uwsgi/sites
COPY ./uwsgi-config/secondsite.ini /etc/uwsgi/sites
#COPY ./uwsgi-config/uwsgi.service /etc/systemd/system
RUN mkdir -p /run/uwsgi                             # Тут появится *.socks файл, после запуска uwsgi
#RUN chown root:www-data /run/uwsgi

# nginx configuration
#
COPY ./nginx-config/firstsite /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/firstsite /etc/nginx/sites-enabled
COPY ./nginx-config/secondsite /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/secondsite /etc/nginx/sites-enabled

# Lets encrypt
#
#RUN apt-get install certbot -y

# Create and run entrypoint script
# Не получилось запустить uwsgi через docker-compouse.yml
# 
RUN mkdir /root/.ssh
RUN chmod go-rwx /root/.ssh/
COPY ./nginx-config/localhost.crt /root/.ssh/
COPY ./nginx-config/localhost.key /root/.ssh/
RUN chmod go-rwx /root/.ssh/localhost.crt /root/.ssh/localhost.key

COPY ./entrypoint.sh /webapp
RUN chmod +x /webapp/entrypoint.sh
CMD ["bash", "/webapp/entrypoint.sh"]





