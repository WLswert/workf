###PIC
library(data.table)
source("R/echart/utils.R")
source('R/echart/optSetUtils.R')
source('R/ePie.R')
source('R/echart/eLine.R')

###pie
dt=c(sum(Dtlist$combine$非公司员工.y)/10000,sum(Dtlist$combine$公司员工.y)/10000)
dt=round(dt,digits = 2)
names(dt) = c("非公司员工","公司员工")

ePie(dt,title = "月亮商城销量图",ser.name="销量",
     toolbox  = FALSE,formatter = "{a} <br/>{b} : {c}万 ({d}%)")

####line
ldt=Dtlist$combine[,c(2,6:7)]
y=cbind.data.frame("总销量"=ldt[,1],"非员工销量"=round(ldt[,2]/10000,digits=3))
row.names(y)=as.character(Dtlist$combine$DAYTIME)


eLine(y, opt=list(dataZoom=list(show=TRUE,end=35)),toolbox = FALSE)


####area
debug(eLine)

da=Dtlist$card
melt(Dtlist$card,id.vars = c(1,4))
adt=dcast.data.table(Dtlist$card,DAYTIME+month~PAY_TYPE,value.var = "card_no")
row.names(adt)=as.character(adt$DAYTIME)
pdt=as.data.frame(adt,stringsAsFactor=F)
pdt[is.na(pdt)] <- 0

eArea(pdt[,c(-1,-2)],stack = NULL)

