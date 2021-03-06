RemarkBox States
################

Configuration management Salt States for remarkbox.com.

These states assume machines are ubuntu ...
this assumption will likely change.


RemarkBox Architecture 
======================

.. code-block::

                        +---------------------------------+
                        |             Internet            |   2 x mx       postfix
                        +-----------------+---------------+
                                          |                   2 x web      nginx
                                          |
                        +-----------------v---------------+   4 x app      uwsgi
                        |          DNS Round Robin        |
                        +------+-------------------+------+   1 x db       postgresql
                               |                   |
                               |                   |          1 x salt     master
                       +-------v-------+   +-------v-------+
                       |               |   |               |  1 x jenkins  build host
                       |   Nginx Load  |   |   Nginx Load  |
                       |               |   |               |
                       |    Balancer   |   |   Balancer    |
                       |               |   |               |
                   +---+  256M $4.75   |   | 256M $4.75/mo +--+
                   |   |               |   |               |  |
                   |   +---------------+   +---------------+  |
                   |                                          |
                   |                                          |
          +--------+-----------+--------------------+---------+----------+
          |                    |                    |                    |
          |                    |                    |                    |
  +-------v-------+    +-------v-------+    +-------v-------+    +-------v-------+
  |               |    |               |    |               |    |               |
  |     uWSGI     |    |     uWSGI     |    |     uWSGI     |    |     uWSGI     |
  |               |    |               |    |               |    |               |
  |    Port 80    |    |    Port 80    |    |    Port 80    |    |    Port 80    |
  |               |    |               |    |               |    |               |
  | 256M $4.75/mo |    | 256M $4.75/mo |    | 256M $4.75/mo |    | 256M $4.75/mo |
  |               |    |               |    |               |    |               |
  +----------+----+    +----------+----+    +---+-----------+    +----+----------+
             |                    |             |                     |
             |                    |             |                     |
             +--------------------+-------+-----+---------------------+
                                          |
                                          |
  +-------------------+        +----------v----------+       +-------------------+
  |                   |        |                     |       |                   |
  | Config Management |        | PostgreSQL Database |       | Build Host Worker |
  |                   |        |                     |       |                   |
  |    Salt Master    |        | t4+standard+1G 20G  |       |     Jenkins       |
  |                   |        |                     |       |                   |
  |  256M $4.75/mo    |        |      $19.32/mo      |       |  256M $4.75/mo    |
  |                   |        |                     |       |                   |
  +-------------------+        +---------------------+       +-------------------+


Joyent Smart Datacenter Provision
=================================

Create new ubuntu instance, configure hostname, and bootstrap salt.

.. code-block::

 HOSTNAME='remarkbox-web02'
 IMAGE=$(sdc-listimages | json -c 'this.name=="ubuntu-14.04" && this.version=="20151005"' 0.id)
 PACKAGE=$(sdc-listpackages | json -c 'this.name=="t4-standard-256M"' 0.id)

 sdc-createmachine --image $IMAGE --package $PACKAGE --script bootstrap.sh \
   --metadata master=10.112.3.33 --metadata hostname=$HOSTNAME --name $HOSTNAME 

