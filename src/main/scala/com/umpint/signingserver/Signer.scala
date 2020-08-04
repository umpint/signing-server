package com.umpint.signingserver

import java.io.File

import org.slf4j.LoggerFactory

class Signer (val keyFile: String)  {
  val logger=LoggerFactory.getLogger(getClass)
  var lastModifiedTime=new File(keyFile).lastModified()
  var privateKey=KeyUtils.getPrivateKeyFromFile(new File(keyFile))
  logger.info(s"Timestamp of key is $lastModifiedTime at startup")
  def Sign(hash: String) ={
    val f=new File(keyFile).lastModified()
    if(f>lastModifiedTime) {
      logger.info(s"Timestamp of key change from $lastModifiedTime to $f")
      lastModifiedTime=f
      privateKey=KeyUtils.getPrivateKeyFromFile(new File(keyFile))
    }
    KeyUtils.sign(privateKey,hash)
  }
}
