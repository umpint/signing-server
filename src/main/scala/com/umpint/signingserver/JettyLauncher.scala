package com.umpint.signingserver

import org.eclipse.jetty.server.Server
import org.eclipse.jetty.webapp.WebAppContext
import org.scalatra.servlet.ScalatraListener
import org.slf4j.LoggerFactory

object JettyLauncher { // this is my entry object as specified in sbt project definition
  def main(args: Array[String]) {
    val logger=LoggerFactory.getLogger(getClass)
    logger.info("jetty launcher starting up")
    val port = if(System.getenv("UMPINT_PORT") != null) System.getenv("UMPINT_PORT").toInt else 8080
    logger.info(s"jetty launcher starting up on port $port")
    val server = new Server(port)
    val context = new WebAppContext()
    context setContextPath "/"
    context.setResourceBase("src/main/webapp")
    context.addEventListener(new ScalatraListener)
    //context.addServlet(classOf[DefaultServlet], "/")

    server.setHandler(context)

    server.start
    server.join
  }
}
