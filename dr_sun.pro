PRO dr_sun

    obj_nm = 'Sun'
    tag_in = 'amx'
    tag_out=tag_in+'60'
    root_dir = '/Volumes/solar_extracted_040/'
    obs_dir = root_dir + 'fitspec/'
    vels_dir = root_dir + 'vels/cbc_idl/'
    templates_dir = vels_dir + 'templates/'
    excalibur = 1 
    ngau = 60

    div_telluric = 0
    
    restore, 'cat_drive.dat'
    
    ffound1 = file_search(vels_dir+'/templates/'+obj_nm+'_templ_'+tag_in+'.dat', count=c1)
    ffound2 = file_search(vels_dir+'/templates/'+obj_nm+'_templ_'+tag_out+'.dat', count=c2)
    if (c1 eq 0) and c2 eq 0 then begin    ; no morphed template - make one   
        templ_obnm = '201022.' + ['1120', '1121', '1122', '1123']
        date = strmid(templ_obnm[0], 0, 6)
        coadd_templ_nm = obj_nm+'_coadd_'+date+'.dat'
        t_obj_nm = templ_obnm[-1]        
        rayclean, templ_obnm, obstack, star, $
                  data_dir=obs_dir, $
                  starnm=obj_nm,  $
                  outfname=templates_dir + coadd_templ_nm, $
                 excalibur=excalibur, $
                 /auto

        cbc_star_templ, obj_nm, t_obj_nm, $
                tag=tag_in, $
                coadd_obnm=coadd_obnm, $
                coadd_templ_nm=templates_dir + coadd_templ_nm, $
                excalibur=excalibur, $
                root_dir=root_dir     

      cbc_templ_morph, obj_nm, t_obj_nm, $
                tag_in=tag_in, $
                tag_out=tag_out, $
                ngau=ngau, $
                thresh=thresh, $
                /coadd, $
                excalibur=excalibur, $
                root_dir=root_dir, $
                fix_rotbro=0, $
                fix_rv=0,  $
                demo=0

    endif

   if ~keyword_set(mincts) then mincts=10000.
   dr_cbc_star, obj_nm=obj_nm, $
                templ_tag=tag_out, $
                vdtag=tag_in, $
                excalibur=excalibur, $
                demo=0, $
                div_telluric=div_telluric, $
                mincts=mincts, $
                root_dir=root_dir   
   
END