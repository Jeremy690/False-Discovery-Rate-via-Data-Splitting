rm(list = ls())
#### Data splitting for Gaussian mean problem
np=800; s0=trunc(np*.2); nob=1000; nrep=400
mu=c(rnorm(s0)*0.5,rep(0,np-s0))
xob=matrix(rnorm(np*nob),ncol=np)+outer(rep(1,nob),mu)

#### Get the p-values
tst=colMeans(xob)*sqrt(nob)
pval=pnorm(-abs(tst))*2
#### Get mirror stat and inclusion rate for 400 independent runs
nsp=400; fdrs=rep(0,nsp)%o%rep(1,2)
inclurate=rep(0,nsp)%o%rep(0,np)
for(j in 1:nsp){
  #xob=matrix(rnorm(np*nob),ncol=np)+outer(rep(1,nob),mu)
  s1=sample(c(1:nob), nob/2); s2=setdiff(c(1:nob),s1)
  xs1=colMeans(xob[s1,]); xs2=colMeans(xob[s2,])
  mstat=abs(xs1+xs2)-abs(xs1-xs2)
  sm=sort(mstat); t1=sm[1]
  for(i in 2:np){
    r1=length((which(mstat<t1)))/length(which(mstat>abs(t1)))
    if(r1<0.1){t1=sm[i]}else{
      cut1=abs(t1); break
    }
  }
  sel2=which(mstat>cut1); fs2=sel2[sel2>s0]
  fdrs[j,]=c(length(fs2),length(sel2))
  inclurate[j,sel2]=inclurate[j,sel2]+1/length(sel2)
}
index <- intersect(which(log(pval)>(-10)), which(log(pval)<(-2)))
par(mar = c(2.5, 2.5, 5.1, 2.5))
plot(pval[index],colMeans(inclurate)[index], pch="+", col="orange", xlab = "", 
     ylab = "", cex.lab = 1.4, xaxt = 'n', yaxt = 'n')
axis(side = 2, tck = -0.01, padj = 1.4)
grid(col = "darkgrey")
par(new = T)
plot(pval[index], mstat[index], pch=20, col="grey", axes=F, xlab=NA, ylab=NA, cex.lab = 1.5, cex.axis = 1.5)
axis(side = 4, tck = -0.01, padj = -1.4)
axis(side = 1, tck = -0.01, padj = -1.4)
mtext(side = 4, line = 1.4, 'Mirror statistic', cex = 1.5, cex.axis = 2)
mtext(side = 1, line = 1.4, 'p-value', cex = 1.5, cex.axis = 2)
mtext(side = 2, line = 1.4, 'Inclusion rate', cex = 1.5, cex.axis = 2)
box(lwd = 0.01)

#### Get inclusion rate for 10000 independent runs
nsp=10000; fdrs=rep(0,nsp)%o%rep(1,2)
inclurate=rep(0,nsp)%o%rep(0,np)
for(j in 1:nsp){
  #xob=matrix(rnorm(np*nob),ncol=np)+outer(rep(1,nob),mu)
  s1=sample(c(1:nob), nob/2); s2=setdiff(c(1:nob),s1)
  xs1=colMeans(xob[s1,]); xs2=colMeans(xob[s2,])
  mstat=abs(xs1+xs2)-abs(xs1-xs2)
  sm=sort(mstat); t1=sm[1]
  for(i in 2:np){
    r1=length((which(mstat<t1)))/length(which(mstat>abs(t1)))
    if(r1<0.1){t1=sm[i]}else{
      cut1=abs(t1); break
    }
  }
  sel2=which(mstat>cut1); fs2=sel2[sel2>s0]
  fdrs[j,]=c(length(fs2),length(sel2))
  inclurate[j,sel2]=inclurate[j,sel2]+1/length(sel2)
}
par(new = T)
plot(pval[index],colMeans(inclurate)[index], pch="*", col="dodgerblue", xlab = NA, axes=F,
     ylab = NA, cex.lab = 1.5, cex.axis = 1.5)
legend(0.07, 0.006, pch = c("*", NA), legend = c("",""), bty ='n', col = "dodgerblue")
legend(0.066, 0.006, legend = c("/", NA), bty ='n', col = "black")
legend(0.074, 0.00635, pch = c(NA, "+"), legend = c("", NA), bty ='n', col = "orange")
legend(0.072, 0.0058, pch = c(NA, 20), legend = c("",""), bty ='n', col = "grey")
legend(0.072, 0.0061, legend = c("Inclusion rate", NA), bty='n', pt.cex = 2, cex = 1.4)
legend(0.072, 0.0061, legend = c("", "Mirror statistic"), bty='n', pt.cex = 2, cex = 1.4)