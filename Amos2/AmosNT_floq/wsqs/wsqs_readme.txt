How to use the WSMED demo from a web browser
============================================

1. Register as a user with a given username.

2. Import wsdl URI's

   a).  http://user.it.uu.se/~msabesan/WSDL/TerraService2.wsdl
   b).  http://user.it.uu.se/~msabesan/WSDL/PlaceLookup.wsdl
   c).  http://user.it.uu.se/~msabesan/WSDL/ZipCodeLookup.wsdl
   d).  http://user.it.uu.se/~msabesan/WSDL/uszip.wsdl

3. Import Passwords to ulilize the opertions provided with some web services
   a). 
       1. WSDL URI - http://user.it.uu.se/~msabesan/WSDL/PlaceLookup.wsdl
       2. Web service name- GeoPlaces 
       3. Webservice operation name -  GetAllStates 
       4. SOAP Info - 5Dk7GEJdXC5Fe07t6wzk7iKrngadVXznLjVQT0gC0vsb2VNLushCXeiAhB2Ki0HuwiQY43c+1QpQOqTLLKX2Y8cRTCHDHO+Q

   b).
       1. WSDL URI - http://user.it.uu.se/~msabesan/WSDL/PlaceLookup.wsdl
       2. Web service name- GeoPlaces 
       3. Webservice operation name -  GetPlacesWithin
       4. SOAP Info - 5Dk7GEJdXC5Fe07t6wzk7iKrngadVXznLjVQT0gC0vsb2VNLushCXeiAhB2Ki0HuwiQY43c+1QpQOqTLLKX2Y8cRTCHDHO+Q

   c).
       1. WSDL URI - http://user.it.uu.se/~msabesan/WSDL/ZipCodeLookup.wsdl
       2. Web service name - ZipCodes
       3. Webservice operation name -  GetPlacesInside
       4. SOAP Info - 5Dk7GEJdXC5Fe07t6wzk7iKrngadVXznLjVQT0gC0vsb2VNLushCXeiAhB2Ki0HuwiQY43c+1QpQOqTLLKX2Y8cRTCHDHO+Q

   d).

       1. WSDL URI - http://user.it.uu.se/~msabesan/WSDL/ZipCodeLookup.wsdl
       2. Web service name - ZipCodes
       3. Webservice operation name -  GetZipCodesWithin
       4. SOAP Info - 5Dk7GEJdXC5Fe07t6wzk7iKrngadVXznLjVQT0gC0vsb2VNLushCXeiAhB2Ki0HuwiQY43c+1QpQOqTLLKX2Y8cRTCHDHO+Q

4. Example SQL queries:

   a). select * from  GetAllStates gs

   b). select gl.City ,  gl.PlaceTypeId from  GetAllStates gs, GetPlacesWithin gp, GetPlaceList gl where gs.State=gp.state and gp.distance=15.0 and gp.placeTypeToFind= 'City' and gp.place= 'Atlanta' and gl.placeName=gp.ToPlace+' , '+gp.ToState and gl.MaxItems=100 and gl.imagePresence= 'true' 


