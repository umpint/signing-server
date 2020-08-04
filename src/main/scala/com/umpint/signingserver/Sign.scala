package com.umpint.signingserver

import org.scalatra._
import org.slf4j.LoggerFactory

import scala.io.Source
class Sign extends ScalatraServlet {
  val logger=LoggerFactory.getLogger(getClass)
  val privateKeyFile = System.getenv("UMPINT_KEY")
  val secret = System.getenv("UMPINT_SECRET")
  val keyUrl=System.getenv("UMPINT_URL")
  val serverHostUrl=System.getenv("UMPINT_SERVERHOST")
  val homepage=System.getenv("UMPINT_HOMEPAGE")
  val homepageString = Source.fromFile(homepage).getLines.mkString
  val signer=new Signer(privateKeyFile)
  val sender=new Sender(keyUrl,serverHostUrl)
  val rt = Runtime.getRuntime
  def logMemUsage()={
    val usedMB = (rt.totalMemory - rt.freeMemory) / 1024 / 1024
    logger.info("Memory usage (MB):" + usedMB)
  }
  get("/") {

    contentType="text/html"
    logMemUsage()
    Ok(homepageString)
  }

  get("/sign") {
    val hashParam = params("hash")
    val secretParam = params("secret")
    logger.info(s"GET sign called - hash:[$hashParam] secret[$secretParam]")

    secretParam match {
      case `secret` =>
        logger.debug("secret correct")
        val signature = signer.Sign(hashParam).replace("+", "-").replace("=", "_").replace("/", "~")
        val sendResult = sender.sendSig(HashSig(hashParam, signature))
        logger.debug("returned:"+sendResult)
        logMemUsage()
        Ok(sendResult)
      case _ =>
        logger.info(s"secret[$secretParam] incorrect - rejecting call")
        Unauthorized(s"Secret parameter of $secretParam did not match expected.")
    }
  }
  post("/sign") {
    val secretParam=params("secret")
    //logger.info("post:"+request.body)
    val hashes = request.body.split("\n")
    logger.info(s"POST sign called - secret[$secretParam]")

    secretParam match {
      case `secret` =>
        logger.info("secret correct")
        val hashSigs=hashes.map { hash=>
          val signature=signer.Sign(hash).replace("+","-").replace("=","_").replace("/","~")
          HashSig(hash,signature)
        }
        val sendResult=sender.sendSig(hashSigs)
        logger.debug("returned:"+sendResult)
        logMemUsage()
        Ok(sendResult)
      case _ =>
        logger.info(s"secret[$secretParam] incorrect - rejecting call")
        Unauthorized(s"Secret parameter of $secretParam did not match expected.")
    }
  }

}
