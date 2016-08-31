# swagger-rails
Aplicación de muestra de creación de API con swagger, implementado en Rails 5 en su versión reducida RailsApi, además la muestra del ejemplo [swagger-rails](https://swagger-rails.herokuapp.com/) está disponible en [Heroku](https://www.heroku.com/) para usarla desde [Postman](https://www.getpostman.com/) o similares .

## Swagger
Es un potente Framework para documentación de API en tiempo de creación, tiene un pseudo lenguaje que permite que mientras comentas y construyes la API, de manera automática se está creando la documentación de la API, esta puede ser accedida desde la WEB.

```ruby
swagger_controller :users, "User Management"

  swagger_api :index do
    summary "Fetches all User items"
    notes "This lists all the active users"
    param :query, :page, :integer, :optional, "Page number"
    response :unauthorized
    response :not_acceptable
    response :requested_range_not_satisfiable
  end
```
> - Ejemplo de Swagger tomado desde la implementación oficial de la [Gema swagger-docs!](https://github.com/richhollis/swagger-docs)

## Rails-api
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

# Ejecución. 

## Creación de proyecto **RailApi**
La ejecución del comando de creación de una palicación RAILS con `--api`, permite que se genere el proyecto sin inlcuir algunas de las caracteríticas que el Framework posee por defecto, por ejemplo las VISTAS. Para generar la aplicación directamente con la configuración para la base de datos MYSQL, se usa el `-d`, el motor por defecto de Rails es SQLite.

```ruby
rails new swagger-rails --api -d mysql
```

## Construyendo nuestra API con Scaffold
Cuando se creó inicialmente una aplciación del tipo `API`, no es necesario agregar ningún comando en especial para la generación de Scaffold.

```ruby
rails g scaffold user name:string email:string password:string state:boolean

```
> Podrá notar que no se generó niguna vista, por ser un proyecto del tipo `API`

Para poner en marcha nuestra aplicación y ver como esta funcionando, tenemos que:

1. Crear la Base de Datos.
2. Ejecutar la Migración, para que se cree el modelo en la BD.
3. Ejecutar el Servidor por defecto de Rails `Puma`.
4. Visulaizar los Resultados desde el navegador.

```ruby
rake db:create
rake db:migrate
rails s -p3001
http://localhost:3001/users
```
5. Para insertar datos en el modelo creado, podemos entra en la consola de nuestra aplicación con `rails c`
```Ruby 
User.create(:name => "a", :email => "a@a.com")
User.create(:name => "b", :email => "b@b.com", :state => false)
User.create(:name => "c", :email => "c@c.com", :state => nil)
User.create(:name => "d", :email => "d@d.com", :state => true)
User.create(:name => "e", :email => "e@e.com", :state => true)
```
> Si actualizamos nuestro navegador en la dirección *http://localhost:3001/users*, podremos observar que ahora tenemos datos para visualizar.

## Serialización
Para que un modelo de Base de Datos en nuestro caso `user` se pueda representar de manera más facil como una salida `JSON` es necesario usar Serialización, en nuestro caso nosotros ya podemos ver la repuesta en JSON, entonces para que me serviria serializar???... Bien con la serialización se puede reresentar un modelo con sus respectivos campos de relación con otras tablas, excluir/agregar campos en la respuesta JSON. Tambien permite definir métodos para mostrar información extra en las respuestas por ejemplo, si queremos que en el JSON agregue tambien un campo `is_active` que basado en el valor del campo `state` nunca devuelva como respuesta un NULL(nil), se puede declarar una función con el nombre del atributo(is_active), para que verifique el valor, y lo cambie si es necesario.

```ruby
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :state, :is_active
  
  def is_active 
    _state = object.state
    (_state.nil? or _state == false ) ? false : true 
  end 

end
```

#### Serializando las respuestas de nuestra aplicación, basados en los modelos de BD.
Lo primero es agregar la [gema](https://github.com/rails-api/active_model_serializers) que permite la serialización en el archivo Gemfile, luego de esto hay que instalarla en nuestra aplicación.

**1.** Agregar al Archivo Gemfile
```ruby
# Gema de serialziación de los modelos
gem 'active_model_serializers'
```
**2.** Instalar mediante la consola la gema agregada recientemente.
```cmd
bundle install
```
**3.** Crear la serialización por defecto para el modelo USER.
```cmd
rails g serializer user
```
**4.** Agregar la depedencia de serialización
/app/controllers
**5.** Se creo el archivo de serialización de USER en la dirección *app/serializers/user_serializer.rb*, si recargamos nuestro servidor local y revisamos la respuesta, podremos comprobar que el único atributo que se muestra en la respuesta es el ID, ya que es el único que por defecto figura en el archivo de serialización.
```ruby
rails s
```
> Si necesita agregar mas campos o personalizar puede [dirigirse a la sección](##Serialización) 

**6.** Para estandarizar mejor la repuesta JSON, es necesario cubrir la respuesta en el parametro `data`, este normalmente debería ser un arduo trabajo, se podría hacer de distintas maneras según tu lógica de implementación y desarrollo, sin embargo con la gema de serialziación es muy fácil, puesto basta con crear el archivo *active_model_serializer.rb*, tambien agrega el atributo `type` en el que como valor coloca el nombre del modelo, para este caso `user`:
```ruby 
#config/initializers
ActiveModel::Serializer.config.adapter = ActiveModelSerializers::Adapter::JsonApi
```
El JSON de respuesta que tendríamos para el usuario con ID 1:
```json
#http://localhost:3001/users/1
{
  "data": {
    "id": "1",
    "type": "users",
    "attributes": {
      "name": "a",
      "email": null,
      "state": null,
      "is-active": false
    }
  }
}
```
> Podemos notar que el campo `state` para el usuario 1, tiene como valor NULL, sin embargo en el campo agregado `is-active` muestra FALSE, esto debido a que pesonalizamos la respuesta de este, así se pueden crear los campos que se estimen necesarios para luego implementar la lógica del cliente que consuma la API.

## Permitir llamadas cruzadas **Cross domain calls**
Por defecto las API no permiten que se realizen llamadas desde otros dominios, por temas de seguridad, para nuestro caso si implementamos una sencilla página web que realize una conexión mediante AJAX a nuestra API, no Permitirá conexiones cruzadas.

Llamada AJAX **sin especificar** "Content Type"
![cross-site-no-content-type](https://s26.postimg.org/g92cwxlkp/cross_site_no_content_type.png)

Llamada AJAX **especificando** "Content Type"
![cross-site](https://s26.postimg.org/my8wcy6wp/cross_site.png)

Para poder permitir conexiones desde otro dominio, es necesario usar la gema ![Cors](https://github.com/cyu/rack-cors).

Agregar la gema Cors a Gemfile
```Ruby 
#Gema para permitir conexiones de otros dominios Coss Site
gem 'rack-cors'
```
Para instalar las dependencias de gema
```cmd 
bundle install
```
Finalmente para habilitar el funcionamient de CORS y hacer nuestra API publica a otros dominios, es necesario agregar en nuestro archivo de configuración de aplicación:
```ruby
#congig/application
#For a public API, enable Cross-Origin Resource Sharing (CORS)
config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
      resource '*', :headers => :any, :methods => [:get, :post, :options]
    end
end
```
Si visualizamos ahora la espuesta de la API, tendrémos algo como lo siguiente:
![response_cross_site_enabled](https://s26.postimg.org/d3hr6q2yh/response_cross_site_enabled.png)


## Limitando las peticiones, bloqueando conexiones
Para proteger nuestra API de ataques comunes como DDOS, Ataques a fuerza bruta, multiples solicitudes de servicios y los costos que esto implicaría, es necesario utilizar algún tipo de protección, la gema [Rack::Attack](https://github.com/kickstarter/rack-attack) nos facilita la implementación de este tipo de protección.

Agregar la gema rack-attack a Gemfile
```Ruby 
#Gema para permitir conexiones de otros dominios Coss Site
gem 'rack-attack'
```
Para instalar las dependencias de gema
```cmd 
bundle install
```
Para habilitar el funcionamient de Rack Attack, es necesario agregar en nuestro archivo de configuración de aplicación:
```ruby
#congig/application
#Protect To protect our API from DDoS, brute force attacks, hammering, or even to monetize with paid usage limits
config.middleware.use Rack::Attack
```
Para la configuración de esta Gema, es necesario crear un acrhivo de sonfiguración *rack_attack.rb* que será incluido en los **initializers** de nuestra aplicación, para que sean cargados al momento de arrancar la aplicación `config/initializers/rack_attack.rb`.
```ruby
class Rack::Attack
  # `Rack::Attack` is configured to use the `Rails.cache` value by default,
  # but you can override that by setting the `Rack::Attack.cache.store` value
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Allow all local traffic
  # Excluir de la protección a la IP local
  # Always allow requests from localhost
  # (blocklist & throttles are skipped)
  self.safelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  # Allow an IP address to make 5 requests every 5 seconds
  # Permitir hasta 5 llamadas en 1sg, para la misma IP
  self.throttle('req/ip', limit: 5, period: 1) do |req|
    req.ip
  end

  # Send the following response to throttled clients
  # Mensaje  de respuesta para el cliente que esta realizando muchas llamadas a la API.
  self.throttled_response = lambda do |env|
    now = Time.now
    match_data = env['rack.attack.match_data']
    retry_after = (match_data || {})[:period]
    rate_limit_reset =  (now + (match_data[:period] - now.to_i % match_data[:period]))

    headers = {
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => rate_limit_reset.to_s,
      'Content-Type' => 'application/json',
      'Retry-After' => retry_after.to_s
    }

    [ 429, headers, [
      {:error => "Throttle limit reached. Retry later."}.to_json
      ]
    ]
  end
end
```

### Descargar y Revisar...
Para revisar el proyecto de manera local, basta con:
```cmd
git clone https://github.com/tundervirld/swagger-rails.git
cd swagger-rails
bundle install
rake db:create
rake db:migrate
rake db:seed
rails s -b 0.0.0.0 -p3001
```