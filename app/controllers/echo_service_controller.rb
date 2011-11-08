class EchoServiceController < ApplicationController
  Mime::Type.register "application/wsdl+xml", :wsdl

  def wsdl
    @url = ENV['BASE_URL'] || "http://localhost:#{request.port}"
    respond_to :wsdl
  end

  def endpoint
  end
end
