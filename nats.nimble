# Package

version       = "3.0.0"
author        = "Dmitry Dorofeev"
description   = "Nim wrapper for the nats.c - NATS client library"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 0.19.0"
#requires "nimgen >= 0.5.3"
#requires "nimterop >= 0.6.12"


import distros

var cmd = ""
var ldpath = ""
var ext = ""
if detectOs(Windows):
    cmd = "cmd /c "
    ext = ".exe"
if detectOs(Linux):
    ldpath = "LD_LIBRARY_PATH=x64 "
    putEnv("PATH", getEnv("PATH") & ":~/.nimble/bin:/usr/sbin")

task setup, "Download and generate":
    exec cmd & " nimgen nats.cfg"

before install:
    setupTask()

task test, "Test nats":
#    exec "nim c --passL:'-L/usr/local/lib -lnats_static' -d:nimDebugDlOpen tests/natstest.nim"
    exec "nim c -d:nimDebugDlOpen tests/natstest.nim"
    withDir("nats"):
      exec "kill `cat /tmp/nim-nats-test.pid` > /dev/null 2>&1; echo Old nats-server cleanup done." # sometimes things go wrong, try to clean up
      exec "nats-server --port 12345 --debug --trace --pid /tmp/nim-nats-test.pid &"
      exec "sleep 1"
      exec ldpath & "../tests/natstest" & ext
      exec "sleep 1; kill $(cat /tmp/nim-nats-test.pid)"
      rmFile("/tmp/nim-nats-test.pid")
