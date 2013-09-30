* __20%__ of transactions fetching a slow resource in approx. 3.5s

```
>>>
Request URL:http://s1.site-staging.flood.io:8000/slow
Request Method:GET
Status Code:200 OK
<<<
Connection:close
Content-Encoding:gzip
Content-Type:text/plain
Date:Mon, 30 Sep 2013 10:23:12 GMT
Server:nginx/1.1.19
Vary:Accept-Encoding
```
* __40%__ of transactions making conditional reuqests to a cacheable resource

```
>>>
Request URL:http://s1.site-staging.flood.io:8000/plain_text.html
Request Method:GET
Status Code:304 Not Modified
<<<
Connection:keep-alive
Date:Mon, 30 Sep 2013 10:25:08 GMT
Last-Modified:Fri, 27 Sep 2013 04:22:25 GMT
Server:nginx/1.1.19
Vary:Accept-Encoding
```

* __30%__ of transactions fetching a non cacheable resource

```
>>>
Request URL:http://s1.site-staging.flood.io:8000/non_cacheable?id=1
Request Method:GET
Status Code:200 OK
<<<
Connection:close
Content-Encoding:gzip
Content-Type:text/plain
Date:Mon, 30 Sep 2013 10:26:28 GMT
Server:nginx/1.1.19
Vary:Accept-Encoding
```

* __10%__ of transactions posting to a slow resource in approx. 

```
>>>
Request URL:http://s1.site-staging.flood.io:8000/slow_post\?id\=1
Request Method:GET
Status Code:200 OK
<<<
Connection: close
Content-Type: text/plain
Date: Mon, 30 Sep 2013 10:28:15 GMT
Server: nginx/1.1.19
Vary: Accept-Encoding
```
