module.exports = (grunt) ->

  grunt.initConfig

    coffee:
      compileWithMaps:
        options:
          #sourceMap: true
          join: true
          bare: true
        files:
          'gignal/lib/app.js': [
            '_scripts/app.coffee'
            '_scripts/views.coffee'
            '_scripts/init.coffee'
          ]

    hogan:
      app:
        options:
          defaultName: (filename) ->
            filename.split('/').pop().split('.').shift()
        files:
          'gignal/lib/templates.js': [
            '_scripts/*.mustache'
          ]

    uglify:
      options:
        # sourceMapRoot: 'gignal/lib'
        # sourceMapIn: 'gignal/lib/app.js.map'
        # sourceMap: './gignal/lib/app.min.js.map'
        mangle: false
        #wrap: 'gignal'
      app:
        files:
          'gignal/lib/app.min.js': [
            'bower_components/underscore/underscore.js'
            'bower_components/backbone/backbone.js'
            'bower_components/isotope/jquery.isotope.js'
            'bower_components/humane-dates/humane.js'
            'bower_components/scrollbottom/src/jquery.scrollbottom.js'
            'bower_components/hogan/web/builds/2.0.0/template-2.0.0.js'
            'gignal/lib/templates.js'
            'gignal/lib/app.js'
          ]

    stylus:
      compile:
        options:
          paths: ['gignal/lib']
        files:
          'gignal/lib/style.min.css': [
            '_scripts/style.styl'
          ]

    watch:
      stylus:
        files: ['_scripts/*.styl']
        tasks: ['stylus']
      coffee:
        files: ['_scripts/*.coffee', '_scripts/*.mustache']
        tasks: ['coffee', 'hogan', 'uglify']

    connect:
      app:
        options:
          keepalive: true

  grunt.registerTask 'default', ['coffee', 'hogan', 'uglify', 'stylus']

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-hogan'
