# Instrucciones despliegue en local
Usaremos como ejemplo un proyecto llamado sampleproject

1. Clonación del repositorio en local

```sh
git clone git@github.com:daniunizar/laravel-api-template.git sampleproject
```

2. Accedemos al proyecto:
```sh
cd sampleproject
```

3. Modificamos el valor de server_name en el fichero docker/local/nginx/default.conf
```sh
server_name local.sampleproject.lan;
```

4. Generamos el fichero `docker/local/.env` que contendrá las variables de docker a partir de la plantilla `docker/local/.env`:
```sh
cp -v docker/local/.env.dist docker/local/.env
```

4. Modificamos los valores del fichero `docker/local/.env`

Los campos más comunes son:
```yaml
# Project configuration
PROJECT_NAME=sampleproject
PROJ_CLIENT=sampleclient
PROJ_DOMAIN=local.sampleproject.lan # Somos consecuentes con el valor de server_name de docker/local/nginx/default.conf

# Docker environment configuration
DOCKER_NETWORK_CIDR=192.17.203.0/24 #Utilizar una ip nueva en cada proyecto para evitar colisiones. Sistematizar el incremento

# Mysql
MYSQL_ROOT_PASSWORD=samplerootpassword
MYSQL_DATABASE=db_sampleproject
MYSQL_USER=dba_sampleproject
MYSQL_PASSWORD=samplepassword

# Mysql Testing
MYSQL_TESTING_ROOT_PASSWORD=samplepassword
MYSQL_TESTING_DATABASE=db_sampleproject-test
MYSQL_TESTING_USER=dba_sampleproject-test
MYSQL_TESTING_PASSWORD=samplepassword
```

5. Generamos el fichero `.env` en la raíz del proyecto a partir de `.env.example` de Laravel
```sh
cp -v .env.example .env
```

6. Modificamos los valores del fichero `.env`

Los campos más comunes son:

```yaml
APP_NAME=SampleProject
APP_ENV=local
APP_URL=http://local.sampleproject.lan # Somos consecuentes con el valor de server_name de docker/local/nginx/default.conf y PROJ_DOMAIN en este mismo fichero

DB_CONNECTION=mysql
DB_HOST=sampleclient-sampleproject_db #El valor es el nombre del contenedor de la base de datos. Se extrer de la variable MYSQL_CONTAINER_NAME del fichero .env del docker. Y es "${PROJ_CLIENT}-${PROJECT_NAME}_${MYSQL_HOSTNAME}", osea: cliente_proyecto_db
DB_PORT=3306
DB_DATABASE=db_sampleclient # Se extrae del MYSQL_DATABASE del .env de docker
DB_USERNAME=dba_sampleclient # Se extrae del MYSQL_USER del .env de docker
DB_PASSWORD=samplepassword # Se extrae del MYSQL_PASSWORD del .env de docker
```

7. Generamos el fichero `.env.testing` en la raíz del proyecto a partir de `.env.example` de Laravel
```sh
cp -v .env.example .env.testing
```

8. Modificamos los valores del fichero `.env.testing`

Los campos más comunes son:

```yaml
APP_NAME=SampleProject
APP_ENV=testing
APP_URL=http://local.sampleproject.lan # Somos consecuentes con el valor de server_name de docker/local/nginx/default.conf y PROJ_DOMAIN en este mismo fichero

DB_CONNECTION=mysql
DB_HOST=first-first_db-test # El valor es el nombre del contenedor de la base de datos de prueba. Se extrae de MYSQL_TESTING_CONTAINER_NAME="${PROJ_CLIENT}-${PROJECT_NAME}_${MYSQL_TESTING_HOSTNAME}" en el fichero .env de docker. cliente-projecto_db_test
DB_PORT=3306
DB_DATABASE=db_first-test # Se extrae del campo MYSQL_TESTING_DATABASE del .env de docker
DB_USERNAME=dba_first-test # Se extrae del campo MYSQL_TESTING_USER del .env de docker
DB_PASSWORD=DB@_2024!test # Se extrae del campo MYSQL_TESTING_PASSWORD del .env de docker 
```

9. Buildeamos
```sh
make build hard
```

10. Flujo de trabajo futuro:
Arrancar contenedores:
```sh
make start
```

Detener contenedores
```sh
make stop
```

Acceder a alguno de los contenedores:
```sh
make ssh php
make ssh db
```