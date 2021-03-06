import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._

class RecordedSimulation extends Simulation {

  val threads   = Integer.getInteger("threads",  10)
  val rampup    = Integer.getInteger("rampup",   60).toLong
  val duration  = Integer.getInteger("duration", 120).toLong
    
  val uuid      = List(System.getProperty("uuid"))

  val httpConf = httpConfig
      .baseURL("http://loadtest.flood.io")
      .acceptHeader("text/javascript, text/html, application/xml, text/xml, */*")
      .acceptEncodingHeader("gzip,deflate,sdch")
      .connection("keep-alive")
      .userAgentHeader("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.46 Safari/536.5")
      .requestInfoExtractor((request: Request) => { uuid })
      .responseInfoExtractor(response => Option(response.getHeader("Content-Length"))
                              .map(List(_))
                              .getOrElse(List("0")) ++ List[String](response.getStatusCode.toString())
                            )

  val headers_13 = Map(
      "If-Modified-Since" -> """Thu, 01 Aug 2013 17:55:05 GMT""",
      "If-None-Match" -> """"2072c-cc17-4e2e68abf7040""""
  )

  val headers_14 = Map(
      "If-Modified-Since" -> """Tue, 25 Jun 2013 22:03:42 GMT""",
      "If-None-Match" -> """"20725-57d7-4e001b3bdeb80""""
  )

  val headers_15 = Map(
      "If-Modified-Since" -> """Wed, 21 Aug 2013 18:17:04 GMT""",
      "If-None-Match" -> """"207c9-16b9d-4e4792e314800""""
  )

  val headers_16 = Map(
      "If-Modified-Since" -> """Tue, 23 Jul 2013 15:28:25 GMT""",
      "If-None-Match" -> """"207ef-1c20-4e22f71a7b840""""
  )

  val headers_17 = Map(
      "If-Modified-Since" -> """Wed, 21 Nov 2012 22:31:55 GMT""",
      "If-None-Match" -> """"207c2-155b-4cf08eaee0cc0""""
  )

  val headers_18 = Map(
      "If-Modified-Since" -> """Tue, 25 Jun 2013 21:30:43 GMT""",
      "If-None-Match" -> """"206fa-7f6-4e0013dc8c6c0""""
  )

  val scn = scenario("Scenario Name")
    .during(duration seconds) {
      group("app_home") {
        exec(http("app_home")
          .get("/wordpress/")
        )
        .pause(990 milliseconds)
        .exec(http("app_home")
          .get("http://fonts.googleapis.com/css")
          .queryParam("""family""", """Source Sans Pro:300,400,700,300italic,400italic,700italic|Bitter:400,700""")
          .queryParam("""subset""", """latin,latin-ext""")
        )
        .pause(27 milliseconds)
        .exec(http("app_home")
          .get("/wordpress/wp-content/themes/twentythirteen/fonts/genericons.css")
          .queryParam("""ver""", """2.09""")
        )
        .pause(17 milliseconds)
        .exec(http("app_home")
          .get("/wordpress/wp-content/themes/twentythirteen/style.css")
          .queryParam("""ver""", """2013-07-18""")
        )
        .pause(416 milliseconds)
        .exec(http("app_home")
          .get("/wordpress/wp-includes/js/jquery/jquery-migrate.min.js")
          .queryParam("""ver""", """1.2.1""")
        )
        .pause(58 milliseconds)
        .exec(http("app_home")
          .get("/wordpress/wp-content/themes/twentythirteen/js/functions.js")
          .queryParam("""ver""", """2013-07-18""")
        )
        .pause(1)
        .exec(http("app_home")
          .get("/wordpress/wp-includes/js/jquery/jquery.js")
          .queryParam("""ver""", """1.10.2""")
        )
        .pause(142 milliseconds)
        .exec(http("app_home")
          .get("/wordpress/wp-includes/js/jquery/jquery.masonry.min.js")
          .queryParam("""ver""", """2.1.05""")
        )
      }
      .pause(10,15)
      .exec(http("app_sample_page")
        .get("/wordpress/sample-page/")
      )
      .pause(10,15)
      .group("app_search_random_word") {
        exec(http("app_search_random_word")
          .get("/wordpress/")
          .queryParam("""s""", """Staircase""")
        )
        .pause(390 milliseconds)
        .exec(http("app_search_random_word")
          .get("http://fonts.googleapis.com/css")
          .queryParam("""family""", """Source Sans Pro:300,400,700,300italic,400italic,700italic|Bitter:400,700""")
          .queryParam("""subset""", """latin,latin-ext""")
        )
        .pause(81 milliseconds)
        .exec(http("app_search_random_word")
          .get("/wordpress/wp-content/themes/twentythirteen/style.css")
          .headers(headers_13)
          .queryParam("""ver""", """2013-07-18""")
          .check(status.is(304))
        )
        .exec(http("app_search_random_word")
          .get("/wordpress/wp-content/themes/twentythirteen/fonts/genericons.css")
          .headers(headers_14)
          .queryParam("""ver""", """2.09""")
          .check(status.is(304))
        )
        .pause(14 milliseconds)
        .exec(http("app_search_random_word")
          .get("/wordpress/wp-includes/js/jquery/jquery.js")
          .headers(headers_15)
          .queryParam("""ver""", """1.10.2""")
          .check(status.is(304))
        )
        .pause(349 milliseconds)
        .exec(http("app_search_random_word")
          .get("/wordpress/wp-includes/js/jquery/jquery-migrate.min.js")
          .headers(headers_16)
          .queryParam("""ver""", """1.2.1""")
          .check(status.is(304))
        )
        .pause(73 milliseconds)
        .exec(http("app_search_random_word")
          .get("/wordpress/wp-includes/js/jquery/jquery.masonry.min.js")
          .headers(headers_17)
          .queryParam("""ver""", """2.1.05""")
          .check(status.is(304))
        )
        .pause(11 milliseconds)
        .exec(http("app_search_random_word")
          .get("/wordpress/wp-content/themes/twentythirteen/js/functions.js")
          .headers(headers_18)
          .queryParam("""ver""", """2013-07-18""")
          .check(status.is(304))
        )
      }
    }
  setUp(scn.users(threads).ramp(rampup).protocolConfig(httpConf))
}
