require "nokogiri"
require "json"

Dir["target/output/celesta/**/*.html"].each do |file_name|
  # next if file_name != 'target/output/celesta/7/1050_celesta_sql.html'
  puts file_name
  doc = File.open(file_name) { |f| Nokogiri::HTML(f) }
  doc.xpath("//div[contains(@class, 'literalblock') or contains(@class, 'imageblock')]").each do |el|
    el_id = el["id"].to_s
    file_to_search = "#{File.dirname(file_name)}/_images/asciidoctor-diagrams/#{el_id}.svg"
    # puts file_to_search
    if File.file?(file_to_search)
      puts el["id"]
      svg_contents = File.read(file_to_search)
      width = Nokogiri::XML(svg_contents).xpath("/svg:svg/@width", "svg" => "http://www.w3.org/2000/svg");
      height = Nokogiri::XML(svg_contents).xpath("/svg:svg/@height", "svg" => "http://www.w3.org/2000/svg");
      el.after("
        <div id='#{el_id}' class='imageblock'>
          <div class='content'>
            <object type='image/svg+xml' data='create_schema.svg' width='#{width}' height='#{height}')
              #{svg_contents}
            </object>
          </div>
        </div>")
      el.remove
    end
  end
  File.write(file_name, doc.to_html)
end

