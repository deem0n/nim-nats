nim-nats is a [Nim](https://nim-lang.org/) wrapper for the [cnats](https://github.com/nats-io/cnats) library.

nim-nats is distributed as a [Nimble](https://github.com/nim-lang/nimble) package and depends on [nimgen](https://github.com/genotrance/nimgen) and [c2nim](https://github.com/nim-lang/c2nim/) to generate the wrappers.

nim-nats requires dynamic cnats lib to be installed on the system and be available at runtime. On Mac OS X you can easily install it with `brew install cnats`

__Installation__

nim-nats can be installed via [Nimble](https://github.com/nim-lang/nimble):

```
 nimble install nimgen

 git clone https://github.com/deem0n/nim-nats
 cd nim-nats
 nimble install -y
```

This will download, wrap and install nim-nats in the standard Nimble package location, typically ~/.nimble. Once installed, it can be imported into any Nim program.

__Usage__

Check [nimtest.nim](https://github.com/deem0n/nim-nats/blob/master/tests/natstest.nim) for example usage.

Module documentation can be found [here](http://nimgen.genotrance.com/nim-nats).

Just import nats:

```nim
import nats
```

__Testing__

```
 git clone https://github.com/deem0n/nim-nats
 cd nim-nats
 nimble setup
 nimble test
```

`nimble test` will start `gnatsd` server on port 12345 and run the test client app which will publish and recieve messages to/from NATS subject. `gnatsd` server will be killed after test completion. Please note, that test code will run on Mac OS X and Linux only, but I happily accept PR to fix Windows. 

__Credits__

nim-nats wraps the cnats source code and all licensing terms of [cnats](https://github.com/nats-io/cnats/blob/master/LICENSE) apply to the usage of this package. cnats is licensed under Apache 2.0. All other code (i.e tests) in this repo is licensed under MIT license.

Credits go out to [c2nim](https://github.com/nim-lang/c2nim/) and to [nimgen](https://github.com/genotrance/nimgen) as well without which this package would be greatly limited in its abilities.

__Future plans__

1. Add Streaming NATS API
2. More tests
3. Examples of async API with callbacks (requires event loop on the nim side)

__Feedback__

nim-nats is a work in progress and any feedback or suggestions are welcome. It is hosted on [GitHub](https://github.com/deem0n/nim-nats) with an MIT license so issues, forks and PRs are most appreciated.
