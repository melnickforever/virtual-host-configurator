#!/bin/bash
function createHostPath() {
if [ ! -d "$hostDir" ]
then
    mkdir $hostDir
    chown $SUDO_USER:$SUDO_USER $hostDir
    cat > $hostDir/$indexName <<EOF
<html>
    <head><title>Hello ${hostName}</title></head>
    <body>
        <div>Hello ${hostName}</div>
    </body>
</html>
EOF
    chown $SUDO_USER:$SUDO_USER $hostDir/$indexName
    echo "Host Path has been created"

else
    echo "$hostDir already exists."
fi

}

function createHostConfig() {
if [ -f "$fullFileName" ]
then
	echo "File: $fullFileName already exists."
else
    cat > $fullFileName <<EOF
        <VirtualHost *:80>
            # The ServerName directive sets the request scheme, hostname and port that
            # the server uses to identify itself. This is used when creating
            # redirection URLs. In the context of virtual hosts, the ServerName
            # specifies what hostname must appear in the request's Host: header to
            # match this virtual host. For the default virtual host (this file) this
            # value is not decisive as it is used as a last resort host regardless.
            # However, you must set it for any further virtual host explicitly.
            #ServerName www.example.com

            ServerAdmin webmaster@localhost
            DocumentRoot ${hostDir}
            ServerName ${hostName}

        <Directory "${hostDir}">
           AllowOverride All
           Require all granted
        </Directory>

            # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
            # error, crit, alert, emerg.
            # It is also possible to configure the loglevel for particular
            # modules, e.g.
            #LogLevel info ssl:warn

            ErrorLog \${APACHE_LOG_DIR}/${logFilename}_error.log
            CustomLog \${APACHE_LOG_DIR}/${logFilename}_access.log combined

            # For most configuration files from conf-available/, which are
            # enabled or disabled at a global level, it is possible to
            # include a line for only one particular virtual host. For example the
            # following line enables the CGI configuration for this host only
            # after it has been globally disabled with "a2disconf".
            #Include conf-available/serve-cgi-bin.conf
        </VirtualHost>
EOF
echo "Host Config has been created"
fi
}

function restartSoft()
{
echo "127.0.0.1     ${hostName}" >> $hostFilePath
cd $filePath
a2ensite $fileName
service apache2 reload
echo "Created Configuration File: ${fullFileName}"
echo "Created Index File: ${hostDir}/${indexName}"
echo "Updated: ${hostFilePath}"
echo "Visit: http://${hostName}"
}

filePath="/etc/apache2/sites-available"
fileExt=".local.conf"
hostExt=".local"
hostDir="$1"
rowFileName="$(basename $hostDir)"
hostDir=${hostDir/$hostExt/''}$hostExt
fileName=${rowFileName/$fileExt/''}$fileExt
hostName=${rowFileName/$hostExt/''}$hostExt
hostFilePath="/etc/hosts"
fullFileName=$filePath/$fileName
logFilename=${fileName//'.'/'_'}
indexName="index.htm"

result=`createHostPath`
if [ "$result" == "Host Path has been created" ]
then
    echo "Success: ${result}"
    resultConfig=`createHostConfig`
    if  [ "$resultConfig" == "Host Config has been created" ]
    then
        softLog=`restartSoft`
        echo "${softLog}"
    fi
else
    echo "Error: ${result}"
fi
