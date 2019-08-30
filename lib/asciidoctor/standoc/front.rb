require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"

module Asciidoctor
  module Standoc
    module Front
      def metadata_id(node, xml)
        part, subpart = node&.attr("partnumber")&.split(/-/)
        id = node.attr("docnumber") || ""
        id += "-#{part}" if part
        id += "-#{subpart}" if subpart
        xml.docidentifier id
        xml.docnumber node.attr("docnumber")
      end

      def metadata_version(node, xml)
        xml.edition node.attr("edition") if node.attr("edition")
        xml.version do |v|
          v.revision_date node.attr("revdate") if node.attr("revdate")
          v.draft node.attr("draft") if node.attr("draft")
        end
      end

      def committee_component(compname, node, out)
        out.send compname.gsub(/-/, "_"), node.attr(compname),
          **attr_code(number: node.attr("#{compname}-number"),
                      type: node.attr("#{compname}-type"))
        i = 2
        while node.attr(compname+"_#{i}") do
          out.send compname.gsub(/-/, "_"), node.attr(compname+"_#{i}"),
            **attr_code(number: node.attr("#{compname}-number_#{i}"),
                        type: node.attr("#{compname}-type_#{i}"))
          i += 1
        end
      end

      def organization(org, orgname)
        org.name orgname
      end

      def metadata_author(node, xml)
        publishers = node.attr("publisher") || ""
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "author" }
            c.organization { |a| organization(a, p) }
          end
        end
        personal_author(node, xml)
      end

      def personal_author(node, xml)
        if node.attr("fullname") || node.attr("surname")
          personal_author1(node, xml, "")
        end
        i = 2
        while node.attr("fullname_#{i}") || node.attr("surname_#{i}")
          personal_author1(node, xml, "_#{i}")
          i += 1
        end
      end

      def personal_author1(node, xml, suffix)
        xml.contributor do |c|
          c.role **{ type: node.attr("role#{suffix}")&.downcase || "author" }
          c.person do |p|
            p.name do |n|
              if node.attr("fullname#{suffix}")
                n.completename node.attr("fullname#{suffix}")
              else
                n.forename node.attr("givenname#{suffix}")
                n.initial node.attr("initials#{suffix}")
                n.surname node.attr("surname#{suffix}")
              end
            end
            node.attr("affiliation#{suffix}") and p.affiliation do |a|
              a.organization do |o|
                o.name node.attr("affiliation#{suffix}")
                node.attr("address#{suffix}") and o.address do |ad|
                  ad.formattedAddress node.attr("address#{suffix}")
                end
              end
            end
            node.attr("email#{suffix}") and p.email node.attr("email#{suffix}")
            node.attr("contributor-uri#{suffix}") and
              p.uri node.attr("contributor-uri#{suffix}")
          end
        end
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || return
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "publisher" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("publisher") || " "
        publishers.split(/,[ ]?/).each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            p.match(/[A-Za-z]/).nil? or c.owner do |owner|
              owner.organization { |o| organization(o, p) }
            end
          end
        end
      end

      def metadata_status(node, xml)
        xml.status do |s|
          s.stage ( node.attr("status") || node.attr("docstage") || "published" )
          node.attr("docsubstage") and s.substage node.attr("docsubstage")
          node.attr("iteration") and s.iteration node.attr("iteration")
        end
      end

      def metadata_committee(node, xml)
        return unless node.attr("technical-committee")
        xml.editorialgroup do |a|
          committee_component("technical-committee", node, a)
        end
      end

      def metadata_ics(node, xml)
        ics = node.attr("library-ics")
        ics && ics.split(/,\s*/).each do |i|
          xml.ics do |ics|
            ics.code i
          end
        end
      end

      def metadata_source(node, xml)
        node.attr("uri") && xml.uri(node.attr("uri"))
        node.attr("xml-uri") && xml.uri(node.attr("xml-uri"), type: "xml")
        node.attr("html-uri") && xml.uri(node.attr("html-uri"), type: "html")
        node.attr("pdf-uri") && xml.uri(node.attr("pdf-uri"), type: "pdf")
        node.attr("doc-uri") && xml.uri(node.attr("doc-uri"), type: "doc")
        node.attr("relaton-uri") && xml.uri(node.attr("relaton-uri"),
                                            type: "relaton")
      end

      def metadata_date1(node, xml, type)
        date = node.attr("#{type}-date")
        date and xml.date **{ type: type } do |d|
          d.on date
        end
      end

      def datetypes
        %w{ published accessed created implemented obsoleted
            confirmed updated issued circulated unchanged received }
      end

      def metadata_date(node, xml)
        datetypes.each { |t| metadata_date1(node, xml, t) }
        node.attributes.keys.each do |a|
          next unless a == "date" || /^date_\d+$/.match(a)
          type, date = node.attr(a).split(/ /, 2)
          type or next
          xml.date **{ type: type } do |d|
            d.on date
          end
        end
      end

      def metadata_language(node, xml)
        xml.language (node.attr("language") || "en")
      end

      def metadata_script(node, xml)
        xml.script (node.attr("script") || "Latn")
      end

      def relaton_relations
        %w(part-of)
      end

      def metadata_relations(node, xml)
        relaton_relations.each do |t|
          metadata_getrelation(node, xml, t)
        end
      end

      def relation_normalise(type)
        type.sub(/-by$/, "By").sub(/-of$/, "Of").sub(/-from$/, "From")
      end

      def metadata_getrelation(node, xml, type)
        docs = node.attr(type) || return
        docs.split(/,/).each do |d|
          xml.relation **{ type: relation_normalise(type) } do |r|
            fetch_ref(r, d, nil, {}) or r.bibitem do |b|
              b.title "--"
              b.docidentifier d
            end
          end
        end
      end

      def metadata_keywords(node, xml)
        return unless node.attr("keywords")
        node.attr("keywords").split(/,[ ]*/).each do |kw|
          xml.keyword kw
        end
      end

      def metadata(node, xml)
        title node, xml
        metadata_source(node, xml)
        metadata_id(node, xml)
        metadata_date(node, xml)
        metadata_author(node, xml)
        metadata_publisher(node, xml)
        metadata_version(node, xml)
        metadata_note(node, xml)
        metadata_language(node, xml)
        metadata_script(node, xml)
        metadata_status(node, xml)
        metadata_copyright(node, xml)
        metadata_relations(node, xml)
        metadata_series(node, xml)
        metadata_keywords(node, xml)
        xml.ext do |ext|
        metadata_ext(node, xml)
        end
      end

      def metadata_ext(node, ext)
          metadata_doctype(node, ext)
          metadata_committee(node, ext)
          metadata_ics(node, ext)
      end

      def metadata_doctype(node, xml)
        xml.doctype doctype(node)
      end

      def metadata_note(node, xml)
      end

      def metadata_series(node, xml)
      end

      def asciidoc_sub(x)
        return nil if x.nil?
        return "" if x.empty?
        d = Asciidoctor::Document.new(x.lines.entries, {header_footer: false})
        b = d.parse.blocks.first
        b.apply_subs(b.source)
      end

      def title(node, xml)
        title_english(node, xml)
        title_otherlangs(node, xml)
      end

      def title_english(node, xml)
        ["en"].each do |lang|
          at = { language: lang, format: "text/plain" }
          xml.title **attr_code(at) do |t|
            t << asciidoc_sub(node.attr("title") || node.attr("title-en") ||
                              node.title)
          end
        end
      end

      def title_otherlangs(node, xml)
        node.attributes.each do |k, v|
          next unless /^title-(?<titlelang>.+)$/ =~ k
          next if titlelang == "en"
          xml.title v, { language: titlelang, format: "text/plain" }
        end
      end
    end
  end
end
