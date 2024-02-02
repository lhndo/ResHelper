resonances_axis <- read.csv(dir('/tmp/', full.names=T, pattern="^resonances_"))


peak_power_axis<-max(resonances_axis$psd_xyz)


peak_freq_axis<-resonances_axis$freq[resonances_axis$psd_xyz==peak_power_axis]


half_power_axis<-peak_power_axis/sqrt(2)


library(rootSolve)


roots_axis<-uniroot.all(approxfun(resonances_axis$freq,resonances_axis$psd_xyz-half_power_axis),c(1,135))


Damping_Ratio_axis=(roots_axis[2]-roots_axis[1])/(2*peak_freq_axis)


print(trunc(Damping_Ratio_axis*10^4)/10^4)
