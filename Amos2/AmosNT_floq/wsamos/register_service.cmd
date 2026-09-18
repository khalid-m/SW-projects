net stop "Apache Tomcat"
net start "Apache Tomcat"
java org.apache.axis.client.AdminClient undeploy.wsdd
java org.apache.axis.client.AdminClient deploy.wsdd
