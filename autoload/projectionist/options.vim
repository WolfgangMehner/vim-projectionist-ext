" Location:     autoload/projectionist/options.vim
" Author:       Wolfgang Mehner

let s:TDICT = type ( {} )

function! projectionist#options#activate ()
  if &l:buftype == 'help' && &l:readonly == 1
    return
  endif
  " first global, then local options
  for [ scope, cmd ] in [ ['&g:','setglobal'], ['&l:','setlocal'] ]
    " go from least specialized to most specialized and apply all
    for [ root, options ] in reverse( projectionist#query(cmd) )
      " check options
      if type ( options ) != s:TDICT | continue | endif

      for [ optspec, value ] in items( options )
        " ensure that the options are sane, get the operation
        let mlist = matchlist ( optspec, '^\(\w\+\)\([-+^=:&<]\|[-+^]=\)\?' )
        if empty ( mlist )
          continue
        endif
        let [ opt, op ] = mlist[1:2]
        try
          if op == '' || op == '=' || op == ':'
            " setl opt=value
            if eval ( scope.opt ) != value
              execute 'sandbox' 'let' scope.opt '= '.string( value )
            endif
          elseif op =~ '^[-+^]=\?'
            " setl opt+=value  ET AL.
            let op = ( op =~ '^.=' ) ? op : op.'='
            execute 'sandbox' cmd opt.op.escape( value, ' |"\' )
          elseif op == '&' || ( op == '<' && cmd == 'setlocal' )
            " setl opt&  ET AL.
            execute 'sandbox' cmd opt.op
          endif
        catch
          echohl ErrorMsg
          echomsg 'while setting option:' optspec 'loaded from' root ':'
          echomsg v:exception
          echohl None
        finally
        endtry
      endfor
    endfor
  endfor
endfunction    " ----------  end of function projectionist#options#activate  ----------
