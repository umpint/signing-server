package uk.co.rowit

import com.umpint.signingserver.Sign
import org.scalatra.test.scalatest._

class SignTests extends ScalatraFunSuite {

  addServlet(classOf[Sign], "/*")

  test("GET / on Sign should return status 200") {
    get("/") {
      status should equal (200)
    }
  }

}
