clearing :on

build_dir = "./build"
ignore %r{build/}
ignore %r{asciidoctor.*}
ignore %r{reveal.*}
directories %w(src lib)

build_docs = proc do |_, _, changes|
  puts "Building due to changes in #{changes}"
  system("asciidoctor -T asciidoctor-reveal.js/templates/slim/ -r asciidoctor-bibtex -r ./lib/asciidoc_helpers.rb src/slides.adoc -o build/slides.html") || throw(:task_has_failed)
  system("asciidoctor -r asciidoctor-bibtex -r ./lib/asciidoc_helpers.rb src/slides.adoc -o build/book.html") || throw(:task_has_failed)
end

guard :yield, run_on_modifications: build_docs do
  watch(/src\/.*.adoc/)
  watch(/lib\/.*\.rb/)
  watch(/build\/images\/.*/)
end

guard 'remote-sync', :source => './src/', :destination => './build/images' do
  watch(/src\/(.*)\.(jpg|png|svg)/)
end
