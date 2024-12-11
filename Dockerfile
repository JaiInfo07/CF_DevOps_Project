# Base Image
FROM adobecoldfusion/coldfusion2021:latest
 
# Accept EULA and set environment variables
ENV acceptEULA=YES
ENV adminPassword="Admin@123"
ENV enableSecureProfile=NO
 
# Set working directory
WORKDIR /opt/coldfusion/cfusion/wwwroot
 
# Update apt and install utilities
RUN apt-get update && apt-get install -y unzip vim && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
 
# Copy the build.zip file into the container
COPY build.zip /tmp/build.zip
 
# Extract the zip file and clean up
RUN unzip /tmp/build.zip -d /tmp/build && \
    cp -r /tmp/build/. /opt/coldfusion/cfusion/wwwroot && \
    rm -rf /tmp/build /tmp/build.zip
 
# Modify `neo-security.xml` dynamically to disable admin security
RUN sed -i "s|<var name='admin.security.enabled'><boolean value='true'/>|<var name='admin.security.enabled'><boolean value='false'/>|g" /opt/coldfusion/cfusion/lib/neo-security.xml
 
# Modify `<Context>` tag in `server.xml` dynamically
RUN sed -i 's|<Context path="" docBase="/app" .*|<Context path="" docBase="/opt/coldfusion/cfusion/wwwroot" WorkDir="/opt/coldfusion/cfusion/runtime/conf/Catalina/localhost/tmp" allowLinking="true" listings="true">|g' \
    /opt/coldfusion/cfusion/runtime/conf/server.xml
 
# Install necessary ColdFusion packages
RUN /opt/coldfusion/cfusion/bin/cfpm.sh install sqlserver debugger image mail

RUN /opt/coldfusion/cfusion/bin/cfpm.sh install sqlserver debugger image mail

# Set up data source using the Admin API
COPY datasource.cfm /opt/coldfusion/cfusion/wwwroot/WEB-INF/datasource.cfm
RUN cfexecute="bash /opt/coldfusion/cfusion/wwwroot/WEB-INF/datasource.cfm"

# Expose ColdFusion server port
EXPOSE 8500
 
# Final CMD to start ColdFusion server
CMD ["/opt/coldfusion/cfusion/bin/coldfusion", "start"]
