import Vapor
import Fluent
import FluentMySQLDriver
import FluentSQL

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
        
    try app.register(collection: ProductController())
    try app.register(collection: RatingController())
    try app.register(collection: UserController())
    try app.register(collection: PagesController())
    
    for route in app.routes.all {
        print("\(route)\n")
    }
}
