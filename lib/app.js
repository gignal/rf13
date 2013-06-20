var Post, Stream, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

document.gignal = {
  views: {}
};

Post = (function(_super) {
  __extends(Post, _super);

  function Post() {
    _ref = Post.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Post.prototype.idAttribute = 'stream_id';

  return Post;

})(Backbone.Model);

Stream = (function(_super) {
  __extends(Stream, _super);

  function Stream() {
    this.update = __bind(this.update, this);
    _ref1 = Stream.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  Stream.prototype.model = Post;

  Stream.prototype.calling = false;

  Stream.prototype.parameters = {
    cid: 0,
    limit: 5,
    sinceTime: 0
  };

  Stream.prototype.initialize = function() {
    this.on('add', this.inset);
    this.update();
    return this.setIntervalUpdate();
  };

  Stream.prototype.inset = function(model) {
    var view;
    switch (model.get('type')) {
      case 'text':
        view = new document.gignal.views.TextBox({
          model: model
        });
        break;
      case 'photo':
        view = new document.gignal.views.PhotoBox({
          model: model
        });
    }
    document.gignal.widget.$el.prepend(view.render().el).isotope('reloadItems').isotope({
      sortBy: 'original-order'
    });
    return document.gignal.widget.refresh();
  };

  Stream.prototype.parse = function(response) {
    return response.stream;
  };

  Stream.prototype.comparator = function(item) {
    return -item.get('saved_on');
  };

  Stream.prototype.update = function() {
    var sinceTimeCall,
      _this = this;
    if (this.calling) {
      return;
    }
    this.calling = true;
    sinceTimeCall = this.parameters.sinceTime;
    return this.fetch({
      remove: false,
      cache: true,
      timeout: 15000,
      jsonpCallback: 'callme',
      data: {
        limit: this.parameters.limit,
        sinceTime: this.parameters.sinceTime,
        cid: this.parameters.cid += 1
      },
      success: function() {
        _this.calling = false;
        _this.parameters.sinceTime = _.max(_this.pluck('saved_on'));
        if (sinceTimeCall !== _this.parameters.sinceTime) {
          return _this.parameters.cid = 0;
        }
      },
      error: function(c, response) {
        if (response.statusText === 'timeout') {
          return _this.calling = false;
        } else {

        }
      }
    });
  };

  Stream.prototype.setIntervalUpdate = function() {
    return window.setInterval(function() {
      return document.gignal.stream.update();
    }, 4800);
  };

  return Stream;

})(Backbone.Collection);

document.gignal.views.Event = (function(_super) {
  __extends(Event, _super);

  function Event() {
    this.refresh = __bind(this.refresh, this);
    _ref2 = Event.__super__.constructor.apply(this, arguments);
    return _ref2;
  }

  Event.prototype.el = '#gignal-widget';

  Event.prototype.columnWidth = 240;

  Event.prototype.isotoptions = {
    itemSelector: '.gignal-outerbox',
    layoutMode: 'masonry',
    sortAscending: true
  };

  Event.prototype.initialize = function() {
    var columnsAsInt, magic, mainWidth, radix;
    radix = 10;
    magic = 10;
    mainWidth = this.$el.innerWidth();
    columnsAsInt = parseInt(mainWidth / this.columnWidth, radix);
    this.columnWidth = this.columnWidth + (parseInt((mainWidth - (columnsAsInt * this.columnWidth)) / columnsAsInt, radix) - magic);
    return this.$el.isotope(this.isotoptions);
  };

  Event.prototype.refresh = function() {
    var _this = this;
    return this.$el.imagesLoaded(function() {
      return _this.$el.isotope(_this.isotoptions);
    });
  };

  return Event;

})(Backbone.View);

document.gignal.views.Text = (function(_super) {
  __extends(Text, _super);

  function Text() {
    this.render = __bind(this.render, this);
    _ref3 = Text.__super__.constructor.apply(this, arguments);
    return _ref3;
  }

  Text.prototype.tagName = 'p';

  Text.prototype.className = 'gignal-text';

  Text.prototype.re_links = /(\b(https?):\/\/[\-A-Z0-9+&@#\/%?=~_|!:,.;]*[\-A-Z0-9+&@#\/%=~_|])/g;

  Text.prototype.render = function() {
    var text;
    text = this.model.get('text');
    text = text.replace(this.re_links, '<a href="$1" target="_top">link</a>');
    this.$el.html(text);
    return this;
  };

  return Text;

})(Backbone.View);

document.gignal.views.TextBox = (function(_super) {
  __extends(TextBox, _super);

  function TextBox() {
    this.render = __bind(this.render, this);
    _ref4 = TextBox.__super__.constructor.apply(this, arguments);
    return _ref4;
  }

  TextBox.prototype.tagName = 'blockquote';

  TextBox.prototype.className = 'gignal-outerbox';

  TextBox.prototype.initialize = function() {
    this.text = new document.gignal.views.Text({
      model: this.model
    }).render();
    return this.footer = new document.gignal.views.Footer({
      model: this.model
    }).render();
  };

  TextBox.prototype.render = function() {
    this.$el.data('saved_on', this.model.get('saved_on'));
    this.$el.css('width', document.gignal.widget.columnWidth);
    this.$el.html(this.text.$el);
    return this;
  };

  return TextBox;

})(Backbone.View);

document.gignal.views.PhotoBox = (function(_super) {
  __extends(PhotoBox, _super);

  function PhotoBox() {
    this.render = __bind(this.render, this);
    _ref5 = PhotoBox.__super__.constructor.apply(this, arguments);
    return _ref5;
  }

  PhotoBox.prototype.tagName = 'blockquote';

  PhotoBox.prototype.className = 'gignal-outerbox gignal-imagebox';

  PhotoBox.prototype.initialize = function() {
    return this.footer = new document.gignal.views.Footer({
      model: this.model
    }).render();
  };

  PhotoBox.prototype.render = function() {
    this.$el.data('saved_on', this.model.get('saved_on'));
    this.$el.css('width', document.gignal.widget.columnWidth);
    this.$el.css('background-image', 'url(' + this.model.get('thumb_photo') + ')');
    this.$el.append(this.footer.$el);
    return this;
  };

  return PhotoBox;

})(Backbone.View);

document.gignal.views.Footer = (function(_super) {
  __extends(Footer, _super);

  function Footer() {
    this.render = __bind(this.render, this);
    _ref6 = Footer.__super__.constructor.apply(this, arguments);
    return _ref6;
  }

  Footer.prototype.tagName = 'div';

  Footer.prototype.className = 'gignal-box-footer';

  Footer.prototype.initialize = function() {
    this.avatar = new Backbone.View({
      tagName: 'img',
      className: 'gignal-avatar',
      attributes: {
        src: this.model.get('user_image'),
        alt: 'Avatar'
      }
    });
    return this.serviceProfileLink = new Backbone.View({
      tagName: 'a',
      attributes: {
        href: 'http://' + this.model.get('service') + '.com/' + this.model.get('username')
      }
    });
  };

  Footer.prototype.render = function() {
    $(this.serviceProfileLink.$el).append(this.avatar.$el);
    $(this.serviceProfileLink.$el).append(this.model.get('name'));
    this.$el.html(this.serviceProfileLink.$el);
    return this;
  };

  return Footer;

})(Backbone.View);

jQuery(function($) {
  Backbone.$ = $;
  document.gignal.widget = new document.gignal.views.Event();
  return document.gignal.stream = new Stream([], {
    url: 'http://dev.gignal.com/event/api/uuid/' + $('#gignal-widget').data('eventid') + '?callback=?'
  });
});

/*
//@ sourceMappingURL=app.js.map
*/