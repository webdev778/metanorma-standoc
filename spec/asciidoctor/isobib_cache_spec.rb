require "spec_helper"
require "relaton_iso"
require "fileutils"

IETF_123_SHORT = <<~XML.freeze
  <bibitem type="standard" id="IETF123">
    <title format="text/plain" language="en" script="Latn">Rubber latex -- Sampling</title>
    <docidentifier type="IETF">RFC 123</docidentifier>
    <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>
    <status><stage>Published</stage></status>
  </bibitem>
XML

ISO_123_SHORT = <<~XML.freeze
  <bibitem type="standard" id="ISO123">
    <title format="text/plain" language="en" script="Latn">Rubber latex -- Sampling</title>
    <docidentifier type="ISO">ISO 123</docidentifier>
    <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>
    <status><stage>Published</stage></status>
  </bibitem>
XML

ISO_124_SHORT = <<~XML.freeze
  <bibitem type="standard" id="ISO124">
    <fetched>#{Date.today}</fetched>
    <title format="text/plain" language="en" script="Latn">Latex, rubber -- Determination of total solids content</title>
    <docidentifier type="ISO">ISO 124</docidentifier>
    <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>
    <status><stage>Published</stage></status>
  </bibitem>
XML

ISO_124_SHORT_ALT = <<~XML.freeze
  <bibitem type="standard" id="ISO124">
    <fetched>#{Date.today}</fetched>
    <title format="text/plain" language="en" script="Latn">Latex, rubber -- Replacement</title>
    <docidentifier type="ISO">ISO 124</docidentifier>
    <contributor>    <role type="publisher"/>    <organization>      <name>International Organization for Standardization</name>      <abbreviation>ISO</abbreviation>      <uri>www.iso.org</uri>    </organization>  </contributor>
    <status><stage>60</stage><substage>60</substage></status>
  </bibitem>
XML

ISO_124_DATED = <<~XML.freeze
  <bibdata type="standard">
         <fetched>#{Date.today}</fetched>
         <title type="title-intro" format="text/plain" language="en" script="Latn">Latex, rubber</title>
         <title type="title-main" format="text/plain" language="en" script="Latn">Determination of total solids content</title>
         <title type='main' format='text/plain' language='en' script='Latn'>Latex, rubber - Determination of total solids content</title>
         <uri type="src">https://www.iso.org/standard/61884.html</uri>
         <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:61884:en</uri>
         <uri type="rss">https://www.iso.org/contents/data/standard/06/18/61884.detail.rss</uri>
         <docidentifier type="ISO">ISO 124:2014</docidentifier>
         <docidentifier type='URN'>urn:iso:std:iso:124:stage-90.93:ed-7:en</docidentifier>
         <docnumber>124</docnumber>
         <date type="published">
           <on>2014-03</on>
         </date>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>International Organization for Standardization</name>
             <abbreviation>ISO</abbreviation>
             <uri>www.iso.org</uri>
           </organization>
         </contributor>
         <edition>7</edition>
         <language>en</language>
         <script>Latn</script>
         <abstract format="text/plain" language="en" script="Latn">ISO 124:2014 specifies methods for the determination of the total solids content of natural rubber field and concentrated latices and synthetic rubber latex. These methods are not necessarily suitable for latex from natural sources other than the Hevea brasiliensis, for vulcanized latex, for compounded latex, or for artificial dispersions of rubber.</abstract>
         <status>
           <stage>90</stage>
           <substage>93</substage>
         </status>
         <copyright>
           <from>2014</from>
           <owner>
             <organization>
               <name>ISO</name>
             </organization>
           </owner>
         </copyright>
         <relation type="obsoletes">
           <bibitem type="standard">
             <formattedref format="text/plain">ISO 124:2011</formattedref>
           </bibitem>
         </relation>
         <place>Geneva</place>
         <ext>
           <doctype>international-standard</doctype>
           <editorialgroup>
           <technical-committee number='45' type='TC' identifier='ISO/TC 45/SC 3'>Raw materials (including latex) for use in the rubber industry</technical-committee>
           </editorialgroup>
           <ics>
             <code>83.040.10</code>
             <text>Latex and raw rubber</text>
           </ics>
           <structuredidentifier type="ISO">
             <project-number part="">ISO 124</project-number>
           </structuredidentifier>
         </ext>
       </bibdata>
XML

ISO_123_UNDATED = <<~XML.freeze
  <bibdata type="standard">
        <fetched>#{Date.today}</fetched>
        <title type="title-intro" format="text/plain" language="en" script="Latn">Rubber latex</title>
        <title type="title-main" format="text/plain" language="en" script="Latn">Sampling</title>
        <title type="main" format="text/plain" language="en" script="Latn">Rubber latex – Sampling</title>
        <uri type="src">https://www.iso.org/standard/23281.html</uri>
        <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:23281:en</uri>
        <uri type="rss">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</uri>
        <docidentifier type="ISO">ISO 123</docidentifier>
        <docnumber>123</docnumber>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
            <uri>www.iso.org</uri>
          </organization>
        </contributor>
        <edition>3</edition>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage>90</stage>
          <substage>93</substage>
        </status>
        <copyright>
          <from>2001</from>
          <owner>
            <organization>
              <name>ISO</name>
            </organization>
          </owner>
        </copyright>
        <relation type="obsoletes">
          <bibitem type="standard">
            <formattedref format="text/plain">ISO 123:1985</formattedref>
          </bibitem>
        </relation>
        <relation type="instance">
          <bibitem type="standard">
            <fetched>#{Date.today}</fetched>
            <title type="title-main" format="text/plain" language="en" script="Latn">Rubber latex – Sampling</title>
            <title type="main" format="text/plain" language="en" script="Latn">Rubber latex – Sampling</title>
            <uri type="src">https://www.iso.org/standard/23281.html</uri>
            <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:23281:en</uri>
            <uri type="rss">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</uri>
            <docidentifier type="ISO">ISO 123:2001</docidentifier>
            <docnumber>123</docnumber>
            <date type="published">
              <on>2001</on>
            </date>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
                <uri>www.iso.org</uri>
              </organization>
            </contributor>
            <edition>3</edition>
            <language>en</language>
            <script>Latn</script>
            <status>
              <stage>90</stage>
              <substage>93</substage>
            </status>
            <copyright>
              <from>2001</from>
              <owner>
                <organization>
                  <name>ISO</name>
                </organization>
              </owner>
            </copyright>
            <relation type="obsoletes">
              <bibitem type="standard">
                <formattedref format="text/plain">ISO 123:1985</formattedref>
              </bibitem>
            </relation>
          </bibitem>
        </relation>
        <ext>
          <doctype>international-standard</doctype>
          <editorialgroup>
          <technical-committee number='45' type='TC' identifier='ISO/TC 45/SC 3'>Raw materials (including latex) for use in the rubber industry</technical-committee>
          </editorialgroup>
          <ics>
            <code>83.040.10</code>
            <text>Latex and raw rubber</text>
          </ics>
          <structuredidentifier type="ISO">
            <project-number part="">ISO 123</project-number>
          </structuredidentifier>
        </ext>
      </bibdata>
XML

ISO_123_DATED = <<~XML.freeze
    <bibdata type="standard">
           <fetched>#{Date.today}</fetched>
           <title type="title-intro" format="text/plain" language="en" script="Latn">Rubber latex</title>
           <title type="title-main" format="text/plain" language="en" script="Latn">Sampling</title>
           <title type='main' format='text/plain' language='en' script='Latn'>Rubber latex - Sampling</title>
           <uri type="src">https://www.iso.org/standard/23281.html</uri>
           <uri type="obp">https://www.iso.org/obp/ui/#!iso:std:23281:en</uri>
           <uri type="rss">https://www.iso.org/contents/data/standard/02/32/23281.detail.rss</uri>
           <docidentifier type="ISO">ISO 123:2001</docidentifier>
           <docidentifier type='URN'>urn:iso:std:iso:123:stage-90.93:ed-3:en</docidentifier>
           <docnumber>123</docnumber>
           <date type="published">
             <on>2001-05</on>
           </date>
           <contributor>
             <role type="publisher"/>
             <organization>
               <name>International Organization for Standardization</name>
               <abbreviation>ISO</abbreviation>
               <uri>www.iso.org</uri>
             </organization>
           </contributor>
           <edition>3</edition>
           <language>en</language>
           <script>Latn</script>
           <abstract format='text/plain' language='en' script='Latn'>
    This International Standard specifies procedures for sampling natural rubber
    latex concentrate and for sampling synthetic rubber latices and artificial
    latices. It is also suitable for sampling rubber latex contained in drums,
    tank cars or tanks. The procedures may also be used for sampling plastics
    dispersions.
  </abstract>
           <status>
             <stage>90</stage>
             <substage>93</substage>
           </status>
           <copyright>
             <from>2001</from>
             <owner>
               <organization>
                 <name>ISO</name>
               </organization>
             </owner>
           </copyright>
           <relation type="obsoletes">
             <bibitem type="standard">
               <formattedref format="text/plain">ISO 123:1985</formattedref>
             </bibitem>
           </relation>
           <place>Geneva</place>
           <ext>
             <doctype>international-standard</doctype>
             <editorialgroup>
             <technical-committee number='45' type='TC' identifier='ISO/TC 45/SC 3'>Raw materials (including latex) for use in the rubber industry</technical-committee>
             </editorialgroup>
             <ics>
               <code>83.040.10</code>
               <text>Latex and raw rubber</text>
             </ics>
             <structuredidentifier type="ISO">
               <project-number part="">ISO 123</project-number>
             </structuredidentifier>
           </ext>
         </bibdata>
XML

RSpec.describe Asciidoctor::Standoc do
  it "does not activate biblio caches if isobib disabled" do
    FileUtils.rm_rf File.expand_path("~/.relaton-bib.pstore1")
    FileUtils.mv(File.expand_path("~/.relaton/cache"),
                 File.expand_path("~/.relaton-bib.pstore1"), force: true)
    FileUtils.rm_rf File.expand_path("~/.iev.pstore1")
    FileUtils.mv File.expand_path("~/.iev.pstore"),
                 File.expand_path("~/.iev.pstore1"), force: true
    FileUtils.rm_rf "relaton/cache"
    FileUtils.rm_rf "test.iev.pstore"
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton/cache")).to be false
    expect(File.exist?("#{Dir.home}/.iev.pstore")).to be false
    expect(File.exist?("relaton/cache")).to be false
    expect(File.exist?("test.iev.pstore")).to be false

    FileUtils.rm_rf File.expand_path("~/.relaton/cache")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                 File.expand_path("~/.relaton/cache"), force: true
    FileUtils.rm_rf File.expand_path("~/.iev.pstore")
    FileUtils.mv File.expand_path("~/.iev.pstore1"),
                 File.expand_path("~/.iev.pstore"), force: true
  end

  it "does not activate biblio caches if isobib caching disabled" do
    FileUtils.rm_rf File.expand_path("~/.relaton-bib.pstore1")
    FileUtils.mv File.expand_path("~/.relaton/cache"),
                 File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.rm_rf File.expand_path("~/.iev.pstore1")
    FileUtils.mv File.expand_path("~/.iev.pstore"),
                 File.expand_path("~/.iev.pstore1"), force: true
    FileUtils.rm_rf "relaton/cache"
    FileUtils.rm_rf "test.iev.pstore"
    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton/cache")).to be false
    expect(File.exist?("#{Dir.home}/.iev.pstore")).to be false
    expect(File.exist?("relaton/cache")).to be false
    expect(File.exist?("test.iev.pstore")).to be false

    FileUtils.rm_rf File.expand_path("~/.relaton/cache")
    FileUtils.rm_rf File.expand_path("~/.iev.pstore")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                 File.expand_path("~/.relaton/cache"), force: true
    FileUtils.mv File.expand_path("~/.iev.pstore1"),
                 File.expand_path("~/.iev.pstore"), force: true
  end

  it "flushes biblio caches" do
    relaton_bib_file  = File.expand_path("~/.relaton/cache")
    relaton_bib_file1 = File.expand_path("~/.relaton-bib.pstore1")
    iev_file          = File.expand_path("~/.iev/cache")
    iev_file1         = File.expand_path("~/.iev.pstore1")
    FileUtils.rm_rf relaton_bib_file1 if File.exist? relaton_bib_file1
    File.exist? relaton_bib_file and
      FileUtils.mv relaton_bib_file, relaton_bib_file1
    FileUtils.rm_rf iev_file1 if File.exist? iev_file1
    FileUtils.mv iev_file, iev_file1 if File.exist? iev_file

    File.open("#{Dir.home}/.relaton/cache", "w") { |f| f.write "XXX" }
    FileUtils.rm_rf File.expand_path("~/.iev/cache")

    # mock_isobib_get_123
    VCR.use_cassette "isobib_get_123_2001" do
      Asciidoctor.convert(<<~"INPUT", *OPTIONS)
        #{FLUSH_CACHE_ISOBIB_BLANK_HDR}
        [bibliography]
        == Normative References

        * [[[iso123,ISO 123:2001]]] _Standard_
      INPUT
    end
    expect(File.exist?("#{Dir.home}/.relaton/cache")).to be true
    expect(File.exist?("#{Dir.home}/.iev/cache")).to be false

    mock_open_uri("103-01-02")
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      [bibliography]
      == Normative References
      * [[[iev,IEV]]], _iev_

      == Terms and definitions
      === Automation

      [.source]
      <<iev,clause="103-01-02">>
    INPUT
    expect(File.exist?("#{Dir.home}/.iev/cache")).to be true

    db = Relaton::Db.new "#{Dir.home}/.relaton/cache", nil
    entry = db.load_entry("ISO(ISO 123:2001)")
    expect(entry).to include("<fetched>#{Date.today}</fetched>")
    expect(xmlpp(entry)).to be_equivalent_to(xmlpp(ISO_123_DATED))

    FileUtils.rm_rf File.expand_path("~/.relaton/cache")
    FileUtils.rm_rf File.expand_path("~/.iev/cache")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                 File.expand_path("~/.relaton/cache"), force: true
    FileUtils.mv File.expand_path("~/.iev.pstore1"),
                 File.expand_path("~/.iev/cache"), force: true
  end

  it "does not fetch references for ISO references in preparation" do
    FileUtils.mv File.expand_path("~/.relaton/cache"),
                 File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.rm_rf "relaton/cache"
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:--]]] footnote:[The standard is in press] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton/cache")).to be true
    db = Relaton::Db.new "#{Dir.home}/.relaton/cache", nil
    entry = db.load_entry("ISO(ISO 123:--)")
    expect(entry).to be nil

    FileUtils.rm_rf File.expand_path("~/.relaton/cache")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                 File.expand_path("~/.relaton/cache"), force: true
  end

  it "inserts prefixes to fetched reference identifiers other than ISO IEC" do
    FileUtils.mv File.expand_path("~/.relaton/cache"),
                 File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.rm_rf "relaton/cache"
    mock_isobib_get_123
    mock_ietfbib_get_123
    out = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{CACHED_ISOBIB_BLANK_HDR}

      <<iso123>>
      <<ietf123>>

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
      * [[[ietf123,RFC 123]]] _Standard_
    INPUT
    expect(out).to include '<eref type="inline" bibitemid="iso123" citeas="ISO 123:2001"/>'
    expect(out).to include '<eref type="inline" bibitemid="ietf123" citeas="IETF RFC 123"/>'
  end

  it "activates global cache" do
    FileUtils.mv File.expand_path("~/.relaton/cache"),
                 File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.rm_rf "relaton/cache"
    VCR.use_cassette "isobib_get_123_2001" do
      Asciidoctor.convert(<<~"INPUT", *OPTIONS)
        #{CACHED_ISOBIB_BLANK_HDR}
        [bibliography]
        == Normative References

        * [[[iso123,ISO 123:2001]]] _Standard_
      INPUT
    end

    # mock_isobib_get_123
    # Asciidoctor.convert(<<~"INPUT", *OPTIONS)
    # #{CACHED_ISOBIB_BLANK_HDR}
    # [bibliography]
    #== Normative References
    #
    # * [[[iso123,ISO 123:2001]]] _Standard_
    # INPUT
    expect(File.exist?("#{Dir.home}/.relaton/cache")).to be true
    expect(File.exist?("relaton/cache")).to be false

    db = Relaton::Db.new "#{Dir.home}/.relaton/cache", nil
    entry = db.load_entry("ISO(ISO 123:2001)")
    expect(entry).to_not be nil

    FileUtils.rm_rf File.expand_path("~/.relaton/cache")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                 File.expand_path("~/.relaton/cache"), force: true
  end

  it "activates local cache" do
    FileUtils.mv File.expand_path("~/.relaton/cache"),
                 File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.rm_rf "relaton/cache"
    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{LOCAL_CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton/cache")).to be true
    expect(File.exist?("relaton/cache")).to be true

    db = Relaton::Db.new "#{Dir.home}/.relaton/cache", nil
    entry = db.load_entry("ISO(ISO 123:2001)")
    expect(entry).to_not be nil

    db = Relaton::Db.new "relaton/cache", nil
    entry = db.load_entry("ISO(ISO 123:2001)")
    expect(entry).to_not be nil

    FileUtils.rm_rf File.expand_path("~/.relaton/cache")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                 File.expand_path("~/.relaton/cache"), force: true
  end

  it "renames local cache" do
    FileUtils.mv File.expand_path("~/.relaton/cache"),
                 File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.rm_rf "test/cache"
    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :local-cache: test

      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("test/cache")).to be true

    db = Relaton::Db.new "test/cache", nil
    entry = db.load_entry("ISO(ISO 123:2001)")
    expect(entry).to_not be nil

    FileUtils.rm_rf File.expand_path("~/.relaton/cache")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                 File.expand_path("~/.relaton/cache"), force: true
  end

  it "activates only local cache" do
    relaton_bib_file  = File.expand_path("~/.relaton/cache")
    relaton_bib_file1 = File.expand_path("~/.relaton-bib.pstore1")
    FileUtils.rm_rf relaton_bib_file1 if File.exist? relaton_bib_file1
    File.exist? relaton_bib_file and
      FileUtils.mv(relaton_bib_file, relaton_bib_file1, force: true)
    FileUtils.rm_rf "relaton/cache"
    mock_isobib_get_123
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{LOCAL_ONLY_CACHED_ISOBIB_BLANK_HDR}
      [bibliography]
      == Normative References

      * [[[iso123,ISO 123:2001]]] _Standard_
    INPUT
    expect(File.exist?("#{Dir.home}/.relaton/cache")).to be false
    expect(File.exist?("relaton/cache")).to be true

    db = Relaton::Db.new "relaton/cache", nil
    entry = db.load_entry("ISO(ISO 123:2001)")
    expect(entry).to_not be nil

    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                 File.expand_path("~/.relaton/cache"), force: true
  end

  it "fetches uncached references" do
    FileUtils.mv File.expand_path("~/.relaton/cache"),
                 File.expand_path("~/.relaton-bib.pstore1"), force: true
    db = Relaton::Db.new "#{Dir.home}/.relaton/cache", nil
    bibitem = RelatonIsoBib::XMLParser.from_xml ISO_123_DATED
    bibitem.instance_variable_set :@fetched, (Date.today - 2)

    db.save_entry("ISO(ISO 123:2001)", bibitem.to_xml)
    # {
    # "fetched" => (Date.today - 2).to_s,
    # "bib" => RelatonIsoBib::XMLParser.from_xml(ISO_123_DATED)
    # }
    # )

    # mock_isobib_get_124
    VCR.use_cassette "isobib_get_124" do
      Asciidoctor.convert(<<~"INPUT", *OPTIONS)
        #{CACHED_ISOBIB_BLANK_HDR}
        [bibliography]
        == Normative References

        * [[[iso123,ISO 123:2001]]] _Standard_
        * [[[iso124,ISO 124:2014]]] _Standard_
      INPUT
    end

    entry = db.load_entry("ISO(ISO 123:2001)")
    # expect(db.fetched("ISO(ISO 123:2001)")).to eq(Date.today.to_s)
    expect(entry).to include("<fetched>#{Date.today - 2}</fetched>")
    # expect(entry).to be_equivalent_to(ISO_123_DATED)
    entry = db.load_entry("ISO(ISO 124:2014)")
    # expect(db.fetched("ISO(ISO 124:2014)")).to eq(Date.today.to_s)
    expect(entry).to include("<fetched>#{Date.today}</fetched>")
    expect(xmlpp(entry)).to be_equivalent_to(xmlpp(ISO_124_DATED))

    FileUtils.rm_rf File.expand_path("~/.relaton/cache")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                 File.expand_path("~/.relaton/cache"), force: true
  end

  it "expires stale undated references" do
    FileUtils.rm_rf File.expand_path("~/.relaton-bib.pstore1")
    FileUtils.mv File.expand_path("~/.relaton/cache"),
                 File.expand_path("~/.relaton-bib.pstore1"), force: true

    db = Relaton::Db.new "#{Dir.home}/.relaton/cache", nil
    bibitem = RelatonIsoBib::XMLParser.from_xml ISO_123_SHORT
    bibitem.instance_variable_set :@fetched, (Date.today - 90)
    db.save_entry("ISO 123", bibitem.to_xml)
    # {
    # "fetched" => (Date.today - 90),
    # "bib" => RelatonIsoBib::XMLParser.from_xml(ISO_123_SHORT)
    # }
    # )

    # mock_isobib_get_123_undated
    VCR.use_cassette "isobib_get_123" do
      Asciidoctor.convert(<<~"INPUT", *OPTIONS)
        #{CACHED_ISOBIB_BLANK_HDR}
        [bibliography]
        == Normative References

        * [[[iso123,ISO 123]]] _Standard_
      INPUT
    end

    entry = db.load_entry("ISO(ISO 123)")
    # expect(db.fetched("ISO(ISO 123)")).to eq(Date.today.to_s)
    expect(entry).to include("<fetched>#{Date.today}</fetched>")
    # expect(entry).to be_equivalent_to(ISO_123_UNDATED)  # NN TEMP

    FileUtils.rm_rf File.expand_path("~/.relaton/cache")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                 File.expand_path("~/.relaton/cache"), force: true
  end

  it "does not expire stale dated references" do
    VCR.use_cassette "isobib_get_123_2001" do
      FileUtils.rm_rf File.expand_path("~/.relaton-bib.pstore1")
      FileUtils.mv File.expand_path("~/.relaton/cache"),
                   File.expand_path("~/.relaton-bib.pstore1"), force: true

      bibitem = RelatonIsoBib::XMLParser.from_xml ISO_123_DATED
      bibitem.instance_variable_set :@fetched, (Date.today - 90)

      db = Relaton::Db.new "#{Dir.home}/.relaton/cache", nil
      db.save_entry("ISO(ISO 123:2001)", bibitem.to_xml)
      #   {
      #     "fetched" => (Date.today - 90),
      #     "bib" => RelatonIsoBib::XMLParser.from_xml(ISO_123_DATED)
      #   }
      # )

      Asciidoctor.convert(<<~"INPUT", *OPTIONS)
        #{CACHED_ISOBIB_BLANK_HDR}
        [bibliography]
        == Normative References

        * [[[iso123,ISO 123:2001]]] _Standard_
      INPUT

      entry = db.load_entry("ISO(ISO 123:2001)")
      # expect(db.fetched("ISO(ISO 123:2001)")).to eq((Date.today - 90).to_s)
      expect(entry).to include("<fetched>#{Date.today - 90}</fetched>")
      # expect(entry).to be_equivalent_to(ISO_123_DATED)
      # It can't be true since fetched date is changed

      FileUtils.rm_rf File.expand_path("~/.relaton/cache")
      FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                   File.expand_path("~/.relaton/cache"), force: true
    end
  end

  it "prioritises local over global cache values" do
    VCR.use_cassette "isobib_get_123_2001" do
      VCR.use_cassette "isobib_get_124" do
        FileUtils.rm_rf File.expand_path("~/.relaton-bib.pstore1")
        FileUtils.mv File.expand_path("~/.relaton/cache"),
                     File.expand_path("~/.relaton-bib.pstore1"), force: true
        FileUtils.rm_rf "relaton/cache"

        db = Relaton::Db.new "#{Dir.home}/.relaton/cache", nil
        db.save_entry("ISO(ISO 123:2001)",
                      RelatonIsoBib::XMLParser.from_xml(ISO_123_DATED).to_xml)
        #   {
        #     "fetched" => Date.today,
        #     "bib" => RelatonIsoBib::XMLParser.from_xml(ISO_123_DATED)
        #   }
        # )
        db.save_entry("ISO(ISO 124)",
                      RelatonIsoBib::XMLParser.from_xml(ISO_124_SHORT).to_xml)
        #   {
        #     "fetched" => Date.today,
        #     "bib" => RelatonIsoBib::XMLParser.from_xml(ISO_124_SHORT)
        #   }
        # )

        localdb = Relaton::Db.new "relaton/cache", nil
        localdb.save_entry("ISO(ISO 124)",
                           RelatonIsoBib::XMLParser
          .from_xml(ISO_124_SHORT_ALT).to_xml)
        #   {
        #     "fetched" => Date.today,
        #     "bib" => RelatonIsoBib::XMLParser.from_xml(ISO_124_SHORT_ALT)
        #   }
        # )

        input = <<~DOC
          #{LOCAL_CACHED_ISOBIB_BLANK_HDR}
          [bibliography]
          == Normative References

          * [[[ISO123-2001,ISO 123:2001]]] _Standard_
          * [[[ISO124,ISO 124]]] _Standard_
        DOC

        Asciidoctor.convert(input, *OPTIONS)
        expect(db.load_entry("ISO(ISO 123:2001)")).to include("Rubber latex")
        expect(db.load_entry("ISO(ISO 124)"))
          .to include("Latex, rubber -- Determination of total solids content")
        expect(localdb.load_entry("ISO(ISO 123:2001)"))
          .to include("Rubber latex")
        expect(localdb.load_entry("ISO(ISO 124)"))
          .to include("Latex, rubber -- Replacement")

        FileUtils.rm_rf File.expand_path("~/.relaton/cache")
        FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"),
                     File.expand_path("~/.relaton/cache"), force: true
      end
    end
  end

  private

  def mock_isobib_get_123
    expect(RelatonIso::IsoBibliography).to receive(:get)
      .with("ISO 123", "2001", anything)
      .and_return(RelatonIsoBib::XMLParser.from_xml(ISO_123_DATED))
  end

  def mock_isobib_get_123_undated
    expect(RelatonIso::IsoBibliography).to receive(:get)
      .with("ISO 123", nil, anything)
      .and_return(RelatonIsoBib::XMLParser.from_xml(ISO_123_UNDATED))
  end

  def mock_isobib_get_124
    expect(RelatonIso::IsoBibliography).to receive(:get)
      .with("ISO 124", "2014", anything)
      .and_return(RelatonIsoBib::XMLParser.from_xml(ISO_124_DATED))
  end

  def mock_ietfbib_get_123
    expect(RelatonIetf::IetfBibliography).to receive(:get)
      .with("RFC 123", nil, anything)
      .and_return(RelatonIsoBib::XMLParser.from_xml(IETF_123_SHORT))
  end
end
