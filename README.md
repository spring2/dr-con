# DR CoN

A Windows containers implementation of the architecture described by Graham Jenson, here:

https://maori.geek.nz/scalable-architecture-dr-con-docker-registrator-consul-consul-template-and-nginx-8da2820d02f9

and from his tutorial repo here:

https://github.com/grahamjenson/DR-CoN/.

build:

```docker build . -t drcon```

run:

```docker run -d --name drcon -e "CONSUL=[consul ip:port]" -e "SERVICE=[service name]" -p 80:80 drcon```
