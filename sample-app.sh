#!/bin/bash
set -euo pipefail

# Maak directories aan, indien ze nog niet bestaan
mkdir -p tempdir/templates
mkdir -p tempdir/static

# Kopieer bestanden
cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/.
cp -r static/* tempdir/static/.

# Dockerfile aanmaken
cat > tempdir/Dockerfile << _EOF_
FROM python
RUN pip install flask
COPY  ./static /home/myapp/static/
COPY  ./templates /home/myapp/templates/
COPY  sample_app.py /home/myapp/
EXPOSE 5050
CMD python /home/myapp/sample_app.py
_EOF_

# Verwijder bestaande container als die er is
if [ "$(docker ps -a -q -f name=samplerunning)" ]; then
    docker rm -f samplerunning
fi

# Verwijder bestaande image als die er is
if [ "$(docker images -q sampleapp)" ]; then
    docker rmi sampleapp
fi

# Bouw de Docker-image en start de container
cd tempdir || exit
docker build -t sampleapp .
docker run -t -d -p 5050:5050 --name samplerunning sampleapp

# Toon de status van alle containers
docker ps -a

