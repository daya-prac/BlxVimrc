""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Require Module for VimScript
"
"   Auth:       Brambles
"   Email:      qjnight@gmail.com
"   Respone:    https://github.com/bramblex/BlxVimrc.git
"   Date:       Wed Jun 17 2015
"
"=================== Configure ==============================
let s:conf = {}
let s:conf.module_subfix = '.vimrc'
let s:conf.package_mainfile = 'base' . s:conf.module_subfix

"================= Module Context  ==========================
let s:context = {}
let s:context.__include__ = []
let s:context.__content__ = []

function s:context.push(path)
    let c = {}
    let c.path = a:path
    let c.dirname = fnamemodify(a:path, ':h')
    let c.cache = {}
    call add(self.__content__, c)
    let g:Module = self.__content__[-1]
endfunction

function s:context.pop()
    call remove(self.__content__, -1)
    let g:Module = self.__content__[-1]
endfunction

if !exists('g:require_base_module')
    let g:require_base_module = expand('<sfile>:p')
end
call s:context.push(g:require_base_module)

"================= Load & Excute & Stroe module ============
let s:Modules = {}
function s:LoadModule(module_path, force)
    if has_key(s:Modules, a:module_path) && !a:force 
        return s:Modules[a:module_path]
    endif

    let s:Modules[a:module_path] = {}
    let l:module = s:Modules[a:module_path]
    
    "===================
    call s:context.push(a:module_path)

    exec 'source ' . a:module_path
    if has_key(g:Module, 'Define')
        let l:module.Define = g:Module.Define
        call l:module.Define()
        if l:module.Define == g:Module.Define
            call remove(l:module, 'Define')
        endif
    endif

    call s:context.pop()
    "===================

    return l:module
endfunction

"======================= Cache =======================
function s:Cache(key, module)
    g:Module.cache[a:key] == a:module
endfunction

function s:SearchCache(key)
    return g:Module.cache[a:key]
endfunction

"=============== Path =====================================
let s:utils = {}
function s:utils.trip(str)
    return  substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

let s:path = {}
let s:path.separator = '/'
function s:path.join(...)
    return simplify(join(a:000, self.separator))
endfunction

function s:path.file_name(path)
    let path = s:utils.trip(a:path)
    if path[-1] == self.separator
        let path = path[0: -2]
    endif
    return join(split(fnamemodify(path, ':t'), '.')[0: -2], '')
endfunction

function s:path.can_load(path)
    if filereadable(a:path)

        if isdirectory(a:path)
            let mainfile = self.join(a:path, s:conf.package_mainfile)
            if filereadable(mainfile) && !isdirectory(mainfile)
                return 1
            endif
        elseif
            let name = self.file_name(a:path)
            if name =~ '^.+\' . s:conf.module_subfix . '$' 
                return 1
            end
        endif

    endif
    "'^.+\.vimrc$' 
    return 0
endfunction

"================ Require Interface ========================

function Require(module_name)
    let module_path = s:path.join(g:Module.dirname, a:module_name)

    if isdirectory(module_path)
        let package_mainfile = s:path.join(module_path, s:conf.package_mainfile)
        if filereadable(package_mainfile)
            return s:LoadModule(package_mainfile, 0)
        endif
    endif

    let module_file_path = module_path . s:conf.module_subfix
    if filereadable(module_file_path)
        return s:LoadModule(module_file_path, 0)
    endif

    echoerr 'BLXE002: Can not find module or package: ' . a:module_name
                \ . ' in ' . g:Module.path
endfunction

" Vim
" vim: set filetype=vim
"
" Emacs
" -*- mode: vim; -*-
