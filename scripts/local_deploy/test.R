library(DSI)
library(DSOpal)
library(httr)
set_config(config(ssl_verifyhost = 0L, ssl_verifypeer = 0L))
library(dsBaseClient)


b <- DSI::newDSLoginBuilder()
b$append(
    server   = "local",
    url      = "http://localhost:8080",
    user     = "administrator",
    password = "ChangeMe123!",
    profile = "default"
)

logins <- b$build()
conns <- DSI::datashield.login(logins)
ds.ls()
