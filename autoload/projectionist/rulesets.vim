" Location:     autoload/projectionist/rulesets.vim
" Author:       Wolfgang Mehner

let s:TDICT = type ( {} )

function! projectionist#rulesets#detect ()
  " use every ruleset only once, never read a file with no name ...
  let used_ruleset = { "" : 1 }
  " ... and limit recursion depth for rulesets importing other rulesets
  for i in range( 1, 100 )
    let new_ruleset = 0
    for [root, rulespec] in projectionist#query('rulesets')
      " turn rulespec into a list
      if type( rulespec ) == type( '' )
        let rulelist = split( rulespec, ',' )
      elseif type( rulespec ) == type( [] )
        let rulelist = rulespec
      else
        let rulelist = []
      endif
      " import every rule in the list
      for name in rulelist
        try
          " append .json if necessary
          if name !=? '\.json$'
            let name = name.'.json'
          endif
          let name = '.projectionist/'.name
          " find file on 'runtimepath'
          let list = globpath ( &rtp, name, 1, 1 )
          let file = get( list, 0, "" )
          " check and import
          if ! get( used_ruleset, file, 0 )
            let value = projectionist#json_parse(readfile(file))
            call projectionist#append(root, value)
            let used_ruleset[file] = 1            " mark as used
            let new_ruleset = 1
          elseif file != '' && get( used_ruleset, file, 0 )
            " noop
          endif
        catch
          echohl ErrorMsg
          echomsg 'while reading ruleset:' name 'loaded from' root ':'
          echomsg v:exception
          echohl None
        endtry
      endfor
    endfor
    if new_ruleset == 0
      break
    endif
  endfor
endfunction    " ----------  end of function projectionist#rulesets#detect  ----------
