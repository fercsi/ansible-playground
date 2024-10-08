FAMILIES := debian ubuntu redhat almalinux
DEBIAN_VERSIONS := deb11 deb12
UBUNTU_VERSIONS := u20 u22 u24
REDHAT_VERSIONS := rh8 rh9
ALMALINUX_VERSIONS := alma8 alma9
ALL_VERSIONS = $(DEBIAN_VERSIONS) $(UBUNTU_VERSIONS) $(REDHAT_VERSIONS) $(ALMALINUX_VERSIONS)

MKD = util/mkdocker.py
TESTIMG = util/testimg.sh
DBUILD = docker build
DPUSH = docker push
REPO = fercsi/ansible-playground

########################################
# CREATE Dockerfiles

.PHONY: create-hosts
create-hosts: $(addprefix create-, $(FAMILIES))

.PHONY: create-debian
create-debian: $(addprefix create-, $(DEBIAN_VERSIONS))

.PHONY: create-ubuntu
create-ubuntu: $(addprefix create-, $(UBUNTU_VERSIONS))

.PHONY: create-redhat
create-redhat: $(addprefix create-, $(REDHAT_VERSIONS))

.PHONY: create-almalinux
create-almalinux: $(addprefix create-, $(ALMALINUX_VERSIONS))

# per file

CREATE_ALL_VERSIONS = $(addprefix create-, $(ALL_VERSIONS))

.PHONY: $(CREATE_ALL_VERSIONS)
$(CREATE_ALL_VERSIONS): create-%: hosts/Dockerfile.%

hosts/Dockerfile.deb%: templates/Dockerfile-debian
	$(MKD) debian deb$* debian:$*

hosts/Dockerfile.u%: templates/Dockerfile-debian
	$(MKD) debian u$* ubuntu:$*.04

hosts/Dockerfile.rh%: templates/Dockerfile-redhat
	$(MKD) redhat rh$* redhat/ubi$*

hosts/Dockerfile.alma%: templates/Dockerfile-redhat
	$(MKD) redhat alma$* almalinux:$*

########################################
# BUILD IMAGES

.PHONY: build-hosts
build-hosts: $(addprefix build-, $(FAMILIES))

.PHONY: build-debian
build-debian: $(addprefix build-, $(DEBIAN_VERSIONS))

.PHONY: build-ubuntu
build-ubuntu: $(addprefix build-, $(UBUNTU_VERSIONS))

.PHONY: build-redhat
build-redhat: $(addprefix build-, $(REDHAT_VERSIONS))

.PHONY: build-almalinux
build-almalinux: $(addprefix build-, $(ALMALINUX_VERSIONS))

.PHONY: build-%
build-%:
	$(DBUILD) -t $(REPO):$*-host -f hosts/Dockerfile-$* hosts

########################################
# BUILD IMAGES

.PHONY: test-hosts
test-hosts: $(addprefix test-, $(FAMILIES))

.PHONY: test-debian
test-debian: $(addprefix test-, $(DEBIAN_VERSIONS))

.PHONY: test-ubuntu
test-ubuntu: $(addprefix test-, $(UBUNTU_VERSIONS))

.PHONY: test-redhat
test-redhat: $(addprefix test-, $(REDHAT_VERSIONS))

.PHONY: test-almalinux
test-almalinux: $(addprefix test-, $(ALMALINUX_VERSIONS))

.PHONY: test-%
test-%:
	$(TESTIMG) $(REPO):$*-host

########################################
# PUSH TO DOCKER HUB

.PHONY: push-hosts
push-hosts: $(addprefix push-, $(FAMILIES))

.PHONY: push-debian
push-debian: $(addprefix push-, $(DEBIAN_VERSIONS))

.PHONY: push-ubuntu
push-ubuntu: $(addprefix push-, $(UBUNTU_VERSIONS))

.PHONY: push-redhat
push-redhat: $(addprefix push-, $(REDHAT_VERSIONS))

.PHONY: push-almalinux
push-almalinux: $(addprefix push-, $(ALMALINUX_VERSIONS))

.PHONY: push-%
push-%:
	$(DPUSH) $(REPO):$*-host
