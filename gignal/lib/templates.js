this["Templates"] = this["Templates"] || {};

this["Templates"]["footer"] = new Hogan.Template(function(c,p,i){var _=this;_.b(i=i||"");_.b("<div class=\"gignal-box-footer\">");_.b("\n" + i);_.b("  <div class=\"pull-left\">");_.b("\n" + i);_.b("    <a href=\"http://");_.b(_.v(_.f("service",c,p,0)));_.b(".com/");_.b(_.v(_.f("username",c,p,0)));_.b("\" target=\"_blank\"><img src=\"");_.b(_.v(_.f("user_image",c,p,0)));_.b("\" class=\"gignal-avatar\" /></a>");_.b("\n" + i);_.b("  </div>");_.b("\n" + i);_.b("  ");_.b(_.v(_.f("name",c,p,0)));_.b("\n" + i);if(_.s(_.f("username",c,p,1),c,p,0,214,307,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("    <br /><a href=\"http://");_.b(_.v(_.f("service",c,p,0)));_.b(".com/");_.b(_.v(_.f("username",c,p,0)));_.b("\" target=\"_blank\">@");_.b(_.v(_.f("username",c,p,0)));_.b("</a>");_.b("\n");});c.pop();}_.b("  <br /><small class=\"lcase\"><a href=\"");_.b(_.v(_.f("direct",c,p,0)));_.b("\" target=\"_blank\" class=\"direct\">");_.b(_.v(_.f("since",c,p,0)));_.b("</a></small>");_.b("\n" + i);_.b("  <a href=\"http://");_.b(_.v(_.f("service",c,p,0)));_.b(".com/\" target=\"_blank\"><img src=\"./gignal/images/");_.b(_.v(_.f("service",c,p,0)));_.b(".png\" class=\"gignal-service\" /></a>");_.b("\n" + i);_.b("</div>");_.b("\n");return _.fl();;});

this["Templates"]["photo"] = new Hogan.Template(function(c,p,i){var _=this;_.b(i=i||"");_.b("<div class=\"gignal-imagebox\">");_.b("\n" + i);_.b("  <div class=\"gignal-image\" style=\"background-image:url('");_.b(_.v(_.f("photo",c,p,0)));_.b("')\"></div>");_.b("\n" + i);if(_.s(_.f("message",c,p,1),c,p,0,121,165,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("    <p class=\"message\">");_.b(_.t(_.f("message",c,p,0)));_.b("</p>");_.b("\n");});c.pop();}_.b("</div>");_.b("\n" + i);_.b("\n" + i);_.b(_.rp("footer",c,p,""));return _.fl();;});

this["Templates"]["post"] = new Hogan.Template(function(c,p,i){var _=this;_.b(i=i||"");_.b("<div class=\"gignal-text\">");_.b("\n" + i);_.b("  <span class=\"message\">");_.b(_.t(_.f("message",c,p,0)));_.b("</span>");_.b("\n" + i);_.b("  <hr />");_.b("\n" + i);_.b("</div>");_.b("\n" + i);_.b("\n" + i);_.b(_.rp("footer",c,p,""));return _.fl();;});