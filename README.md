
# censys-tcl
## Tcl library for Censys
Censys is advanced search engine for Internet connected devices.
This library is a TCL interface to [Censys API](https://censys.io/api).

Library currently supports:
- Search API

## Requirements
Library requires:
- Censys API key and secret phrase
- TCL 8.6
or
- TCL 8.5 + TclOO packages installed
## Instalation
Repository content shall be placed in the TCL library path

## Loading library
```
package require censsys
```

## Examples
### Initialization of Censys API
```
set s_api [censys_api new <api_key>]
```

### Search
```
$api_s search ipv4 "test"
```