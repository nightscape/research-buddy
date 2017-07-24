require 'oga'
require 'deterministic'
require 'yaml'
file_name = ARGV[0]
html = File.read(file_name)
parsed = Oga.parse_html(html)
paragraphs = parsed.xpath('p')
pairs = paragraphs.drop(1).each_cons(2)
Highlight = Struct.new(:text, :page, :comment)
highlights = pairs.map do |text_element, maybe_comment_element|
  text_element_is_text = text_element.text.start_with?('"')
  page_text = text_element.css("[href]").text.gsub(/ :(\d+)/, "\\1")
  page = if page_text && !page_text.empty?
           page_text.to_i
         else
           nil
         end
  text = text_element.text.gsub(/"(.*)" \( :#{page}\)/, "\\1")

  em_elems = maybe_comment_element.css("em")
  comment_element = Deterministic::Option.any?(em_elems).fmap(&:first)
  comment_text = comment_element.fmap { |e| e.children.map {|e| (e.respond_to?(:name) && e.name == "br") ? "\n" : e.text }.join.gsub(/ \(note on p.\d+\)/, "") }
  comment_hash = comment_text.fmap do |comment|
    begin
      hash = YAML.load(comment)
      if hash["tags"]
        hash.merge("tags" => hash["tags"].split(",").map(&:strip))
      else
        hash
      end
    rescue => e
      {"text" => comment}
    end
  end
  if text_element_is_text
    Highlight.new(text, page)
  else
    nil
  end
end

puts highlights.to_yaml
