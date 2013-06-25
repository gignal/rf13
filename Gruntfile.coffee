module.exports = (grunt) ->

  grunt.initConfig
  
    coffee:
      compileWithMaps:
        options:
          sourceMap: true
          join: true
          bare: true
        files:
          'lib/app.js': [
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
          'lib/templates.js': [
            '_scripts/*.mustache'
          ]

    uglify:
      options:
        sourceMapRoot: 'lib'
        sourceMapIn: 'lib/app.js.map'
        sourceMap: './lib/app.min.js.map'
        mangle: false
        #wrap: 'gignal'
      app:
        files: 
          'lib/app.min.js': [
            'components/underscore/underscore.js'
            'components/backbone/backbone.js'
            'components/isotope/jquery.isotope.js'
            'components/humane-dates/humane.js'
            'components/hogan/web/builds/2.0.0/template-2.0.0.js'
            'lib/templates.js'
            'lib/app.js'
          ]

    stylus:
      compile:
        options:
          paths: ['lib']
        files: 
          'lib/style.min.css': [
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
