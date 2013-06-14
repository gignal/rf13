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
        sourceMap: 'lib/app.min.js.map'
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

    less:
      app:
        files: 
          'lib/style.min.css': [
            '_scripts/app.less'
          ]
        options:
          compress: true

    watch:
      less:
        files: ['_scripts/app.less']
        tasks: ['less']
      coffee:
        files: ['_scripts/*.coffee']
        tasks: ['uglify']

    connect:
      app:
        options:
          keepalive: true

  grunt.registerTask 'default', ['coffee', 'uglify', 'less']

  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
