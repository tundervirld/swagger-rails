# swagger-rails
Aplicación de muestra de creación de API con swagger, implementado en Rails 5 en su versión reducida RailsApi, además la muestra del ejemplo [swagger-rails](https://swagger-rails.herokuapp.com/) está disponible en [Heroku](https://www.heroku.com/) para usarla desde [Postman](https://www.getpostman.com/) o similares .

##Swagger
Es un potente Framework para documentación de API en tiempo de creación, tiene un pseudo lenguaje que permite que mientras comentas y construyes la API, de manera automática se está creando la documentación de la API, esta puede ser accedida desde la WEB.

```rails
swagger_controller :users, "User Management"

  swagger_api :index do
    summary "Fetches all User items"
    notes "This lists all the active users"
    param :query, :page, :integer, :optional, "Page number"
    response :unauthorized
    response :not_acceptable
    response :requested_range_not_satisfiable
  end
````
> - Ejemplo de Swagger tomado desde la implementación oficial de la [Gema swagger-docs!](https://github.com/richhollis/swagger-docs)

##Rails-api
Rails, es un potente Framework MVC que ayuda en el desarrollo aplicaciones WEB robustas, RailsApi es una versión reducida del Framework que permite concentrar las funcionalidades en la construcción de API, disminuyendo peso de componentes que no son necesarios como por ejemplo carga de helpers, gemas y demás relacionadas con las vistas, además esta versión del Framework considera mejores prácticas y estándares al momento de crear APIS.
Por que usar [RailApi](http://edgeguides.rubyonrails.org/api_app.html), según su documentación nos ofrece:

- Capa Middleware:
  - Logs de los diferentes eventos.
  - Seguridad en ataques de suplantación de identidad.
  - Parámetros como objetos en las llamadas, fácilmente legibles desde la implementación con la variable **param**.
  - Códigos de estados HTTP.
  - Manejo de HEADERS.
- Capa de Acciones:  
  - Enrutamiento inteligente.
  - Token de autenticación.
  - Plugins para dar potencia a la aplicación.
  
###Desarrollo
Para revisar el proyecto de manera local, basta con:
```cmd
git clone https://github.com/tundervirld/swagger-rails.git
cd swagger-rails
rails s
```
