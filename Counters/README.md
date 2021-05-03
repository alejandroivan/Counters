# Counters

The project doesn't need anything special to run, just open `Counters.xcodeproj` with Xcode,
select the active scheme and a simulator and press "Run". It doesn't use any external dependency,
so it's good to go.

Unit tests were added for the Main scene (for example purposes), along with tests for the Services
business logic (there's no point to test `Endpoint` for the example, but something could be done to
test the `path(for:)` method).

# What else could be done here?

## Modularize

The Services group is a strong candidate to do it, along with the Extensions and the Models.
UIComponents too in its own module.

This could have been easily achievable using CocoaPods (`pod lib create <name>`) and setting
the correct visibility to some objects (`public`/`open` for the local caches for example), but creating
more repositories in GitHub could have been misinterpreted as an "external" dependency, along with
making the process to compile a bit longer (`pod install`, `open Counters.xcworkspace`, etc).

Swift Package Manager could have been another option.

# What to improve (technical test approach)?

Since this is an example test, the networking layer **should not** have been pointed to  `127.0.0.1`,
but rather let the developer set this request base URL. This way, he can get himself into the trouble of
dealing with App Transport policy (if using a local network IP, `192.168.x.y`).

That forces the developer to test for connectivity issues too, if he chooses that route.
**To note**: Network Link Conditioner doesn't work with loopback IP. Boomer!
