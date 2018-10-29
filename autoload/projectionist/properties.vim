" Location:     autoload/projectionist/properties.vim
" Author:       Wolfgang Mehner

let s:TDICT = type ( {} )

if ! exists ( 'g:properties' )
  let g:properties = {}
endif

function! projectionist#properties#activate ()
  for [ root, props ] in projectionist#query('properties')
    " check properties
    if type ( props ) != s:TDICT | continue | endif

    for [ name, prop ] in items( props )
      " check this property
      if type ( prop ) != s:TDICT | continue | endif

      let new_default = 0

      " new property?
      if has_key ( g:properties, name )
        let rec_prop = g:properties[name]
      else
        let rec_prop = { "last_root" : "", "current_value" : "" }
        let g:properties[name] = rec_prop
      endif

      " new root?
      if has_key ( rec_prop, root )
        let rec_root = rec_prop[root]
        let def = get ( prop, 'default', '' )
        if rec_root.default != def
          let rec_root.default = def            " update default
          let new_default      = 1
        endif
      else
        let rec_root = { "default" : prop.default }
        let rec_prop[root] = rec_root
      endif

      " switch root?
      if rec_prop.last_root != root || ( new_default && !has_key ( rec_root, "value" ) )
        let rec_prop.last_root = root
        " get value
        if has_key ( rec_root, "value" )
          let rec_prop.current_value = rec_root.value
        else
          let rec_prop.current_value = rec_root.default
        endif
        " emit autocommand
        try
          let g:projectionist_root  = rec_prop.last_root
          let g:projectionist_prop  = name
          let g:projectionist_value = rec_prop.current_value
          silent doautocmd User ProjectionistProperty
        catch
          echohl ErrorMsg
          echomsg 'while activating property:' name 'loaded from' root ':'
          echomsg v:exception
          echohl None
        finally
          unlet! g:projectionist_root
          unlet! g:projectionist_prop
          unlet! g:projectionist_value
        endtry
      endif
    endfor
  endfor
endfunction    " ----------  end of function projectionist#properties#activate  ----------
