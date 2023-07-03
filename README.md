# Public Super Retro Mega Wars Servers

[Super Retro Mega Wars](https://github.com/retrowars/retrowars) is a free software multiplayer game.
To support the multiplayer aspect, a server is required.
To ensure that multiple people are able to offer servers for the community, we maintain a public
list of servers in this repository:

> [`./docs/.well-known/com.serwylo.retrowars-servers.json`](./docs/.well-known/com.serwylo.retrowars-servers.json).

This in turn is then made available at:

> https://retrowars.github.io/retrowars-servers/.well-known/com.serwylo.retrowars-servers.json.

The [retrowars game](https://github.com/retrowars/retrowars) queries this JSON file in order to ascertain which servers are available for playing.

## Contributing

### Running a public server

Retrowars is a community driven project. We will try to make sure that there are servers run by the maintainers, but it would also be wonderful if others who enjoy the game and have the skills/resources were able to contribute a server to the pool of publicly available servers.

#### Using Docker

The latest server image can be pulled from [`pserwylo/retrowars` on Dockerhub](`https://hub.docker.com/r/pserwylo/retrowars`).

Here is an example docker-compose file you could use:

```
version: '3.1'
services:

  your-retrowars-server.com:

    image: pserwylo/retrowars:latest

    expose:
      - 80

    environment:
      - PORT=80

      # Example configuration options:
      - MAX_ROOMS=10
      - ROOM_SIZE=4
      - FINAL_SCORE_DURATION=7500

    # volumes:

      # If you want to customise the logging format:
      # - ./logback.xml:/etc/retrowars/logback.xml

      # If you want to retain logs:
      # - retrowars-latest-logs:/var/log/retrowars/
```

#### Using the portable executable .jar file

Obtaining a `.jar` file by either:
* [Downloading the latest version from the release page of retrowars/retrowars](https://github.com/retrowars/retrowars/releases?q=%22server+release%3A%22&expanded=true), or
* Build your own `.jar` file by cloning [retrowars/retrowars](https://github.com/retrowars/retrowars) then running `./gradlew :server:dist -PexcludeAndroid` from the root directory of that repository.

Once you have obtained a `.jar` file, run it using: `PORT=80 java -jar server.jar` (choosing whatever port you wish).

Note: Requires Java 8 and will likely not work with later versions due to the way the libgdx library works.

To keep the process running even if it crashes, you may wish to wrap this in a script that is periodically called via a cron job.
Here is the script used by [retrowars2.serwylo.com](http://retrowars2.serwylo.com) which runs on a small AWS EC2 machine:

```
#!/bin/bash
@
# Makes sure the retrowars process is always running by regularly running this script.
# If it is already running, this script will do nothing.
#
# https://stackoverflow.com/a/911146/2391921
#

if ps ax | grep -v grep | grep retrowars-server.jar > /dev/null
then
    exit
else
    PORT=8080 java -jar /home/ubuntu/retrowars-server.jar >> /home/ubuntu/retrowars-server.log
fi

exit
```

#### Using an existing Apache2 server and adding an additional virtual host

If the server you are using already has Apache2 configured with other virtual hosts, you probably want to proxy traffic from Apache2 to the retrowars server process. 
To do this, ensure you enable the `mod_proxy` and `mod_proxy_wstunnel` modules and add the following virtual host config ([based on the official docs](http://httpd.apache.org/docs/2.4/mod/mod_proxy_wstunnel.html)):

```
<VirtualHost *:80>
	ServerName retrowars2.serwylo.com

	# The more specific path has to come first, or else all requests
    # will be proxied via the HTTP proxy endpoint at "/*"
	ProxyPass /ws ws://localhost:8080/ws
	ProxyPass / http://localhost:8080/
</VirtualHost>

```

This is the approach used by [retrowars2.serwylo.com](http://retrowars2.serwylo.com) where traffic is proxied through Apache2 to the underlying Java process running as an unprivileged user on port 8080.

#### Using Nginx
Websocket proxy from [nginx docs](https://nginx.org/en/docs/http/websocket.html).

```
server {
	server_name _;
	
	proxy_pass http://localhost:8080;
    	proxy_http_version 1.1;
    	proxy_set_header Upgrade $http_upgrade;
    	proxy_set_header Connection "upgrade";
}
```

### Maintaining this list

#### Adding servers
If you are the maintainer of a public retrowars server, or if you want to help the maintainer be added to the official list of publicly available servers, you can file a pull request to this repository to update the list of servers.

#### Removing servers
If a server becomes defunct, the game will quietly ignore it (after trying to reach it and failing).
This means that the players wont see defunct servers, other than a status message saying it tried to connect to the server (a message which will disappear after failing to connect).

However, it would be polite to prevent the game from even bothering to talk to a server which is defunct.
To do that, we should remove the server from the list.
