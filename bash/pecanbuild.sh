cd ~/
if [ ! -f ~/.pecan_init_indicator ]
then
    ./pecan/bash/pecan.init.sh
fi

R CMD build pecan
PECAn=`ls -v PECAn*tar.gz | tail -n 1`
R CMD INSTALL $PECAn --library='~/lib/R'