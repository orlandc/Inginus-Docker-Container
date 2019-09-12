# Inginius-Docker-Container

## Instalacion de un Contenedor Inginius con aplicacion JuesUN

sudo docker run -d -p 80:80 -p 2222:22 -p443:443 -p 587:587 -p 3000:3000 -p 4567:4567 -p 8003:8003 -p 8088:8088 -p 27017:27017 -p 28017:28017 --name inginious --restart always -v /var/run/docker.sock:/var/run/docker.sock orlandc/inginious

## Instrucciones Obsoletas

Instrucciones para construir y desplegar el contenedor de Inginius-JuezUN

1. Primero se debe ejecutar el archivo Dockerfile con el siguiente comando

docker build -f Dockerfile -t omontenegro/inginiusdocker:v1.0 . 

2. Se hace el despliegue de la imagen con las configuraciones requeridas

docker run -d -p 80:80 -p 2222:22 -p443:443 -p 587:587 -p 3000:3000 -p 4567:4567 -p 8003:8003 -p 8088:8088 -p 27017:27017 -p 28017:28017 --name inginious --restart always -v /var/run/docker.sock:/var/run/docker.sock omontenegro/inginiusdocker:v1.0

## Nota Adicional

Se puede usar como manejador de Docker el Portainer el cual se despliega de la siguiente manera

docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
