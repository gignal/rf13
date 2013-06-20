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
        files: ['_scripts/*.coffee']
        tasks: ['coffee', 'uglify']

    connect:
      app:
        options:
          keepalive: true

  grunt.registerTask 'default', ['coffee', 'uglify', 'stylus']

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
