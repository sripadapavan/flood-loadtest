![](https://flood.io/assets/flood-logo.png)

### Performance Benchmarks from flood.io

Here at Flood IO we love performance testing. Since we support multiple tools including JMeter and Gatling, we think it's best if we keep track of individual tool performance via different benchmarks. You can see the test plans used for benchmarking for __[Gatling](./benchmarks/spec/gatling.scala)__ and __[JMeter](./benchmarks/spec/jmeter.jmx)__.

We're not in the business of playing one tool off the other, we think different tools meet different requirements of our testers. After all, _"all competitive benchmarking is institutionalized cheating."_ [Guerrilla Manifesto](http://www.perfdynamics.com/Manifesto/gcaprules.html#tth_sEc1.21)

As we benchmark the tools in different load scenarios and test configurations we'll document the raw results here for your own analysis. This includes things like GC behvaviour under load, as well as links to summary reports from tests executed on __[flood.io](https://flood.io)__. It's interesting to see how tools behave in high load scenarios. "High" meaning bigger than your own laptop :)

Our basic benchmark consists of throwing __10,000__ users at an __nginx__ site for 30 minutes duration with a [scenario](./benchmarks/spec/scenario.md) that GETs a slow resource (3.5s) 20% of the time, cacheable content (< 10ms) 40% of the time, non-cacheable content (2s) 30% of the time and and the rest simulated POSTs (4s). Each scenario will parse the response (for a string using regular expressions) as well as body and response code assertions. [Apdex](http://apdex.org) is measured on a 4000 ms satisfied target. 

The target site and flood.io node are separate AWS instances (m1.xlarge) located in the same region (Sydney). The JVM heap size max is 6GB typically run with the following settings:

```
java -server -XX:+HeapDumpOnOutOfMemoryError 
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

We also include the __[test lab setup](./sites)__ (cloudformation templates) that can be used to replicate testing using your own AWS account. 

We hope you find this information useful. Questions about the testing can be sent to support@flood.io or please raise an issue against this repo for discussion. You can read [more about this benchmarking here.](https://flood.io/blog/11-benchmarking-jmeter-and-gatling)

Enjoy!

Tim Koopmans

latest benchmarks
==============
We plan to include nightly releases under development.

You can always get the latest current benchmark results from [flood.io](https://flood.io) at:

* [__JMeter 2.9__ RELEASE](https://flood.io/benchmarks/jmeter)   
* [__JMeter 2.10__ NIGHTLY](https://flood.io/benchmarks/jmeter?version=-2.10)     
* [__Gatling 1.5.3__](https://flood.io/benchmarks/gatling)  
* Gatling 2.0.0-M3a TBA

previous benchmarks
==============
* ~~27/9 We observed Gatling was not showing correct throughput due to nginx not setting content-length header~~
* ~~27/9 We observed that Gatling was not making conditional requests (304s)~~
* ~~29/9 Gatling did not make conditional requests (304s) so we have hardcoded the header for cacheable content requests.~~
* 29/9 Gatling throughput measured on flood.io is an approximation only, based on Content-Length headers if they exist. Request rate (per minute) is a more accurate measurement to use when comparing JMeter with Gatling throughput.

| Benchmark                                     | Tool        | Date                         | Duration | Apdex | Mean RT    |
| -----                                         |-----        |-----                         |-----     |-----      |-----      |
| [10000 Users](https://flood.io/e639303fb162ce) [gc](./benchmarks/results/e639303fb162ce.md) | Gatling-1.5.3 | 2013-09-30 09:52:32 | 20 mins | 0.95 [4000] | 1788 ms |
| [10000 Users](https://flood.io/e281b0e339fb14) [gc](./benchmarks/results/e281b0e339fb14.md) | JMeter-2.9 | 2013-09-30 10:13:15 | 20 mins | 0.95 [4000] | 1625 ms |
| [10000 Users](https://flood.io/9fde49a2f3d43b) [gc](./benchmarks/results/9fde49a2f3d43b.md) | JMeter-2.10 | 2013-09-30 10:33:59 | 20 mins | 0.95 [4000] | 1698 ms |
| [20000 Users](https://flood.io/2037deb43774de) [gc](./benchmarks/results/2037deb43774de.md) | JMeter-2.9 | 2013-10-01 08:20:47 | 20 mins | 0.87 [4000] | 2637 ms |
| [20000 Users](https://flood.io/57b90939e21846) [gc](./benchmarks/results/57b90939e21846.md) | JMeter-2.10 | 2013-10-01 08:41:49 | 20 mins | 0.91 [4000] | 2143 ms |
| [20000 Users](https://flood.io/6666b6bc4cb8a2) [gc](./benchmarks/results/6666b6bc4cb8a2.md) | Gatling-1.5.3 | 2013-10-01 09:03:03 | 20 mins | 0.95 [4000] | 1702 ms |
| [40000 Users](https://flood.io/2c13788664d83d) [gc](./benchmarks/results/2c13788664d83d.md) | Gatling-1.5.3 | 2013-10-01 09:53:57 | 20 mins | 0.95 [4000] | 1574 ms |
| [20000 Users](https://flood.io/bc59dd995fd8ff) [gc](./benchmarks/results/bc59dd995fd8ff.md) | Gatling-1.5.3 | 2013-10-02 00:40:44 | 20 mins | 0.95 [4000] | 1710 ms |
| [20000 Users](https://flood.io/507945f1702bad) [gc](./benchmarks/results/507945f1702bad.md) | JMeter-2.9 | 2013-10-02 01:21:47 | 20 mins | 0.84 [4000] | 3946 ms |
| [20000 Users](https://flood.io/9e64d234da00ea) [gc](./benchmarks/results/9e64d234da00ea.md) | JMeter-2.10 | 2013-10-02 01:42:47 | 20 mins | 0.9 [4000] | 2179 ms |
| [100 Users](https://flood.io/7a2391f05891b4) [gc](./benchmarks/results/7a2391f05891b4.md) | JMeter-2.10 | 2013-10-02 07:04:30 | 2 mins | null | null ms |
| [100 Users](https://flood.io/2d93bff1fadb8e) [gc](./benchmarks/results/2d93bff1fadb8e.md) | JMeter-2.10 | 2013-10-02 07:21:38 | 2 mins | 0.96 [4000] | 1603 ms |
| [100 Users](https://flood.io/10d61e78930494) [gc](./benchmarks/results/10d61e78930494.md) | Gatling-2.0.0-20131001.201622-332-bundle | 2013-10-02 07:37:37 | 2 mins | null | null ms |
| [100 Users](https://flood.io/2c94e6036be54e) [gc](./benchmarks/results/2c94e6036be54e.md) | Gatling-2.0.0-20131001.201622-332-bundle | 2013-10-02 07:40:41 | 2 mins | null | null ms |
| [100 Users](https://flood.io/6e4a4d2d023fa9) [gc](./benchmarks/results/6e4a4d2d023fa9.md) | Gatling-2.0.0-20131001.201622-332-bundle | 2013-10-02 07:48:21 | 2 mins | null | null ms |
| [100 Users](https://flood.io/5aa77a31f79d87) [gc](./benchmarks/results/5aa77a31f79d87.md) | Gatling-2.0.0-20131001.201622-332-bundle | 2013-10-02 08:00:08 | 2 mins | null | null ms |
