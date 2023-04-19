require "nokogiri"
require "json"

def get_path_relation_attributes(path_from, path_to)
  return { :distance => 0, :relative_path => "" } if path_from == path_to
  path_1_a = path_from.split("/")
  path_2_a = path_to.split("/")
  min_length = [path_1_a.length, path_2_a.length].min
  equal_els = 0
  for i in 0..min_length - 1
    equal_els += 1 if path_1_a[i] == path_2_a[i]
  end
  { :distance => path_1_a.length + path_2_a.length - equal_els * 2,
    :relative_path => "../" * (path_1_a.length - equal_els - 1) + path_2_a[equal_els..-1].join("/") }
end

# puts get_path_relation_attributes("a/b/c", "a/c")

def get_path_distance(path_from, path_to)
  get_path_relation_attributes(path_from, path_to)[:distance]
end

def get_path_relative_path(path_from, path_to)
  get_path_relation_attributes(path_from, path_to)[:relative_path]
end

# puts get_path_distance("a/b/c/d", "a/b/f")

anchored_elements = {}

def add_anchored_element(el_id, file_name, content, anchored_elements)
  el_id = el_id.to_s.downcase
  anchored_elements[el_id] = {} if anchored_elements[el_id].nil?
  anchored_elements[el_id][file_name] = content
end

Dir["target/output/**/*.html"].each do |file_name|
  # next if file_name != 'target/output/celesta/7/1050_celesta_sql.html'
  # puts file_name
  doc = File.open(file_name) { |f| Nokogiri::XML(f) }
  el_id = File.basename(file_name).sub(/^[0-9]*_/, '').sub(/[\.]html$/, '')

  if not doc.xpath('//h1')[0].nil?
    content = doc.xpath('//h1')[0].content.gsub(/\s+/, " ").strip
  elsif not doc.xpath('//h2')[0].nil?
    content = doc.xpath('//h2')[0].content.gsub(/\s+/, " ").strip
  else
    content = el_id
  end

  add_anchored_element(el_id, file_name, content, anchored_elements)
  add_anchored_element("#{el_id}_section", file_name, content, anchored_elements)
  add_anchored_element("#{el_id.gsub(/[_]/, '')}", file_name, content, anchored_elements)
  add_anchored_element("#{el_id.gsub(/[_]/, '')}_section", file_name, content, anchored_elements)

  doc.xpath("//*[@id]").each do |el|
    el_id = el.xpath("@id").first.value
    add_anchored_element(el_id, file_name, el.content.gsub(/\s+/, " ").strip, anchored_elements)
  end
end

# puts anchored_elements.to_json

Dir["target/output/**/*.html"].each do |file_name|
  # next if file_name != 'target/output/celesta/7/1050_celesta_sql.html'
  # puts file_name
  doc = File.open(file_name) { |f| Nokogiri::HTML(f) }
  doc.xpath("//a[starts-with(@href, '#')]").each do |el|
    # next if el.to_s != '<a href="#basic_settings_section">параметров конфигурации</a>'
    # puts el.to_s
    ref_id = el.xpath("@href").first.value[1..-1]
    # next if ref_id.downcase != 'celestasql'
    # puts ref_id
    min_path_distance = 100
    anchor_file_name = ""
    if anchored_elements[ref_id.downcase].nil?
      # puts "ERROR: Anchor for reference #{ref_id} in file #{file_name} not found"
    else
      anchored_elements[ref_id.downcase].each_key do |possible_anchor_file_name|
        if get_path_distance(file_name, possible_anchor_file_name) < min_path_distance
          min_path_distance = get_path_distance(file_name, possible_anchor_file_name)
          anchor_file_name = possible_anchor_file_name
        end
      end
      if min_path_distance != 0
        el.xpath("@href").first.value = "#{get_path_relative_path(file_name, anchor_file_name)}##{ref_id}"
        if el.content.strip == "[#{ref_id}]"
          el.content = anchored_elements[ref_id.downcase][anchor_file_name]
        end
      end
    end
    # puts ref_id, anchored_elements[ref_id.downcase]
  end
  File.write(file_name, doc.to_html)
end

Dir["target/output/**/*.svg"].each do |file_name|
  # next if file_name != 'target/output/celesta/7/1050_celesta_sql.html'
  puts file_name
  doc = File.open(file_name) { |f| Nokogiri::XML(f) }
  doc.xpath("//svg:a[starts-with(@xlink:href, '.#')]", 'xlink' => 'http://www.w3.org/1999/xlink',
            'svg' => 'http://www.w3.org/2000/svg').each do |el|
    ref_id = el.xpath("@xlink:href", 'xlink' => 'http://www.w3.org/1999/xlink').first.value[2..-1]
    # next if ref_id != 'CelestaSQL'
    puts ref_id
    min_path_distance = 100
    anchor_file_name = ""
    if anchored_elements[ref_id.downcase].nil?
      # puts "ERROR: Anchor for reference #{ref_id} in file #{file_name} not found"
    else
      anchored_elements[ref_id.downcase].each_key do |possible_anchor_file_name|
        if get_path_distance(file_name, possible_anchor_file_name) < min_path_distance
          min_path_distance = get_path_distance(file_name, possible_anchor_file_name)
          anchor_file_name = possible_anchor_file_name
        end
      end
      if min_path_distance != 0
        # puts file_name
        # puts "#{file_name.match(/(.*)_images/)[1]}somefile"
        el.xpath("@xlink:href", 'xlink' => 'http://www.w3.org/1999/xlink').first.value =
          "#{get_path_relative_path("#{file_name.match(/(.*)_images/)[1]}somefile", anchor_file_name)}##{ref_id}"
        puts el.xpath("@xlink:href", 'xlink' => 'http://www.w3.org/1999/xlink').first.value
        # el.xpath("@xlink:href", 'xlink' => 'http://www.w3.org/1999/xlink').first.value = "#{get_path_relative_path(file_name, anchor_file_name)}##{ref_id}"
        # if el.content.strip == "[#{ref_id}]"
        #   el.content = anchored_elements[ref_id.downcase][anchor_file_name]
        # end
      end
    end
    # puts ref_id, anchored_elements[ref_id.downcase]
  end
  File.write(file_name, doc.to_xml)
end

