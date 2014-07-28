import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

import flood._

class TestPlan extends Simulation {

  val httpConf = httpConfigFlood
    .baseURL("https://s3-ap-southeast-2.amazonaws.com/")
    .disableCaching
    .acceptHeader("text/javascript, text/html, application/xml, text/xml, */*;")
    .acceptEncodingHeader("gzip, deflate")

  val scn = scenario("benchmark")
    .during(600 seconds) {
      exec(http("api")
        .get("/flood-loadtest/api.json"))
      .pause(60000 milliseconds)
    }

  setUp(scn.inject(rampUsers(10000) over (600 seconds))).protocols(httpConf)
}
