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
    text = text.replace(this.re_links, '<a href="$1" target="_blank">link</a>');
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
      photo: this.get('large_photo'),
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
    limit: 25,
    offset: 0,
    sinceTime: 0
  };

  Stream.prototype.initialize = function() {
    this.on('add', this.inset);
    this.update();
    return this.setIntervalUpdate();
  };

  Stream.prototype.inset = function(model) {
    var method, view;
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
    method = !this.append ? 'prepend' : 'append';
    document.gignal.widget.$el[method](view.render().el).isotope('reloadItems').isotope({
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

  Stream.prototype.isScrolledIntoView = function(elem) {
    var docViewBottom, docViewTop, elemBottom, elemTop;
    docViewTop = $(window).scrollTop();
    docViewBottom = docViewTop + $(window).height();
    elemTop = $(elem).offset().top;
    elemBottom = elemTop + $(elem).height();
    return (elemBottom <= docViewBottom) && (elemTop >= docViewTop);
  };

  Stream.prototype.update = function(append) {
    var offset, sinceTime,
      _this = this;
    this.append = append;
    if (this.calling) {
      return;
    }
    if (!this.append && !this.isScrolledIntoView('#gignal-stream header')) {
      return;
    }
    this.calling = true;
    if (!this.append) {
      sinceTime = _.max(this.pluck('saved_on'));
      if (!_.isFinite(sinceTime)) {
        sinceTime = null;
      }
      offset = 0;
    } else {
      sinceTime = _.min(this.pluck('saved_on'));
      offset = this.parameters.offset += this.parameters.limit;
    }
    return this.fetch({
      remove: false,
      cache: true,
      timeout: 15000,
      jsonpCallback: 'callme',
      data: {
        limit: this.parameters.limit,
        offset: offset ? offset : void 0,
        sinceTime: _.isFinite(sinceTime) ? sinceTime : void 0
      },
      success: function() {
        return _this.calling = false;
      },
      error: function(c, response) {
        if (response.statusText === 'timeout') {
          return _this.calling = false;
        } else {
          return window.setTimeout(function() {
            return location.reload(true);
          }, 10000);
        }
      }
    });
  };

  Stream.prototype.setIntervalUpdate = function() {
    var sleep, start;
    sleep = 5000;
    start = (sleep * (Math.floor(+new Date() / sleep))) + sleep;
    return window.setTimeout(function() {
      sleep = 5000;
      return window.setInterval(document.gignal.stream.update, sleep);
    }, start);
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

  TextBox.prototype.initialize = function() {
    return this.listenTo(this.model, 'change', this.render);
  };

  TextBox.prototype.render = function() {
    var data;
    this.$el.css('width', document.gignal.widget.columnWidth);
    if (this.model.get('admin_entry')) {
      this.$el.addClass('gignal-owner');
    } else if (this.model.get('username') === 'roskildefestival' && this.model.get('service') === 'Instagram') {
      this.$el.addClass('gignal-owner');
    }
    data = this.model.getData();
    if (!data.message) {
      document.gignal.widget.$el.isotope('remove', this.$el);
    }
    this.$el.html(Templates.post.render(data, {
      footer: Templates.footer
    }));
    return this;
  };

  return TextBox;

})(Backbone.View);

document.gignal.views.PhotoBox = (function(_super) {
  __extends(PhotoBox, _super);

  function PhotoBox() {
    this.linksta = __bind(this.linksta, this);
    this.render = __bind(this.render, this);
    _ref4 = PhotoBox.__super__.constructor.apply(this, arguments);
    return _ref4;
  }

  PhotoBox.prototype.tagName = 'div';

  PhotoBox.prototype.className = 'gignal-outerbox';

  PhotoBox.prototype.events = {
    'click a.direct': 'linksta'
  };

  PhotoBox.prototype.initialize = function() {
    var img,
      _this = this;
    this.listenTo(this.model, 'change', this.render);
    img = new Image();
    img.src = this.model.get('large_photo');
    return img.onerror = function() {
      return document.gignal.widget.$el.isotope('remove', _this.$el);
    };
  };

  PhotoBox.prototype.render = function() {
    var data;
    this.$el.css('width', document.gignal.widget.columnWidth);
    if (this.model.get('admin_entry')) {
      this.$el.addClass('gignal-owner');
    } else if (this.model.get('username' === 'roskildefestival' && this.model.get('service' === 'Instagram'))) {
      this.$el.addClass('gignal-owner');
    }
    data = this.model.getData();
    if (!data.photo) {
      document.gignal.widget.$el.isotope('remove', this.$el);
      return;
    }
    this.$el.html(Templates.photo.render(this.model.getData(), {
      footer: Templates.footer
    }));
    return this;
  };

  PhotoBox.prototype.linksta = function(event) {
    var _this = this;
    if (this.model.get('service') === 'Instagram') {
      event.preventDefault();
      return $.getJSON('https://api.instagram.com/v1/media/' + this.model.get('original_id') + '?client_id=3ebcc844a6df41169c1955e0f75d6fce&callback=?').done(function(response) {
        if (response.data != null) {
          return window.open(response.data.link, '_blank');
        }
      });
    }
  };

  return PhotoBox;

})(Backbone.View);

jQuery(function($) {
  $.ajaxSetup({
    cache: true
  });
  Backbone.$ = $;
  document.gignal.widget = new document.gignal.views.Event();
  document.gignal.stream = new Stream([], {
    url: 'http://api.gignal.com/event/api/uuid/' + $('#gignal-widget').data('eventid') + '?callback=?'
  });
  return $(window).on('scrollBottom', {
    offsetY: -100
  }, function() {
    return document.gignal.stream.update(true);
  });
});
