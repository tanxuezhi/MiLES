######################################################
#------Regimes routines computation for MiLES--------#
#-------------P. Davini (May 2017)-------------------#
######################################################

miles.regimes.fast<-function(dataset,expid,ens,year1,year2,season,z500filename,FILESDIR,PROGDIR,nclusters=nclusters,doforce)  {

#source functions
source(paste0(PROGDIR,"/script/basis_functions.R"))

#t0
t0<-proc.time()

#region boundaries for North Atlantic 
if (nclusters!=4 | season!="DJF") {
	stop("Beta version: unsupported season and/or number of clusters")
}

#test function to smooth seasonal cycle: it does not work fine yet, keep it false
smoothing=T
xlim=c(-80,40)
ylim=c(30,87.5)

#define file where save data
savefile1=file.builder(FILESDIR,"Regimes","RegimesPattern",dataset,expid,ens,year1,year2,season)

#check if data is already there to avoid re-run
if (file.exists(savefile1)) {
        print("Actually requested weather regimes data is already there!")
	print(savefile1)
	if (doforce=="true") {
                print("Running with doforce=true... re-run!")
        } else  {
	        print("Skipping... activate doforce=true if you want to re-run it"); q()
        }
}

#setting up time domain
years=year1:year2
timeseason=season2timeseason(season)

#decide if we want to include this
#increase the number of files to load for edge-day smoothing
#if (smoothing) {
#	timeseason0=timeseason
#	if (season=="DJF") {
#		timeseason=sort(c(timeseason,11,3)) 
#	} else {
#	timeseason=sort(c(timeseason[1]-1,timeseason,timeseason[length(timeseason)]+1))
#	}
#}

#new file opening
fieldlist=ncdf.opener.universal(z500filename,namevar="zg",tmonths=timeseason,tyears=years,rotate="full")

#extract calendar and time unit from the original file
tcal=attributes(fieldlist$time)$cal
tunit=attributes(fieldlist$time)$units

#time array
etime=power.date.new(fieldlist$time)

#declare variable
Z500=fieldlist$field

print("Compute anomalies based on daily mean")
#smoothing flag and daily anomalies
if (smoothing) {
	Z500anom=daily.anom.run.mean(ics,ipsilon,Z500,etime)
} else {
	Z500anom=daily.anom.mean(ics,ipsilon,Z500,etime)
}

#compute weather regimes: new regimes2 function with minimum variance evaluation
weather_regimes=regimes2(ics,ipsilon,Z500anom,ncluster=nclusters,ntime=1000,minvar=0.8,xlim,ylim,alg="Hartigan-Wong")

# Cluster assignation: based on the position of the absolute maximum/minimum
# negative value for NAO-, maximum for the other 3 regimes
compose=weather_regimes$regimes
names=paste("Regimes",1:nclusters)
position=rbind(c(-45,65),c(-35,50),c(10,60),c(-20,60))
rownames(position)<-c("NAO-","Atlantic Ridge","Scandinavian Blocking","NAO+")

#minimum distance in degrees to assign a regime name
min_dist_in_deg=20 

#loop
for (i in 1:nclusters)  {

	#find position of max and minimum values
	MM=which(compose[,,i]==max(compose[,,i],na.rm=T),arr.ind=T)
	mm=which(compose[,,i]==min(compose[,,i],na.rm=T),arr.ind=T)

	#use maximum or minimum (use special vector to alterate distance when needed)
	if (max(compose[,,i],na.rm=T)>abs(min(compose[,,i],na.rm=T))) {
		distmatrix=rbind(c(ics[MM[1]],ipsilon[MM[2]]),position+c(0,0,0,1000))
	} else {
		distmatrix=rbind(c(ics[mm[1]],ipsilon[mm[2]]),position+c(1000,1000,1000,0))
	}

	# compute distances and names assignation
	distMM=dist(distmatrix)[1:nclusters]
	print(distMM)

	# minimum distance for correct assignation of 15 deg
	if (min(distMM)<min_dist_in_deg) {
		names[i]=rownames(position)[which.min(distMM)]

		# avoid double assignation	
		if (i>1 & any(names[i]==names[1:max(c(1,i-1))])) {
			print("Warning: double assignation of the same regime. Avoiding last assignation...")
			names[i]=paste("Regime",i)  
      		}
	}
	print(names[i])

}

t1=proc.time()-t0
print(t1)

##########################################################
#------------------------Save to NetCDF------------------#
##########################################################

#saving output to netcdf files
print("saving NetCDF climatologies...")

# dimensions definition
fulltime=as.numeric(etime$data)-as.numeric(etime$data)[1]
TIME=paste(tunit," since ",year1,"-",timeseason[1],"-01 00:00:00",sep="")
LEVEL=50000
x <- ncdim_def( "lon", "degrees_east", ics, longname="longitude")
y <- ncdim_def( "lat", "degrees_north", ipsilon, longname="latitude")
t <- ncdim_def( "time", TIME, fulltime,calendar=tcal, longname="time", unlim=T)

# extra dimensions definition
cl <- ncdim_def( "lev", "cluster index", 1:nclusters, longname="pressure")

#var definition
unit="m"; longvar="Weather Regimes Pattern"
pattern_ncdf=ncvar_def("Regimes",unit,list(x,y,cl),-999,longname=longvar,prec="single",compression=1)

unit=paste0("0-",nclusters); longvar="Weather Regimes Cluster Index"
cluster_ncdf=ncvar_def("Indices",unit,list(t),-999,longname=longvar,prec="single",compression=1)

unit="%"; longvar="Weather Regimes Frequencies"
frequencies_ncdf=ncvar_def("Frequencies",unit,list(cl),-999,longname=longvar,prec="single",compression=1)

#testnames
dimnchar=ncdim_def("nchar","", 1:max(nchar(names)), create_dimvar=FALSE )
names_ncdf=ncvar_def("Names","", list(dimnchar, cl), prec="char" )

#saving file
ncfile1 <- nc_create(savefile1,list(pattern_ncdf,cluster_ncdf,frequencies_ncdf,names_ncdf))
ncvar_put(ncfile1, "Regimes", weather_regimes$regimes, start = c(1, 1, 1),  count = c(-1,-1,-1))
ncvar_put(ncfile1, "Indices", weather_regimes$cluster, start = c(1),  count = c(-1))
ncvar_put(ncfile1, "Frequencies", weather_regimes$frequencies, start = c(1),  count = c(-1))
ncvar_put(ncfile1, "Names", names) 
nc_close(ncfile1)

}

#blank line
cat("\n\n\n")

# REAL EXECUTION OF THE SCRIPT 
# read command line
args <- commandArgs(TRUE)

# number of required arguments from command line
name_args=c("dataset","expid","ens","year1","year2","season","z500filename","FILESDIR","PROGDIR","nclusters","doforce")
req_args=length(name_args)

# print error message if uncorrect number of command 
if (length(args)!=0) {
    if (length(args)!=req_args) {
        print(paste("Not enough or too many arguments received: please specify the following",req_args,"arguments:"))
        print(name_args)
    } else {
	# when the number of arguments is ok run the function()
        for (k in 1:req_args) {assign(name_args[k],args[k])}
        miles.regimes.fast(dataset,expid,ens,year1,year2,season,z500filename,FILESDIR,PROGDIR,nclusters,doforce)
    }
}


