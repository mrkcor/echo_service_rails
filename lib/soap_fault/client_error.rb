module SoapFault
  class ClientError < StandardError
    def fault_code
      "Client"
    end
  end
end
