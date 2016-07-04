conOra<-function(sqlstr){
  library(ROracle)
  drv <- dbDriver("Oracle")
  
  ###测试环境
  str_test <-"
  (DESCRIPTION=
  (ADDRESS=
  (PROTOCOL=TCP)
  (HOST=192.168.240.202)
  (PORT=1521)
  )
  (CONNECT_DATA=
  (SERVER=DEDICATED)
  (SERVICE_NAME=XE)
  )
  )"

  ###正式环境连接
  str <-"(DESCRIPTION =
  (ADDRESS_LIST =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.65.7)(PORT = 1521))
  )
  (CONNECT_DATA =
  (SID = ECD)
  (SERVER = DEDICATED)
  )
  )"

  con <- dbConnect(drv, username = "bluemoon", password = "bpms123",
                   dbname = str)
  rs <- dbSendQuery(con, sqlstr)
  data <- fetch(rs) 
  if(dbDisconnect(con)) return(data)
  else stop("数据库无法断开")
}


