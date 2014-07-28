import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

import flood._

class TestPlan extends Simulation {

  val httpConf = httpConfigFlood
    .baseURL("https://s3-ap-southeast-2.amazonaws.com/")
    .disableCaching
    .acceptHeader("text/html,application/xhtml+xml,application/xml;")
    .acceptEncodingHeader("gzip, deflate")
    .inferHtmlResources(white = WhiteList("https:\\/\\/s3-ap-southeast.*\\.html"))

  val scn = scenario("benchmark")
    .exec(http("home")
      .get("/flood-loadtest/index.html")
      .check(regex("""id="__VIEWSTATE" value="(.+?)" """).saveAs("viewstate")))
    .during(300 seconds) {
      exec(http("blog")
        .get("/flood-loadtest/blog.html"))
      .pause(20000 milliseconds)
      .exec(http("blog-post")
        .get("/flood-loadtest/blog-post.html"))
      .pause(20000 milliseconds)
      .exec(http("faq")
        .get("/flood-loadtest/faq.html"))
      .pause(20000 milliseconds)
      .exec(http("features")
        .get("/flood-loadtest/features.html"))
      .pause(20000 milliseconds)
      .exec(http("about")
        .get("/flood-loadtest/aboutus.html"))
      .pause(20000 milliseconds)
      .exec(http("contact")
        .get("/flood-loadtest/contact.html"))
      .pause(20000 milliseconds)
      .exec(http("coming-soon")
        .get("/flood-loadtest/coming-soon.html"))
      .pause(20000 milliseconds)
      .exec(http("portfolio")
        .get("/flood-loadtest/portfolio.html"))
      .pause(20000 milliseconds)
    }

  setUp(scn.inject(rampUsers(1000) over (240 seconds))).protocols(httpConf)
}
