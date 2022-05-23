PRO read_pspec, file, f, p

; Read a 1d function from a free-format 2-column file

  x=FltArr(10000000)
  y=FltArr(10000000)

  openr,lun,file,/get_lun

  i=0L & valid = 0
  WHILE valid EQ 0 DO BEGIN
    ON_IOERROR, end_of_file
    ReadF, lun, xx,yy,y2,zz
    x(i)=xx &  y(i)=yy
    i = i + 1L
  ENDWHILE

  end_of_file:
  Close,lun
  Free_lun, lun

  f=x(0:i-1) & p=y(0:i-1)

END

PRO pspec_roy, t, l, f, p, fmax, ofac
                                ; use roy's pspec routine to
                                ; get pspec and window fn
                                ; fmax : max f in pspec
                                ; ofac ; resolution (pts per peak)

                                ; generate an input data file
  writexy,'roy.dat',t,l

                                ; generate the control file for pspec
  openw,lroy,"roy.input",/get_lun
  printf,lroy,"roy.dat"
  printf,lroy,fmax
  printf,lroy,ofac
  close,lroy
  free_lun,lroy
  
                                ; compute the pspec
  spawn, './pspec < roy.input'
  spawn, 'mv pspec.out roy.out'
  spawn, 'mv pspec.peaks roy.peaks'
  spawn, 'sort -r -k2 -n roy.peaks | grep -e "  ......E-03" > roy.peaks.sorted'
  spawn, 'sort -r -k2 -n roy.peaks | grep -e "  ......E-04" >> roy.peaks.sorted'
  spawn, 'sort -r -k2 -n roy.peaks | grep -e "  ......E-05" >> roy.peaks.sorted'
  
                                ; read pspec 
  read_pspec,'roy.out',f,p

END


PRO lk2_qlook,star,fmax
  
  cols=getcolor(/load)

  files=file_search('lk2/'+star+'*.csv')
  ns=n_elements(files)
  !p.multi=[0,1,ns+1,0,0]
  !x.style=1

  FOR n = 0,ns-1 DO BEGIN
     print,'reading ',files(n)
     tess=read_csv(files(n),n_table_header=1)
     IF n EQ 0 THEN BEGIN
        lc=tess.field02-mean(tess.field02)
        t=tess.field01
        plot,t,lc,psym=3,xrange=mean(t)+[-15,15]
        tt = t
        ll = lc
     ENDIF ELSE BEGIN
        lc=tess.field02-mean(tess.field02)
        t=tess.field01
        plot,t,lc,psym=3,xrange=mean(t)+[-15,15]
        tt = [tt,t]
        ll = [ll,lc]
     ENDELSE
  ENDFOR

                                ; make FT more intelligent
                                ; FPAR  - fltarr(3), vector controlling output frequency grid
                                ; ENTER 0 TO SELECT DEFAULT VALUES
                                ; fpar(0) -> frequency increment for the FT  [default: 1/T]
                                ; fpar(1) -> max. frequency in the FT        [default: 1/min(dt)]
                                ; fpar(2) -> points per beam
                                ; [default: 4]
  df = max([ 1./(tt(n_elements(tt)-1)-tt(0)), 0.001])  
  fpar = [ df, fmax, 0. ]
  print,' fpar = ',fpar
  print,' ndata= ',n_elements(tt)
  print,' nf   = ',fmax/df

  pspec_roy, tt,ll, f,p, fmax, 10

  plot,f,sqrt(p^2),xrange=[0,fmax]
  nf = n_elements(p)-1
  ;s = qsmooth(f,sqrt(p^2),fmax/5.)
  ;oplot,f,4*s,color=cols.red

  val=where(f LT fmax)
  pmax=max(sqrt(p(val)^2),k)
  print,'pmax at: ',f(k),' c/d, ',1./f(k),' d'

  !p.multi=[0,1,ns+1,0,0]
  set_plot,'ps'
  device,file='lk2_pspecs/'+star+'.eps',/encapsulated,xsize=15,ysize=15

  pmin=0
  IF ns GT 3 THEN pmin = ns - 3
  !p.multi=[0,1,min([4,ns+1]),0,0]
  FOR n = pmin,ns-1 DO BEGIN
     tess=read_csv(files(n),n_table_header=1)
     lx=tess.field02-mean(tess.field02)
     tx=tess.field01
     plot,tx,lx,psym=3,xrange=mean(tx)+[-15,15]
  ENDFOR
  ymax = 1
  IF MAX(sqrt(p^2)) GT 1 THEN ymax = 10
  plot,f,sqrt(p^2),xrange=[0,fmax],yrange=[0,ymax]
  ;oplot,f,4*s,color=cols.red
  device,/close
  set_plot,'x'

  starx = star
  starx = StrJoin( StrSplit(starx, ' ', /Regex, /Extract, $
                            /Preserve_Null), '\ ')
  command='epstopdf lk2_pspecs/'+starx+'.eps'
  spawn,command
  spawn,'rm lk2_pspecs/*.eps'

  !p.multi=0
  
END
