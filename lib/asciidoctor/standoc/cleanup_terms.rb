require_relative "term_lookup_cleanup"
require_relative "cleanup_terms_designations"

module Asciidoctor
  module Standoc
    module Cleanup
      def termdomain_cleanup(xmldoc)
        xmldoc.xpath("//p/domain").each do |a|
          parent = a.parent
          prev = parent.previous
          prev.next = a.remove
          parent.text.strip.empty? and parent.remove
        end
      end

      def termdomain1_cleanup(xmldoc)
        xmldoc.xpath("//term").each do |t|
          d = t.xpath("./domain | ./subject").last or next
          defn = d.at("../definition") and defn.previous = d.remove
        end
      end

      def termdefinition_cleanup(xmldoc)
        generate_termdefinitions(xmldoc)
        split_termdefinitions(xmldoc)
        alternate_termdefinitions(xmldoc)
      end

      TERMDEF_BLOCKS =
        "./p | ./ol | ./dl[not(@metadata = 'true')] | ./ul | ./figure | "\
        "./formula | ./table".freeze

      def generate_termdefinitions(xmldoc)
        xmldoc.xpath("//term[not(definition)]").each do |d|
          first_child = d.at(TERMDEF_BLOCKS) || next
          t = Nokogiri::XML::Element.new("definition", xmldoc)
          first_child.replace(t)
          t << first_child.remove
          d.xpath(TERMDEF_BLOCKS).each do |n|
            t << n.remove
          end
        end
      end

      def split_termdefinitions(xmldoc)
        xmldoc.xpath("//definition").each do |d|
          if d.at("./p | ./ol | ./dl | ./ul")
            d.children = "<verbal-definition>#{d.children}</verbal-definition>"
          else
            d.children = "<non-verbal-representation>"\
                         "#{d.children}</non-verbal-representation>"
          end
        end
      end

      def alternate_termdefinitions(xmldoc)
        xmldoc.xpath("//term").each do |t|
          t.xpath("./definition").each do |d|
            d1 = d.next_element or next
            if (v = d.at("./verbal-definition")) &&
                !d.at("./non-verbal-representation") &&
                !d1.at("./verbal-definition") &&
                nv = d1.at("./non-verbal-representation")
              v.next = nv.remove
              d1.remove
            end
          end
        end
      end

      def termdocsource_cleanup(xmldoc)
        f = xmldoc.at("//preface | //sections")
        xmldoc.xpath("//termdocsource").each { |s| f.previous = s.remove }
      end

      def term_children_cleanup(xmldoc)
        xmldoc.xpath("//terms[terms]").each { |t| t.name = "clause" }
        xmldoc.xpath("//term").each do |t|
          %w(termnote termexample termsource term).each do |w|
            t.xpath("./#{w}").each { |n| t << n.remove }
          end
        end
      end

      def termdef_from_termbase(xmldoc)
        xmldoc.xpath("//term").each do |x|
          if (c = x.at("./origin/termref")) && !x.at("./definition")
            x.at("./origin").previous = fetch_termbase(c["base"], c.text)
          end
        end
      end

      def termnote_example_cleanup(xmldoc)
        %w(note example).each do |w|
          xmldoc.xpath("//term#{w}[not(ancestor::term)]").each do |x|
            x.name = w
          end
        end
      end

      def termdef_cleanup(xmldoc)
        termdef_unnest_cleanup(xmldoc)
        Asciidoctor::Standoc::TermLookupCleanup.new(xmldoc, @log).call
        term_nonverbal_designations(xmldoc)
        term_dl_to_metadata(xmldoc)
        term_termsource_to_designation(xmldoc)
        term_designation_reorder(xmldoc)
        termdef_from_termbase(xmldoc)
        termdomain_cleanup(xmldoc)
        termdef_stem_cleanup(xmldoc)
        termdefinition_cleanup(xmldoc)
        termdomain1_cleanup(xmldoc)
        termnote_example_cleanup(xmldoc)
        term_children_cleanup(xmldoc)
        termdocsource_cleanup(xmldoc)
      end

      def index_cleanup(xmldoc)
        return unless @index_terms

        xmldoc.xpath("//preferred").each do |p|
          index_cleanup1(p.at("./expression/name | ./letter-symbol/name"),
                         p.xpath("./field-of-application | ./usage-info")
            &.map(&:text)&.join(", "))
        end
        xmldoc.xpath("//definitions/dl/dt").each do |p|
          index_cleanup1(p, "")
        end
      end

      def index_cleanup1(term, fieldofappl)
        return unless term

        idx = term.children.dup
        fieldofappl.empty? or idx << ", &#x3c;#{fieldofappl}&#x3e;"
        term << "<index><primary>#{idx.to_xml}</primary></index>"
      end
    end
  end
end
