import Vapor
import FluentMySQLDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    let corsConfiguration = CORSMiddleware.Configuration(allowedOrigin: .all, allowedMethods: [.GET, .PUT, .POST, .DELETE, .OPTIONS], allowedHeaders: [.accept, .authorization, .contentType ,.origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin])
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors)
    
    app.migrations.add(UserToken.Migration())
    app.migrations.add(Product.Migration())
    app.migrations.add(User.Migration())
    app.migrations.add(Rating.Migration())
    app.migrations.add(Product.AddBarcodeFieldMigration())
    
    app.databases.use(.mysql(hostname: "127.0.0.1", username: "root", password: "1234", database: "Rater", tlsConfiguration: .forClient(certificateVerification: .none)), as: .mysql)
    
    // register routes
    try routes(app)
}
