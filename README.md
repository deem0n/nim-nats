nim-nats is a [Nim](https://nim-lang.org/) wrapper for the [nats-c](https://github.com/nats-io/nats.c) library.

nim-nats is distributed as a [Nimble](https://github.com/nim-lang/nimble) package. nats.nim wrapper is generated with [nimgen](https://github.com/genotrance/nimgen) and [c2nim](https://github.com/nim-lang/c2nim/).

nim-nats may be linked with dynamic nats-c lib which must be installed on the system and be available at runtime. You can link statically as well (see tests folder). On Mac OS X you can easily install lib with `brew install cnats`

Latest nim-nats version 3.x should work with NATS 3.x

JetStream and Key-Value is not yet wrapped, but might be soon.

__Installation__

nim-nats can be installed via [Nimble](https://github.com/nim-lang/nimble):

```
 git clone https://github.com/deem0n/nim-nats
 cd nim-nats
 nimble install -y
```

This will download, wrap and install nim-nats in the standard Nimble package location, typically ~/.nimble. Once installed, it can be imported into any Nim program.

__Usage__

Check [nimtest.nim](https://github.com/deem0n/nim-nats/blob/master/tests/natstest.nim) for example usage.

Module documentation can be found [here](http://nimgen.genotrance.com/nim-nats).

Don't forget to import nats in your code:

```nim
import nats
```

**Hint:** On Linux you may get problems linking your app and see errors like this:

```
/usr/local/lib64/libnats.so: undefined symbol: protobuf_c_empty_string
could not load: libnats.so
```

It happens if your system protobuf_c lib is outdated. For example, CentOS 7 has protobuf_c 1.0.x while current version is 1.3.x.
It seems that recent cnats wants recent protobuf, which is not available on recent Linux distros, ops.
To avoid dll hell I recomend to statically link against `libnats_static.a` (which is installed by default by `nats-c`).
But to make that possible you will need to compile static version of `protobuf_c.a` or pick it up from [cnats distribution](https://github.com/nats-io/cnats/tree/master/pbuf/lib).

```
# wget protobuf-cpp-3.6.1.tar.gz
cd protobuf-3.6.1
./configure --disable-shared --prefix=/opt
make && make install

# wget protobuf-c-1.3.1.tar.gz
cd protobuf-c-1.3.1
PKG_CONFIG_PATH=/opt/lib/pkgconfig ./configure --prefix=/opt
make && make install
```

You can add `static` task to your project .nimble file like this:

```
task static, "builds a static app":
  if buildOS == "linux":
    echo "Assuming that /opt/lib/libprotobuf-c.a is present..."
    exec "nimble -y build --dynlibOverride:nats --passL:-L/usr/local/lib64 --passL:-lnats_static --passL:-lpthread --passL:/opt/lib/libprotobuf-c.a --passL:-lssl --passL:-lcrypto"
  elif buildOS == "macosx":
    exec "nimble -y build --dynlibOverride:nats --passL:-L/usr/local/lib --passL:-lnats_static"
```

Run `nimble static` to build a version of your app which will not depend on cnats and protobuf libs installed on the target host.

__Testing__

```
 git clone https://github.com/deem0n/nim-nats
 cd nim-nats
 nimble setup
 nimble test
```

`nimble test` will start `nats-server` server on port 12345 and run the test client app which will publish and recieve messages to/from NATS subject. `nats-sewrver` will be killed after test completion. Please note, that test code will run on Mac OS X and Linux only, but I happily accept PR to fix Windows. 


__Development__

You will need latest `nimgen`, which is not released. Also I probably will migrate to the nimterop one day. For now you can try to run `nimble setup`, which will download some `nats-c` headers from github and will run `nimgen` to convert headers to nim.

```
 nimble install nimgen@#HEAD
 git clone https://github.com/deem0n/nim-nats
 cd nim-nats
 nimble setup
 nimble test
```

__Credits__

nim-nats wraps the cnats source code and all licensing terms of [cnats](https://github.com/nats-io/cnats/blob/master/LICENSE) apply to the usage of this package. cnats is licensed under Apache 2.0. All other code (i.e tests) in this repo is licensed under MIT license.

Credits go out to [c2nim](https://github.com/nim-lang/c2nim/) and to [nimgen](https://github.com/genotrance/nimgen) as well without which this package would be greatly limited in its abilities.

__Future plans__

1. Add Streaming NATS API
2. More tests
3. Examples of async API with callbacks (requires event loop on the nim side)

__Feedback__

nim-nats is a work in progress and any feedback or suggestions are welcome. It is hosted on [GitHub](https://github.com/deem0n/nim-nats) with an MIT license so issues, forks and PRs are most appreciated.
