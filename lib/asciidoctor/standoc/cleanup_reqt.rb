module Asciidoctor
  module Standoc
    module Cleanup
      def requirement_cleanup(xmldoc)
        requirement_metadata(xmldoc)
        requirement_inherit(xmldoc)
        requirement_descriptions(xmldoc)
      end

      REQRECPER = "//requirement | //recommendation | //permission".freeze

      def requirement_inherit(xmldoc)
        xmldoc.xpath(REQRECPER).each do |r|
          ins = requirement_inherit_insert(r)
          r.xpath("./*//inherit").each { |i| ins.previous = i }
        end
      end

      def requirement_inherit_insert(reqt)
        ins = reqt.at("./classification") || reqt.at(
          "./description | ./measurementtarget | ./specification | "\
          "./verification | ./import | ./description | ./component | "\
          "./requirement | ./recommendation | ./permission",
        ) and return ins
        requirement_inherit_insert1(reqt)
      end

      def requirement_inherit_insert1(reqt)
        if t = reqt.at("./title")
          t.next = " "
          t.next
        else
          if reqt.children.empty? then reqt.add_child(" ")
          else reqt.children.first.previous = " "
          end
          reqt.children.first
        end
      end

      def requirement_descriptions(xmldoc)
        xmldoc.xpath(REQRECPER).each do |r|
          r.xpath(".//p[not(./*)][normalize-space(.)='']").each(&:remove)
          r.children.each do |e|
            requirement_description_wrap(r, e)
          end
          requirement_description_cleanup1(r)
        end
      end

      def requirement_description_wrap(reqt, text)
        return if (text.element? && (reqt_subpart(text.name) ||
                %w(requirement recommendation
                   permission).include?(text.name))) ||
          (text.text.strip.empty? && !text.at(".//xref | .//eref | .//link"))

        t = Nokogiri::XML::Element.new("description", reqt)
        text.before(t)
        t.children = text.remove
      end

      def requirement_description_cleanup1(reqt)
        while d = reqt.at("./description[following-sibling::*[1]"\
                          "[self::description]]")
          n = d.next.remove
          d << n.children
        end
        reqt.xpath("./description[normalize-space(.)='']").each do |r|
          r.replace("\n")
        end
      end

      def requirement_metadata(xmldoc)
        xmldoc.xpath(REQRECPER).each do |r|
          dl = r&.at("./dl[@metadata = 'true']")&.remove or next
          requirement_metadata1(r, dl, r.at("./title"))
        end
      end

      def requirement_metadata1_tags
        %w(label subject inherit)
      end

      def requirement_metadata1(reqt, dlist, ins)
        unless ins
          reqt.children.first.previous = " "
          ins = reqt.children.first
        end
        %w(obligation model type).each do |a|
          dl_to_attrs(reqt, dlist, a)
        end
        requirement_metadata1_tags.each do |a|
          ins = dl_to_elems(ins, reqt, dlist, a)
        end
        reqt_dl_to_classif(ins, reqt, dlist)
      end

      def reqt_dl_to_classif(ins, reqt, dlist)
        if a = reqt.at("./classification[last()]") then ins = a end
        dlist.xpath("./dt[text()='classification']").each do |e|
          val = e.at("./following::dd/p") || e.at("./following::dd")
          req_classif_parse(val.text).each do |r|
            ins.next = "<classification><tag>#{r[0]}</tag>"\
                       "<value>#{r[1]}</value></classification>"
            ins = ins.next
          end
        end
        ins
      end
    end
  end
end
