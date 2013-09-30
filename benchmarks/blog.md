### Overview

[JMeter](http://jmeter.apache.org/) and [Gatling](http://gatling-tool.org/) are two of the most popular open source performance testing tools available, and [flood.io](https://flood.io) proudly supports both of them on its distributed load testing platform.

Which [begs the question](http://en.wikipedia.org/wiki/Begs_the_question), is one tool better than the other?

### Competitive Benchmarks 

Ordinarily, we're not not in the business of playing one tool off the other as we think different tools meet different requirements of our testers. After all, _"all competitive benchmarking is institutionalized cheating."_ [Guerrilla Manifesto](http://www.perfdynamics.com/Manifesto/gcaprules.html#tth_sEc1.21)

Since we offer both tools on our platform, it was in our interest to offer an objective comparison for both our testers and also the hard working developers who give up their own time making fantastic software likke Gatling and JMeter. To that end, benchmark comnparisons are available at any time.

### The Target Site

We needed a target site that could comfortably handle the types of concurrency and volume that we'd be throwing at it. We chose [nginx](http://nginx.org/en/) for this task, an extremely fast HTTP server with low resource overheads.

We also need the target site to behave like an application server, that is respond to normal HTTP GETs but also respond to HTTP POSTs whilst serving up static and dynamic content. The site had to generate artificial latency in response time, much like a normal web tier would behave. To that end, we were able to mock this mix of transactions with our [custom nginx configuration](../sites/sites-enabled-default).

### The Load Generator

[Flood.io](https://flood.io) is a distributed load testing platform that let's you scale out on your own dedicated Grid of flood nodes in minutes. Whilst customers normally launch multiple nodes per Grids in regions across the globe, for the sake of benchmarking we chose to test with just one node, our lowest common demoninator. A flood node is equivalent to an [m1.xlarge](http://aws.amazon.com/ec2/instance-types/instance-details/) which sports a 64bit processor, 4 virtual CPUs and 15 GB RAM.

We run a Java HotSpot JVM with JRE version 1.7.0_13. Each node allocates a 6GB JVM heap size to the test tool running, be it JMeter or Gatling, with the following JVM options:

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
-Xloggc:/var/log/flood/verbosegc.log  -XX:-UseGCLogFileRotation
```

The remaining resources are utilised by our test runners and distributed elasticseach engine.

### The Target Scenario

Our [load scenario](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/spec/scenario) consists of the following user transactions:

* __20%__ of transactions fetching a slow resource in approx. 3.5s
* __40%__ of transactions making conditional reuqests to a cacheable resource
* __30%__ of transactions fetching a non cacheable resource
* __10%__ of transactions posting to a slow resource in approx. 

### The Test Plans

Our test plans are available for [Gatling](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/spec/gatling.scala) and [JMeter](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/spec/jmeter.jmx) with the latter [auto generated](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/spec/jmeter.rb) by the popolar [ruby-jmeter DSL](https://github.com/flood-io/ruby-jmeter).

### The Target Benchmarks

Ordinarily we recommend a planning figure of 1,000 user per flood node as a "finger in the air" guesstimate. It's hard to recommend a planning figure without first knowing your test plan complexity, target volumetrics and target site behaviour under load. To establish a target for these benchmarks we went the traditional exploratory route, and came up with the following that works well for this particular situation:

* 10,000 concurrent users
* Approx. 30,000 requests per minute
* 20 minute duration including a 10 minute rampup

### The Results

Pleasingly, we found that at these volumes, there was not much variance in results between the tools.

