# https://github.com/grahamjenson/DR-CoN
FROM spring2/nginx
SHELL ["powershell", "-Command"]

ENV CONSUL_TEMPLATE_VERSION 0.18.2

ENV CT_FILE ct/template.tmpl
ENV NX_FILE conf/c/app.conf
ENV CONSUL consul:8500
ENV SERVICE consul-8500

RUN mkdir ct; \
	mkdir conf/c;

RUN $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'; \
	[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols; \
	Invoke-WebRequest $('https://releases.hashicorp.com/consul-template/{0}/consul-template_{0}_windows_amd64.zip' -f $env:CONSUL_TEMPLATE_VERSION) \
		-OutFile 'ct.zip' -UseBasicParsing; \
	Expand-Archive -Path ct.zip -DestinationPath ct -Force ; \
	rm ct.zip;
	
# Add in tempalte and custom nginx.conf	
COPY template.txt c:/nginx/template.txt
COPY conf c:/nginx/conf
	
# Replace template with token and run nginx. Launch consul-template to watch for the given service name
CMD ((gc template.txt) -replace ':SERVICE:', $env:SERVICE) | Out-File -Encoding UTF8 $env:CT_FILE; \
	start-process nginx.exe; \ 
	do { $nginx = (get-process nginx -ea silentlycontinue); $i++; start-sleep -s 1; write-host 'Waiting for nginx ({0}s)' -f $i;} while ($nginx -eq $null -and $i -lt 10); \
	if ($nginx -eq $null) { write-host 'nginx failed to start.'; exit 1; }; \
	& .\ct\consul-template.exe -consul-addr $env:CONSUL \
		-template ('{0}:{1}:nginx.exe -s reload' -f $env:CT_FILE, $env:NX_FILE);