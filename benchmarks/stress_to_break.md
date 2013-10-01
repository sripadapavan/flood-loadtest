### Overview

In our [previous post](https://flood.io/blog/11-benchmarking-jmeter-and-gatling) we benchmarked performance of [JMeter](http://jmeter.apache.org/) and [Gatling](http://gatling-tool.org/) in a side by side comparison, with concurrent load up to __10,000 users__ and found little to differentiate the product of each test. That is, we observed relatively flat response time profiles with little to no variation in results.

We alluded to the fact that under the hood, JMeter demonstrated a higher resource utilization profile in terms of CPU and JVM performance. Since the point of the benchmarks was to compare response time performance for given concurrency / volumetrics we did not explore this further. _Until now_.

What happens to the tools when we go beyond the benchmark and into the realms of stress to break testing? Read on to find out.

### Stress to Break

Unlike benchmarks, which typically exercise a given load profile to produce a consistent result, stress to break testing will vary the load profile to hopefully provide inconsistent, or breaking conditions in your test. Stress to break testing is essentially an exploration of what-if scenarios. _What if I increase the number of concurrent users? What if I increase the throughput? What if I increase concurrency and throughput?_

What if we take it to __"ludicrous speed?"__

![](http://3.bp.blogspot.com/-DWhLj1zPEa8/UUhfBsOWclI/AAAAAAAAGHs/Tzp3lTEOW8E/s320/ludicrous+speed+small.jpg)

### The Target Site

We used the same target site as [before](https://flood.io/blog/11-benchmarking-jmeter-and-gatling), an [nginx](http://nginx.org/en/) web server that can handle static/dynamic GETs and POSTs to cache-able and non cache-able resources with artificial delay.

### The Load Generator

Also the same as before, a single flood node which is equivalent to an [m1.xlarge](http://aws.amazon.com/ec2/instance-types/instance-details/) which sports a 64 bit processor, 4 virtual CPUs and 15 GB RAM.

We run the Java HotSpot JVM with JRE version 1.7.0_13 on Ubuntu 12.04 LTS. However to reach fail conditions earlier, we allocated a 4GB JVM max. heap size to the test tool running, be it JMeter or Gatling, with the following JVM options:

```
-XX:+HeapDumpOnOutOfMemoryError 
-Xms4096m -Xmx4096m -XX:NewSize=1024m -XX:MaxNewSize=1024m
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
### The Target Scenario

Our [load scenario](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/spec/scenario.md) was the same and consists of the following user transactions:

* __20%__ of transactions fetching a slow resource in approx. 3.5s
* __40%__ of transactions making conditional requests to a cache-able resource in < 10ms
* __30%__ of transactions fetching a non cache-able resource in approx. 2s
* __10%__ of transactions posting to a slow resource in approx. 4s

### The Test Plans

Our test plans are available for [Gatling](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/spec/gatling.scala) and [JMeter](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/spec/jmeter.jmx) however as we double concurrency to 20,000 users we also doubled the pacing to 30s to maintain the same relative throughput of approx. 30,000 requests/minute.

### The Results

<table class="table table-condensed">
  <tr>
    <th>Tool</th>
    <th>Benchmark</th>
    <th>Date</th>
    <th>Mean RT +/- SDev</th>
  </tr>
  <tr>
    <td>JMeter-2.9</td>
    <td><a href="https://flood.io/2037deb43774de">20,000 Users</a></td>
    <td>2013-10-01 08:20:47</td>
    <td>2,637 +/- 1,015 ms</td>
  </tr>
  <tr>
    <td>JMeter-2.10</td>
    <td><a href="https://flood.io/57b90939e21846">20,000 Users</a></td>
    <td>2013-10-01 08:41:49</td>
    <td>2,143 +/- 446 ms</td>
  </tr>
  <tr>
    <td>Gatling-1.5.3</td>
    <td><a href="https://flood.io/6666b6bc4cb8a2">20,000 Users</a></td>
    <td>2013-10-01 09:03:03</td>
    <td>1,702 +/- 28 ms</td>
  </tr>
</table>

### Key Observations

* __Gatling__ is able to sustain high concurrent load with no obvious degradation in response times at 20K users.

* __JMeter__ is starting to degrade under high concurrent load as evident by the higher mean and standard deviation in response times.

* __JMeter 2.9__ demonstrates heavy resource utilization with CPU around 70 - 80%. __JMeter 2.10__ shows slightly less CPU around 60 - 70%. __Gatling 1.5.3__ shows the least utilization with CPU around 30%, so approx. half of its counterparts for the same load profile as the following chart demonstrates.

![](https://flood.io/images/blog/stress_cpu.png)

* __JMeter__ [under the hood](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/results/2037deb43774de.md) in terms of JVM performance is demonstrating much more aggressive behavior. No longer do we see regularly spaced GC intervals or the classic 'sawtooth' profile of heap utilization. Instead the tenured collection is not dropping below 2.5GB (+60% of heap size). Whilst the young collection is full, the promoted collection is around 100 - 200 MB in size which indicates the JVM is either hanging on to allocated objects for longer, or the rate of allocation is higher than we'd ideally like. This is leading to more frequent GC pauses in the order of 0.5 - 1.0s which ultimately contribute to the general response time degradation we observe. Typically this constitutes a fail condition for us, and there wouldn't be much point trying to 'tune' the JVM beyond our current settings, besides allocating more memory to it.

* __Gatling__ [by comparison](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/results/6666b6bc4cb8a2.md) has a very light profile in terms of JVM performance. Minor GC pauses are less than 0.075s with heap size less than 450 MB. We therefore conclude that Gatling is able to sustain concurrency of at least 20,000 users on a 4GB JVM.

### They've gone to plaid speed !!!

So what happens if we throw 40,000 users onto a single JVM?

Unsurprisingly Gatling is [able to sustain](https://flood.io/2c13788664d83d) relatively stable response times with a mean of 1,574 and standard deviation 111 ms. [JVM heap utilization](https://github.com/flood-io/flood-loadtest/blob/master/benchmarks/results/2c13788664d83d.md) climbs to 1.2GB and minor GC pause increase to around 0.2s under load.

JMeter saturates memory utilization as we'd expect which causes a separate failure of our results collection / report generation on the same machine. The sociability of these separate JVMs are no longer feasible at this concurrency for the given architecture. So we've well and truly reached the breaking point of a single flood node.

### TL;DR

In this post we've taken you well beyond the relatively safe planning figures of 1,000 users per flood node and into the stormy waters of 20,000 users and beyond.

We've taken a look under the hood at JVM performance for each of the tools, and highlighted the obvious differences in terms of raw performance.

It stands to reason that for a given JVM size / configuration, __Gatling__ is able to sustain much higher concurrent volumes without degradation to response time due to in part, its lighter footprint on the JVM. __JMeter__ can also achieve relatively high concurrent volumes but is more susceptible to response time variation consistent with its relatively heavier footprint on the JVM.

Given the distributed nature of [flood.io](https://flood.io) and its ability to scale out to 20 nodes per grid, with grids in 8 geographic regions, any issues relating to single JVM performance becomes a moot point. 

As we mentioned in our last post, the choice between __JMeter__ and __Gatling__ is purely subjective, and is better made on some of the other features that each tool independently provides. 
