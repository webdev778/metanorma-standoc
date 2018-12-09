require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"
require "sass"
require "isodoc"
require "relaton"
require "fileutils"

module Asciidoctor
  module Standoc
    module Base
      Asciidoctor::Extensions.register do
        inline_macro Asciidoctor::Standoc::AltTermInlineMacro
        inline_macro Asciidoctor::Standoc::DeprecatedTermInlineMacro
        inline_macro Asciidoctor::Standoc::DomainTermInlineMacro
        block Asciidoctor::Standoc::PlantUMLBlockMacro
      end

      def content(node)
        node.content
      end

      def skip(node, name = nil)
        name = name || node.node_name
        w = "converter missing for #{name} node in ISO backend"
        Utils::warning(node, w, nil)
        nil
      end

      def html_extract_attributes(node)
        {
          script: node.attr("script"),
          bodyfont: node.attr("body-font"),
          headerfont: node.attr("header-font"),
          monospacefont: node.attr("monospace-font"),
          i18nyaml: node.attr("i18nyaml"),
          scope: node.attr("scope"),
          htmlstylesheet: node.attr("htmlstylesheet"),
          htmlcoverpage: node.attr("htmlcoverpage"),
          htmlintropage: node.attr("htmlintropage"),
          scripts: node.attr("scripts"),
          scripts_pdf: node.attr("scripts-pdf"),
          datauriimage: node.attr("data-uri-image"),
        }
      end

      def html_converter(node)
        IsoDoc::HtmlConvert.new(html_extract_attributes(node))
      end

      def doc_extract_attributes(node)
        {
          script: node.attr("script"),
          bodyfont: node.attr("body-font"),
          headerfont: node.attr("header-font"),
          monospacefont: node.attr("monospace-font"),
          i18nyaml: node.attr("i18nyaml"),
          scope: node.attr("scope"),
          wordstylesheet: node.attr("wordstylesheet"),
          standardstylesheet: node.attr("standardstylesheet"),
          header: node.attr("header"),
          wordcoverpage: node.attr("wordcoverpage"),
          wordintropage: node.attr("wordintropage"),
          ulstyle: node.attr("ulstyle"),
          olstyle: node.attr("olstyle"),
        }
      end

      def doc_converter(node)
        IsoDoc::WordConvert.new(doc_extract_attributes(node))
      end

      def init(node)
        @fn_number ||= 0
        @draft = false
        @refids = Set.new
        @anchors = {}
        @draft = node.attributes.has_key?("draft")
        @novalid = node.attr("novalid")
        @smartquotes = node.attr("smartquotes") != "false"
        @fontheader = default_fonts(node)
        @files_to_delete = []
        @filename = node.attr("docfile") ?
          node.attr("docfile").gsub(/\.adoc$/, "").gsub(%r{^.*/}, "") : ""
        @no_isobib_cache = node.attr("no-isobib-cache")
        @no_isobib = node.attr("no-isobib")
        @bibdb = nil
        @seen_headers = []
        init_bib_caches(node)
        init_iev_caches(node)
      end

      def init_bib_caches(node)
        unless (@no_isobib_cache || @no_isobib)
          globalname = global_bibliocache_name unless node.attr("local-cache-only")
          localname = local_bibliocache_name(node.attr("local-cache") || node.attr("local-cache-only"))
          if node.attr("flush-caches")
            FileUtils.rm_f globalname unless globalname.nil?
            FileUtils.rm_f localname unless localname.nil?
          end
        end        
        @bibdb = Relaton::Db.new(globalname, localname) unless @no_isobib
      end

      def init_iev_caches(node)
        unless (@no_isobib_cache || @no_isobib)
          globalname = ievcache_name(true) unless node.attr("local-cache-only")
          localname = ievcache_name(false) if node.attr("local-cache") ||
          node.attr("local-cache-only")
          if node.attr("flush-caches")
            FileUtils.rm_f globalname unless globalname.nil?
            FileUtils.rm_f localname unless localname.nil?
          end
        end
        @iev = Iev::Db.new(globalname, localname) unless @no_isobib
      end

      def default_fonts(node)
        b = node.attr("body-font") ||
          (node.attr("script") == "Hans" ? '"SimSun",serif' :
           '"Cambria",serif')
        h = node.attr("header-font") ||
          (node.attr("script") == "Hans" ? '"SimHei",sans-serif' :
           '"Cambria",serif')
        m = node.attr("monospace-font") || '"Courier New",monospace'
        "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"
      end

      def document(node)
        init(node)
        ret = makexml(node).to_xml(indent: 2)
        unless node.attr("nodoc") || !node.attr("docfile")
          File.open(@filename + ".xml", "w:UTF-8") { |f| f.write(ret) }
          html_converter(node).convert(@filename + ".xml")
          doc_converter(node).convert(@filename + ".xml")
        end
        @files_to_delete.each { |f| FileUtils.rm f }
        ret
      end

      def makexml1(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<standard-document>"]
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</standard-document>"
        textcleanup(result.flatten * "\n")
      end

      def makexml(node)
        result = makexml1(node)
        ret1 = cleanup(Nokogiri::XML(result))
        ret1.root.add_namespace(nil, "http://riboseinc.com/isoxml")
        validate(ret1) unless @novalid
        ret1
      end

      def draft?
        @draft
      end

      def doctype(node)
        node.attr("doctype")
      end

      def front(node, xml)
        xml.bibdata **attr_code(type: doctype(node)) do |b|
          metadata node, b
        end
        metadata_version(node, xml)
      end

      def middle(node, xml)
        xml.sections do |s|
          s << node.content if node.blocks?
        end
      end

      def term_source_attr(seen_xref)
        { bibitemid: seen_xref.children[0]["target"],
          format: seen_xref.children[0]["format"],
          type: "inline" }
      end

      def add_term_source(xml_t, seen_xref, m)
        xml_t.origin seen_xref.children[0].content,
          **attr_code(term_source_attr(seen_xref))
        m[:text] && xml_t.modification do |mod|
          mod.p { |p| p << m[:text].sub(/^\s+/, "") }
        end
      end

      TERM_REFERENCE_RE_STR = <<~REGEXP.freeze
        ^(?<xref><xref[^>]+>([^<]*</xref>)?)
               (,\s(?<text>.*))?
        $
      REGEXP
      TERM_REFERENCE_RE =
        Regexp.new(TERM_REFERENCE_RE_STR.gsub(/\s/, "").gsub(/_/, "\\s"),
                   Regexp::IGNORECASE | Regexp::MULTILINE)

      def extract_termsource_refs(text, node)
        matched = TERM_REFERENCE_RE.match text
        if matched.nil?
          Utils::warning(node, "term reference not in expected format", text)
        end
        matched
      end

      def termsource(node)
        matched = extract_termsource_refs(node.content, node) || return
        noko do |xml|
          attrs = { status: matched[:text] ? "modified" : "identical" }
          xml.termsource **attrs do |xml_t|
            seen_xref = Nokogiri::XML.fragment(matched[:xref])
            add_term_source(xml_t, seen_xref, matched)
          end
        end.join("\n")
      end
    end
  end
end
