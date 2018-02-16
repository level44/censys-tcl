package require censys

set api_s [censys_api new <your api key> <your secret>]

$api_s search ipv4 "test"