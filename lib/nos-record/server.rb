require "nos-record/error"

module NosRecord
  module Server
    HDR_FMT     = "CL"

    RETRV   = 0
    STORE   = 1
    UNSTORE = 2
    VALUES  = 3

    OK          = 0
    PARSE_ERROR = 1
    REQ_ERROR   = 2
    DS_ERROR    = 3

    ERRORS = {
      PARSE_ERROR => ParseError,
      REQ_ERROR   => RequestError,
      DS_ERROR    => DataStoreError
    }


  end # module::Server
end # module::NosRecord
