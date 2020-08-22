Rails.application.routes.draw do
  get '/echo_service' => 'echo_service#wsdl'
  post '/echo_service' => 'echo_service#endpoint'
end
