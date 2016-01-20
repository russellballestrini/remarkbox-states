RemarkBox States
################

Configuration management Salt States for remarkbox.com.


.. code-block::

                       +---------------------------------+
                       |             Internet            |
                       +-----------------+---------------+
                                         |
                                         |
                       +-----------------v---------------+
                       |          DNS Round Robin        |
                       +----+-----------------------+----+
                            |                       |
                            |                       |
                    +-------v-------+       +-------v-------+             +------------------+
                    |               |       |               |             |                  |
                    |   Nginx Load  |       |   Nginx Load  |             | Config Management|
                +---+               |       |               +---+         |                  |
                |   |    Balancer   |       |   Balancer    |   |         |    Salt Master   |
                |   |               |       |               |   |         |                  |
                |   |  256M $4.75   |       | 256M $4.75/mo |   |         |  256M $4.75/mo   |
                |   |               |       |               |   |         |                  |
                |   +---------------+       +---------------+   |         +------------------+
                |                                               |
                |                                               |
         +------+-------------+--------------------+------------+-------+
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
            +--------------------+------+------+---------------------+
                                        |
                             +----------v----------+
                             |                     |
                             | PostgreSQL Database |
                             |                     |
                             | t4-standard-1G 20G  |
                             |                     |
                             |      $19.32/mo      |
                             |                     |
                             +---------------------+
    2 x mx     postfix
    2 x web    nginx
    4 x app    uwsgi
    1 x db     postgresql
    1 x salt   salt-msater

Joyent Smart Datacenter Provision
=================================

Create new ubuntu instance, configure hostname, and bootstrap salt.

.. code-block::

 HOSTNAME='remarkbox-web02'
 IMAGE=$(sdc-listimages | json -c 'this.name=="ubuntu-14.04" && this.version=="20151005"' 0.id)
 PACKAGE=$(sdc-listpackages | json -c 'this.name=="t4-standard-256M"' 0.id)

 sdc-createmachine --image $IMAGE --package $PACKAGE --script bootstrap.sh \
   --metadata master=10.112.3.33 --metadata hostname=$HOSTNAME --name $HOSTNAME 

