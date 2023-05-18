resonances_Y <- read.csv(dir('/tmp/', full.names=T, pattern="^resonances_y"))


peak_power_Y<-max(resonances_Y$psd_xyz)


peak_freq_Y<-resonances_Y$freq[resonances_Y$psd_xyz==peak_power_Y]


half_power_Y<-peak_power_Y/sqrt(2)


library(rootSolve)


roots_Y<-uniroot.all(approxfun(resonances_Y$freq,resonances_Y$psd_xyz-half_power_Y),c(1,135))


Damping_Ratio_Y=(roots_Y[2]-roots_Y[1])/(2*peak_freq_Y)


print(trunc(Damping_Ratio_Y*10^4)/10^4)
