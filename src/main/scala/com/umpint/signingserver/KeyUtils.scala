package com.umpint.signingserver

import java.io.File
import java.nio.file.{Files, Paths}
import java.security.interfaces.RSAPrivateKey
import java.security.spec.PKCS8EncodedKeySpec
import java.security.{KeyFactory, PrivateKey, Signature}
import java.util.Base64

object KeyUtils {
  def getPrivateKeyFromFile(file: File) = {
    val encoded = Files.readAllBytes(Paths.get(file.toURI()))
    getPrivateKeyFromString(new String(encoded,"UTF-8"))
  }

  def getPrivateKeyFromString(key: String) = {
    var privateKeyPEM = key;
    privateKeyPEM = privateKeyPEM.replace("-----BEGIN PRIVATE KEY-----\n", "");
    privateKeyPEM = privateKeyPEM.replace("-----END PRIVATE KEY-----", "");
    privateKeyPEM = privateKeyPEM.replace("\n", "");

    val decoded = Base64.getDecoder().decode(privateKeyPEM)
    val kf = KeyFactory.getInstance("RSA")
    val keySpec = new PKCS8EncodedKeySpec(decoded)
    val privKey = kf.generatePrivate(keySpec).asInstanceOf[RSAPrivateKey]
    privKey
  }
  def  sign( privateKey: PrivateKey,  message :String) ={
    val sign = Signature.getInstance("SHA256withRSA");
    sign.initSign(privateKey);
    sign.update(message.getBytes());
    new String(Base64.getEncoder().encode(sign.sign()), "UTF-8");
  }
}
