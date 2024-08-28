# SwiftCache

A modular cache or data pipeline system.

The API is loosely based on Combine/SwiftUI. It doesn't resolve caching logic complexity but helps organize it in a far
more modular and testable way.

## Example

Suppose you are working on your CRUD app and find yourself in the following scenario, which no one has encountered
before:

- Your API is returning URLs for your data's images.
- Those images are sizable and take a bit to download.
- The image URLs are stable:
  - URL uniquely identifiers an image.
  - Image pointed at by a given URL will not change.
- Download may fail because network or because backend.
- You want to display the UI already and update the images when they arrive.

This library won't help you with displaying _good_ UI while you wait for image downloads. You better convince your
backend workmates to send in some media metadata like the image size. But as for a reasonably efficient caching system
for the images you would be writing something like _this_:

```swift
import SwiftCache

struct ImageConversionError: Error {}

func buildImageCache() -> AnyThrowingAsyncCache<URL, UIImage> {
    Cache.networkDataSource()
        .mapValue { data in
            guard let image = UIImage(data: data) else {
                throw ImageConversionError()
            }

            return (data, image)
        }
        .storage(LocalFileDataStorage()
            .mapID { url in
                FilePath(url.lastPathComponent)
            }
            .mapValue { data, _ in
                data
            } fromStorage: { data in
                data.flatMap { data in UIImage(data: data).map { (data, $0) } }
            }
        )
        .mapValue { _, image in
            image
        }
        .storage((WeakObjectStorage())
        .coordinated() // Always finish an `async` cache chain with this one. You usually need only one at the end.
        .eraseToAnyCache() // Using `AnyThrowingAsyncCache` as the return type makes for easy substitution in tests.
}
```

Let's look at all of this step by step…

```swift
Cache.networkDataSource()
```

Every cache needs a source, which is expected to always return a thing. If it can't, it ought to `throw`. If you are
reasonably sure it will never fail (i.e. if you are generating the values in code based on some parameters so all the
logic happens under your control) then you can use a non-throwing `Cache` type and simplify its use at the call site.

In this case we are using the simple `Cache.networkDataSource()` method that just returns a source that downloads the
data from the given `URL`, used as its `ID`, and fails if it can't.

```swift
.mapValue { data in
    guard let image = UIImage(data: data) else {
        throw ImageConversionError()
    }

    return (data, image)
}
```

It turns out that if our `Data` is not good we will be storing it and then returning an error every time we try to
retrieve it. So it's wiser to validate before storage. To retry, just request the item again after it has failed.

We pass down both the data and the generated image so we don't have to re-process it on its way back to the caller.

```swift
.storage(LocalFileDataStorage()
    .mapID { url in
        FilePath(url.lastPathComponent)
    }
    .mapValue { data, _ in
        data
    } fromStorage: { data in
        data.flatMap { data in UIImage(data: data).map { (data, $0) } }
    }
)
```

We would like to store these images in local files, in a cache folder that the system can delete if it needs more space.
Luckily for us `LocalFileDataStorage` does just that.

However, `LocalFileDataStorage` runs on `FilePath` and `Data` since it needs things it can easily write to and read from
the file system. `mapID` will convert our URLs into something that the file system likes and and `mapValue` will strip
out the `UIImage` on the way to storage and recreate it if needed.

Note that a failure to create a `UIImage` would not be a hard failure since it can still go check for the network data
again. It's still better in this case to validate before we get here (the step above this one) since that way we won't
accidentally end up storing bad data in the file system. If we only stored data and didn't validate when fetching from
storage we would end up stuck with bad data an an exception every time it were requested.

```swift
.mapValue { _, image in
    image
}
```

We're done with wrangling raw `Data` from now on, so we just filter it out and pass down the `UIImage`.

```swift
.storage((WeakObjectStorage())
```

A weak objects storage means we'll have instant access to any object that someone else has fetched before and is already
using, so it's mostly "free". Other in-memory alternatives can be built with whatever cache invalidation approaches may
work best. `NSCache` sounds good but is rarely what you actually want.

```swift
.coordinated()
```

You will always want to finish any `async` cache chain with this one. It guarantees that whatever other work has to
happen deeper (above) will not be repeated if any other part of your app requests the same item while it's being worked
on.

```swift
.eraseToAnyCache()
```

Using `AnyThrowingAsyncCache` as the return type makes for easy substitution in tests and less trouble dealing with
the Swift type system overall.

## But Wait, One More Example

Ok now you're loading those images but dropping them full size on your UI is making your app performance sad. So you go
to your friendly neighborhood backend engineer:

"Could we add thumbnail URLs to the API"

"No"

Your backend friends are too busy working on the CEOs latest flight of fancy: Uber, but for playing D&D. You're gonna
have to do something about this yourself. Well here comes `SwiftCache` to save the day…:

```swift
func buildThumbnailCache() -> AnyThrowingAsyncCache<URL, UIImage> {
    buildImageCache()
        .mapValue { image in
            if image.isLargerThanThumbnail {
                image.downscaled(size: thumbnailSize)
            } else {
                return image
            }
        }
        .storage((WeakObjectStorage())
        .coordinated()
        .eraseToAnyCache()
}
```

This should help. And if it doesn't help _enough_, you can build up something more sophisticated the same way. Your
cache could literally return a publisher that returns the large image first and the thumbnail once calculated or a
different storage policy may work better for this use case.

## Tips & Tricks

- `SwiftCache` doesn't make complexity go away, but it helps manage it. You're still going to have to think things
through and be careful with your caching design.
- Start with the dumbest setup you can get away with and increase the complexity of individual components as performance
measurements indicate it will be the most impactful.
- If your caching layer or storage may have issues on reentrancy an `actor` is your best friend. In the context of
solving the problems that `SwiftCache` is meant to help with, order of execution of concurrent tasks shouldn't be one,
which makes `actors` a perfect fit for shielding against reentrancy issues for these. And remember that the basic
avoidance of repeated work for the same ID is already taken care of by `coordinated()`.
- Bears repeating: always finish off an `AsyncCache` or `ThrowingAsyncCache` with `coordinated()`
- The given components (`Cache.networkSource`, `LocalFileDataStorage` etc.) are purposefully the dumbest implementations
that work. Feel free to copy/paste them and use more sophisticated logic if your use case warrants it.
