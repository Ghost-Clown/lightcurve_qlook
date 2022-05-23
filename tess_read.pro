pro tess_read,file,time,flux,flux_err,pdc,pdc_err

pri = READFITS(file, hpri, EXTEN_NO=0)
tab = READFITS(file, htab, EXTEN_NO=1)

; Get header value from both PRIMARY and LIGHTCURVE extension:
ticid = SXPAR(hpri, 'TICID')
dt = SXPAR(htab, 'TIMEDEL')

; Extract specific columns from the lightcurve table (extension 1):
time = TBGET(htab, tab, 'TIME')
flux = TBGET(htab, tab, 'SAP_FLUX')
flux_err = TBGET(htab, tab, 'SAP_FLUX_ERR')
pdc = TBGET(htab, tab, 'PDCSAP_FLUX')
pdc_err = TBGET(htab, tab, 'PDCSAP_FLUX_ERR')
END


; Plot the timeseries:
; plot, time, flux, xtitle='Time (TBJD)', ytitle='Corrected flux (ppm)', title='TIC ' + strtrim(ticid,2)
