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
    
    app.group("pages") { pages in
        
        pages.group("products") { products in
            
            //afterid
            products.get() { req -> String  in
                return "products for id"
            }
            
            //afterId
            products.get("foruser") { req -> String in
                return "products for user id"
            }
        }
        
        pages.group("ratings") { ratings in
            
            //afterId
            ratings.get("product", ":id") { req -> String in
                return "Rating for productId"
            }
            //afterId
            ratings.get("user", ":id") { req -> String in
                return "rating for userId"
            }
        }
    }
    
    app.group("user") { user in
        
        user.post("signUp") { req -> String in
            return "signup"
        }
        
        user.post("login") { req -> String in
            return "login"
        }
        
        user.get(":id") { req -> String in
            return "get user"
        }
        
        user.post { req -> String in
            return "Create user"
        }
        
        user.put(":id") { req -> String in
            return "update user"
        }
        
        user.delete(":id") { req -> String in
            return "delete user"
        }
    }
    
}
