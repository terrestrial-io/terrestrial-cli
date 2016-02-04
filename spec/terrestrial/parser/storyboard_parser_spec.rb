require 'spec_helper'

StoryboardParser = Terrestrial::Cli::Parser::Storyboard

describe Terrestrial::Cli::Parser::Storyboard do
  context "find strings" do
    let(:file) { "spec/fixtures/Test.storyboard" }
    let(:parser) { StoryboardParser.new(file) }

    before(:each) do
      parser.find_strings
    end

    it "finds buttons that have not been market for terrestrial" do
      results = parser.result.reject {|e| e["type"] != "storyboard-button"}

      expect(results[0]["string"]).to eq "Mah button"
      expect(results[0]["metadata"]["storyboard_element_id"]).to eq "sjt-dy-pAp"
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/Test.storyboard"
    end

    it "finds text fields that have not been market for terrestrial" do
      results = parser.result.reject {|e| e["type"] != "storyboard-text-field"}

      expect(results[0]["string"]).to eq "Mah Placeholder"
      expect(results[0]["metadata"]["storyboard_element_id"]).to eq "Dh9-Te-mVD"
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/Test.storyboard"
    end

    it "finds labels that have not been market for terrestrial" do
      results = parser.result.reject {|e| e["type"] != "storyboard-label"}

      expect(results[0]["string"]).to eq "My Label Yo"
      expect(results[0]["metadata"]["storyboard_element_id"]).to eq "0J5-M9-Yfl"
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/Test.storyboard"
    end

    it "finds navbar items that have not been market for terrestrial" do
      results = parser.result.reject {|e| e["type"] != "storyboard-navbar-item"}

      expect(results[0]["string"]).to eq "Mah Title"
      expect(results[0]["metadata"]["storyboard_element_id"]).to eq "OYp-Vl-mxW"
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/Test.storyboard"
    end

    it "finds bar button items that have not been market for terrestrial" do
      results = parser.result.reject {|e| e["type"] != "storyboard-bar-button-item"}

      expect(results[0]["string"]).to eq "Mah Bar Item"
      expect(results[0]["metadata"]["storyboard_element_id"]).to eq "Jrj-54-Su4"
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/Test.storyboard"
    end

    it "finds text views that have not been market for terrestrial" do
      results = parser.result.reject {|e| e["type"] != "storyboard-text-view"}

      expect(results[0]["string"]).to eq "Le text view content"
      expect(results[0]["metadata"]["storyboard_element_id"]).to eq "2VW-lv-jgm"
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/Test.storyboard"
    end
  end
  context "find strings" do
    let(:file) { "spec/fixtures/AnnotatedTest.storyboard" }
    let(:parser) { StoryboardParser.new(file) }

    before(:each) do
      parser.find_api_calls
    end

    it "finds buttons that have terrestrial turned on" do
      results = parser.result.reject {|e| e["type"] != "storyboard-button"}

      expect(results[0]["string"]).to eq "Mah button"
      expect(results[0]["context"]).to eq "Some button context"
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/AnnotatedTest.storyboard"
    end

    it "doesn't find elements that are not enabled by terrestrial" do
      results = parser.result.reject {|e| e["string"] != "THIS SHOULD NOT SHOW UP"}
      expect(results).to eq []
    end

    it "finds text-fields that have terrestrial turned on" do
      results = parser.result.reject {|e| e["type"] != "storyboard-text-field"}

      expect(results[0]["string"]).to eq "Mah Placeholder"
      expect(results[0]["context"]).to eq ""
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/AnnotatedTest.storyboard"
    end

    it "finds labels that have terrestrial turned on" do
      results = parser.result.reject {|e| e["type"] != "storyboard-label"}

      expect(results[0]["string"]).to eq "My Label Yo"
      expect(results[0]["context"]).to eq ""
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/AnnotatedTest.storyboard"
    end

    it "finds navbar button items that have terrestrial turned on" do
      results = parser.result.reject {|e| e["type"] != "storyboard-bar-button-item"}

      expect(results[0]["string"]).to eq "Mah Bar Item"
      expect(results[0]["context"]).to eq "BAR CONTEXT"
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/AnnotatedTest.storyboard"
    end
    
    it "finds navbar items that have terrestrial turned on" do
      results = parser.result.reject {|e| e["type"] != "storyboard-navbar-item"}

      expect(results[0]["string"]).to eq "Mah Title"
      expect(results[0]["context"]).to eq ""
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/AnnotatedTest.storyboard"
    end

    it "finds text views that have terrestrial turned on" do
      results = parser.result.reject {|e| e["type"] != "storyboard-text-view"}

      expect(results[0]["string"]).to eq "Le text view content"
      expect(results[0]["context"]).to eq ""
      expect(results[0]["line_number"]).to be_nil
      expect(results[0]["file"]).to eq "spec/fixtures/AnnotatedTest.storyboard"
    end
  end
end
