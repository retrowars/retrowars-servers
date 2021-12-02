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

#### Using the portable executable .jar file

You can download the portable executable .jar file from the retrowars project, or run it using `./gradlew :server:dist` from that project.
Once downloaded, run it using: `PORT=80 java -jar server.jar` (choosing whatever port you wish).

Note: Requires Java 8 and will likely not work with later versions due to the way the libgdx library works.

To keep the process running even if it crashes, you may wish to wrap this in a script that is periodically called via a cron job.
Here is the script used by [retrowars2.serwylo.com](http://retrowars2.serwylo.com) which runs on a small AWS EC2 machine:

```
#!/bin/bash
# https://stackoverflow.com/a/911146/2391921
# Makes sure the retrowars process is always running.

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

	# The more specific path has to come first, or else all requests will be proxied via the HTTP proxy endpoint at "/*"
	ProxyPass /ws ws://localhost:8080/ws
	ProxyPass / http://localhost:8080/
</VirtualHost>

```

This is the approach used by [retrowars2.serwylo.com](http://retrowars2.serwylo.com) where traffic is proxied through Apache2 to the underlying Java process running as an unprivileged user on port 8080.

#### Using Heroku

The server is designed so that it can be easily deployed to a Heroku instance. Indeed the [retrowars1.serwylo.com](http://retrowars1.serwylo.com/info) server is hosted on a free Heroku dyno (hence why it takes approx 20 seconds to respond if it hasn't been used in a while and has begun idling).

To do so, you can:
 * Clone the main retrowars project at http://github.com/retrowars/retrowars
 * [Add a Heroku remote to the cloned repository](https://devcenter.heroku.com/articles/git#creating-a-heroku-remote)
 * [Deploy the app via git](https://devcenter.heroku.com/articles/git#deploying-code)

This will result in Heroku building the app and running it for you. From there, you may wish to also:
 * [Add a custom domain](https://devcenter.heroku.com/articles/custom-domains)

### Maintaining this list

#### Adding servers
If you are the maintainer of a public retrowars server, or if you want to help the maintainer be added to the official list of publicly available servers, you can file a pull request to this repository to update the list of servers.

#### Removing servers
If a server becomes defunct, the game will quietly ignore it (after trying to reach it and failing).
This means that the players wont see defunct servers, other than a status message saying it tried to connect to the server (a message which will disappear after failing to connect).

However, it would be polite to prevent the game from even bothering to talk to a server which is defunct.
To do that, we should remove the server from the list.
