### Overview

[Wordpress](http://wordpress.org/about/) is arguably one of the "largest self-hosted blogging tool[s] in the world, used on millions of sites and seen by tens of millions of people every day."

In this post we're going to take a default wordpress installation from zero to hero in terms of performance. We'll discover common bottlenecks with an iterative approach to performance testing using [flood.io](https://flood.io) and the [ruby-jmeter DSL](https://github.com/flood-io/ruby-jmeter), whilst highlighting some tips along the way.

All the results and code used are available on [github](https://github.com/flood-io/flood-loadtest) so the keen can re-create and explore testing themselves.

### Setup

We're using an AWS cloud formation [template](https://raw.github.com/flood-io/flood-loadtest/master/scaling_wordpress/cfn_wordpress.json) which builds a basic single instance, LAMP stack to host wordpress. Once it's setup you should see a page similar to the following:

![](https://flood.io/images/blog/wordpress_hello_world.png)

We're using the [ruby-jmeter DSL](https://github.com/flood-io/ruby-jmeter) which lets us easily write test plans in Ruby and includes the necessary integration to get JMeter tests up and running on the cloud with [flood.io](https://flood.io). Our [test plan](https://github.com/flood-io/flood-loadtest/blob/master/scaling_wordpress/spec/jmeter_wordpress.rb) is simple and straightforward; the guts of it shown here:

```ruby
visit name: 'app_home', url: '/wordpress/'
visit name: 'app_sample_page', url: '/wordpress/sample-page/'
visit name: 'app_search_random_word', url: '/wordpress/?s=${random_word}'
```

You can also download the JMeter version of the [test plan](https://github.com/flood-io/flood-loadtest/blob/master/scaling_wordpress/spec/jmeter.jmx).

Essentially we visit the home page, then a sample page (with more content) and then search for a random word. In terms of coverage, this lets us hit static and dynamic content, as well as make trips to the database. In the default configuration of wordpress this will also include PHP bytecode interpreted by the Apache / PHP modules. This gives us basic coverage of typical user transactions. 

More realistic scenarios would obviously explore more content, and ideally have data seeded in the data base that represents production volumes. We're effectively running on an empty database.

### Performance Model

Being agile, we don't have any performance requirements __:troll:__ and our fictional product manager has approached us and said they need the site to __support 1M concurrent users__!

When we asked for more information to help [clarify](https://flood.io/blog/2-planning-for-high-concurrency-load-tests-with-jmeter) this we were met with empty looks and told _"Look, it just needs to support one million users in one hour OK?"_.

#### Static Analaysis

In any case, in the absence of historical data .. _"this is a new site!"_ .. and lacking any guidance in terms of target <abbr title="a made up word that describes concurrency and throughput">volumetrics</abbr> we used [YSlow](http://developer.yahoo.com/yslow/) to give us a static analysis of how the site might perform with just 1 user.

![](https://flood.io/images/blog/wordpress_weight_graph_before.png)

There's important information we can glean from this without running a single performance test.

#### Throughput

We can see a first visit to the site with an empty (browser) cache makes __17 requests__ for __268 KB__ of content. 
A second visit to the site with a primed cache still makes __17 requests__ but for __18 KB__ of content. So in our 1M users per hour scenario, assuming they all visit the site with an empty browser cache means:

_1M users x 268 KB content = 255 GB of traffic <abbr title="assuming even arrival times of users">per hour</abbr> at 581 Mbps (100000*268/1024*8/3600)._

That throughput would be a fair challenge for our single server setup .. __hint;__ we'll need to scale out to accommodate that.

Further more, _1M users x 17 requests per page = 283K requests per minute_ .. __hint;__ we'll need to wind that back for these types of volumes!

#### Concurrency

At this stage we're starting to build a picture of what throughput might look like for a notional target of __1M users per hour__, but we still don't know what concurrency we'd be targeting. A fall back option for many testers is to divide the number of unique users by the average visit duration for a given period.

For example, _1M unique visitors per hour / ( 60 minutes / 15 minutes per visit ) would equal 250,000 concurrent users._

This approach has its [disadvantages](https://flood.io/blog/2-planning-for-high-concurrency-load-tests-with-jmeter) but it's a start.

#### Targets 

At this point we don't have any better information so we lock down those figures as arbitrary targets:

__250K concurrent users, 1M uniques per hour with up to 280K requests per minute.__

_A bad performance model is better than NO performance model._ 
The model is always something you can test and adjust as feedback comes in from test results and/or subject matter experts.

### Our 50 User Baseline

A baseline is useful as a point of reference before we leap off the deep end when running performance tests. Baselines are simply relative lines in the sand, not absolute. They can be set at different levels of load. A best case load scenario is useful to establish how the target site runs under negligible load. __50 users__ seems harmless enough in the context of our _250K concurrency_ target so our [first test](https://flood.io/4dfecc1e6900e6) is exactly that.

![](https://flood.io/images/blog/wordpress_baseline.png)

We run 50 concurrent users for 10 minutes and observe a mean response time of __358 milliseconds at 359 kbps__. No errors are observed so we're left with _warm tummy feelings_ that this will fly all the way to 250K users.

### Our First 200 User Load Test

Now we have a best case scenario, we attempt our first load test. _4 times the baseline_ seems reasonable so we launch a [load test](https://flood.io/e29adb70c50c1c) with 200 concurrent users.

![](https://flood.io/images/blog/wordpress_load_fail.png)

Everything looked great in the first 10 minutes until we reach 200 users and mean response time blew out to _+15 seconds at 853 kbps_. With sweaty hands we console in and find the culprit:

```
[root@ip-172-31-3-33 ~]# service mysqld status
mysqld dead but subsys locked
```

The database has [run out of connections](https://dev.mysql.com/doc/refman/5.5/en/too-many-connections.html). This highlights a __single point of failure__ for us. Sure we can increase __max_connections__, but we're just going to keep hitting that limit as concurrency goes up. We submit our first request back to the infrastructure team requesting a dedicated database server, with much more RAM and properly tuned configuration. 

_"Infrastructure team are on holidays .. can't action your request until next week and even then, no promises on additional hardware to support."_

Luckily there's some tuning you can do that doesn't involve infrastructure provisioning just yet, and besides, why ask for more hardware if you don't know how much capacity you will need? _It's a long bow to draw describing capacity requirements from 200 to 250,000 users_ ...

#### Application Tuning

We know that the current max connections of 100 users is being reached when the web site has 200 users. If you fall to the temptation of just increasing limits, you may find yourself in an endless game of _"whack the beaver"_. 

![](https://flood.io/images/blog/whack_the_beaver.png)

A better idea is to __reduce demand__ on the database in the first place, as you can always revisit these settings later. I like this bracketed approach rather than opening all the pipes to begin with but it doesn't always suit.

The Guerrilla [Manifesto](http://www.perfdynamics.com/Manifesto/gcaprules.html#tth_sEc1.20) teaches us that _"You never remove a bottleneck, you just move it."_ 

Consider ...

_In any collection of processes (whether manufacturing or computing) the bottleneck is the process with the longest service demand. In any set of processes with inhomogeneous service time requirements, one of them will require the maximum service demand. That's the bottleneck. If you reduce that service demand (e.g., via performance tuning), then another process will have the new maximum service demand. These are sometimes referred to as the primary and the secondary bottlenecks. The performance tuning effort has simply re-ranked the bottleneck._

There's some obvious tuning candidates from our original __YSlow__ report. Namely, the number of requests being made, the size of the requests and the transport compression or lack of being used. We know from experience that the more concurrent requests being served by the web server (Apache in this case), the greater the demand on down stream components such as the PHP engine and database. So when dealing with web stacks, the first obvious point is to reduce this demand.

A common strategy to deal with this is [caching](http://en.wikipedia.org/wiki/Web_cache). Temporary storage of content such as HTML pages can help reduce bandwidth, request demand and service times by offloading content typically to memory or disk. Caching can be implemented at both the client and server level. In this case, reducing the number of requests made to the server from user's browsers, reducing the payload of each request (and hopefully response time), and caching frequently accessed content at the web server without round trips to back end components can dramatically increase perceived performance.

The Wordpress community has a ton of plugins that help deal with this and we chose [W3 total cache](http://wordpress.org/plugins/w3-total-cache/) to implement some of these desired caching characteristics. There's a bunch of things it does reasonably well, namely setting of cache-control headers, caching of PHP and database objects in memory/disk and minification/compression of static assets. Considering it is a plugin that can be activated with _relatively no experience_ in the configuration of these components is a huge plus.

After installing, activating and fixing some other [issues](http://codex.wordpress.org/Using_Permalinks#Fixing_Other_Issues
) related to the plugin we were able to revisit our earlier performance model with YSlow:

![](https://flood.io/images/blog/wordpress_weight_graph_after.png)

This time around the payload is significantly less weighing in at _118 KB for a first visit_, and _5 KB for subsequent visits_, so we'll definitely take a chunk off our bandwidth bill for higher concurrency/volume tests. We're still making the _same amount of requests as before_ but this time making conditional requests for content, which in theory should be served more quickly by the web server (Apache). We're also making better use of _HTTP compression_, namely gzip encoding.

What the YSlow chart can't show is the benefits of caching at both page and database layers that are now in effect. 

### Our Second 200 User Load Test

Time for another [load test](https://flood.io/1cfa4111b85ba0). 

![](https://flood.io/images/blog/wordpress_load_pass.png)

Great, this time we averaged _152 milliseconds response time_ and _halved the throughput_ whilst being able to get to 200 concurrent users with no errors. So instead of _"fixing"_ the perceived bottleneck at the database layer, we _simply reduced demand on the database_ at the web layer with some _caching / compression_ which resulted in better response times for users at the same concurrent load as when it failed earlier.

### Our First 1000 User Stress Test

We decide to up the ante and run a 1000 concurrent user [stress test](https://flood.io/fa8ba0dc4644dd). 

![](https://flood.io/images/blog/wordpress_load_fail.png)

Once again, everything was looking great up until around 800 users where the target site started hitting __max_connections__ on the database again. So now the bottleneck has _shifted back to the database layer_. Is there anything left we can do before calling the infrastructure team? 

### Web App Acceleration

Thankfully there's some even more powerful in-memory caching we can achieve in [front of the web application](http://en.wikipedia.org/wiki/Web_accelerator) with tools like [varnish cache](https://www.varnish-cache.org/). These tools are very simple to install out of the box, for example:

```
yum install varnish
```

Provided your caching strategy is relatively simple and not complicated by things like authenticated users or changing URIs, tools like __Varnish__ are very effective at further reducing load, this time saving round trips to Apache itself.

### Our Second 1000 User Stress Test

We launch another [stress test](https://flood.io/58d311af7bbcbf) to see what difference Varnish makes.

![](https://flood.io/images/blog/wordpress_stress_pass.png)

Great stuff! We're now reaching 2K concurrent users off a single instance before we start to see resource contention on the server itself and response time degradation under load.

### Next Steps

It's at this point we need to consider scaling up and out our infrastructure. We will certainly need a dedicated, highly available database server. We also know that in our worst case scenario (web and database on same instance) we're serving up to 2K concurrent users without response time degradation. We're still a long way off the arbitrary __280K concurrent users__ but we have an empirical baseline from which to test and improve. 

Testing for this is what [flood.io](https://flood.io) does best. Look at some results for __100K user__ benchmarks from a single region using [JMeter](https://flood.io/1f318398f2c306) and [Gatling](https://flood.io/da72ff31a61e8a). You could execute this type of load from 8 regions for truly massive concurrency / volume.  We understand performance testing is an _iterative approach_ and don't govern how many tests you run or constrain the number of users per test. It's __no holds barred testing__ at an affordable price and free to register / try for yourself.

Feel free to run any of these tests yourself and explore the next steps. How many web servers will we need?