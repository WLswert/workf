source("R/ProcessData.R",encoding = "UTF-8")

Dtlist=DtProcess()

ruleDt=Anarules(Dtlist$Arules)

tot_n=ruleDt$numdt
nd=data.frame(tot_n$name,tot_n$count,tot_n$fre*100,stringsAsFactors = F)
wordcloud2(nd[,1:2],size=0.3,shape = 'cardioid')

#####the results of the analysis

goodpartten=10000346,10000410,10000683,10000127 sale=96.14

el=10000051,10000626,10000625 sa=35.54

{10000951}          => {80000266}
