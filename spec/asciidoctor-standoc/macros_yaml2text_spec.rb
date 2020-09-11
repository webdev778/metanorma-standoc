require "spec_helper"

RSpec.describe Asciidoctor::Standoc::Yaml2TextPreprocessor do
  it_behaves_like "structured data 2 text preprocessor" do
    let(:extention) { "yaml" }
    def transform_to_type(data)
      data.to_yaml
    end
  end
end
