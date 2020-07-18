import Vapor
import FluentMySQLDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.migrations.add(CreateProduct())
    
    app.databases.use(.mysql(hostname: "127.0.0.1", username: "root", password: "1234", database: "Rater", tlsConfiguration: .forClient(certificateVerification: .none)), as: .mysql)
    
    // register routes
    try routes(app)
}