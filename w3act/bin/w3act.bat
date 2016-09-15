@REM w3act launcher script
@REM
@REM Environment:
@REM JAVA_HOME - location of a JDK home dir (optional if java on path)
@REM CFG_OPTS  - JVM options (optional)
@REM Configuration:
@REM W3ACT_config.txt found in the W3ACT_HOME.
@setlocal enabledelayedexpansion

@echo off
if "%W3ACT_HOME%"=="" set "W3ACT_HOME=%~dp0\\.."
set ERROR_CODE=0

set "APP_LIB_DIR=%W3ACT_HOME%\lib\"

rem Detect if we were double clicked, although theoretically A user could
rem manually run cmd /c
for %%x in (%cmdcmdline%) do if %%~x==/c set DOUBLECLICKED=1

rem FIRST we load the config file of extra options.
set "CFG_FILE=%W3ACT_HOME%\W3ACT_config.txt"
set CFG_OPTS=
if exist %CFG_FILE% (
  FOR /F "tokens=* eol=# usebackq delims=" %%i IN ("%CFG_FILE%") DO (
    set DO_NOT_REUSE_ME=%%i
    rem ZOMG (Part #2) WE use !! here to delay the expansion of
    rem CFG_OPTS, otherwise it remains "" for this loop.
    set CFG_OPTS=!CFG_OPTS! !DO_NOT_REUSE_ME!
  )
)

rem We use the value of the JAVACMD environment variable if defined
set _JAVACMD=%JAVACMD%

if "%_JAVACMD%"=="" (
  if not "%JAVA_HOME%"=="" (
    if exist "%JAVA_HOME%\bin\java.exe" set "_JAVACMD=%JAVA_HOME%\bin\java.exe"
  )
)

if "%_JAVACMD%"=="" set _JAVACMD=java

rem Detect if this java is ok to use.
for /F %%j in ('"%_JAVACMD%" -version  2^>^&1') do (
  if %%~j==Java set JAVAINSTALLED=1
)

rem BAT has no logical or, so we do it OLD SCHOOL! Oppan Redmond Style
set JAVAOK=true
if not defined JAVAINSTALLED set JAVAOK=false

if "%JAVAOK%"=="false" (
  echo.
  echo A Java JDK is not installed or can't be found.
  if not "%JAVA_HOME%"=="" (
    echo JAVA_HOME = "%JAVA_HOME%"
  )
  echo.
  echo Please go to
  echo   http://www.oracle.com/technetwork/java/javase/downloads/index.html
  echo and download a valid Java JDK and install before running w3act.
  echo.
  echo If you think this message is in error, please check
  echo your environment variables to see if "java.exe" and "javac.exe" are
  echo available via JAVA_HOME or PATH.
  echo.
  if defined DOUBLECLICKED pause
  exit /B 1
)


rem We use the value of the JAVA_OPTS environment variable if defined, rather than the config.
set _JAVA_OPTS=%JAVA_OPTS%
if "%_JAVA_OPTS%"=="" set _JAVA_OPTS=%CFG_OPTS%

rem We keep in _JAVA_PARAMS all -J-prefixed and -D-prefixed arguments
rem "-J" is stripped, "-D" is left as is, and everything is appended to JAVA_OPTS
set _JAVA_PARAMS=

:param_beforeloop
if [%1]==[] goto param_afterloop
set _TEST_PARAM=%~1

rem ignore arguments that do not start with '-'
if not "%_TEST_PARAM:~0,1%"=="-" (
  shift
  goto param_beforeloop
)

set _TEST_PARAM=%~1
if "%_TEST_PARAM:~0,2%"=="-J" (
  rem strip -J prefix
  set _TEST_PARAM=%_TEST_PARAM:~2%
)

if "%_TEST_PARAM:~0,2%"=="-D" (
  rem test if this was double-quoted property "-Dprop=42"
  for /F "delims== tokens=1-2" %%G in ("%_TEST_PARAM%") DO (
    if not "%%G" == "%_TEST_PARAM%" (
      rem double quoted: "-Dprop=42" -> -Dprop="42"
      set _JAVA_PARAMS=%%G="%%H"
    ) else if [%2] neq [] (
      rem it was a normal property: -Dprop=42 or -Drop="42"
      set _JAVA_PARAMS=%_TEST_PARAM%=%2
      shift
    )
  )
) else (
  rem a JVM property, we just append it
  set _JAVA_PARAMS=%_TEST_PARAM%
)

:param_loop
shift

if [%1]==[] goto param_afterloop
set _TEST_PARAM=%~1

rem ignore arguments that do not start with '-'
if not "%_TEST_PARAM:~0,1%"=="-" goto param_loop

set _TEST_PARAM=%~1
if "%_TEST_PARAM:~0,2%"=="-J" (
  rem strip -J prefix
  set _TEST_PARAM=%_TEST_PARAM:~2%
)

if "%_TEST_PARAM:~0,2%"=="-D" (
  rem test if this was double-quoted property "-Dprop=42"
  for /F "delims== tokens=1-2" %%G in ("%_TEST_PARAM%") DO (
    if not "%%G" == "%_TEST_PARAM%" (
      rem double quoted: "-Dprop=42" -> -Dprop="42"
      set _JAVA_PARAMS=%_JAVA_PARAMS% %%G="%%H"
    ) else if [%2] neq [] (
      rem it was a normal property: -Dprop=42 or -Drop="42"
      set _JAVA_PARAMS=%_JAVA_PARAMS% %_TEST_PARAM%=%2
      shift
    )
  )
) else (
  rem a JVM property, we just append it
  set _JAVA_PARAMS=%_JAVA_PARAMS% %_TEST_PARAM%
)
goto param_loop
:param_afterloop

set _JAVA_OPTS=%_JAVA_OPTS% %_JAVA_PARAMS%
:run
 
set "APP_CLASSPATH=%APP_LIB_DIR%\w3act.w3act-1.1.2.jar;%APP_LIB_DIR%\org.scala-lang.scala-library-2.11.7.jar;%APP_LIB_DIR%\com.typesafe.play.twirl-api_2.11-1.0.2.jar;%APP_LIB_DIR%\org.apache.commons.commons-lang3-3.3.2.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-xml_2.11-1.0.1.jar;%APP_LIB_DIR%\com.typesafe.play.play_2.11-2.3.10.jar;%APP_LIB_DIR%\com.typesafe.play.build-link-2.3.10.jar;%APP_LIB_DIR%\com.typesafe.play.play-exceptions-2.3.10.jar;%APP_LIB_DIR%\com.typesafe.play.play-iteratees_2.11-2.3.10.jar;%APP_LIB_DIR%\org.scala-stm.scala-stm_2.11-0.7.jar;%APP_LIB_DIR%\com.typesafe.config-1.2.1.jar;%APP_LIB_DIR%\com.typesafe.play.play-json_2.11-2.3.10.jar;%APP_LIB_DIR%\com.typesafe.play.play-functional_2.11-2.3.10.jar;%APP_LIB_DIR%\com.typesafe.play.play-datacommons_2.11-2.3.10.jar;%APP_LIB_DIR%\joda-time.joda-time-2.3.jar;%APP_LIB_DIR%\org.joda.joda-convert-1.6.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-annotations-2.3.2.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-core-2.3.2.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-databind-2.3.2.jar;%APP_LIB_DIR%\org.scala-lang.scala-reflect-2.11.1.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-parser-combinators_2.11-1.0.1.jar;%APP_LIB_DIR%\io.netty.netty-3.9.9.Final.jar;%APP_LIB_DIR%\com.typesafe.netty.netty-http-pipelining-1.1.2.jar;%APP_LIB_DIR%\org.slf4j.jul-to-slf4j-1.7.6.jar;%APP_LIB_DIR%\org.slf4j.jcl-over-slf4j-1.7.6.jar;%APP_LIB_DIR%\ch.qos.logback.logback-core-1.1.1.jar;%APP_LIB_DIR%\ch.qos.logback.logback-classic-1.1.1.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-actor_2.11-2.3.4.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-slf4j_2.11-2.3.4.jar;%APP_LIB_DIR%\commons-codec.commons-codec-1.9.jar;%APP_LIB_DIR%\xerces.xercesImpl-2.11.0.jar;%APP_LIB_DIR%\xml-apis.xml-apis-1.4.01.jar;%APP_LIB_DIR%\javax.transaction.jta-1.1.jar;%APP_LIB_DIR%\com.typesafe.play.play-java_2.11-2.3.10.jar;%APP_LIB_DIR%\org.yaml.snakeyaml-1.13.jar;%APP_LIB_DIR%\org.hibernate.hibernate-validator-5.0.3.Final.jar;%APP_LIB_DIR%\javax.validation.validation-api-1.1.0.Final.jar;%APP_LIB_DIR%\org.jboss.logging.jboss-logging-3.2.0.Final.jar;%APP_LIB_DIR%\com.fasterxml.classmate-1.0.0.jar;%APP_LIB_DIR%\org.springframework.spring-context-4.0.3.RELEASE.jar;%APP_LIB_DIR%\org.springframework.spring-core-4.0.3.RELEASE.jar;%APP_LIB_DIR%\org.springframework.spring-beans-4.0.3.RELEASE.jar;%APP_LIB_DIR%\org.javassist.javassist-3.19.0-GA.jar;%APP_LIB_DIR%\org.reflections.reflections-0.9.8.jar;%APP_LIB_DIR%\dom4j.dom4j-1.6.1.jar;%APP_LIB_DIR%\com.google.code.findbugs.jsr305-2.0.3.jar;%APP_LIB_DIR%\org.apache.tomcat.tomcat-servlet-api-8.0.5.jar;%APP_LIB_DIR%\com.typesafe.play.play-java-jdbc_2.11-2.3.10.jar;%APP_LIB_DIR%\com.typesafe.play.play-jdbc_2.11-2.3.10.jar;%APP_LIB_DIR%\com.jolbox.bonecp-0.8.0.RELEASE.jar;%APP_LIB_DIR%\com.h2database.h2-1.3.175.jar;%APP_LIB_DIR%\tyrex.tyrex-1.0.1.jar;%APP_LIB_DIR%\com.typesafe.play.play-java-ebean_2.11-2.3.10.jar;%APP_LIB_DIR%\org.avaje.ebeanorm.avaje-ebeanorm-3.3.4.jar;%APP_LIB_DIR%\org.avaje.ebeanorm.avaje-ebeanorm-agent-3.2.2.jar;%APP_LIB_DIR%\org.hibernate.javax.persistence.hibernate-jpa-2.0-api-1.0.1.Final.jar;%APP_LIB_DIR%\com.typesafe.play.play-cache_2.11-2.3.10.jar;%APP_LIB_DIR%\net.sf.ehcache.ehcache-core-2.6.8.jar;%APP_LIB_DIR%\com.typesafe.play.play-java-ws_2.11-2.3.10.jar;%APP_LIB_DIR%\com.typesafe.play.play-ws_2.11-2.3.10.jar;%APP_LIB_DIR%\com.ning.async-http-client-1.8.15.jar;%APP_LIB_DIR%\oauth.signpost.signpost-core-1.2.1.2.jar;%APP_LIB_DIR%\oauth.signpost.signpost-commonshttp4-1.2.1.2.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpcore-4.3.3.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpclient-4.3.6.jar;%APP_LIB_DIR%\org.apache.commons.commons-email-1.3.2.jar;%APP_LIB_DIR%\javax.mail.mail-1.4.5.jar;%APP_LIB_DIR%\javax.activation.activation-1.1.1.jar;%APP_LIB_DIR%\commons-validator.commons-validator-1.5.1.jar;%APP_LIB_DIR%\commons-beanutils.commons-beanutils-1.9.2.jar;%APP_LIB_DIR%\commons-logging.commons-logging-1.2.jar;%APP_LIB_DIR%\commons-collections.commons-collections-3.2.2.jar;%APP_LIB_DIR%\commons-digester.commons-digester-1.8.1.jar;%APP_LIB_DIR%\org.apache.tika.tika-core-1.11.jar;%APP_LIB_DIR%\org.apache.tika.tika-parsers-1.11.jar;%APP_LIB_DIR%\org.gagravarr.vorbis-java-tika-0.6.jar;%APP_LIB_DIR%\com.healthmarketscience.jackcess.jackcess-2.1.2.jar;%APP_LIB_DIR%\commons-lang.commons-lang-2.6.jar;%APP_LIB_DIR%\com.healthmarketscience.jackcess.jackcess-encrypt-2.1.1.jar;%APP_LIB_DIR%\org.bouncycastle.bcprov-jdk15on-1.52.jar;%APP_LIB_DIR%\net.sourceforge.jmatio.jmatio-1.0.jar;%APP_LIB_DIR%\org.apache.james.apache-mime4j-core-0.7.2.jar;%APP_LIB_DIR%\org.apache.james.apache-mime4j-dom-0.7.2.jar;%APP_LIB_DIR%\org.apache.commons.commons-compress-1.10.jar;%APP_LIB_DIR%\org.tukaani.xz-1.5.jar;%APP_LIB_DIR%\org.apache.pdfbox.pdfbox-1.8.10.jar;%APP_LIB_DIR%\org.apache.pdfbox.fontbox-1.8.10.jar;%APP_LIB_DIR%\org.apache.pdfbox.jempbox-1.8.10.jar;%APP_LIB_DIR%\org.bouncycastle.bcmail-jdk15on-1.52.jar;%APP_LIB_DIR%\org.bouncycastle.bcpkix-jdk15on-1.52.jar;%APP_LIB_DIR%\org.apache.poi.poi-3.13.jar;%APP_LIB_DIR%\org.apache.poi.poi-scratchpad-3.13.jar;%APP_LIB_DIR%\org.apache.poi.poi-ooxml-3.13.jar;%APP_LIB_DIR%\org.apache.poi.poi-ooxml-schemas-3.13.jar;%APP_LIB_DIR%\org.apache.xmlbeans.xmlbeans-2.6.0.jar;%APP_LIB_DIR%\org.ccil.cowan.tagsoup.tagsoup-1.2.1.jar;%APP_LIB_DIR%\org.ow2.asm.asm-5.0.4.jar;%APP_LIB_DIR%\com.googlecode.mp4parser.isoparser-1.0.2.jar;%APP_LIB_DIR%\org.aspectj.aspectjrt-1.8.0.jar;%APP_LIB_DIR%\com.drewnoakes.metadata-extractor-2.8.0.jar;%APP_LIB_DIR%\com.adobe.xmp.xmpcore-5.1.2.jar;%APP_LIB_DIR%\de.l3s.boilerpipe.boilerpipe-1.1.0.jar;%APP_LIB_DIR%\rome.rome-1.0.jar;%APP_LIB_DIR%\jdom.jdom-1.0.jar;%APP_LIB_DIR%\org.gagravarr.vorbis-java-core-0.6.jar;%APP_LIB_DIR%\com.googlecode.juniversalchardet.juniversalchardet-1.0.3.jar;%APP_LIB_DIR%\org.codelibs.jhighlight-1.0.2.jar;%APP_LIB_DIR%\com.pff.java-libpst-0.8.1.jar;%APP_LIB_DIR%\com.github.junrar.junrar-0.7.jar;%APP_LIB_DIR%\commons-logging.commons-logging-api-1.1.jar;%APP_LIB_DIR%\org.apache.commons.commons-vfs2-2.0.jar;%APP_LIB_DIR%\org.apache.maven.scm.maven-scm-api-1.4.jar;%APP_LIB_DIR%\org.codehaus.plexus.plexus-utils-1.5.6.jar;%APP_LIB_DIR%\org.apache.maven.scm.maven-scm-provider-svnexe-1.4.jar;%APP_LIB_DIR%\org.apache.maven.scm.maven-scm-provider-svn-commons-1.4.jar;%APP_LIB_DIR%\regexp.regexp-1.3.jar;%APP_LIB_DIR%\org.apache.cxf.cxf-rt-rs-client-3.0.3.jar;%APP_LIB_DIR%\org.apache.cxf.cxf-rt-transports-http-3.0.3.jar;%APP_LIB_DIR%\org.apache.cxf.cxf-core-3.0.3.jar;%APP_LIB_DIR%\org.codehaus.woodstox.woodstox-core-asl-4.4.1.jar;%APP_LIB_DIR%\org.codehaus.woodstox.stax2-api-3.1.4.jar;%APP_LIB_DIR%\org.apache.ws.xmlschema.xmlschema-core-2.1.0.jar;%APP_LIB_DIR%\org.apache.cxf.cxf-rt-frontend-jaxrs-3.0.3.jar;%APP_LIB_DIR%\javax.ws.rs.javax.ws.rs-api-2.0.1.jar;%APP_LIB_DIR%\javax.annotation.javax.annotation-api-1.2.jar;%APP_LIB_DIR%\org.apache.opennlp.opennlp-tools-1.5.3.jar;%APP_LIB_DIR%\org.apache.opennlp.opennlp-maxent-3.0.3.jar;%APP_LIB_DIR%\net.sf.jwordnet.jwnl-1.3.3.jar;%APP_LIB_DIR%\commons-io.commons-io-2.4.jar;%APP_LIB_DIR%\org.apache.commons.commons-exec-1.3.jar;%APP_LIB_DIR%\com.googlecode.json-simple.json-simple-1.1.1.jar;%APP_LIB_DIR%\org.json.json-20140107.jar;%APP_LIB_DIR%\edu.ucar.netcdf4-4.5.5.jar;%APP_LIB_DIR%\net.jcip.jcip-annotations-1.0.jar;%APP_LIB_DIR%\net.java.dev.jna.jna-4.1.0.jar;%APP_LIB_DIR%\org.slf4j.slf4j-api-1.7.7.jar;%APP_LIB_DIR%\edu.ucar.grib-4.5.5.jar;%APP_LIB_DIR%\com.google.protobuf.protobuf-java-2.5.0.jar;%APP_LIB_DIR%\org.jdom.jdom2-2.0.4.jar;%APP_LIB_DIR%\org.jsoup.jsoup-1.8.1.jar;%APP_LIB_DIR%\edu.ucar.jj2000-5.2.jar;%APP_LIB_DIR%\org.itadaki.bzip2-0.9.1.jar;%APP_LIB_DIR%\edu.ucar.cdm-4.5.5.jar;%APP_LIB_DIR%\edu.ucar.udunits-4.5.5.jar;%APP_LIB_DIR%\edu.ucar.httpservices-4.5.5.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpmime-4.2.6.jar;%APP_LIB_DIR%\org.quartz-scheduler.quartz-2.2.0.jar;%APP_LIB_DIR%\c3p0.c3p0-0.9.1.1.jar;%APP_LIB_DIR%\com.google.guava.guava-17.0.jar;%APP_LIB_DIR%\com.beust.jcommander-1.35.jar;%APP_LIB_DIR%\org.apache.commons.commons-csv-1.0.jar;%APP_LIB_DIR%\org.apache.sis.core.sis-utility-0.5.jar;%APP_LIB_DIR%\org.opengis.geoapi-3.0.0.jar;%APP_LIB_DIR%\javax.measure.jsr-275-0.9.3.jar;%APP_LIB_DIR%\org.apache.sis.storage.sis-netcdf-0.5.jar;%APP_LIB_DIR%\org.apache.sis.storage.sis-storage-0.5.jar;%APP_LIB_DIR%\org.apache.sis.core.sis-metadata-0.5.jar;%APP_LIB_DIR%\org.apache.sis.core.sis-referencing-0.5.jar;%APP_LIB_DIR%\postgresql.postgresql-9.1-901-1.jdbc4.jar;%APP_LIB_DIR%\com.maxmind.geoip2.geoip2-0.7.0.jar;%APP_LIB_DIR%\com.maxmind.db.maxmind-db-0.3.1.jar;%APP_LIB_DIR%\com.google.http-client.google-http-client-1.17.0-rc.jar;%APP_LIB_DIR%\org.mindrot.jbcrypt-0.3m.jar;%APP_LIB_DIR%\com.rabbitmq.amqp-client-3.3.1.jar;%APP_LIB_DIR%\eu.scape-project.bitwiser.bitwiser-1.0.0.jar;%APP_LIB_DIR%\log4j.log4j-1.2.12.jar;%APP_LIB_DIR%\com.github.kevinsawicki.timeago-1.0.1.jar;%APP_LIB_DIR%\uk.bl.wa.whois.jruby-whois-3.5.9.2.jar;%APP_LIB_DIR%\org.julienrf.play-jsmessages_2.11-1.6.2.jar;%APP_LIB_DIR%\w3act.w3act-1.1.2-assets.jar"
set "APP_MAIN_CLASS=play.core.server.NettyServer"

rem Call the application and pass all arguments unchanged.
"%_JAVACMD%" %_JAVA_OPTS% %W3ACT_OPTS% -cp "%APP_CLASSPATH%" %APP_MAIN_CLASS% %*
if ERRORLEVEL 1 goto error
goto end

:error
set ERROR_CODE=1

:end

@endlocal

exit /B %ERROR_CODE%
