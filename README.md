# BAPersistentOperationQueue

A persistent operation queue that uses a database to save operations that need to be completed at a later time.

[![Build Status](https://travis-ci.org/inf0rmer/BAPersistentOperationQueue.svg?branch=master)](https://travis-ci.org/inf0rmer/BAPersistentOperationQueue)
[![Version](http://cocoapod-badges.herokuapp.com/v/BAPersistentOperationQueue/badge.png)](http://cocoadocs.org/docsets/BAPersistentOperationQueue)
[![Platform](http://cocoapod-badges.herokuapp.com/p/BAPersistentOperationQueue/badge.png)](http://cocoadocs.org/docsets/BAPersistentOperationQueue)

BAPersistentOperation employs a FIFO queue that uses both a database and an in-memory queue to save operations that, for some reason, must be completed at a later time. The best use case (and the purpose of its existence!) is to allow POST/PUT/DELETE requests in an app to be saved and performed in their correct order at a later time, in case the network connection is unavailable. It uses an NSOperationQueue to automatically handle these operations in separate threads, and makes use of delegate methods to provide the host application “hooks” to serialize and deserialize objects for greater flexibility.

Its only dependency is [FMDB](https://github.com/ccgus/fmdb).

## Example

To run the example project; clone the repo, and run `pod install` from the Example directory first.
The project consists of a simple table view that allows you to create "Requests", which are mock asynchronous operations that have a random amount of latency before they finish.
There is also a button to make your app go "online" and "offline". When "offline", any new requests added start in a "Stopped" state. When you either go "online" or restart the application, these Requests are inserted into a queue and then performed one at a time.

## Requirements
[FMDB](https://github.com/ccgus/fmdb)

## Installation

BAPersistentOperationQueue is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

```
pod "BAPersistentOperationQueue"
```

## How to use

Full documentation is available through [CocoaDocs](http://cocoadocs.org/docsets/BAPersistentOperationQueue), but here are the highlights:

### The queue

#### startWorking
Starts processing operations in the queue. If the queue has no operations in memory, it will try to load more from the database.

#### stopWorking
Stops processing operations in the queue.

#### loadOperationsFromDatabase
Loads operations from the database into the memory queue.

### The BAPersistentOperationQueue Delegate
The class where you'll use the queue can (and probably should) conform to this protocol.

#### persistentOperationQueueSerializeObject:
This hook gives you the chance to serialize your custom objects into the queue. You should return an ```NSDictionary``` with arbitrary data that you want to save. This data will later be used to reconstruct your object.

#### persistentOperationQueueStartedOperation:
This hook is triggered when an operation begins processing. You are then able to use the operation's ```data``` property to reconstruct your original object. You are also responsible for finishing the operation in this delegate, by calling ```[operation finish]```.

## License

BAPersistentOperationQueue is available under the MIT license. See the LICENSE file for more info.
