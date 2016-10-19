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
import PerfectMustache


// Create HTTP server.
let server = HTTPServer()

// MongoDB
// MongoDB database
let client = try! MongoClient(uri: "mongodb://localhost")
let db = client.getDatabase(name : "perfect")
let participants = db.getCollection(name: "participants")
defer {
    participants?.close()
    db.close()
    client.close()
}

struct UserListHandler: MustachePageHandler { // all template handlers must inherit from PageHandler
    // This is the function which all handlers must impliment.
    // It is called by the system to allow the handler to return the set of values which will be used when populating the template.
    // - parameter context: The MustacheWebEvaluationContext which provides access to the HTTPRequest containing all the information pertaining to the request
    // - parameter collector: The MustacheEvaluationOutputCollector which can be used to adjust the template output. For example a `defaultEncodingFunc` could be installed to change how outgoing values are encoded.
    
    func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        var values = MustacheEvaluationContext.MapType()
        
        let fields = BSON()
        fields.append(key: "name", int:1)
        fields.append(key: "job", int:1)
        fields.append(key: "_id", int: 0)
        let fnd = participants!.find(query: BSON(), fields: fields)
        // Initialize empty array to receive formatted results
        var arr = [[String:Any]]()
        // The "fnd" cursor is typed as MongoCursor, which is iterable
        for x in fnd! {
            arr.append(try! x.asString.jsonDecode() as! [String:Any])
        }
        
        values["empty"] = arr.count == 0
        values["participants"] = arr
        
        contxt.extendValues(with: values)
        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch {
            let response = contxt.webResponse
            response.status = .internalServerError
            response.appendBody(string: "\(error)")
            response.completed()
        }
    }
}

// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
		request, response in
		response.setHeader(.contentType, value: "text/html")
        // Setting the body response to the generated list via Mustache
        mustacheRequest(
            request: request,
            response: response,
            handler: UserListHandler(),
            templatePath: request.documentRoot + "/index.mustache"
        )
	}
)

routes.add(method: .get, uri: "/newParticipant", handler: {
    request, response in
    response.setHeader(.contentType, value: "text/html")
    // Setting the body response to the generated list via Mustache
    mustacheRequest(
        request: request,
        response: response,
        handler: UserListHandler(),
        templatePath: request.documentRoot + "/participant.mustache"
    )
    }
)

routes.add(method: .post, uri: "/createParticipant", handler : {
    request, response in
    defer { response.completed() }
    let params:[(key: String, value: String)] = request.postParams;
    let bson = BSON()
    defer {
        bson.close()
    }
    
    for param in params {
        if (param.key == "name") {
            bson.append(key: "name", string: param.value)
        } else if (param.key == "job") {
            bson.append(key: "job", string: param.value)
        }
    }
    _ = participants!.save(document: bson)
    
    response.status = .found
    response.setHeader(.location, value:"/")
    
})

routes.add(method: .get, uri:"/participants", handler: {
    request, response in
        response.setHeader(.contentType, value: "application/json; charset=UTF-8")
        defer { response.completed() }
        let fields = BSON()
        fields.append(key: "name", int:1)
        fields.append(key: "job", int:1)
        fields.append(key: "_id", int: 0)
        let res = participants!.find(query:BSON(), fields: fields)
    
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
    defer { response.completed() }
    guard let params = try! request.postBodyString?.jsonDecode() as? [String:Any] else {
        response.status = .badRequest
        return
    }
    let newParticipant = BSON()
    newParticipant.append(key: "name", string: params["name"] as! String)
    newParticipant.append(key: "job", string: params["job"] as! String)
    _ = participants?.insert(document: newParticipant)
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
