'use strict'

theme = undefined
source = undefined
run = undefined
error = undefined
bare = undefined
header = undefined
editor = undefined
destination = undefined
change = undefined
changeTheme = undefined
changeSource = undefined
evalCode = undefined

theme = document.getElementById 'themes'
source = document.getElementById 'source'
run = document.getElementById 'run'
error = document.getElementById 'error'
bare = document.getElementById 'bare'
header = document.getElementById 'header'

editor = ace.edit 'editor'
editor.setTheme 'ace/theme/monokai'
editor.getSession().setMode "ace/mode/coffee"
destination = ace.edit 'destination'
destination.setReadOnly true
destination.setTheme 'ace/theme/monokai'
destination.getSession().setMode 'ace/mode/javascript'

change = ->
  compiledSource = undefined
  return false  if editor.session.getValue() is ""
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
  editor.setTheme "bower_components/ace/lib/ace/theme/" + theme
  destination.setTheme "bower_components/ace/lib/ace/theme/" + theme
  editor.focus()
  editor.navigateFileEnd()
  return

changeSource = (e) ->
  source = e.srcElement.value
  scriptEl = document.createElement("script")
  document.getElementsByTagName("script")[0].remove()
  scriptEl.src = "assets/js/" + source
  document.head.appendChild scriptEl
  scriptEl.onload = change
  return

evalCode = (e) ->
  # jshint evil:true
  do e.preventDefault
  return unless chrome.devtools?

  chrome.devtools.inspectedWindow.eval destination.session.getValue(), (result, isException) ->
    if (typeof isException isnt "undefined" and isException isnt null) and ((if typeof isException isnt "undefined" and isException isnt null then isException.isException else undefined)) is true
      error.classList.remove "hide"
      error.innerHTML = isException.value
      str = JSON.stringify(isException.value)
      chrome.devtools.inspectedWindow.eval "console.error(" + str + ");"
    return

  return

theme.onchange = changeTheme
source.onchange = changeSource
bare.onchange = change
header.onchange = change
editor.on "change", change

run.addEventListener "click", evalCode
