require '../css/style.styl'
body = require 'jade!../../views/body.jade'

PAGES =
	contactme: require 'jade!../../views/contactme.jade'
	experience: require 'jade!../../views/experience.jade'
	mywork: require 'jade!../../views/mywork.jade'
	index: require 'jade!../../views/index.jade'
	whoiam: require 'jade!../../views/whoiam.jade'

KEYCODES =
	'37': 'left'
	'38': 'up'
	'39': 'right'
	'40': 'down'

class Player
	$el: $('<div class="player"></div>')
	width: 10
	constructor: (options={}) ->
		{@name = 'Me', @id='me', @x=null, @y=null} = options
		self = @
		$play = $ '#play-area'
		pad = @width/2+1
		if ! options.x or ! options.y
			options.x = _.random pad, $play.width()-pad
			options.y = _.random pad, $play.height()-pad-100
		_.each options, (v, k) -> self[k] = v
		@$el
			.appendTo $play
			.css { left:@x, top:@y }
		@talk 'This is you. Press the ARROW KEYS to move around. Type a message below to talk.'
	move: (direction, px=10) ->
		@$el.popup 'hide'
		pad = @width/2+1
		$play = $ '#play-area'
		css = {}
		switch direction
			when 'up' then newY = @y - px
			when 'down' then newY = @y + px
			when 'left' then newX = @x - px
			when 'right' then newX = @x + px
		validX = pad < newX < $play.width()-pad
		validY = pad < newY < $play.height()-pad-100
		if validX then css.left = @x = newX
		if validY then css.top = @y = newY
		@$el.animate css, queue:false
	talk: (message) ->
		self = @
		@$el.popup 'hide'
		if @timer then clearTimeout @timer
		@$el
			.popup
				offset: -15
				content: message
			.popup 'show'
		Stats.update 'messagesSent', 1
		@timer = _.delay (-> self.$el.popup 'hide'), 5000

Game =
	mainPlayer: null
	players: []
	init: ->
		# TODO - grab other players and draw them here
		@loadPlayer()
	loadPlayer: (player) ->
		if ! player # new player
			@mainPlayer = new Player()

Site =
	init: ->
		$('#page-body').html body()
		@loadPage if _.isEmpty(location.hash) then null else location.hash.substr(1)
		$('body')
			.unbind()
			.on 'click', '[data-href]', ->
				Site.loadPage $(this).attr 'data-href'
			.on 'click', '#page-nav .item:not(.active)', ->
				Site.loadPage $(this).attr 'data-page'
			# up, down, left, right arrows move player
			.on 'keyup', (e) ->
				if 37 <= e.keyCode <= 40
					Game.mainPlayer.move KEYCODES[e.keyCode]
					e.preventDefault()
				else # focus on the chat bar
					$('#chat-bar input').trigger 'focus'
				Stats.update 'keysPressed', 1
			# hitting enter in chat bar will show message
			.on 'keyup', '#chat-bar input', (e) ->
				e.stopPropagation()
				$input = $ this
				Stats.update 'keysPressed', 1
				if 37 <= e.keyCode <= 40
					Game.mainPlayer.move KEYCODES[e.keyCode]
					e.preventDefault()
				else if e.keyCode == 13 # enter key
					Game.mainPlayer.talk $input.val()
					$input.val ''
				else if e.keyCode == 27
					$input.trigger 'blur'
			.on 'click', '#chat-bar button', (e) ->
				$input = $('#chat-bar input')
				Game.mainPlayer.talk $input.val()
				$input.val ''
	loadPage: (page='index') ->
		if PAGES[page]
			location.hash = page
			Stats.update 'linksActivated', 1
			$('#page-nav .active').removeClass 'active'
			$('#page-nav .item[data-page="'+page+'"]').addClass 'active'
			$('#page-content')
				.attr 'data-page', page
				.html PAGES[page]()
				.hide()
				.fadeIn()

Stats =
	$el: $('#stats')
	init: ->
		setInterval (->
			Stats.timeOnSite += 1
			min = Math.floor Stats.timeOnSite/60
			sec = Stats.timeOnSite%60
			if sec < 10 then sec = '0'+sec
			$('.statistic[data-id="timeOnSite"] .value').text min+':'+sec
			), 1000
	timeOnSite: 0
	keysPressed: 0
	linksActivated: 0
	messagesSent: 0
	users: 1
	update: _.throttle (key, increment) ->
		if ! _.isUndefined Stats[key]
			Stats[key] += increment
			$('.statistic[data-id="'+key+'"] .value').text Stats[key]

Site.init()
Game.init()
Stats.init()

if module.hot
	module.hot.accept()
