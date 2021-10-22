require_relative "term_lookup_cleanup"

module Asciidoctor
  module Standoc
    module Cleanup
      def termdef_stem_cleanup(xmldoc)
        xmldoc.xpath("//term/p/stem").each do |a|
          if a.parent.elements.size == 1 # para contains just a stem expression
            parent = a.parent
            parent.replace("<admitted><expression><name>#{a.to_xml}"\
                           "</name></expression></admitted>")
          end
        end
        xmldoc.xpath("//term//expression/name[stem]").each do |n|
          n.parent.name = "letter-symbol"
        end
      end

      def termdomain_cleanup(xmldoc)
        xmldoc.xpath("//p/domain").each do |a|
          prev = a.parent.previous
          prev.next = a.remove
        end
      end

      def termdomain1_cleanup(xmldoc)
        xmldoc.xpath("//term").each do |t|
          d = t.xpath("./domain | ./subject | ./usageinfo").last or next
          defn = d.at("../definition") and defn.previous = d.remove
        end
      end

      def termdefinition_cleanup(xmldoc)
        xmldoc.xpath("//term[not(definition)]").each do |d|
          first_child = d.at("./p | ./figure | ./formula") || next
          t = Nokogiri::XML::Element.new("definition", xmldoc)
          first_child.replace(t)
          t << first_child.remove
          d.xpath("./p | ./figure | ./formula").each { |n| t << n.remove }
        end
      end

      # release termdef tags from surrounding paras
      def termdef_unnest_cleanup(xmldoc)
        desgn = "//p/admitted | //p/deprecates | //p/preferred | //p//related"
        nodes = xmldoc.xpath(desgn)
        while !nodes.empty?
          nodes[0].parent.replace(nodes[0].parent.children)
          nodes = xmldoc.xpath(desgn)
        end
      end

      def termdef_subclause_cleanup(xmldoc)
        xmldoc.xpath("//terms[terms]").each { |t| t.name = "clause" }
      end

      def termdocsource_cleanup(xmldoc)
        f = xmldoc.at("//preface | //sections")
        xmldoc.xpath("//termdocsource").each { |s| f.previous = s.remove }
      end

      def term_children_cleanup(xmldoc)
        xmldoc.xpath("//term").each do |t|
          %w(termnote termexample termsource).each do |w|
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
        xmldoc.xpath("//termnote[not(ancestor::term)]").each do |x|
          x.name = "note"
        end
        xmldoc.xpath("//termexample[not(ancestor::term)]").each do |x|
          x.name = "example"
        end
      end

      def term_dl_to_metadata(xmldoc)
        xmldoc.xpath("//term[dl[@metadata = 'true']]").each do |t|
          t.xpath("./dl[@metadata = 'true']").each do |dl|
            prev = dl_to_designation(dl) or next
            term_dl_to_designation_metadata(prev, dl)
            term_dl_to_term_metadata(prev, dl)
            term_dl_to_expression_metadata(prev, dl)
            dl.remove
          end
        end
      end

      def term_dl_to_term_metadata(prev, dlist)
        return unless prev.name == "preferred" &&
          prev.at("./preceding-sibling::preferred").nil?

        ins = term_element_insert_point(prev)
        %w(domain subject usageinfo).each do |a|
          ins = dl_to_elems(ins, prev.parent, dlist, a)
        end
      end

      def term_dl_to_designation_metadata(prev, dlist)
        prev.name == "related" and prev = prev.at("./preferred")
        %w(absent geographicArea).each { |a| dl_to_attrs(prev, dlist, a) }
      end

      def term_element_insert_point(prev)
        ins = prev
        while %w(preferred admitted deprecates related domain dl)
            .include? ins&.next_element&.name
          ins = ins.next_element
        end
        ins
      end

      def term_dl_to_expression_metadata(prev, dlist)
        %w(language script type isInternational).each do |a|
          dl_to_attrs(prev, dlist, a)
        end
        %w(abbreviationType pronunciation).reverse.each do |a|
          dl_to_elems(prev.at("./expression/name"), prev, dlist, a)
        end
        g = dlist.at("./dt[text()='grammar']/following::dd//dl") and
          term_dl_to_expression_grammar(prev, g)
        term_to_letter_symbol(prev, dlist)
      end

      def term_dl_to_expression_grammar(prev, dlist)
        prev.at(".//expression") or return
        prev.at(".//expression") << "<grammar><sentinel/></grammar>"
        %w(gender isPreposition isParticiple isAdjective isAdverb isNoun
           grammarValue).reverse.each do |a|
          dl_to_elems(prev.at(".//expression/grammar/*"), prev.elements.last,
                      dlist, a)
        end
        term_dl_to_designation_gender(prev)
      end

      def term_dl_to_designation_gender(prev)
        gender = prev.at(".//expression/grammar/gender")
        /,/.match?(gender&.text) and
          gender.replace(gender.text.split(/,\s*/)
            .map { |x| "<gender>#{x}</gender>" }.join)
        prev.at(".//expression/grammar/sentinel").remove
      end

      def term_to_letter_symbol(prev, dlist)
        ls = dlist.at("./dt[text()='letter-symbol']/following::dd/p")
        return unless ls&.text == "true"

        n = prev.at(".//expression")
        n.name = "letter-symbol"
      end

      def dl_to_designation(dlist)
        prev = dlist.previous_element
        unless %w(preferred admitted deprecates related).include? prev&.name
          @log.add("AsciiDoc Input", dlist, "Metadata definition list does "\
                                            "not follow a term designation")
          return nil
        end
        prev
      end

      def termdef_cleanup(xmldoc)
        termdef_unnest_cleanup(xmldoc)
        Asciidoctor::Standoc::TermLookupCleanup.new(xmldoc, @log).call
        term_nonverbal_designations(xmldoc)
        term_dl_to_metadata(xmldoc)
        term_termsource_to_designation(xmldoc)
        term_designation_reorder(xmldoc)
        termdef_from_termbase(xmldoc)
        termdef_stem_cleanup(xmldoc)
        termdomain_cleanup(xmldoc)
        termdefinition_cleanup(xmldoc)
        termdomain1_cleanup(xmldoc)
        termnote_example_cleanup(xmldoc)
        termdef_subclause_cleanup(xmldoc)
        term_children_cleanup(xmldoc)
        termdocsource_cleanup(xmldoc)
      end

      def term_nonverbal_designations(xmldoc)
        xmldoc.xpath("//term/preferred | //term/admitted | //term/deprecates")
          .each do |d|
          d.text.strip.empty? or next
          n = d.next_element
          if %w(formula figure).include?(n&.name)
            term_nonverbal_designations1(d, n)
          else d.at("./expression/name") or
            d.children = "<expression><name/></expression>"
          end
        end
      end

      def term_nonverbal_designations1(desgn, elem)
        desgn.name == "related" and desgn = desgn.at("./preferred")
        if elem.name == "figure"
          elem.at("./name").remove
          desgn.children =
            "<graphical-symbol>#{elem.remove.to_xml}</graphical-symbol>"
        else
          a = elem.at("./stem").to_xml
          desgn.children = "<expression><name>#{a}</name></expression>"
          elem.remove
        end
      end

      def term_termsource_to_designation(xmldoc)
        xmldoc.xpath("//term/termsource").each do |t|
          p = t.previous_element
          while %w(domain subject usageinfo).include? p&.name
            p = p.previous_element
          end
          %w(preferred admitted deprecates related).include?(p&.name) or
            next
          p.name == "related" and p = p.at("./preferred")
          p << t.remove
        end
      end

      def term_designation_reorder(xmldoc)
        xmldoc.xpath("//term").each do |t|
          %w(preferred admitted deprecates related)
            .each_with_object([]) do |tag, m|
            t.xpath("./#{tag}").each { |x| m << x.remove }
          end.reverse.each do |x|
            t.children.first.previous = x
          end
        end
      end
    end
  end
end
