# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import strformat
import nats

var nc: ptr natsConnection 
var sub: ptr natsSubscription

proc onMsg(nc: ptr natsConnection, sub: ptr natsSubscription, msg: ptr natsMsg, closure: pointer) = 
    echo "GOT MESSAGE!"
    # Prints the message, using the message getters:
    echo fmt"==>ON subject {natsMsg_GetSubject(msg)} received bytes: {natsMsg_GetDataLength(msg)}"
    #echo fmt"==>{natsMsg_GetData(msg)}"
    # Don't forget to destroy the message!
    natsMsg_Destroy(msg);

proc connect(port: int) : natsStatus =
  var status = natsConnection_ConnectTo(addr nc, fmt"nats://localhost:{port}" ) 
  echo status
  return status

proc talkToMyself(subj: string, msgCount: int): int = 
  let st = natsConnection_SubscribeSync(addr sub, nc, subj)
  echo "subscribe: ", st
  var i = 0
  var r = 0
  var timeouts = 0
  while i < msgCount and timeouts < 10:
    i = i + 1
    discard natsConnection_PublishString(nc, subj, fmt"Hi man: {i}")
    discard natsConnection_Flush(nc)
    var msg: ptr natsMsg
    let s = natsSubscription_NextMsg(addr msg, sub, 1)
    if s == NATS_OK:
      echo fmt"==>ON subject {natsMsg_GetSubject(msg)} received {natsMsg_GetData(msg)} [{natsMsg_GetDataLength(msg)} bytes]"
      natsMsg_Destroy(msg)
      r = r + 1
      timeouts = 0
    elif s == NATS_TIMEOUT:
      echo "Timed out, will try again..."
      timeouts = timeouts + 1
      i = i - 1 # give it a chance
    else:
      echo "BAD Next Message status: ", s
  return r


test "server is not started: can not connect":
  check connect(44422) == NATS_NO_SERVER # hopefully nobody listen...

test "successful connect":
  check connect(12345) == NATS_OK # test should start gnatsd on this port

test "talking to myself":
  let testsCount = 44
  check talkToMyself("nim", testsCount) == testsCount

test "unsubscribe":
  check natsSubscription_Unsubscribe(sub) == NATS_OK

test "subs destroy":
  natsSubscription_Destroy(sub)
  check true

test "conn destroy":
  natsConnection_Close(nc)
  natsConnection_Destroy(nc)
  check true