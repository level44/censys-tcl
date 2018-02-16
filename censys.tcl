################################################################################
#   censys.tcl
#
#
#   ----------------------------------------------------------------------------
#   Revision: 0.0.1
#   Author: level44
#
#   ----------------------------------------------------------------------------
#****h* /censys_api
# DESCRIPTION
#   Library allows to comunicate with Censys database
#
# Basic examples
#
#******
################################################################################
################################################################################
#
#

package provide censys 0.0.1

package require http
package require TclOO
package require tls
package require json
package require base64
http::register https 443 [list ::tls::socket -tls1 1 -servername censys.io]

oo::class create censys {
    variable Api_key
    variable Api_secret
    variable Auth
    variable Debug
    variable Api_url

    #****p* censys/constructor
    # NAME
    #   constructor
    #
    # DESCRIPTION
    #   Create censys object
    #
    # ARGUMENTS
    #   api_key - censys api key
    #
    # RESULT
    #   Object handler
    #
    # USAGE
    #   set api_s [censys <api_key> <secret>]
    #
    #******
    constructor {api_key api_secret} {
        set Api_key $api_key
        set Api_secret $api_secret
        set Auth [base64::encode $Api_key:$Api_secret]
        set Debug 1
    }

    #****ip* censys/Debug
    # NAME
    #   Debug
    #
    # DESCRIPTION
    #   Private procedure used to print out debug informations
    #
    # ARGUMENTS
    #   str - string to print out if debuging is enabled
    #
    # RESULT
    #
    # USAGE
    #   my Debug "test debug"
    #
    #******
    method Debug {str} {
        if {$Debug} {
            puts $str
        }
    }

    #****ip* censys/Execute
    # NAME
    #   Execute
    #
    # DESCRIPTION
    #   Private procedure used to perform call to censys server
    #
    # ARGUMENTS
    #   path - path to method
    #   method - method to call
    #   query - query data
    #
    # RESULT
    #   2 element List with returnCode and dictionary as result
    #       first element - error code
    #           >0 OK
    #       second element - dictionary
    #
    # USAGE
    #
    #******
    method Execute {path method data {mode {format}}} {
        my Debug "Called"
        set header [list Authorization "Basic $Auth"]
        switch $method {
            GET {
                my Debug "Executed for $path?[http::formatQuery {*}$data]"
                set tok [http::geturl $path?[my FormatQuery $data $mode]  -method $method -headers $header]
            }
            POST {
                my Debug "POST method"
                my Debug "$path\n$data"
                set tok [http::geturl $path -query [my FormatQuery $data $mode]  -method $method -headers $header]
            }
            PUT {
                my Debug "PUT method"
                my Debug "$path\n$data"
                my Debug "headers: $header"
                set tok [http::geturl $path -query [my FormatQuery $data $mode]  -method $method -headers $header]
            }
            DELETE {
                my Debug "DELETE method"
                my Debug "$path\n$data"
                set tok [http::geturl $path -query [my FormatQuery $data $mode]  -method $method -headers $header]
            }
        }
        set ncode [::http::ncode $tok]
        my Debug "Request response ncode $ncode"
        if {$ncode eq 401} {
            ::http::cleanup $tok
            return [list -1 [dict create error "Not authorized"]]
        } elseif {$ncode ne 200} {
            my Debug [::http::data $tok]
            return [list -1 [dict create error "Return code $ncode"]]
        } else {
            set ret [ http::data $tok ]
            my Debug "Response:"
            my Debug $ret
            ::http::cleanup $tok
            if {[catch {set ret [::json::json2dict $ret]}]} {
                return [list -1 "Not possible to parse json"]
            } else {
                return [list 0 $ret]
            }
        }
    }

    #****ip* censys/FormatQuery
    # NAME
    #   FormatQuery
    #
    # DESCRIPTION
    #   Private procedure to format query
    #
    # ARGUMENTS
    #   data - source data
    #   mode - raw/format
    #
    # RESULT
    #   Formated or original data (depends on mode setting)
    #
    # USAGE
    #
    #******
    method FormatQuery {data mode} {
        if {$mode eq "format"} {
            return [http::formatQuery {*}$data]
        } else {
            return $data
        }
    }

}

oo::class create censys_api {
    superclass censys
    variable Api_url
    variable Auth

    constructor {args} {
        set Api_url "https://censys.io/api/v1"
        next {*}$args
    }

    #****p* censys_api/search
    # NAME
    #   search
    #
    # DESCRIPTION
    #   Search censys database
    #
    # ARGUMENTS
    #   index - the search index to be queried. Must be one of ipv4, websites, or certificates.
    #   query - the query to be executed
    #   page - the page of the results
    #   fields - the fields to return
    #   flatten - format of the returned results
    #
    # RESULT
    #
    #
    # USAGE
    #   $api_s search ipv4 "test"
    #
    #******
    method search {index query {page {1}} {fields {}} {flatten {true}}} {
        set path "$Api_url/search/$index"
        puts $path
        set data "{\"query\":\"$query\",\"page\":$page,\"fields\":\[\"ip\"\],\"flatten\": $flatten}"
        return [my Execute $path POST $data raw]
    }
}