![](https://flood.io/assets/flood-logo.png)

### Performance Benchmarks from flood.io

Here at Flood IO we love performance testing. Since we support multiple tools including JMeter and Gatling, we think it's best if we keep track of individual tool performance via different benchmarks. You can see the test plans used for benchmarking for __[Gatling](./benchmarks/spec/gatling.scala)__ and __[JMeter](./benchmarks/spec/jmeter.jmx)__.

We're not in the business of playing one tool off the other, we think different tools meet different requirements of our testers. We consider _"all competitive benchmarking is institutionalized cheating."_ [Guerrilla Manifesto](http://www.perfdynamics.com/Manifesto/gcaprules.html#tth_sEc1.21)

As we benchmark the tools in different load scenarios and test configurations we'll document the raw results here for your own analysis. This includes things like GC behvaviour under load, as well as links to summary reports from tests executed on __[flood.io](https://flood.io)__. It's interesting to see how tools behave in high load scenarios. "High" meaning bigger than your own laptop :)

Our basic benchmark consists of throwing __10,000__ users at an __nginx__ site for 60 minutes duration with a [scenario](./benchmarks/spec/scenario.md) that GETs a slow resource (3.5s) 20% of the time, cacheable content (< 10ms) 40% of the time, non-cacheable content (2s) 30% of the time and and the rest simulated POSTs (4s). Each scenario will parse the response (for a string using regular expressions) as well as body and response code assertions. [Apdex](http://apdex.org) is measured on a 4000 ms satisfied target. 

The target site and flood.io node are separate AWS instances (m1.xlarge) located in the same region (Sydney). The JVM heap size max is 4GB typically run with the following settings:

```
 -Xms4096m -Xmx4096m -XX:NewSize=1024m -XX:MaxNewSize=1024m 
 -XX:MaxTenuringThreshold=2 -XX:MaxPermSize=128m -XX:PermSize=64m 
 -Xmn100M -Xss2M 
 -XX:+UseThreadPriorities -XX:ThreadPriorityPolicy=42 
 -XX:+AggressiveOpts -XX:+OptimizeStringConcat -XX:+UseFastAccessorMethods 
 -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled 
 -XX:+CMSClassUnloadingEnabled -XX:SurvivorRatio=8 
 -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly 
 -Dsun.rmi.dgc.client.gcInterval=600000 
 -Dsun.rmi.dgc.server.gcInterval=600000 
 -XX:+HeapDumpOnOutOfMemoryError 
 -verbose:gc -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps 
 -XX:+PrintGCDetails -Xloggc:/var/log/flood/verbosegc.log 
 -XX:-UseGCLogFileRotation
```

We also include the __[test lab setup](./sites)__ (cloudformation templates) that can be used to replicate testing using your own AWS account. 

We hope you find this information useful. Questions about the testing can be sent to support@flood.io or please raise an issue against this repo for discussion. You can read [more about this benchmarking here.](https://flood.io/blog/11-benchmarking-jmeter-and-gatling)

Enjoy!

Tim Koopmans

latest benchmarks
==============
You can always get the latest current benchmark results from [flood.io](https://flood.io) at:

### JMeter

Current Release [https://flood.io/benchmarks/jmeter](https://flood.io/benchmarks/jmeter?tag=benchmark-release)

Latest Release [https://flood.io/benchmarks/jmeter?tag=benchmark-latest](https://flood.io/benchmarks/jmeter?tag=benchmark-latest)

### Gatling

Current Release [https://flood.io/benchmarks/gatling](https://flood.io/benchmarks/gatling?tag=benchmark-release)

Latest Release [https://flood.io/benchmarks/gatling?tag=benchmark-latest](https://flood.io/benchmarks/gatling?tag=benchmark-latest)

previous benchmarks
==============

| Benchmark  | Date         | Users                        | Apdex | Mean       |
| -----      |-----         |-----                         |-----  |-----       |
| [:chart_with_upwards_trend:](./benchmarks/results/e639303fb162ce.md) [:link:](https://flood.io/e639303fb162ce) Gatling-1.5.3    | 20 mins<br>2013-09-30 09:52:32| 10000  | 0.95 [4000] | 1788 ms |
| [:chart_with_upwards_trend:](./benchmarks/results/e281b0e339fb14.md) [:link:](https://flood.io/e281b0e339fb14) JMeter-2.9       | 20 mins<br>2013-09-30 10:13:15| 10000  | 0.95 [4000] | 1625 ms |
| [:chart_with_upwards_trend:](./benchmarks/results/9fde49a2f3d43b.md) [:link:](https://flood.io/9fde49a2f3d43b) JMeter-2.10      | 20 mins<br>2013-09-30 10:33:59| 10000  | 0.95 [4000] | 1698 ms |
| [:chart_with_upwards_trend:](./benchmarks/results/2037deb43774de.md) [:link:](https://flood.io/2037deb43774de) JMeter-2.9       | 20 mins<br>2013-10-01 08:20:47| 20000  | 0.87 [4000] | 2637 ms |
| [:chart_with_upwards_trend:](./benchmarks/results/57b90939e21846.md) [:link:](https://flood.io/57b90939e21846) JMeter-2.10      | 20 mins<br>2013-10-01 08:41:49| 20000  | 0.91 [4000] | 2143 ms |
| [:chart_with_upwards_trend:](./benchmarks/results/6666b6bc4cb8a2.md) [:link:](https://flood.io/6666b6bc4cb8a2) Gatling-1.5.3    | 20 mins<br>2013-10-01 09:03:03| 20000  | 0.95 [4000] | 1702 ms |
| [:chart_with_upwards_trend:](./benchmarks/results/2c13788664d83d.md) [:link:](https://flood.io/2c13788664d83d) Gatling-1.5.3    | 20 mins<br>2013-10-01 09:53:57| 40000  | 0.95 [4000] | 1574 ms |
| [:chart_with_upwards_trend:](./benchmarks/results/5bdd2601b9fb3c.md) [:link:](https://flood.io/5bdd2601b9fb3c) Gatling-1.5.3    | 2 mins<br>2013-10-02 10:29:33 |  100   | 0.93 [4000] | 1931 ms |
| [:chart_with_upwards_trend:](./benchmarks/results/4ab9feb117064d.md) [:link:](https://flood.io/4ab9feb117064d) JMeter-2.9       | 2 mins<br>2013-10-02 10:32:10 |  100   | 0.97 [4000] | 1130 ms |
| [:chart_with_upwards_trend:](./benchmarks/results/a7d55f2a8d313b.md) [:link:](https://flood.io/a7d55f2a8d313b) JMeter-r1528295  | 2 mins<br>2013-10-02 10:35:14 |  100   | 0.96 [4000] | 1600 ms |
| [:chart_with_upwards_trend:](./benchmarks/results/9d32af84735887.md) [:link:](https://flood.io/9d32af84735887) Gatling-2.0.0-20131001.201622-332-bundle | 2 mins<br>2013-10-02 10:37:44 | 100 | 0.96 [4000] | 1638 ms |
| [:chart_with_upwards_trend:](./benchmarks/results/60438b3ba7ff40.md) [:link:](https://flood.io/60438b3ba7ff40) Gatling-1.5.3 | 2 mins<br>2013-10-02 11:21:56 | 1000 | 0.96 [4000] | 1635 |
| [:chart_with_upwards_trend:](./benchmarks/results/92414be786899f.md) [:link:](https://flood.io/92414be786899f) JMeter-2.9 | 2 mins<br>2013-10-02 11:24:39 | 1000 | 0.96 [4000] | 1589 |
| [:chart_with_upwards_trend:](./benchmarks/results/c475124fac6feb.md) [:link:](https://flood.io/c475124fac6feb) JMeter-r1528295 | 2 mins<br>2013-10-02 11:27:37 | 1000 | 0.97 [4000] | 1094 |
| [:chart_with_upwards_trend:](./benchmarks/results/6c2b0496fecd57.md) [:link:](https://flood.io/6c2b0496fecd57) Gatling-2.0.0-20131001.201622-332-bundle | 2 mins<br>2013-10-02 11:29:19 | 1000 | null | null |
| [:chart_with_upwards_trend:](./benchmarks/results/2b930982efff3d.md) [:link:](https://flood.io/2b930982efff3d) Gatling-1.5.3 | 60 mins<br>2013-10-02 15:02:02 | 10000 | 0.95 [4000] | 1695 |
| [:chart_with_upwards_trend:](./benchmarks/results/4ba5ec4844fae0.md) [:link:](https://flood.io/4ba5ec4844fae0) JMeter-2.9 | 60 mins<br>2013-10-02 16:02:42 | 10000 | 0.95 [4000] | 1702 |
| [:chart_with_upwards_trend:](./benchmarks/results/ab2d479bfd2fc5.md) [:link:](https://flood.io/ab2d479bfd2fc5) JMeter-r1528295 | 60 mins<br>2013-10-02 17:04:20 | 10000 | 0.95 [4000] | 1643 |
| [:chart_with_upwards_trend:](./benchmarks/results/a13baf1f8fcb89.md) [:link:](https://flood.io/a13baf1f8fcb89) Gatling-2.0.0-20131001.201622-332-bundle | 60 mins<br>2013-10-02 17:55:04 | 10000 | 0.95 [4000] | 1700 |
| [:chart_with_upwards_trend:](./benchmarks/results/cee9983bd489d1.md) [:link:](https://flood.io/cee9983bd489d1) Gatling-1.5.3 | 60 mins<br>2013-10-03 15:02:36 | 10000 | 0.95 [4000] | 1708 |
| [:chart_with_upwards_trend:](./benchmarks/results/992552b6145fa4.md) [:link:](https://flood.io/992552b6145fa4) JMeter-2.9 | 60 mins<br>2013-10-03 16:03:20 | 10000 | 0.95 [4000] | 1708 |
| [:chart_with_upwards_trend:](./benchmarks/results/402cd50f91467b.md) [:link:](https://flood.io/402cd50f91467b) Gatling-2.0.0-20131002.164439-333-bundle | 60 mins<br>2013-10-03 16:55:02 | 10000 | 0.95 [4000] | 1704 |
| [:chart_with_upwards_trend:](./benchmarks/results/cb50ec33fe73ac.md) [:link:](https://flood.io/cb50ec33fe73ac) Gatling-1.5.3 | 20 mins<br>2013-10-04 05:41:08 | 30000 | 0.95 [4000] | 1706 |
| [:chart_with_upwards_trend:](./benchmarks/results/954b7d5d79f134.md) [:link:](https://flood.io/954b7d5d79f134) JMeter-2.9 | 20 mins<br>2013-10-04 06:04:16 | 30000 | 0.24 [4000] | 238395 |
| [:chart_with_upwards_trend:](./benchmarks/results/962be9007851f2.md) [:link:](https://flood.io/962be9007851f2) JMeter-r1529062 | 20 mins<br>2013-10-04 06:26:32 | 30000 | 0.18 [4000] | 39645 |
| [:chart_with_upwards_trend:](./benchmarks/results/e6aa19ec83d795.md) [:link:](https://flood.io/e6aa19ec83d795) Gatling-2.0.0-20131003.084332-335-bundle | 20 mins<br>2013-10-04 06:42:19 | 30000 | 0.95 [4000] | 1654 |
| [:chart_with_upwards_trend:](./benchmarks/results/7d83a8fffb0b5f.md) [:link:](https://flood.io/7d83a8fffb0b5f) JMeter-2.9 | 20 mins<br>2013-10-04 10:33:58 | 30000 | 0.94 [4000] | 1790 |
| [:chart_with_upwards_trend:](./benchmarks/results/85639de7e9d7e3.md) [:link:](https://flood.io/85639de7e9d7e3) Gatling-1.5.3 | 20 mins<br>2013-10-04 10:55:31 | 30000 | 0.95 [4000] | 1710 |
| [:chart_with_upwards_trend:](./benchmarks/results/281e7285b26e08.md) [:link:](https://flood.io/281e7285b26e08) JMeter-2.9 | 20 mins<br>2013-10-04 11:18:45 | 30000 | 0.18 [4000] | 259847 |
| [:chart_with_upwards_trend:](./benchmarks/results/edbe245547dd43.md) [:link:](https://flood.io/edbe245547dd43) JMeter-r1529062 | 20 mins<br>2013-10-04 11:41:05 | 30000 | 0.25 [4000] | 40335 |
| [:chart_with_upwards_trend:](./benchmarks/results/5f9a354d37f077.md) [:link:](https://flood.io/5f9a354d37f077) Gatling-2.0.0-20131003.084332-335-bundle | 20 mins<br>2013-10-04 11:56:55 | 30000 | 0.95 [4000] | 1710 |
| [:chart_with_upwards_trend:](./benchmarks/results/9323a04545be43.md) [:link:](https://flood.io/9323a04545be43) Gatling-1.5.3 | 60 mins<br>2013-10-04 15:02:35 | 10000 | 0.95 [4000] | 1710 |
| [:chart_with_upwards_trend:](./benchmarks/results/cca530ef912308.md) [:link:](https://flood.io/cca530ef912308) JMeter-2.9 | 60 mins<br>2013-10-04 16:03:20 | 10000 | 0.95 [4000] | 1705 |
| [:chart_with_upwards_trend:](./benchmarks/results/f4f046d210ff21.md) [:link:](https://flood.io/f4f046d210ff21) JMeter-r1529062 | 60 mins<br>2013-10-04 17:04:55 | 10000 | 0.95 [4000] | 1707 |
| [:chart_with_upwards_trend:](./benchmarks/results/e69df113d8996f.md) [:link:](https://flood.io/e69df113d8996f) Gatling-2.0.0-20131003.084332-335-bundle | 60 mins<br>2013-10-04 17:55:42 | 10000 | 0.95 [4000] | 1705 |
| [:chart_with_upwards_trend:](./benchmarks/results/5d95ccbdbe02df.md) [:link:](https://flood.io/5d95ccbdbe02df) Gatling-1.5.3 | 60 mins<br>2013-10-05 03:28:17 | 10000 | 0.95 [4000] | 1759 |
| [:chart_with_upwards_trend:](./benchmarks/results/9eea54ba751d91.md) [:link:](https://flood.io/9eea54ba751d91) JMeter-2.9 | 60 mins<br>2013-10-05 04:28:59 | 10000 | 0.95 [4000] | 1695 |
| [:chart_with_upwards_trend:](./benchmarks/results/700437d8f8d924.md) [:link:](https://flood.io/700437d8f8d924) JMeter-r1529062 | 60 mins<br>2013-10-05 05:29:57 | 10000 | 0.95 [4000] | 1706 |
| [:chart_with_upwards_trend:](./benchmarks/results/c3efa60d11aabc.md) [:link:](https://flood.io/c3efa60d11aabc) Gatling-2.0.0-20131003.084332-335-bundle | 60 mins<br>2013-10-05 06:20:41 | 10000 | 0.95 [4000] | 1707 |
| [:chart_with_upwards_trend:](./benchmarks/results/0ea10ce79e0ae4.md) [:link:](https://flood.io/0ea10ce79e0ae4) JMeter-2.9 Kludge | 20 mins<br>2013-10-05 09:00:52 | 30000 | 0.9 [4000] | 2116 |
| [:chart_with_upwards_trend:](./benchmarks/results/95c0b87dab34e4.md) [:link:](https://flood.io/95c0b87dab34e4) JMeter-2.9 Kludge | 20 mins<br>2013-10-05 09:13:43 | 30000 | 0.32 [4000] | 85491 |
| [:chart_with_upwards_trend:](./benchmarks/results/348f997ed2dab8.md) [:link:](https://flood.io/348f997ed2dab8) JMeter-2.9 Kludge | 20 mins<br>2013-10-05 10:28:07 | 30000 | 0.87 [4000] | 2206 |
| [:chart_with_upwards_trend:](./benchmarks/results/52626555a22ecd.md) [:link:](https://flood.io/52626555a22ecd) JMeter-2.9 Kludge | 20 mins<br>2013-10-05 12:14:53 | 30000 | 0.79 [4000] | 3489 |
| [:chart_with_upwards_trend:](./benchmarks/results/04f7b780d73b20.md) [:link:](https://flood.io/04f7b780d73b20) Gatling-1.5.3 | 60 mins<br>2013-10-05 14:06:37 | 10000 | 0.95 [4000] | 1676 |
| [:chart_with_upwards_trend:](./benchmarks/results/15884b0de2796d.md) [:link:](https://flood.io/15884b0de2796d) JMeter-2.9 | 60 mins<br>2013-10-05 14:16:58 | 10000 | null | null |
| [:chart_with_upwards_trend:](./benchmarks/results/4238fc7e101136.md) [:link:](https://flood.io/4238fc7e101136) JMeter-r1529379 | 60 mins<br>2013-10-05 14:24:37 | 10000 | 0.96 [4000] | 1609 |
| [:chart_with_upwards_trend:](./benchmarks/results/980d1ab0f68627.md) [:link:](https://flood.io/980d1ab0f68627) Gatling-2.0.0-20131003.084332-335-bundle | 60 mins<br>2013-10-05 14:27:02 | 10000 | 0.95 [4000] | 1733 |
| [:chart_with_upwards_trend:](./benchmarks/results/4d2450d341a3d2.md) [:link:](https://flood.io/4d2450d341a3d2) JMeter-2.9 Kludge | 20 mins<br>2013-10-05 21:54:37 | 30000 | 0.94 [4000] | 1779 |
| [:chart_with_upwards_trend:](./benchmarks/results/a0542103d3f2d5.md) [:link:](https://flood.io/a0542103d3f2d5) JMeter-2.9 Kludge | 20 mins<br>2013-10-05 22:03:47 | 30000 | 0.8 [4000] | 3825 |
| [:chart_with_upwards_trend:](./benchmarks/results/aeb3bffd64ab4b.md) [:link:](https://flood.io/aeb3bffd64ab4b) JMeter-2.9 Kludge | 20 mins<br>2013-10-05 23:16:31 | 30000 | 0.9 [4000] | 2654 |
| [:chart_with_upwards_trend:](./benchmarks/results/e48ba7b6ae3f71.md) [:link:](https://flood.io/e48ba7b6ae3f71) JMeter-2.9 Kludge | 20 mins<br>2013-10-05 23:35:56 | 30000 | 0.86 [4000] | 2390 |
| [:chart_with_upwards_trend:](./benchmarks/results/69ccab50eeccff.md) [:link:](https://flood.io/69ccab50eeccff) Gatling-1.5.3 | 60 mins<br>2013-10-06 15:01:53 | 10000 | 0.95 [4000] | 1709 |
| [:chart_with_upwards_trend:](./benchmarks/results/618acd6b08afbd.md) [:link:](https://flood.io/618acd6b08afbd) JMeter-2.9 | 60 mins<br>2013-10-06 16:02:34 | 10000 | 0.95 [4000] | 1707 |
| [:chart_with_upwards_trend:](./benchmarks/results/d363b92430e6ca.md) [:link:](https://flood.io/d363b92430e6ca) JMeter-r1529559 | 60 mins<br>2013-10-06 17:03:57 | 10000 | 0.95 [4000] | 1707 |
| [:chart_with_upwards_trend:](./benchmarks/results/b3daa344b159d2.md) [:link:](https://flood.io/b3daa344b159d2) Gatling-2.0.0-20131003.084332-335-bundle | 60 mins<br>2013-10-06 17:54:46 | 10000 | 0.95 [4000] | 1707 |
