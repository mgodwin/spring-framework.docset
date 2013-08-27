cheerio = require 'cheerio'
sqlite3 = require('sqlite3').verbose()

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-shell'

  buildDocsetDir = "build/spring-framework.docset"
  docsDir = "docs"

  grunt.initConfig
    clean: ["build"]
    shell:
      javadocset:
        command: "./javadocset #{buildDocsetDir.replace(/\.docset/, '')} #{docsDir}/javadoc-api"
        options:
          stdout: true
    copy:
      plist:
        src: 'Info.plist'
        dest: "#{buildDocsetDir}/Contents/Info.plist"
      docs:
        expand: true
        cwd: "#{docsDir}/spring-framework-reference/html"
        src: '**'
        dest: "#{buildDocsetDir}/Contents/Resources/Documents/guide"
      icon:
        src: 'icon.png'
        dest: "#{buildDocsetDir}/icon.png"

  grunt.registerTask 'buildIndex', 'Build Search Index', ->
    itemsAdded = 0
    done = @async()

    addToIndex = (name, type, path) ->
      db.run "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ( ? , ?, ?)", name, type, "guide/" + path, (error) ->
        if error?
          grunt.log.error error
          done(false)
        itemsAdded++
    
    #grunt.file.mkdir('build/spring-framework.docset/Contents/Resources/Documents')
    db = new sqlite3.Database './build/spring-framework.docset/Contents/Resources/docSet.dsidx'
    # grunt.log.write "Creating database..."
    # db.exec "DROP TABLE IF EXISTS searchIndex;" +
    #   "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);" +
    #   "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path)", (error) ->
    #     if error?
    #       grunt.log.error error
    #       done(false)
    
    #     grunt.log.writeln "Done"

    guideHTML = grunt.file.read "#{docsDir}/spring-framework-reference/html/index.html", "utf-8"
    $ = cheerio.load(guideHTML)    

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

        grunt.log.writeln "#{itemsAdded} items were added to the index"

        done()    

  grunt.registerTask 'default', ['clean', 'shell', 'copy', 'buildIndex']