
strClean <- function(str){
  s=gsub('[\n|" "]','',str)
  # s=gsub("\\[",'{',s,perl = T)
  # s=gsub("\\]",'}',s,perl = T)
  s=gsub('\'',"\"",s)
}
repstr<-function(str,rep){
  sp=strsplit(str,rep)
  name.rex <- "([^0-9\\{\\[].*[^}\\]])"
  parsed <- regexpr(name.rex, sp[[1]], perl = TRUE)
  return(list(potion=parsed,original=sp[[1]],rep=rep))
}
adds <-function(i){
  if(!grepl('\"',i,perl = T)) i=paste0('\"',i,'\"')
  else i
}

parse<- function(regstr, result,string,qu=":") {
  tmp=""
  for(i in seq_along(regstr)){
    if(result[i] == -1){tmp=regstr[i] ;next;}
    st <- attr(result, "capture.start")[i, ]
    subs=substring(regstr[i], st, st + attr(result, "capture.length")[i, ] - 1)
    if(grepl(',',subs,perl = T)){
      subreg=repstr(subs,',')
      old=parse(subreg$original, subreg$potion,subs,subreg$rep)
    }
    else{
      old= adds(subs)
    }
    str= gsubfn(subs,old,regstr[i])
    if(i>1) tmp=paste0(tmp,qu,str) else tmp=str
    ## print(str)
  }
  return(tmp)
}


OpChgEchat<-function(opti0n){
  library(gsubfn)
  clean=strClean(option)
  sp=repstr(clean,':')
  z=parse(sp$original,sp$potion,clean,sp$rep)
  echart(fromJSON(z,simplifyVector = F)) 
}
