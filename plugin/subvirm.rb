require 'rexml/document'
require 'time'

def search_svn_log(search_term, limit)
    #TODO JQ: dont strip the root and instead make the commands from the search page use the URL syntax instead of file
    output = []
    doc = REXML::Document.new(`svn log --xml -vl #{limit}`)
    any_results = false
    doc.elements.each('*/logentry') do |entry|
        msg = entry.elements['msg'].text
        author = entry.elements['author'].text
        if msg =~ /#{search_term}/ || author =~ /#{search_term}/
            any_results = true
            time = Time.parse(entry.elements['date'].text)
            output << "rev.#{entry.attributes['revision']} | #{author} | #{time.localtime.strftime('%a, %d %b %Y @ %H:%M:%S %Z')}"
            output << msg << ""
            output << "Affected paths:"
            entry.elements.each('paths/path') do |path|
                path_sans_root = path.text[/\/.+?\/(.+)/, 1]
                output << "#{path.attributes['action']}  ./#{path_sans_root}"
            end
            output << ""
            output << "--------------------"
            output << ""
        end
    end
    unless any_results
        output << "no results"
        output << ""
        output << "--------------------"
        output << ""
    end
    output
end
