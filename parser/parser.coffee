class UI
	constructor: () ->
		@out = document.getElementById 'output'
		@loader = document.getElementById 'loader'
		# Drag/drop support.
		document.addEventListener 'dragover', (e) => e.preventDefault(); e.dataTransfer.dropEffect = 'none'
		document.addEventListener 'drop', (e) => e.preventDefault()
		@out.addEventListener 'dragover', (e) =>
			e.stopPropagation(); e.preventDefault(); e.dataTransfer.dropEffect = 'copy'
		@out.addEventListener 'drop', (e) => @importer.bind(@) e
		# File picker support.
		@loader.addEventListener 'change', (e) => @importer.bind(@) e
		@out.addEventListener 'click', (e) => @loader.click() unless @loader.value
		# Paste support.
		document.addEventListener 'paste', (e) => @convert.bind(@) e.clipboardData.getData 'Text'
		# Showing ui.
		document.getElementById('ui').style.visibility = 'visible'

	importer: (e) ->
		e.stopPropagation()
		e.preventDefault()
		feed = e.dataTransfer ? e.target
		if feed = feed.files[0]
			reader = new FileReader()
			reader.readAsText feed
			reader.onload = (e) -> @convert e.target.result

	convert: (src) ->
		listing					= new Set()
		@out.style.background	= 'transparent'
		for data from @parse src
			info = "<span class='ip'>#{data.get 'ip'}</span><span class='port'>:#{data.get 'port'}</span>
					#{data.get 'username'}<span class='delim'>:</span>#{data.get 'password'}"
			http = "http://#{encodeURIComponent data.get 'username'}:#{encodeURIComponent data.get 'password'
					}@#{data.get 'ip'}:#{data.get 'port'}"
			setTimeout ((info, http) =>
				@out.innerHTML = "<div class='info'>⟲ .:Loading entry \##{listing.size}:. ⟳</div>"
				listing.add "<div class='liner'><a href='#{http}' target='_blank'>#{info}</a></div>"
			).bind(@, info, http)
		setTimeout (() =>
			@out.innerHTML = [...listing].join ''
			@out.style.background = '#2f2f2f').bind @

	parse: (text) ->
		buffer = new Map()
		for line in text.split /\r?\n/ when cut = line.match(/^(\[92m)?\[\+]The /)?[0]
			buffer = new Map [...buffer].concat line[cut.length..].split(",").map (t) -> t.split ':'
			if buffer.has('username') and buffer.has 'password'
				yield buffer
				buffer.clear()

# == Main code ==
ui = new UI()