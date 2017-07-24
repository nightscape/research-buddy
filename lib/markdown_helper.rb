module MarkdownHelper
  def images(imgs = {}, &blk)
    inner = capture_erb(&blk)
    text = "<div class=\"images\">\n" +
           markdown_to_html(inner) +
           "</div>\n"
    guard_block(text)
  end
end
class Slideshow::Gen
  include MarkdownHelper
end
