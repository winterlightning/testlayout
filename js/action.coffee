rss_feed_library = 
	'Techcrunch': 'feeds.feedburner.com/TechCrunch/'
	'AVC': 'http://feeds.feedburner.com/avc'
	'Venturebeat': 'http://venturebeat.com/feed/'

load_rss_feed = (feed)->
	feed = rss_feed_library[feed] if rss_feed_library[feed]
	condition = escape("select * from xml where url = '#{feed}'");
	url = "http://query.yahooapis.com/v1/public/yql?q=#{condition}&format=json&diagnostics=true"
	$.get url, (data)->
		save_to_local(feed, data.query.results.rss)
		build_rss_list(data.query.results.rss)

save_to_local = (feed, rss)->
	key = md5(feed)
	items = window.localStorage[key]
	if not items
		items = {}
	else
		items = JSON.parse(items)
	for node in rss.channel.item
		key = md5(node.link)
		items[key] = node
	window.localStorage[key] = JSON.stringify(items)


render_item = (item)->
	model = """
		<div onclick="load_item_content('{{id}}')" class="node-item">
			<div class="title">{{title}}</div>
			<div class="description">{{description}}</div>
		</div>
	"""
	model = model.replace("{{title}}", item.title)
	model = model.replace("{{description}}", item.description)
	model = model.replace("{{id}}", md5(item.link))

build_rss_list = (rss)->
	inner_html = ''
	for node in rss.channel.item
		inner_html += render_item(node)
	$('#item-list').html(inner_html);