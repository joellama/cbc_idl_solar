pro dr_cbc_star, obj_nm=obj_nm, obsnm=obsnm, date=date, templ_tag=templ_tag, $
                 templ_nm=templ_nm, vdtag=vdtag, demo=demo, div_telluric=div_telluric,$
                 ddir=ddir, excalibur=excalibur, mincts=mincts, root_dir=root_dir



root_path=root_dir                   ; the code lives here
obs_dir = root_path + 'fitspec/'
templ_dir = root_path + 'vels/cbc_idl/templates/'

if strlowcase(obj_nm) eq 'sun' then path_append = '_solar' else path_append = ''

if keyword_set(obsnm) then begin
    full_path= obs_dir + '20'+ strmid(obsnm[0], 0, 2)+'/'+strmid(obsnm[0],0,6) + path_append
    ff = file_search(full_path+obj_nm+'_'+obsnm+'.fits', count=nobs)
endif else if keyword_set(date) then begin
    ff = []
    nobs = 0 
    foreach d, date, idx do begin 
        full_path= obs_dir + '20'+ strmid(d[0], 0, 2)+'/'+strmid(d[0],0,6) + path_append
        _ff = file_search(full_path+obj_nm+'*.fits', count=_nobs)
        nobs += _nobs
        ff = [ff, _ff]
    endforeach
endif else if keyword_set(file_list) then begin
    ff = file_list 
    nobs = (size(ff))[1]

endif else begin
    full_path = obs_dir+'*/*' + path_append+'/' + obj_nm+'_??????.????.fits'
    ff = file_search(full_path, count=nobs)
endelse
; JL edits - remove files that don't have excalibur wavelengths 

print, "Found " + string(nobs, '(I0)') + " files, now checking if they have exalibur wavelengths"

; Python.Run, $
;     "def check_bary_excalibur(fh):\n" + $
;     "    from astropy.io.fits import getheader\n" + $
;     "    if 'bary_excalibur' in getheader(fh, 1).values():\n" + $
;     "        return 1\n" + $
;     "    else:\n" + $
;     "        return 0\n"
; Python.Run, $
;     "def batch_check_bary_excalibur(file_list):\n" + $
;     "    from pqdm.threads import pqdm\n" + $
;     "    res = pqdm(file_list, check_bary_excalibur, n_jobs=32)\n" + $
;     "    return res"
;  x = Python.batch_check_bary_excalibur(ff)


; if keyword_set(excalibur) then begin
;     gd_ff = []
;     foreach fh, ff, i do begin
;         print, string(i, format='(I0)') + " / " + string((size(ff))[1], format='(I0)')
;        if tag_exist(mrdfits(fh, 1, hdr, /SILENT), 'bary_excalibur') then gd_ff = [gd_ff, fh]
;     endforeach
;     ff = gd_ff
;     nobs = n_elements(ff)
; endif

 
if ~keyword_set(templ_nm) then templ_nm = obj_nm+'_templ_'+templ_tag+'.dat'  ; morphed template 
 
; print, "Checking SNR of each observation"
; sn_array = fltarr(nobs) 
; for i = 0, nobs-1 do sn_array[i] = ck_snr(file=ff[i])
; print, "Done checking SNR of each observation"

print, 'Running cbc code'
if ~keyword_set(vdtag) then vdtag=templ_tag 
for i = 0, nobs-1 do begin
    x1=strpos(ff[i],'_', /reverse_search)
    obsnm = strmid(ff[i], x1+1, 11)
    observation_dir = strmid(ff[i], 0, strpos(ff[i],'/', /reverse_search)+1) 
    cbc_file = observation_dir+'vd'+vdtag+'_'+obj_nm+'.'+obsnm+'.dat'
    cbc_found = file_search(cbc_file, count=nfound) 
    if nfound eq 1 then begin
        print, 'Found Result: ' + cbc_found + "Skipping cbc"
    endif else begin
        print, 'Running cbc: ' + obsnm
        if tag_exist(mrdfits(ff[i], 1, hdr, /SILENT), 'bary_excalibur') and $
           tag_exist(mrdfits(ff[i], 1, hdr, /SILENT), 'tellurics') then begin
            cbc_chunk_setup, obj_nm, obsnm, templ_nm, $
                        templ_tag=templ_tag, $
                        vdtag=vdtag, $
                        excalibur=excalibur, $
                        div_telluric=div_telluric,$
                        root_dir=root_dir
            cbc_main, obj_nm, obsnm, templ_nm,$
                        vdtag=vdtag, $
                        ddir=ddir, $
                        excalibur=excalibur,$
                        root_dir=root_dir
        endif else print, "Skipping " + obsnm + ": No bary_excalibur wavelengths or telluric model"         
    endelse
endfor 
cbc_vank, obj_nm, vdtag, ddir=ddir, mincts=mincts
    


 

end   ; pro
