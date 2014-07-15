import io.gatling.core.Predef._
import io.gatling.core.session.Expression
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._
import io.gatling.http.Headers.Names._
import io.gatling.http.Headers.Values._
import scala.concurrent.duration._
import bootstrap._
import assertions._

import flood._

class TestPlan extends Simulation {

  val httpConf = httpConfigFlood
    .baseURL("http://172.31.2.77:9000/")
    .disableResponseChunksDiscarding

  val scn = scenario("Throughput Test")
    .during(2 minutes) {
      exec(http("throughput")
      .get("/plain_text.html"))
      .pause(1000 milliseconds)
    }

  setUp(scn.inject(ramp(1000 users) over (60 seconds))).protocols(httpConf)

}
