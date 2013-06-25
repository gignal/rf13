var Post, Stream, _ref, _ref1, _ref2, _ref3, _ref4,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

document.gignal = {
  views: {}
};

Post = (function(_super) {
  __extends(Post, _super);

  function Post() {
    this.getData = __bind(this.getData, this);
    _ref = Post.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Post.prototype.idAttribute = 'stream_id';

  Post.prototype.re_links = /((http|https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?)/g;

  Post.prototype.getData = function() {
    var data, direct, text, username;
    text = this.get('text');
    text = text.replace(this.re_links, '<a href="$1">link</a>');
    if (text.indexOf(' ') === -1) {
      text = null;
    }
    username = this.get('username');
    if (username.indexOf(' ') !== -1) {
      username = null;
    }
    switch (this.get('service')) {
      case 'Twitter':
        direct = 'http://twitter.com/' + username + '/status/' + this.get('original_id');
        break;
      case 'Facebook':
        direct = 'http://facebook.com/' + this.get('original_id');
        break;
      case 'Instagram':
        direct = 'http://instagram.com/p/' + this.get('original_id');
        break;
      default:
        direct = '#';
    }
    data = {
      message: text,
      username: username,
      name: this.get('name'),
      since: humaneDate(this.get('creation')),
      service: this.get('service'),
      user_image: this.get('user_image'),
      thumb_photo: this.get('thumb_photo'),
      direct: direct
    };
    return data;
  };

  return Post;

})(Backbone.Model);

Stream = (function(_super) {
  __extends(Stream, _super);

  function Stream() {
    this.update = __bind(this.update, this);
    this.inset = __bind(this.inset, this);
    _ref1 = Stream.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  Stream.prototype.model = Post;

  Stream.prototype.calling = false;

  Stream.prototype.parameters = {
    cid: 0,
    limit: 30,
    sinceTime: 0
  };

  Stream.prototype.initialize = function() {
    this.on('add', this.inset);
    return this.update();
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
    return document.gignal.widget.$el.prepend(view.render().el).isotope('reloadItems').isotope({
      sortBy: 'original-order'
    });
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

document.gignal.views.TextBox = (function(_super) {
  __extends(TextBox, _super);

  function TextBox() {
    this.render = __bind(this.render, this);
    _ref3 = TextBox.__super__.constructor.apply(this, arguments);
    return _ref3;
  }

  TextBox.prototype.tagName = 'div';

  TextBox.prototype.className = 'gignal-outerbox';

  TextBox.prototype.render = function() {
    this.$el.css('width', document.gignal.widget.columnWidth);
    if (this.model.get('admin_entry')) {
      this.$el.addClass('gignal-owner');
    }
    this.$el.html(Templates.post.render(this.model.getData(), {
      footer: Templates.footer
    }));
    return this;
  };

  return TextBox;

})(Backbone.View);

document.gignal.views.PhotoBox = (function(_super) {
  __extends(PhotoBox, _super);

  function PhotoBox() {
    this.render = __bind(this.render, this);
    _ref4 = PhotoBox.__super__.constructor.apply(this, arguments);
    return _ref4;
  }

  PhotoBox.prototype.tagName = 'div';

  PhotoBox.prototype.className = 'gignal-outerbox';

  PhotoBox.prototype.render = function() {
    this.$el.css('width', document.gignal.widget.columnWidth);
    this.$el.html(Templates.photo.render(this.model.getData(), {
      footer: Templates.footer
    }));
    return this;
  };

  return PhotoBox;

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