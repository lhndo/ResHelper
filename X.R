resonances_X <- read.csv(dir('/tmp/', full.names=T, pattern="^resonances_x"))


peak_power_X<-max(resonances_X$psd_xyz)


peak_freq_X<-resonances_X$freq[resonances_X$psd_xyz==peak_power_X]


half_power_X<-peak_power_X/sqrt(2)


library(rootSolve)


roots_X<-uniroot.all(approxfun(resonances_X$freq,resonances_X$psd_xyz-half_power_X),c(1,135))


Damping_Ratio_X=(roots_X[2]-roots_X[1])/(2*peak_freq_X)


print(trunc(Damping_Ratio_X*10^4)/10^4)
