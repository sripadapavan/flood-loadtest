import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import com.excilys.ebi.gatling.redis.Predef.redisFeeder
import akka.util.duration._
import bootstrap._
import com.redis._
import serialization._

class Redis extends Simulation {

  val threads = Integer.getInteger("threads", 2)
  val rampup = Integer.getInteger("rampup", 10).toLong
  val duration = Integer.getInteger("duration", 120).toLong

  val uuid = List(System.getProperty("uuid", "test"))

  val redisPool = new RedisClientPool("54.252.206.143", 6379)

  val httpConf = httpConfig
    .baseURL("http://s1.site-staging.flood.io:8000")
    .acceptHeader("text/javascript, text/html, application/xml, text/xml, */*")
    .acceptEncodingHeader("gzip,deflate,sdch")
    .connection("keep-alive")
    .userAgentHeader("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.46 Safari/536.5")
    .requestInfoExtractor((request: Request) => { uuid })
    .responseInfoExtractor(response => Option(response.getHeader("Content-Length"))
    .getOrElse("0") :: List(response.getStatusCode.toString))

  val scn = scenario("Gatling Redis Benchmark")
    .feed(redisFeeder(redisPool, "random_words"))
    .during(duration, "counter") {
      exec(http("get_slow")
        .get("/?random_word=${random_words}"))
        .pause(1 seconds)
    }

  setUp(scn.users(threads).ramp(rampup).protocolConfig(httpConf))

}
