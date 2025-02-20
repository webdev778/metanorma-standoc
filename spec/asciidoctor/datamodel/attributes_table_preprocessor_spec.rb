# frozen_string_literal: true

require "spec_helper"

RSpec.describe Asciidoctor::Standoc::Datamodel::AttributesTablePreprocessor do
  describe "#process" do
    context "when simple models without relations" do
      let(:datamodel_file) do
        examples_path("datamodel/address_class_profile.adoc")
      end
      let(:result_file) do
        examples_path("datamodel/address_class_profile.xml")
      end
      let(:output) do
        [
          BLANK_HDR,
          File.read(fixtures_path("macros_datamodel/address_class_profile.xml")),
        ]
          .join
      end

      after do
        %w[doc html xml err].each do |extention|
          path = examples_path("datamodel/address_class_profile.#{extention}")
          FileUtils.rm_f(path)
          FileUtils.rm_f("address_class_profile.#{extention}")
        end
      end

      it "correctly renders input" do
        Asciidoctor.convert_file(datamodel_file,
                                 backend: :standoc,
                                 safe: :safe,
                                 header_footer: true)
        expect(xmlpp(strip_guid(File.read(result_file))))
          .to(be_equivalent_to(xmlpp(output)))
      end
    end

    context "when complex relations" do
      let(:datamodel_file) do
        examples_path("datamodel/address_component_profile.adoc")
      end
      let(:result_file) do
        examples_path("datamodel/address_component_profile.xml")
      end
      let(:output) do
        path = fixtures_path("macros_datamodel/address_component_profile.xml")
        [
          BLANK_HDR,
          File.read(path),
        ]
          .join("\n")
      end

      after do
        %w[doc html xml err].each do |extention|
          path = examples_path(
            "datamodel/address_component_profile.#{extention}",
          )
          FileUtils.rm_f(path)
          FileUtils.rm_f("address_component_profile.#{extention}")
        end
      end

      it "correctly renders input" do
        Asciidoctor.convert_file(datamodel_file,
                                 backend: :standoc,
                                 safe: :safe,
                                 header_footer: true)
        expect(xmlpp(strip_guid(File.read(result_file))))
          .to(be_equivalent_to(xmlpp(output)))
      end
    end

    context "when missing definition" do
      let(:datamodel_file) do
        examples_path("datamodel/blank_definition_profile.adoc")
      end
      let(:result_file) do
        examples_path("datamodel/blank_definition_profile.xml")
      end
      let(:output) do
        path = fixtures_path("macros_datamodel/blank_definition_profile.xml")
        [
          BLANK_HDR,
          File.read(path),
        ].join("\n")
      end

      after do
        %w[doc html xml err].each do |extention|
          path = examples_path(
            "datamodel/blank_definition_profile.#{extention}",
          )
          FileUtils.rm_f(path)
          FileUtils.rm_f("blank_definition_profile.#{extention}")
        end
      end

      it "correctly renders input" do
        Asciidoctor.convert_file(datamodel_file,
                                 backend: :standoc,
                                 safe: :safe,
                                 header_footer: true)
        expect(xmlpp(strip_guid(File.read(result_file))))
          .to(be_equivalent_to(xmlpp(output)))
      end
    end
  end
end
