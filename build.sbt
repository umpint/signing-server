import sbt.Keys.libraryDependencies


val ScalatraVersion = "2.7.0"

organization := "com.umpint"

name := "SigningServer"

version := "0.1.0-SNAPSHOT"

scalaVersion := "2.13.2"

resolvers += Classpaths.typesafeReleases


test in assembly := {}


libraryDependencies ++= Seq(
  "org.scalatra" %% "scalatra" % ScalatraVersion,
  "org.scalatra" %% "scalatra-scalatest" % ScalatraVersion % "test",
  "ch.qos.logback" % "logback-classic" % "1.2.3" % "runtime",
  "org.eclipse.jetty" % "jetty-webapp" % "9.4.28.v20200408" % "container;compile",
  "javax.servlet" % "javax.servlet-api" % "3.1.0" % "provided",
  "org.scalaj" %% "scalaj-http" % "2.4.2"
)

enablePlugins(SbtTwirl)
enablePlugins(ScalatraPlugin)
