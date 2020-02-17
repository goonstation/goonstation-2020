var/datum/testTags/test = new

/datum/tag
	var/tmp/list/attributes = list()
	var/tmp/list/classes = list()
	var/tmp/list/children = list()
	var/tmp/datum/tag/parent
	var/tmp/tagName = ""
	var/tmp/selfCloses = 0
	var/tmp/gt = ">"
	var/tmp/lt = "<"
	var/tmp/innerHtml

	New(var/_tagName as text)
		tagName = _tagName

	proc/addChildElement(var/datum/tag/child)
		children.Add(child)
		child.setParent(src)
		return src

	proc/setParent(var/datum/tag/_parent)
		parent = _parent
		return src

	proc/addClass(var/class as text)
		var/tmp/list/classlist = kText.text2list(class, " ")

		for(var/cls in classlist)
			if(!classes.Find(cls))
				classes.Add(cls)

	proc/setAttribute(var/attribute as text, var/value as text)
		attributes[attribute] = "[attribute]=\"[value]\""

	proc/toHtml()
		beforeToHtmlHook()
		var/tmp/html = "";

		html = "[lt][tagName]"

		if(classes.len)
			var/cls = kText.list2text(classes, " ")
			setAttribute("class", cls)

		if(attributes.len)
			for(var/atr in attributes)
				html += " "
				html += attributes[atr]

		if(!selfCloses)
			html += "[gt]"

			for(var/datum/tag/child in children)
				html += child.toHtml()

			if(innerHtml)
				html += "[innerHtml]"

			html += "[lt]/[tagName][gt]"
		else
			html += "/[gt]"

		return html

	proc/beforeToHtmlHook()
		return

/datum/testTags
	proc/test()
		var/datum/tag/page/html = new
		var/datum/tag/heading/h = new (1)
		var/datum/tag/paragraph/para = new
		var/datum/tag/title/title = new
		title.setText("TESTING LOL")
		html.addToBody(h)
		html.addToBody(para)
		html.addToHead(title)

		var/datum/tag/anchor/a = new
		a.setAttribute("onclick", "window.location='?src=\ref[src];foo=bar'")
		a.setText("test")
		html.addToBody(a)
		h.setText("Test Heading")
		para.setText("Test Paragraph")
		usr << browse('bootstrap/js/bootstrap.js', "display=0")
		usr << browse('bootstrap/css/bootstrap.min.css', "display=0")
		usr << browse('bootstrap/css/bootstrap-responsive.min.css', "display=0")
		usr << browse('bootstrap/img/glyphicons-halflings-white.png', "display=0")
		usr << browse('bootstrap/img/glyphicons-halflings.png', "display=0")
		var/datum/tag/div/container = new
		var/datum/tag/div/navbar = new
		container.addClass("container")

		var/datum/tag/script/scr = new
		scr.setContent({"
		$(function() {
			$.get('http://www.google.com', function(data) {alert(data)});
		});
		function out(txt) {
			alert(txt);
		}
		"})
		html.addToBody(scr)

		html.addToBody(container)
		container.addChildElement(navbar)
		navbar.addClass("navbar navbar-inverse navbar-fixed-top")

		var/datum/tag/cssinclude/bootstrap = new
		bootstrap.setHref("bootstrap.min.css")
		html.addToHead(bootstrap)

		var/datum/tag/cssinclude/bootstrapResponsive = new
		bootstrapResponsive.setHref("bootstrap-responsive.min.css")
		html.addToHead(bootstrapResponsive)

		var/datum/tag/scriptinclude/jquery = new
		jquery.setSrc("http://code.jquery.com/jquery-1.9.0.js")
		html.addToHead(jquery)

		var/datum/tag/scriptinclude/jqueryMigrate = new
		jqueryMigrate.setSrc("http://code.jquery.com/jquery-migrate-1.0.0.js")
		html.addToHead(jqueryMigrate)

		var/datum/tag/scriptinclude/bootstrapJs = new
		bootstrapJs.setSrc("bootstrap.min.js")
		html.addToBody(bootstrapJs)

		usr << browse(html.toHtml(), "window=foo")

	Topic(href, href_list)
		world << "no, here"
		/*usr << browse("foo", "window=foo")*/
		usr << output("bar", "foo.browser:out")

mob
	verb/testTags()
		test.test()

	Topic(href, href_list)
		world << "here"
		usr << browse("foo", "window=foo")
