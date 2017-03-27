PROJECT_NAME=rsyncd

build:
	docker-compose build

run:
	docker-compose -p "${PROJECT_NAME}" down
	docker-compose -p "${PROJECT_NAME}" up -d --build
	docker exec -t ${PROJECT_NAME}_rsyncd_1 bash -c 'cat /etc/rsyncd.conf'
#	docker inspect --format='{{(index (index .NetworkSettings.Ports "873/tcp") 0).HostPort}}' ${PROJECT_NAME}_rsyncd_1
	docker-compose logs -f
