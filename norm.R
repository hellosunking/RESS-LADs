#
# Author: Kun Sun @SZBL (sunkun@szbl.ac.cn)
# Date  :
#
# R script for 
#

options( stringsAsFactors=F );

argv = commandArgs(T);
if( length(argv) != 3 ) {
	print( 'usage: R --slave --args <LaminAC.info> <LaminB1.info> <cnt> < norm.R' );
	q();
}

infoAC = read.table( argv[1], row.names=1 )
infoB1 = read.table( argv[2], row.names=1 )
cnt    = read.table( argv[3], row.names=1, head=T )

## normalize using overall reads
ctrAC=c()
aphAC=c()
for( sid in rownames(infoAC) ) {
	cnt[, sid] = cnt[, sid] / infoAC[sid, 4]
	if( infoAC[sid, 1] == "CTR" ){
		ctrAC=c(ctrAC, sid)
	} else if( infoAC[sid, 1] == "APH" ) {
		aphAC=c(aphAC, sid)
	} else {
		print("ERROR: unknown category.")
		q()
	}
}

ctrB1=c()
aphB1=c()
for( sid in rownames(infoB1) ) {
	cnt[, sid] = cnt[, sid] / infoB1[sid, 4]
	if( infoB1[sid, 1] == "CTR" ){
		ctrB1=c(ctrB1, sid)
	} else if( infoB1[sid, 1] == "APH" ) {
		aphB1=c(aphB1, sid)
	} else {
		print("ERROR: unknown category.")
		q()
	}
}

pAC=c()
pB1=c()

for(i in 1:nrow(cnt)) {
	here=t.test(cnt[i,ctrAC], cnt[i,aphAC])
	pAC=c(pAC, here$p.value)
	here=t.test(cnt[i,ctrB1], cnt[i,aphB1])
	pB1=c(pB1, here$p.value)
}

fdrAC=p.adjust(pAC, method="fdr")
fdrB1=p.adjust(pB1, method="fdr")

avg_ctrAC = rowSums(cnt[, ctrAC])
avg_aphAC = rowSums(cnt[, aphAC])
fcAC = avg_aphAC / avg_ctrAC
log2fcAC=log2(fcAC)

avg_ctrB1 = rowSums(cnt[, ctrB1])
avg_aphB1 = rowSums(cnt[, aphB1])
fcB1 = avg_aphB1 / avg_ctrB1
log2fcB1=log2(fcB1)

rpm=data.frame(cnt, pAC, fdrAC, log2fcAC, pB1, fdrB1, log2fcB1)
#rpm=rpm[, c("avg_ctr", "avg_aph", "pvalue", "fdr", "log2fc")]
write.table(rpm, file="Lamin.RPM", quote=F, sep="\t")

