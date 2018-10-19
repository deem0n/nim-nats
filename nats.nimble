# Package

version       = "1.0.0"
author        = "Dmitry Dorofeev"
description   = "Nim wrapper for the cnats - NATS and NATS Streaming client library"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 0.19.0"
requires "nimgen >= 0.4.0"


import distros

var cmd = ""
var ldpath = ""
var ext = ""
if detectOs(Windows):
    cmd = "cmd /c "
    ext = ".exe"
if detectOs(Linux):
    ldpath = "LD_LIBRARY_PATH=x64 "

task setup, "Download and generate":
    exec cmd & "nimgen nats.cfg"

before install:
    setupTask()

task test, "Test nats":
    exec "nim c -d:nimDebugDlOpen tests/natstest.nim"
    withDir("nats"):
      exec "kill `cat /tmp/nim-nats-test.pid` > /dev/null 2>&1; echo Old gnatsd cleanup done." # sometimes things go wrong, try to clean up
      exec "gnatsd --port 12345 --debug --trace --pid /tmp/nim-nats-test.pid &"
      exec "sleep 1"
      exec ldpath & "../tests/natstest" & ext
      exec "sleep 1; kill $(cat /tmp/nim-nats-test.pid)"
      rmFile("/tmp/nim-nats-test.pid")