UNAME := $(shell uname)

BROWSER=firefox
ifeq ($(UNAME), Darwin)
BROWSER=open
endif
ifeq ($(UNAME), Windows)
BROWSER=/cygdrive/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe
endif
ifeq ($(UNAME), CYGWIN_NT-6.3)
BROWSER=/cygdrive/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe
endif

doc: 
	cd docs; make html



adoc: man
	sphinx-apidoc -f -o docs/source/code/base ../base/cloudmesh_base
	sphinx-apidoc -f -o docs/source/code/client cloudmesh_client
	cd docs; make html
	cp -r scripts docs/build/html


d:
	rm -rf build
	pip uninstall -y cloudmesh_client
	pip uninstall -y cloudmesh_client
	python setup.py install; python cloudmesh_client/db/CloudmeshDatabase.py
	cm hpc run uname --cluster=india

db:
	rm ~/.cloudmesh/cloudmesh.db
	cm default list

test:
	echo $(UNAME)



publish:
	ghp-import -n -p docs/build/html

view:
	$(BROWSER) docs/build/html/index.html

man: cloudmesh
	cm man > docs/source/man/man.rst

# cm debug off')
# cm man | grep -A10000 \"Commands\"  | sed \$d  > docs/source/man/man.rst

cloudmesh:
	python setup.py install

log:
	gitchangelog | fgrep -v ":dev:" | fgrep -v ":new:" > ChangeLog
	git commit -m "chg: dev: Update ChangeLog" ChangeLog
	git push

######################################################################
# CLEANING
######################################################################

clean:
	rm -rf docs/build

######################################################################
# TAGGING
######################################################################

tag: log
	python setup.py tag

rmtag:
	python setup.py rmtag

######################################################################
# DOCKER
######################################################################

docker-mahine:
	docker-machine create --driver virtualbox cloudmesh

docker-machine-login:
	eval "$(docker-machine env cloudmesh)"

docker-build:
	docker build -t laszewski/cloudmesh .

# dockerhub
docker-login:
	docker login

docker-push:
	docker push laszewski/cloudmesh

docker-pull:
	docker pull laszewski/client

#
# does not work yet
#
docker-run:
	docker run -t -i cloudmesh /bin/bash

docker-clean-images:
	bin/docker-clean-images

