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
    .during(1800 seconds) {
      exec(http("api")
        .get("/flood-loadtest/api.json"))
      .pause(10000 milliseconds)
    }

  setUp(scn.inject(rampUsers(5000) over (240 seconds))).protocols(httpConf)
}
