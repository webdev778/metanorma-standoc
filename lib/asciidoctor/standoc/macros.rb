require "asciidoctor/extensions"
require "fileutils"

module Asciidoctor
  module Standoc
    class AltTermInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :alt
      parse_content_as :text
      using_format :short

      def process(parent, _target, attrs)
        out = Asciidoctor::Inline.new(parent, :quoted, attrs["text"]).convert
        %{<admitted>#{out}</admitted>}
      end
    end

    class DeprecatedTermInlineMacro <
      Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :deprecated
      parse_content_as :text
      using_format :short

      def process(parent, _target, attrs)
        out = Asciidoctor::Inline.new(parent, :quoted, attrs["text"]).convert
        %{<deprecates>#{out}</deprecates>}
      end
    end

    class DomainTermInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :domain
      parse_content_as :text
      using_format :short

      def process(parent, _target, attrs)
        out = Asciidoctor::Inline.new(parent, :quoted, attrs["text"]).convert
        %{<domain>#{out}</domain>}
      end
    end

    class ToDoAdmonitionBlock < Extensions::BlockProcessor
      use_dsl
      named :TODO
      on_contexts :example, :paragraph

      def process parent, reader, attrs
        attrs['name'] = 'todo'
        attrs['caption'] = 'TODO'
        create_block parent, :admonition, reader.lines, attrs, content_model: :compound
      end
    end

    class ToDoInlineAdmonitionBlock < Extensions::Treeprocessor
      def process document
        (document.find_by context: :paragraph).each do |para|
          next unless /^TODO: /.match para.lines[0]
          parent = para.parent
          para.set_attr("name", "todo")
          para.set_attr("caption", "TODO")
          para.lines[0].sub!(/^TODO: /, "")
          todo = Block.new parent, :admonition, attributes: para.attributes,
            source: para.lines, content_model: :compound
          parent.blocks[parent.blocks.index(para)] = todo
        end
      end
    end

    class PlantUMLBlockMacroBackend
      # https://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
      def self.plantuml_installed?
        cmd = "plantuml"
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable?(exe) && !File.directory?(exe)
          end
        end
        nil
      end

      def self.generate_file parent, reader
        localdir = Utils::localdir(parent.document)
        src = reader.source
        !reader.lines.first.sub(/\s+$/, "").match /^@startuml($| )/ or
          src = "@startuml\n#{src}\n@enduml\n"
        /^@startuml (?<filename>[^\n]+)\n/ =~ src
        filename ||= parent.document.reader.lineno
        FileUtils.mkdir_p "#{localdir}/plantuml"
        File.open("#{localdir}plantuml/#{filename}.pml", "w") { |f| f.write src }
        system "plantuml #{localdir}plantuml/#{filename}.pml"
        filename
      end

      def self.generate_attrs attrs
        through_attrs = %w(id align float title role width height alt).
          inject({}) do |memo, key|
          memo[key] = attrs[key] if attrs.has_key? key
          memo
        end
      end
    end

    class PlantUMLBlockMacro < Asciidoctor::Extensions::BlockProcessor
      use_dsl
      named :plantuml
      on_context :literal
      parse_content_as :raw

      def process(parent, reader, attrs)
        if PlantUMLBlockMacroBackend.plantuml_installed?
          filename = PlantUMLBlockMacroBackend.generate_file parent, reader
          through_attrs = PlantUMLBlockMacroBackend.generate_attrs attrs
          through_attrs["target"] = "plantuml/#{filename}.png"
          create_image_block parent, through_attrs
        else
          warn "PlantUML not installed"
          # attrs.delete(1) : remove the style attribute
          attrs["language"] = "plantuml"
          create_listing_block parent, reader.source, attrs.reject { |k, v| k == 1 }
        end
      end
    end
  end
end
