require 'soap_fault'

class EchoServiceController < ApplicationController
  Mime::Type.register "application/wsdl+xml", :wsdl
  Mime::Type.unregister :xml
  Mime::Type.register "text/xml", :xml

  skip_before_action :verify_authenticity_token

  # Service the WSDL
  def wsdl
    @url = ENV['BASE_URL'] || "http://localhost:#{request.port}"
    respond_to :wsdl
  end

  # This is the SOAP endpoint
  def endpoint
    soap_message = Nokogiri::XML(request.body.read)
    process_soap_headers(soap_message)
    soap_body = extract_soap_body(soap_message)
    validate_soap_body(soap_body)
    # Attempt to determine the SOAP operation and process it
    self.send(soap_operation_to_method(soap_body), soap_body)
  rescue StandardError => e
    # If any exception was raised generate a SOAP fault, if there is no
    # fault_code present then default to fault_code Server (indicating the
    # message failed due to an error on the server)
    @fault_code = e.respond_to?(:fault_code) ? e.fault_code : "Server"
    @fault_string = e.message
    render :fault, :status => 500
  end

  private

  def process_soap_headers(soap_message)
    # The EchoService isn't programmed to handle particular SOAP headers,
    # any SOAP headers with mustUnderstand="1" will result in a SOAP fault
    # with fault_code MustUnderstand (indicating that the EchoService
    # couldn't process a mandatory SOAP header)
    raise(SoapFault::MustUnderstandError, "SOAP Must Understand Error", "MustUnderstand") if soap_message.root.at_xpath('//soap:Header/*[@soap:mustUnderstand="1" and not(@soap:actor)]', 'soap' => 'http://schemas.xmlsoap.org/soap/envelope/')
  end

  def extract_soap_body(soap_message)
    # Extract the SOAP body from SOAP envelope using XSLT
    xslt = Nokogiri::XSLT(File.read("#{Rails.root}/lib/soap_body.xslt"))
    xslt.transform(soap_message)
  end

  def validate_soap_body(soap_body)
    # Validate the content of the SOAP body using the XML schema that is used
    # within the WSDL
    xsd = Nokogiri::XML::Schema(File.read("#{Rails.root}/public/echo_service.xsd"))
    errors = xsd.validate(soap_body).map{|e| e.message}.join(", ")
    # If the content of the SOAP body does not validate generate a SOAP fault
    # with fault_code Client (indicating the message failed due to a client
    # error)
    raise(SoapFault::ClientError, errors) unless errors == ""
  end

  # Detect the SOAP operation based on the root element in the SOAP body
  def soap_operation_to_method(soap_body)
    method = soap_body.root.name.sub(/Request$/, '').underscore.to_sym
  end

  # Echo operation, send back the message given
  def echo(soap_body)
    @message = soap_body.root.at_xpath('//echo:Message/text()', 'echo' => 'http://www.without-brains.net/echo').to_s
    render :echo
  end

  # ReverseEcho operation, send back the message given in reverse
  def reverse_echo(soap_body)
    @message = soap_body.root.at_xpath('//echo:Message/text()', 'echo' => 'http://www.without-brains.net/echo').to_s.reverse!
    render :reverse_echo
  end
end
