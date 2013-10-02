### Overview

[JMeter](http://jmeter.apache.org/) and [Gatling](http://gatling-tool.org/) are two of the most popular open source performance testing tools available, and [flood.io](https://flood.io) proudly supports both of them on its distributed load testing platform.

![](https://flood.io/assets/feature-jmeter_gatling.jpg)

Which [begs the question](http://en.wikipedia.org/wiki/Begs_the_question), is one tool better than the other?

### Competitive Benchmarks 

Ordinarily, we're not in the business of playing one tool off the other as we think different tools meet different requirements of our testers. Considered that, _"all competitive benchmarking is institutionalized cheating."_ [Guerrilla Manifesto](http://www.perfdynamics.com/Manifesto/gcaprules.html#tth_sEc1.21)

Since we offer both tools on our platform, it was in our interest to offer an objective comparison for both our testers and also the hard working developers who give up their own time making fantastic software like Gatling and JMeter. To that end, we'll continue to make these [benchmarks](https://github.com/flood-io/flood-loadtest) available at the following URLs on a regular basis:

#### JMeter

Current Release [https://flood.io/benchmarks/jmeter](https://flood.io/benchmarks/jmeter?tag=benchmark-release)

Latest Release [https://flood.io/benchmarks/jmeter?tag=benchmark-latest](https://flood.io/benchmarks/jmeter?tag=benchmark-latest)


#### Gatling

Current Release [https://flood.io/benchmarks/gatling](https://flood.io/benchmarks/gatling?tag=benchmark-release)

Latest Release [https://flood.io/benchmarks/gatling?tag=benchmark-latest](https://flood.io/benchmarks/gatling?tag=benchmark-latest)


### The Target Site

We needed a target site that could comfortably handle the types of concurrency and volume that we'd be throwing at it. We chose [nginx](http://nginx.org/en/) for this task, an extremely fast HTTP server with low resource overheads.

We also needed the target site to behave like an application server; that is, respond to normal HTTP GETs but also respond to HTTP POSTs whilst serving up static and dynamic content. The site had to generate artificial latency in response time, much like a normal web tier would behave. To that end, we were able to mock this mix of transactions with our [custom nginx configuration](https://github.com/flood-io/flood-loadtest/blob/master/sites/sites-enabled-default). 

We tuned the OS kernel / TCP network [settings](https://github.com/flood-io/flood-loadtest/blob/master/sites/os-tuning-mods-nginx.sh) and allocated 4 virtual CPUs and 15 GB RAM to make sure there were no bottlenecks on the target site.

### The Load Generator

[Flood.io](https://flood.io) is a distributed load testing platform that lets you scale out on your own dedicated Grid of flood nodes within minutes. Whilst customers normally launch multiple nodes per Grids in regions across the globe, for the sake of benchmarking we chose to test with just one node, our lowest common denominator. A flood node is equivalent to an [m1.xlarge](http://aws.amazon.com/ec2/instance-types/instance-details/) which sports a 64 bit processor, 4 virtual CPUs and 15 GB RAM.

We run the Java HotSpot JVM with JRE version 1.7.0_13 on Ubuntu 12.04 LTS. Each node allocates a 6GB JVM max. heap size to the test tool running, be it JMeter or Gatling, with the following JVM options:

```
-XX:+HeapDumpOnOutOfMemoryError 
-Xms6144m -Xmx6144m -XX:NewSize=1536m -XX:MaxNewSize=1536m 
-XX:MaxTenuringThreshold=2 -XX:+UseConcMarkSweepGC 
-Dsun.rmi.dgc.client.gcInterval=600000 
-Dsun.rmi.dgc.server.gcInterval=600000 
-XX:PermSize=64m -XX:MaxPermSize=128m 
-verbose:gc 
-XX:+PrintGCDateStamps 
-XX:+PrintGCTimeStamps 
-XX:+PrintGCDetails
-Xloggc:/var/log/flood/verbosegc.log 
-XX:-UseGCLogFileRotation
```

The remaining resources are utilized by our test runner and distributed elasticseach engine. We also tune the OS kernel / TCP network settings in a similar fashion to the target site.

### The Target Scenario

Our [load scenario](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/spec/scenario.md) consists of the following user transactions:

* __20%__ of transactions fetching a slow resource in approx. 3.5s
* __40%__ of transactions making conditional requests to a cache-able resource in < 10ms
* __30%__ of transactions fetching a non cache-able resource in approx. 2s
* __10%__ of transactions posting to a slow resource in approx. 4s

### The Test Plans

Our test plans are available for [Gatling](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/spec/gatling/1.5.3/benchmark.scala) and [JMeter](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/spec/jmeter.jmx) with the latter [auto generated](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/spec/jmeter/benchmark.rb) by our popular [ruby-jmeter DSL](https://github.com/flood-io/ruby-jmeter).

### The Target Benchmarks

Ordinarily we recommend a planning figure of __1,000 users__ per flood node as a _"finger in the air"_ guesstimate. It's hard to recommend a planning figure without first knowing your test plan complexity, target volumetrics and target site behavior under load. To establish a target for these benchmarks we went the traditional exploratory route, and came up with the following that works well for this particular scenario:

<table class="table table-condensed">
  <tr>
    <th>Concurrency</th>
    <th>Volume</th>
    <th>Duration</th>
  </tr>
  <tr>
    <td>10,000 users</td>
    <td>30,000 requests per minute</td>
    <td>20 minute duration with 10 minute rampup</td>
  </tr>
</table>

### The Results

Pleasingly, we found that at these volumes, there was not much variance in results between the tools. But compare if you must!

<table class="table table-condensed">
  <tr>
    <th>Tool</th>
    <th>Benchmark</th>
    <th>Date</th>
    <th>Mean RT +/- SDev</th>
  </tr>
  <tr>
    <td>Gatling-1.5.3</td>
    <td><a href="https://flood.io/e639303fb162ce">10,000 Users</a></td>
    <td>2013-09-30 09:52:32</td>
    <td>1788 +/- 362 ms</td>
  </tr>
  <tr>
    <td>JMeter-2.9</td>
    <td><a href="https://flood.io/e281b0e339fb14">10,000 Users</a></td>
    <td>2013-09-30 10:13:15</td>
    <td>1625 +/- 322 ms</td>
  </tr>
  <tr>
    <td>JMeter-2.10</td>
    <td><a href="https://flood.io/9fde49a2f3d43b">10,000 Users</a></td>
    <td>2013-09-30 10:33:59</td>
    <td>1698 +/- 31 ms</td>
  </tr>
</table>

### Key Observations

* __Gatling__ _does not record response size in bytes_, hence [flood.io](https://flood.io) uses an estimate based on Content-Length headers if they exist, which is optimistic and does not accurately reflect true network throughput. Request rate per minute should be used as a measure of throughput instead if using Gatling. Alternatively use external network monitors during your test. The following graph demonstrates network utilization parity between the tools.

![](https://flood.io/images/blog/benchmark_network.png)

* __[JMeter](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/results/9fde49a2f3d43b.md)__ is more resource heavy on the JVM compared to __[Gatling](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/results/e639303fb162ce.md)__. At Flood we use Concurrent Mark Sweep (CMS) for garbage collection in an effort to lower the latency of GC pauses. 

* __JMeter__ is more resource heavy on system CPU and Memory as the following graphs demonstrates this in terms of CPU and JVM Heap utilization. This may affect you more if the complexity of your test plans increase or perceived concurrency on the JVM increases with a slower performing target site.

![](https://flood.io/images/blog/benchmark_cpu.png)

![](https://raw.github.com/flood-io/flood-loadtest/master/benchmarks/results/gc/9fde49a2f3d43b/tenured_size.jpg)

* __Both__ JMeter and Gatling demonstrated the desired characteristics of relatively _flat_ response times for measured transactions during rampup and under load, with little variance. Mean response time shouldn't be used as a measure of the tool's performance aside from the prior observation in this sense.

* __Both__ JMeter and Gatling were able to sustain an average throughput in the region of 30,000 requests per minute with no deviation.

* __Both__ JMeter and Gatling were able rampup to 10,000 concurrent users within 10 minutes, which is ordinarily considered an aggressive target from a single load generator.

* __Both__ JMeter and Gatling demonstrated correct caching behavior, particularly when making conditional requests for static resources that respond with a HTTP 304. _Gatling were able to promptly provide us with a patch to ensure this_.

* __Both__ JMeter and Gatling test plans included extraction of content via regular expressions from the response body, as well as assertions for contained text and HTTP response codes without detriment to performance.

### TL;DR

In terms of concurrency and throughput achievable from a single load generator, there is little to differentiate between Gatling and JMeter. Gatling has some limitations in the ability to accurately record response payload in bytes, which can be compensated by external monitors. JMeter generally demonstrates higher resource usage in terms of CPU, Memory and JVM performance, but can otherwise manage the load when run with appropriate memory allocation.

We don't anticipate users ordinarily run JVMs at their peak as we did in this benchmark, and flood.io automatically warns the user if any of the Grid nodes are exhausting available resources in such a case. 

For the sake of these benchmarks, we chose a simplistic scenario to reduce the number of variables that can affect a side by side comparison. As such results should be analyzed in context of the test boundaries described above. It is possible that performance will differ in more realistic scenarios. The best way to explore is to try for yourself. We host a free node on [flood.io](https://flood.io) which lets you run JMeter or Gatling tests, and registration is free.

At the end of the day, the choice between __JMeter__ and __Gatling__ is purely subjective, and is better made on some of the other features that each tool independently provides. 

We hope this brings some clarity to the relative performance of these great tools.

### Special Thanks!

A special thank you to <a href="http://www.ubikloadpack.com/">Philippe Mouawad</a> and <a href="http://labs.excilys.com/">Stéphane Landelle</a>, core contributors to the [Apache JMeter](http://jmeter.apache.org/) and [Gatling-Tool](http://gatling-tool.org/) projects. They both helped improve the quality of these benchmarks as well as provide advice / code / patches where appropriate. Thanks!
