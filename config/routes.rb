EchoServiceRails::Application.routes.draw do
  match '/echo_service' => 'echo_service#wsdl', :via => :get
  match '/echo_service' => 'echo_service#endpoint', :via => :post
end
