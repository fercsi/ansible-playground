# Ansible Playground

This   configuration  has   been  created   for  developers   or  system
administrators  who would  like to  practice using  ansible, but  have a
single Linux  environment. Instead  of creating  multiple VM-s,  you can
simply create some docker containers. Using this configuration, you just
have to install docker and docker  compose and use the command to create
the environment:

```
docker-compose up -d
```

## Default environment

To practice the use of ansible we created a simple playground. The
default configuration can be seen on the following figure.

            +------------+
            | controller |
            +------------+
                   | private nw
        +----------+----------+
        |          |          |
    +-------+  +-------+  +-------+
    | host1 |  | host2 |  | host3 |
    +-------+  +-------+  +-------+

If you  need a more  complex environment, you  can create your  own one.
There are some hints in
[Create alternative configurations](#create-alternative-configurations).
below.

### Ansible controller (`controller`)

Server is based  on a simple Debian  distribution (`bookworm-slim`), but
there are some  handy tools installed. The most  important is `ansible`,
but also `less` and `vim` can be very helpful during the tests.

During  the first  run's initialization,  server connects  to hosts  and
stores fingerprints of them in `known\_hosts`, so hosts  can be accessed
from server easily. Also, ansible inventory is configured.

### Ansible host (`host1`..`host3`)

Similarly to the server, hosts are also based on Debian. On hosts Python
3  is installed,  because ansible  needs  it to  proceed tasks.  Ansible
itself  is  not  installed,  because  it has  to  be  installed  on  the
controller only.

## Login to Ansible server

To login to the ansible server (`controller`):

```
docker exec -it controller /bin/bash
```

Alternatively, you can determine the IP  address of the server and login
with ssh. To get IP address(es):

```
docker inspect -f '{{.NetworkSettings.Networks.ansible_default.IPAddress}}' controller
```

Note, that ansible  controller has 2 IP  adresses if the hosts  are on a
private  network. The  previous  command  prints only  the  ones on  the
default network.

```
ssh root@<IP address>
```

Using a single command:

```
ssh root@$(docker inspect -f '{{.NetworkSettings.Networks.ansible_default.IPAddress}}' controller)
```

## Using the playground

Using the  default configuration,  you can easily  access all  the hosts
from the controller (without entering a password):

```
ssh host1
```

This  is important  for  ansible to  connect easily  to  them. To  check
whether ansible  can also  connect to  all of the  hosts defined  in the
inventory  -  `/etc/ansible/hosts`  (this  is  configured  automatically
during the initialization of the ansible server):


```
$ ansible all -m ping
```

Alternatively, if local host's work directory is bind mounted (default):

```
$ ./check.sh
```

Note: if you login with ssh, change to directory `/var/work`. If you use
the docker exec method, directory is selected automatically.


## Create alternative configurations

You can derive your own server  and host docker images from the default,
but in most cases they are sufficient for all needsx. You can create any
configurations built on them.

### Different hosts

To  add simply  more hosts,  or you  would like  to rename  them, simply
modify  `docker-compose` accordingly.  Add or  remove containers  if the
number  of containers  does  not  match your  needs  and  change both  `
hostname` and `container_name`.

Initialization process  creates ansible `hosts`,  so you have  to inform
ansible controller this change setting environment variable `APG_HOSTS`.
So  add   the  followings  to   the  ansible  server   configuration  in
`docker-compose`, if you renamed your hosts:

```
    environment:
        APG_HOSTS: frontend backend db
```

Similarly, update `depends_on`. This is necessary for the initialization
phase, so that the controller can connect to the hosts.

### Different host configuration

If you need  a more complex configuration (e.g.  grouping hosts), create
your own inventory (`hosts` file), upload  it to the server (the easiest
way is to simply put it  into the work directory somewhere, but creating
your own Docker image  can be also a way) and pass the  path of the file
in the environment variable `APG_HOSTS_FILE`. If this variable is given,
the file will be copied instead of creating an own one.

Note  that, since  ansible  configuration (including  the inventory)  is
created per  platform, in global level  a single list of  involved hosts
can be sufficient for initial tests.

### Fingerprint changes

If  you  create a  new  configuration  after  running a  different  one,
fingerprint may  change, but  IP address  remains the  same. So,  if you
login to ansible  server with ssh instead of executing  a bash directly,
you have to remove previous fingerprint by:

```
ssh-keygen -R $(docker inspect -f '{{.NetworkSettings.Networks.ansible_default.IPAddress}}'
controller)
```

### Different `root` password

Since this is only a playground, root of the hosts (and also that of the
server)  has a  simple  password 'root'.  If you  use  a different  host
solution  with  different  root  password,  you can  change  it  by  the
environment variable  `APG_HOST_PASSWORD`. Note,  that all of  the hosts
must havr the same password, using different ones is not supported.

### Example confuguration

```
version: "3.6"
services:
    controller:
        image: fercsi/ansible-playground:controller
        ports:
            - 22:22
        volumes:
            - ./work:/var/work
        container_name: controller
        hostname: controller
        restart: always
        depends_on:
            - web
            - db
        environment:
            APG_HOSTS: web db
            APG_HOST_PASSWORD: pwd123
        networks:
            - default
    web:
        image: yourown
        ports:
            - 22:22
        container_name: web
        hostname: web
        restart: always
        networks:
            - default
    db:
        image: yourown
        ports:
            - 22:22
        container_name: db
        hostname: db
        restart: always
        networks:
            - default
```
