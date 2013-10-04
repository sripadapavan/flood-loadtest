import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._

class Benchmark extends Simulation {

  val threads = Integer.getInteger("threads", 2)
  val rampup = Integer.getInteger("rampup", 10).toInt
  val duration = Integer.getInteger("duration", 120).toInt
  val uuid = System.getProperty("uuid", "test")

  // AHC response.getHeader throws Exception when response could not be built (connection crashed)
  def contentLength(response: Response) = if (response.hasResponseStatus) Option(response.getHeader("Content-Length")) else None

  val httpConf = http
    .baseURL("http://172.31.2.77:8000")
    // .baseURL("http://s1.site-staging.flood.io:8000")
    .acceptHeader("text/javascript, text/html, application/xml, text/xml, */*")
    .acceptEncodingHeader("gzip,deflate,sdch")
    .userAgentHeader("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.46 Safari/536.5")
    .extraInfoExtractor((_, _, _, response) => uuid :: contentLength(response).getOrElse("0") :: List(response.getStatusCode.toString))

  val get_slow = exec(http("get_slow").get("/slow"))

  val get_cacheable = exec(http("get_cacheable").get("/plain_text.html"))

  val get_non_cacheable = exec(http("get_non_cacheable").get("/non_cacheable")
    .check(regex("""Little Blind (\w+)""").saveAs("response_value"),
      regex("""Little Blind Text""")))

  val post_slow = exec(http("post_slow")
    .post("/slow_post?id=${counter}"))

  val scn = scenario("Gatling 2 Stress")
    .forever("counter") {
      randomSwitch(
        20 -> get_slow,
        40 -> get_cacheable,
        30 -> get_non_cacheable,
        10 -> post_slow)
        .pause(30 seconds)
    }

  setUp(scn.inject(rampUsers(threads) over rampup))
    .protocols(httpConf)
    .maxDuration(duration)
}
