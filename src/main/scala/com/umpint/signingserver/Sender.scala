package com.umpint.signingserver

import org.slf4j.LoggerFactory
import scalaj.http.{Http, HttpOptions, HttpResponse}

case class HashSig(hash:String, signature:String)

class Sender(keyURL:String,URL: String) {

  val logger=LoggerFactory.getLogger(getClass)
  logger.info(s"Sender sending to:[$URL] for host [$keyURL]")

  def sendSig(hashSig: HashSig) ={
    val url=s"${URL}/api/v1/sign/$keyURL?hash=${hashSig.hash}&sig=${hashSig.signature}"
    logger.info(s"running get:[$url]")
    val result=scala.io.Source.fromURL(url).mkString
    logger.info(s"result was [$result]")
    result
  }
  def sendSig(hashSigs: Seq[HashSig]) ={
    logger.info(s"hashSigs :${hashSigs.size} URL $URL")
    val postData=hashSigs.map { hashsig=>
      "[\""+hashsig.hash+"\",\""+hashsig.signature+"\"]"
    }.mkString(",")

    val result=Http(s"${URL}/api/v1/sign/$keyURL").postData("["+postData+"]")
      .header("Content-Type", "application/json")
      .header("Charset", "UTF-8")
      .option(HttpOptions.readTimeout(60000)).asString.body
    logger.info(s"result was [$result]")
    result
  }
}
