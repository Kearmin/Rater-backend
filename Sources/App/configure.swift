import Vapor
import FluentMySQLDriver

// configures your application
public func configure(_ app: Application) throws {
    
    //remove existing middlewares
    app.middleware = .init()
    
    let corsConfiguration = CORSMiddleware.Configuration(allowedOrigin: .all, allowedMethods: [.GET, .PUT, .POST, .DELETE, .OPTIONS], allowedHeaders: [.accept, .authorization, .contentType ,.origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin])
    let cors = CORSMiddleware(configuration: corsConfiguration)
    
    app.middleware.use(cors)
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
//    app.middleware.use(SleepMiddleware(sleepDuration: 2))
    
    app.migrations.add(UserToken.Migration())
    app.migrations.add(Product.Migration())
    app.migrations.add(User.Migration())
    app.migrations.add(Rating.Migration())
    app.migrations.add(Product.AddBarcodeFieldMigration())
    app.migrations.add(Rating.AddForeignKeyMigration())
    app.migrations.add(User.AddAdminToUser())
    app.migrations.add(Favourite.AddFavouriteMigration())
    
    app.databases.use(.mysql(hostname: "127.0.0.1", username: "root", password: "1234", database: "Rater", tlsConfiguration: .forClient(certificateVerification: .none)), as: .mysql)
    
    // register routes
    try routes(app)
}
