module SoapFault
  class MustUnderstandError < StandardError
    def fault_code
      "MustUnderstand"
    end
  end
end
