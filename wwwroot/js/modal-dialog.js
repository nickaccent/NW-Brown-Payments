
var Modal = new Class({
	toElement: function()
	{
		return this.el;
	}
	,
	initialize: function(name,title,content){
	
	//Create Background Overlay
	 
	
	//Sets the element
	this.el=new Element('div',{'class': 'modal',id:name});
	//Create Title Bar
	this.modaltitle=new Element('div',{'class': 'modaltitle'});
	this.modaltitle.set('text',title);
	
	//Create Close Button
	this.closebutton= new Element('a',{'class': "close-modal", id:name+'x'});
	this.closebutton.set('text','X');
	
	//Combine Close into Title
	this.closebutton.inject(this.modaltitle,'bottom');
	
	//Add TitleBar to the top of the element
	this.modaltitle.inject(this.el,'top');
	
	//Create Contents
	this.modalcontent=new Element('div',{'class': 'modalcontent'});
	this.modalcontent.set('html',content);
	//Add Contents to bottom of window
	this.modalcontent.inject(this.el,'bottom');
	
	this.bg=new Element('div', {'class': 'modalbackground'});
	
	$(this).addEvent('click:relay(a.close-modal)', function(event){
		event.stop();
		event.preventDefault();
		//this.getParent().getParent().fade('out',{onComplete:function(){this.dispose();}});
		this.close();
		//$$('.modalbackground').fade('out',{onComplete:function(){this.dispose()}});
	}.bind(this));
	
	
	
	},
	changeContents: function(title,contents)
	{
		this.modaltitle.set('text',title);
		this.modalcontent.set('html',contents);
	},
	
	open: function()
	{
	
	this.bg.inject($(document.body),'top');
	this.el.inject($(document.body).getFirst('div'),'before');
	
		this.el.fade('in');
		$$('.modalbackground').show();
		$$('.modalbackground').setStyles({'width':$(document.body).getScrollSize().x,'height':$(document.body).getScrollSize().y,'opacity':0.5,'visibility':'visible','z-index':200})		
	},
	close: function(event)
	{
		if(event)
			event.stop();
	$$('.modalbackground').hide();
	this.bg.dispose();
	this.el.fade('out');
	
	
	},
	setTitle:function(title)
	{
	this.title=title;
	}
	});