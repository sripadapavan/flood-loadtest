import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._

class Benchmark extends Simulation {

  val threads = Integer.getInteger("threads", 1)
  val rampup = Integer.getInteger("rampup", 10).toLong
  val duration = Integer.getInteger("duration", 60).toLong

  val uuid = List(System.getProperty("uuid", "test"))

  val httpConf = httpConfig
    .baseURL("http://172.31.2.77:8000")
    // .baseURL("http://s1.site-staging.flood.io:8000")
    .acceptHeader("text/javascript, text/html, application/xml, text/xml, */*")
    .acceptEncodingHeader("gzip,deflate,sdch")
    .connection("keep-alive")
    .userAgentHeader("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.46 Safari/536.5")
    .requestInfoExtractor((request: Request) => { uuid })
    .responseInfoExtractor(response => Option(response.getHeader("Content-Length")).getOrElse("0") :: List(response.getStatusCode.toString))

  val get_slow = exec(http("get_slow")
    .get("/slow"))
    .pause(15 seconds)

  val get_cacheable = exec(http("get_cacheable")
    .get("/plain_text.html"))
    .pause(15 seconds)

  val get_non_cacheable = exec(http("get_non_cacheable")
    .get("/non_cacheable")
    .check(regex("""Little Blind (\w+)""").saveAs("response_value"))
    .check(regex("""Little Blind Text""")))
    .pause(15 seconds)

  val post_slow = exec(http("post_slow")
    .post("/slow_post?id=${counter}"))
    .pause(15 seconds)

  val scn = scenario("Gatling 1 Benchmark")
    .during(duration, "counter") {
      randomSwitch(
        20 -> get_slow,
        40 -> get_cacheable,
        30 -> get_non_cacheable,
        10 -> post_slow)
    }

  setUp(scn.users(threads).ramp(rampup).protocolConfig(httpConf))
}
