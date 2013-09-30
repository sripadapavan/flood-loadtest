![](https://flood.io/assets/flood-logo.png)

### Performance Benchmarks from flood.io

Here at Flood IO we love performance testing. Since we support multiple tools including JMeter and Gatling, we think it's best if we keep track of individual tool performance via different benchmarks. You can see the test plans used for benchmarking for __[Gatling](./benchmarks/spec/gatling.scala)__ and __[JMeter](./benchmarks/spec/jmeter.jmx)__.

We're not in the business of playing one tool off the other, we think different tools meet different requirements of our testers. After all, _"all competitive benchmarking is institutionalized cheating."_ [Guerrilla Manifesto](http://www.perfdynamics.com/Manifesto/gcaprules.html#tth_sEc1.21)

As we benchmark the tools in different load scenarios and test configurations we'll document the raw results here for your own analysis. This includes things like GC behvaviour under load, as well as links to summary reports from tests executed on __[flood.io](https://flood.io)__. It's interesting to see how tools behave in high load scenarios. "High" meaning bigger than your own laptop :)

Our basic benchmark consists of throwing __10,000__ users at an __nginx__ site for 30 minutes duration with a scenario that GETs a slow resource (1.5s) 20% of the time, a cacheable content (304s) 40% of the time, non-cacheable content (200s) 30% of the time and and the rest simulated POSTs. Each scenario will parse the response (for a string using regular expressions) as well as body and response code assertions. [Apdex](http://apdex.org) is measured on a 300 ms satisfied target with up to 320 ms tolerated. 

The target site and flood.io node are separate AWS instances (m1.xlarge) located in the same region (Sydney). The JVM heap size max is 4GB typically run with the following settings:

```
java -server -XX:+HeapDumpOnOutOfMemoryError 
-Xms4096m -Xmx4096m -XX:NewSize=1024m -XX:MaxNewSize=1024m 
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

We also include the __[test lab setup](./sites)__ (cloudformation templates) that can be used to replicate testing using your own AWS account. 

We're also continuing to try and level the playing field in terms of comparison, picking only features of each tool that can be compared on a 1:1 basis. This is a work in progress and we hope to refine this. We'd love your feedback.

We hope you find this information useful. Questions about the testing can be sent to support@flood.io or please raise an issue against this repo for discussion.

Enjoy!

Tim Koopmans

latest benchmarks
==============
We plan to include nightly releases under development.
You can always get the latest current benchmark results from [flood.io](https://flood.io) at:

* https://flood.io/benchmarks/jmeter __JMeter 2.9__    
* https://flood.io/benchmarks/gatling __Gatling 1.5.3__ 

previous benchmarks
==============
[summary results ...](./benchmarks/results/README.md)

* ~~27/9 We observed Gatling was not showing correct throughput due to nginx not setting content-length header~~
* ~~27/9 We observed that Gatling was not making conditional requests (304s)~~
* ~~29/9 Gatling did not make conditional requests (304s) so we have hardcoded the header for cacheable content requests.~~
* 29/9 Not much to differentiate tools in terms of performance, we're going to double concurrency and maintain throughput.
* 29/9 Gatling throughput measured on flood.io is an approximation only, based on Content-Length headers if they exist. Request rate (per minute) is a more accurate measurement to use when comparing JMeter with Gatling throughput.

| Benchmark                                     | Tool        | Date                         | Duration | Apdex | Mean RT    |
| -----                                         |-----        |-----                         |-----     |-----      |-----      |
