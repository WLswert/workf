source('R/SelFromOra.R', encoding = 'UTF-8')

argsProcess<-function(tablestr,funstr,by,argv=NULL){
  if(!is.null(argv))
  {argv=gsub("\t","",argv)
  s=scan(what="",text =argv,sep = "{" )}else
  {argv=list(tablestr,funstr,by,)
  s=scan(what="",text =unlist(argv),sep = "{" )}
  if(length(s)>1){
    for(i in 1:length(s)){
      name=paste0("pasestr",i)
      tmp=parse(text = s[i])
      assign(name,tmp)
    }
    evldata=unique(eval(pasestr1))
    dt=evldata[, eval(pasestr2), by = eval(pasestr3)]
    return(dt)
  }else{
    tmp=parse(text = s)
    evldata=unique(eval(tmp))
  }
}


DtProcess<-function(){
library(data.table)


##data$DAYTIME=strptime(data$DAYTIME,'%Y-%m-%d')

bak = data.table(data)

attach(bak)

#####

######get data which have a realtionship of outcode ,need to unique outcode
widedt=data.table(OUTCODE,PAY_TYPE,CARDUSE_TYPE,PAY_TOTAL,ITEM_NAME
           ,USERID,PROVINCE_NAME,CITY_NAME,DAYTIME)

#########use function
day_sales=argsProcess(argv=c("data.table(ORDER_ID,NUM, PAY_TOTAL, DAYTIME)","list(paytotal=round(sum(PAY_TOTAL) / 100 / 10000, 2),itemnum=sum(NUM))","DAYTIME"
))
sale_num=argsProcess(argv=c(
"data.table(OUTCODE, DAYTIME,USERID)","list(ordernum=length(OUTCODE))","list(DAYTIME,USERID)"
))
add_total=argsProcess(argv=c(
"data.table(PROVINCE_NAME,CITY_NAME,OUTCODE,DAYTIME)","list(order_no=length(OUTCODE))","list(DAYTIME,CITY_NAME,PROVINCE_NAME)"
))

partion_item=argsProcess(argv = "data.table(OUTCODE,ITEM_NAME)")

USER_DT=argsProcess(argv = c(
  "data.table(DAYTIME,OUTCODE,PAY_TOTAL,USERID)","list(usersale=sum(PAY_TOTAL)/100)","list(DAYTIME,USERID)"
))
card_wide=argsProcess(argv = "data.table(DAYTIME,OUTCODE,PAY_TYPE,PAY_TOTAL,CARDUSE_TYPE,USERID)")

card_tl=argsProcess(argv=c(
  "data.table(DAYTIME,OUTCODE,PAY_TYPE)","list(card_no=length(OUTCODE))","list(DAYTIME,PAY_TYPE)"
))

worker=argsProcess(argv=c(
  "data.table(USER_ID,USERID,PAY_TOTAL,ITEMNAME,OUTCODE,PAY_TYPE)","list(user_pay=sum(PAY_TOTAL),times=length(PAY_TOTAL))","list(USER_ID,USERID)"
))

detach(bak)

Gwork=worker[order(worker$user_pay,decreasing = T),][1:30,]

chg_saleNum=dcast(sale_num, DAYTIME ~USERID , drop=FALSE)


chg_useDT=dcast(USER_DT, DAYTIME ~USERID , drop=FALSE)

names(day_sales)[1]='DAYTIME'
combine_DT=Reduce((function() {counter = 0
  function(x, y) {
    counter <<- counter + 1
    d = merge(x, y, all = T, by = 'DAYTIME')
    setnames(d, names(d))
  }})(), list(day_sales, chg_saleNum, chg_useDT))

card_tl$month=months(card_tl$DAYTIME)
add_total$month=months(add_total$DAYTIME)

combine_DT$month=months(combine_DT$DAYTIME)

return(list(card=card_tl,addres=add_total,combine=combine_DT,Arules=partion_item,workers=worker))

}


#####need to manual analysis the rules

Anarules<-function(order_item,supp=0.001,conf=0.1,lift=5){
  library(arules)
  #library(arulesViz)
  sp=split(order_item$ITEM_NAME,order_item$OUTCODE)

  ts=as(sp,"transactions")

  iteminfo=data.frame(
    count=itemFrequency(ts,"absolute"),
    fre=round(itemFrequency(ts),4))

  iteminfo$name=rownames(iteminfo)

  iteminfo=iteminfo[order(iteminfo$count,decreasing = T),]

  rules <- apriori(ts,
                   parameter = list(supp = supp, conf = conf, target = "rules"))

  sub.rule=subset(sort(rules,by=c("confidence","lift")),subset=lift>lift)

  return(list(endt=sub.rule,orule=rules,numdt=iteminfo,len=length(order_item[,1])))
}

# 相关系数
# library(psych)
# corr.test((combine_DT[,"pasestr3"=NULL]),method = "pearson")
# cor(combine_DT$paytotal,combine_DT$公司员工)


