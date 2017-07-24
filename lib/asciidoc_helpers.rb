# coding: utf-8
require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

include Asciidoctor

Extensions.register do
  block do
    named :images
    on_context :open

    process do |parent, reader, attrs|
      wrapper = create_open_block parent, [], {}
      parse_content wrapper, reader.lines, {}
      warn wrapper.blocks
      wrapper
    end
  end
end

require 'asciidoctor'
require 'asciidoctor/extensions'

class LightboxDocinfoProcessor < Extensions::DocinfoProcessor
  use_dsl
  at_location :header

  def process(doc)
    backend = doc.backend
    if backend == 'html5'
      %(
        <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/jquery.fancybox.min.css" type="text/css" media="screen" />
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/jquery.fancybox.pack.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/helpers/jquery.fancybox-buttons.css" type="text/css" media="screen" />
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/helpers/jquery.fancybox-buttons.js"></script>
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/helpers/jquery.fancybox-media.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/helpers/jquery.fancybox-thumbs.css" type="text/css" media="screen" />
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/helpers/jquery.fancybox-thumbs.js"></script>
        <script type="text/javascript" src="https://cdn.rawgit.com/yairEO/simpleGrid/master/simpleGrid.js"></script>
        <script type="text/javascript">
          $(document).ready(function() {
            $(".fancybox").fancybox();
          });
        </script>)
    elsif backend == 'xhtml5'
      %(
        <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/jquery.fancybox.min.css" type="text/css" media="screen" />
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/jquery.fancybox.pack.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/helpers/jquery.fancybox-buttons.css" type="text/css" media="screen" />
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/helpers/jquery.fancybox-buttons.js"></script>
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/helpers/jquery.fancybox-media.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/helpers/jquery.fancybox-thumbs.css" type="text/css" media="screen" />
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/helpers/jquery.fancybox-thumbs.js"></script>
        <script type="text/javascript" src="https://cdn.rawgit.com/yairEO/simpleGrid/master/simpleGrid.js"></script>

        <script type="text/javascript">
          $(document).ready(function() {
            $(".fancybox").fancybox();
          });
        </script>)
    end
  end
end

Asciidoctor::Extensions.register do
  block do
    named :gallery
    on_context :open
    # A bit hacky. Each image gallery needs a unique string:
    # http://stackoverflow.com/questions/88311/how-best-to-generate-a-random-string-in-ruby#88341
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    process do |parent, reader, attrs|
      wrapper = create_open_block parent, [], {}
      parse_content wrapper, reader
      counter = (0...50).map { o[rand(o.length)] }.join
      images = wrapper.find_by(context: :image)
      lines = images.map do |img|
        src = img.attr 'target'
        alt = img.attr 'alt'
        thumb_src = src#.sub(/\.[^.]+$/, '-thumb\0')
        rel_size = 90 / images.size
        num_columns = Math.sqrt(images.size.to_f).round
        %(<div class="square-grid__cell square-grid__cell--#{num_columns}"><div class="square-grid__content"><a class="fancybox" rel="fancybox-#{counter}" href="#{parent.image_uri src}" title="#{img.attr 'title'}"><img src="#{parent.image_uri thumb_src}" alt="#{alt}"></a></div></div>)
      end
      create_paragraph parent, %w(<div class="gallery">) + lines + %w(</div>), {}, subs: nil
    end
  end

  block do
    named :notes
    on_context :open
    process do |parent, reader, attrs|
      new_attrs = {}
      wrapper = create_open_block parent, [], new_attrs
      parse_content wrapper, reader.lines, {}
      warn wrapper.blocks
      wrapper
    end
  end
  docinfo_processor LightboxDocinfoProcessor
  docinfo_processor do
    at_location :header
    process do |doc|
      %(
        <style>
        .gallery img {
          display: block;
          border: 0px !important;
        }

        .gallery {
          float: left;
          width: 50%;
          height: 500px;
          display: flex;
          flex-wrap: wrap;
          justify-content: right;
        }
        .reveal p {
          margin: 5px 0 !important;
        }
        .reveal h2 {
          font-size: 1.5em;
        }
        .notes {
          overflow: hidden;
        }

        .square-grid__cell {
          overflow: hidden;
          position: relative;
        }

        .square-grid__content {
          left: 0;
          position: absolute;
          top: 0;
        }

        .square-grid__cell:after {
          content: '';
          display: block;
        }

        // Sizes – Number of cells per row

        .square-grid__cell--10 {
          flex-basis: 10%;
        }

        .square-grid__cell--9 {
          flex-basis: 11.1111111%;
        }

        .square-grid__cell--8 {
          flex-basis: 12.5%;
        }

        .square-grid__cell--7 {
          flex-basis: 14.2857143%;
        }

        .square-grid__cell--6 {
          flex-basis: 16.6666667%;
        }

        .square-grid__cell--5 {
          flex-basis: 20%;
        }

        .square-grid__cell--4 {
          flex-basis: 25%;
        }

        .square-grid__cell--3 {
          flex-basis: 33.333%;
        }

        .square-grid__cell--2 {
          flex-basis: 50%;
        }

        .square-grid__cell--1 {
          flex-basis: 100%;
        }
       </style>)
    end
  end
end
