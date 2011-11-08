require 'test_helper'

class EchoServiceTest < ActionDispatch::IntegrationTest
  fixtures :all

  def teardown
    ENV['BASE_URL'] = nil
  end

  test "echo to the echo service" do
    post "/echo_service", %Q{<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:echo="http://www.without-brains.net/echo">
   <soapenv:Body>
      <echo:EchoRequest>
         <echo:Message>Hello World!</echo:Message>
      </echo:EchoRequest>
   </soapenv:Body>
</soapenv:Envelope>}

  expected = %Q{<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/" xmlns:echo="http://www.without-brains.net/echo">
  <SOAP:Body>
    <echo:EchoResponse>
      <echo:Message>Hello World!</echo:Message>
    </echo:EchoResponse>
  </SOAP:Body>
</SOAP:Envelope>}

    assert_equal expected, @response.body.strip
    assert_equal 200, @response.status
  end

  test "reverse to the echo service" do
    post "/echo_service", %Q{<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:echo="http://www.without-brains.net/echo">
   <soapenv:Body>
      <echo:ReverseEchoRequest>
         <echo:Message>Hello World!</echo:Message>
      </echo:ReverseEchoRequest>
   </soapenv:Body>
</soapenv:Envelope>}

  expected = %Q{<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/" xmlns:echo="http://www.without-brains.net/echo">
  <SOAP:Body>
    <echo:ReverseEchoResponse>
      <echo:Message>!dlroW olleH</echo:Message>
    </echo:ReverseEchoResponse>
  </SOAP:Body>
</SOAP:Envelope>}

    assert_equal expected, @response.body.strip
    assert_equal 200, @response.status
  end

  test "echo service gives soap error on invalid message" do
    post "/echo_service", %Q{<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:echo="http://www.without-brains.net/echo">
   <soapenv:Body>
      <echo:EchoRequest>
      </echo:EchoRequest>
   </soapenv:Body>
</soapenv:Envelope>}

  expected = %Q{<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP:Body>
    <SOAP:Fault>
      <faultcode>SOAP:Client</faultcode>
      <faultstring>Element '{http://www.without-brains.net/echo}EchoRequest': Missing child element(s). Expected is ( {http://www.without-brains.net/echo}Message ).</faultstring>
    </SOAP:Fault>
  </SOAP:Body>
</SOAP:Envelope>}

    assert_equal expected.strip, @response.body.strip
    assert_equal 500, @response.status
  end

  test "echo service gives error for must understand soap headers" do
    post "/echo_service", %Q{<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:echo="http://www.without-brains.net/echo">
   <soapenv:Header>
     <echo:RandomHeader soapenv:mustUnderstand="1">
       Yes
     </echo:RandomHeader/>
   </soapenv:Header>
   <soapenv:Body>
      <echo:EchoRequest>
         <echo:Message>Hello World!</echo:Message>
      </echo:EchoRequest>
   </soapenv:Body>
</soapenv:Envelope>}

  expected = %Q{<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP:Body>
    <SOAP:Fault>
      <faultcode>SOAP:MustUnderstand</faultcode>
      <faultstring>SOAP Must Understand Error</faultstring>
    </SOAP:Fault>
  </SOAP:Body>
</SOAP:Envelope>}

    assert_equal expected.strip, @response.body.strip
    assert_equal 500, @response.status
  end

  test "echo service ignores soap headers with actor attribute set" do
    post "/echo_service", %Q{<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:echo="http://www.without-brains.net/echo">
   <soapenv:Header>
     <echo:RandomHeader soapenv:mustUnderstand="1" soapenv:actor="http://www.without-brains.net/another_service">
       Yes
     </echo:RandomHeader/>
   </soapenv:Header>
   <soapenv:Body>
      <echo:EchoRequest>
         <echo:Message>Hello World!</echo:Message>
      </echo:EchoRequest>
   </soapenv:Body>
</soapenv:Envelope>}

  expected = %Q{<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/" xmlns:echo="http://www.without-brains.net/echo">
  <SOAP:Body>
    <echo:EchoResponse>
      <echo:Message>Hello World!</echo:Message>
    </echo:EchoResponse>
  </SOAP:Body>
</SOAP:Envelope>}

    assert_equal expected.strip, @response.body.strip
    assert_equal 200, @response.status
  end

  test "echo service checks all soap headers" do
    post "/echo_service", %Q{<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:echo="http://www.without-brains.net/echo">
   <soapenv:Header>
     <echo:FirstRandomHeader soapenv:mustUnderstand="1" soapenv:actor="http://www.without-brains.net/another_service">
       Yes
     </echo:FirstRandomHeader/>
     <echo:SecondRandomHeader soapenv:mustUnderstand="1">
       Yes
     </echo:SecondRandomHeader/>
   </soapenv:Header>
   <soapenv:Body>
      <echo:EchoRequest>
         <echo:Message>Hello World!</echo:Message>
      </echo:EchoRequest>
   </soapenv:Body>
</soapenv:Envelope>}

  expected = %Q{<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP:Body>
    <SOAP:Fault>
      <faultcode>SOAP:MustUnderstand</faultcode>
      <faultstring>SOAP Must Understand Error</faultstring>
    </SOAP:Fault>
  </SOAP:Body>
</SOAP:Envelope>}

    assert_equal expected.strip, @response.body.strip
    assert_equal 500, @response.status
  end

  test "wsdl_has_endpoint_url_based_on_env" do
    ENV['BASE_URL'] = 'http://echo.without-brains.net'
    get '/echo_service.wsdl'
    assert_equal 200, @response.status
    wsdl_doc = Nokogiri::XML(@response.body)
    endpoint_url =  wsdl_doc.root.at_xpath('//wsdl:service/wsdl:port/soap:address/@location', 'wsdl' => 'http://schemas.xmlsoap.org/wsdl/', 'soap' => 'http://schemas.xmlsoap.org/wsdl/soap/').value
    assert_equal "http://echo.without-brains.net/echo_service", endpoint_url
  end

  test "wsdl_has_localhost_endpoint_url_when_none_is_set_in_env" do
    get '/echo_service.wsdl'
    assert_equal 200, @response.status
    wsdl_doc = Nokogiri::XML(@response.body)
    endpoint_url =  wsdl_doc.root.at_xpath('//wsdl:service/wsdl:port/soap:address/@location', 'wsdl' => 'http://schemas.xmlsoap.org/wsdl/', 'soap' => 'http://schemas.xmlsoap.org/wsdl/soap/').value
    assert_equal "http://localhost:#{@request.port}/echo_service", endpoint_url
  end
end
