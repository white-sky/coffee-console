'use strict'

theme = document.getElementById 'themes'
source = document.getElementById 'source'
run = document.getElementById 'run'
error = document.getElementById 'error'
bare = document.getElementById 'bare'
header = document.getElementById 'header'

editor = ace.edit 'editor'
editor.setTheme 'ace/theme/monokai'
editor.getSession().setMode 'ace/mode/coffee'

destination = ace.edit 'destination'
destination.setReadOnly true
destination.setTheme 'ace/theme/monokai'
destination.getSession().setMode 'ace/mode/javascript'

change = ->
  return false  if editor.session.getValue() is ''
  try
    compiledSource = CoffeeScript.compile(editor.session.getValue(),
      header: header.checked
      bare: bare.checked
    )
    destination.session.setValue compiledSource
    error.classList.add "hide"
  catch e
    error.classList.remove "hide"
    error.innerHTML = e.message
  return

changeTheme = (e) ->
  theme = e.srcElement.value
  editor.setTheme "ace/theme/#{theme}"
  destination.setTheme "ace/theme/#{theme}"
  do editor.focus
  do editor.navigateFileEnd
  return

evalCode = (e) ->
  do e.preventDefault
  inspectedWindow = chrome.devtools.inspectedWindow
  return unless inspectedWindow?

  inspectedWindow.eval destination.session.getValue(), (result, isException) ->

    return unless isException?.isException?

    error.classList.remove "hide"
    error.innerHTML = isException.value
    str = JSON.stringify(isException.value)
    inspectedWindow.eval "console.error(#{str});"

  return

theme.onchange = changeTheme
bare.onchange = change
header.onchange = change
editor.on 'change', change

run.addEventListener "click", evalCode

editor.session.setValue '''
sayHi = -> console.log 'hi'

do sayHi
'''
