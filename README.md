# Dash docset for the Spring Framework

![Dash with Spring Framework Documentation](http://mgodwin.github.io/spring-framework.docset/screenshot.png)

## Add to Dash

* __Docset Feed:__ https://raw.github.com/mgodwin/spring-framework.docset/master/SpringFramework.xml
* __Download Docset Manually:__ Visit the [Releases page](https://github.com/mgodwin/spring-framework.docset/releases) and download the latest release, or a specific version of the docset.


## Contributing

### How to Build

    npm install -g grunt-cli    # Only necessary if not already installed
    grunt

The docset will be placed in the `build` directory.

Add it to Dash by clicking the '+' in the Docsets panel.

### General project structure
The docset is generated dynamically by parsing the table of contents page of the Spring Framework documentation using `cheerio`.  Chapter headings are set as 'Guides' and section headings are set as 'Sections' in Dash.  

Javadocs are generated using the tool provided by kapeli.

If you have a better approach, or find a bug, please submit an issue or a pull request!
