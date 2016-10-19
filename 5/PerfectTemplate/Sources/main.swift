//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import MongoDB

// Create HTTP server.
let server = HTTPServer()

// MongoDB
// MongoDB database
let client = try! MongoClient(uri: "mongodb://localhost")
let db = client.getDatabase(name : "perfect")
let users = db.getCollection(name: "participants")
defer {
    users?.close()
    db.close()
    client.close()
}

// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
		request, response in
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
		response.completed()
	}
)

routes.add(method: .get, uri:"/participants", handler: {
    request, response in
    response.setHeader(.contentType, value: "application/json; charset=UTF-8")
    defer {
        response.completed()
    }
    let fields = BSON()
    fields.append(key: "name", int:1)
    fields.append(key: "job", int:1)
    fields.append(key: "_id", int: 0)
    let res = users!.find(query:BSON(), fields: fields)
    
    // Initialize empty array to receive formatted results
    var arr = [[String:Any]]()
    // The "fnd" cursor is typed as MongoCursor, which is iterable
    for x in res! {
        arr.append(try! x.asString.jsonDecode() as! [String:Any])
    }
    response.appendBody(string: try! arr.jsonEncodedString())
})

routes.add(method: .post, uri:"/participants", handler: {
    request, response in
    response.setHeader(.contentType, value: "application/json; charset=UTF-8")
    defer {
        response.completed()
    }
    guard let params = try! request.postBodyString?.jsonDecode() as? [String:Any] else {
        response.status = .badRequest
        return
    }
    let newParticipant = BSON()
    newParticipant.append(key: "name", string: params["name"] as! String)
    newParticipant.append(key: "job", string: params["job"] as! String)
    _ = users?.insert(document: newParticipant)
    response.status = .ok
})

// Add the routes to the server.
server.addRoutes(routes)

// Set a listen port of 8181
server.serverPort = 8181

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**
server.documentRoot = "./webroot"

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
