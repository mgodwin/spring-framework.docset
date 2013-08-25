jsdom = require 'jsdom'
fs = require "fs"
sqlite3 = require('sqlite3').verbose()

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.initConfig
    clean: ["build"]
    copy:
      plist:
        src: 'Info.plist'
        dest: 'build/spring-framework.docset/Contents/Info.plist'
      docs:
        expand: true
        cwd: 'spring_docs/html'
        src: '**'
        dest: 'build/spring-framework.docset/Contents/Resources/Documents/'
      icon:
        src: 'icon.png'
        dest: 'build/spring-framework.docset/icon.png'

  grunt.registerTask 'buildIndex', 'Build Search Index', ->
    done = @async()
    itemsAdded = 0
    grunt.file.mkdir('build/spring-framework.docset/Contents/Resources/Documents')
    db = new sqlite3.Database './build/spring-framework.docset/Contents/Resources/docSet.dsidx'
    grunt.log.write "Creating database..."
    db.exec "DROP TABLE IF EXISTS searchIndex;" +
      "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);" +
      "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path)", (error) ->
        if error?
          grunt.log.error error
          done(false)
    
        grunt.log.writeln "Done"
        grunt.log.write "Creating JS DOM..."
        jsdom.env 
          file: "./spring_docs/html/index.html"
          scripts: ["../../jquery.js"]
          done: (errors, window) ->
            if errors?
              grunt.log.error errors
              done(false)

            grunt.log.writeln "Done"

            $ = window.$
            chapters = $('.chapter')

            db.serialize ->
              $('.chapter').each (i, el) ->
                addToIndex $(this).text(), 'Guide', $(this).find('a').attr('href')

              $('.section').each (i, el) ->
                sanitizedText = $(this).text().replace(/\n/, '').replace(/\s+/g, ' ')
                addToIndex sanitizedText, 'Section', $(this).find('a').attr('href')

              db.all "SELECT * FROM searchIndex", (err, rows) ->
                if err?
                  grunt.log.error error
                  done(false)

                if rows.length != itemsAdded
                  grunt.log.error 'The searchIndex does not have the correct number of items'
                  done false

                grunt.log.writeln "#{rows.length} items were added to the index"

                done()


    addToIndex = (name, type, path) ->
      db.run "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ( ? , ?, ?)", name, type, path, (error) ->
        if error?
          grunt.log.error error
          done(false)
        itemsAdded++

  grunt.registerTask 'default', ['clean', 'copy', 'buildIndex']