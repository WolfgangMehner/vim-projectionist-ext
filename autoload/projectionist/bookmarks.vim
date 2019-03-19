" Location:     autoload/projectionist/bookmarks.vim
" Author:       Wolfgang Mehner

let s:TDICT = type ( {} )

if ! exists ( 'g:PROJECTIONIST_BOOKMARKS' )
  let g:PROJECTIONIST_BOOKMARKS = {}
endif

function! projectionist#bookmarks#activate ()
  for [ root, bookmark ] in projectionist#query('bookmark')
    " check properties
    if type ( bookmark ) != type ( '' )
      break
    endif
    let g:PROJECTIONIST_BOOKMARKS[bookmark] = root
    break
  endfor
endfunction    " ----------  end of function projectionist#bookmarks#activate  ----------

function! s:GetBookmarkList ( ArgLead, CmdLine, CursorPos )
	return sort( filter( keys( g:PROJECTIONIST_BOOKMARKS ), 'v:val =~ "\\V\\<'.escape(a:ArgLead,'\').'\\w\\*"' ) )
endfunction    " ----------  end of function s:GetBookmarkList  ----------

function! s:OpenProject ( name, mods )
  if ! has_key ( g:PROJECTIONIST_BOOKMARKS, a:name )
    echohl WarningMsg
    echo 'no bookmark "'.a:name.'"'
    echohl None
    return
  endif
  if -1 == match ( a:mods, '\<\(aboveleft\|belowright\|botright\|leftabove\|rightbelow\|tab\|topleft\|vertical\)\>' )
    exec a:mods 'edit' fnameescape ( g:PROJECTIONIST_BOOKMARKS[a:name] )
  else
    exec a:mods 'split' fnameescape ( g:PROJECTIONIST_BOOKMARKS[a:name] )
  endif
  return
endfunction    " ----------  end of function s:OpenProject  ----------

function! s:RemoveBookmark ( name )
  if ! has_key ( g:PROJECTIONIST_BOOKMARKS, a:name )
    echohl WarningMsg
    echo 'no bookmark "'.a:name.'"'
    echohl None
    return
  endif
  call remove ( g:PROJECTIONIST_BOOKMARKS, a:name )
  echo 'bookmark "'.a:name.'" removed'
  return
endfunction    " ----------  end of function s:RemoveBookmark  ----------

function! s:ListBookmark ()
  let ll = keys ( g:PROJECTIONIST_BOOKMARKS )
  call sort ( ll )

  let m = 1
  for k in ll
    let m = max ( [ m, len( k ) ] )
  endfor
  let fmt = '%-'.m.'s : %s'

  for k in ll
    echo printf ( fmt, k, g:PROJECTIONIST_BOOKMARKS[k] )
  endfor
endfunction    " ----------  end of function s:ListBookmark  ----------

command! -nargs=* -complete=customlist,<SID>GetBookmarkList   ProjectBookmark     call <SID>OpenProject(<q-args>,'<mods>')
command! -nargs=* -complete=customlist,<SID>GetBookmarkList   ProjectBookmarkRm   call <SID>RemoveBookmark(<q-args>)
command! -nargs=0                                             ProjectBookmarkLs   call <SID>ListBookmark()
