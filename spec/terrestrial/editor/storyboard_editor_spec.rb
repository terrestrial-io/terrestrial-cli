require 'spec_helper'

describe Terrestrial::Cli::Editor::Storyboard do

  # See this example storyboard file. All elements
  # mentioned in this file can be found in it. 
  let(:storyboard) { "spec/fixtures/Test.storyboard" }

  def create_entry(type, id, path = nil)
    double(:entry,
      file: path || storyboard,
      type: type,
      string: 'random',
      identifier: "GENERATED_ID",
      metadata: { "storyboard_element_id" => id }
    )
  end

  context "save_document" do
    it "saves the document with the userDefinedRuntimeAttributes, while preserving formatting" do
      entry = create_entry('storyboard-label', 'pZ6-a6-9bd', 'spec/fixtures/FormattingTest.storyboard')

      editor = Terrestrial::Cli::Editor::Storyboard.new(entry) 
      editor.insert_attribute
      result = editor.format_document

      expect(result).to eq File.read('spec/fixtures/ExpectedFormattingTest.storyboard')
    end

    it "saves the document with the userDefinedRuntimeAttributes, while preserving formatting (large example)" do
      entry = create_entry('storyboard-button', 'd7v-Ye-fbV', 'spec/fixtures/LargeExample.storyboard')

      editor = Terrestrial::Cli::Editor::Storyboard.new(entry) 
      editor.insert_attribute
      result = editor.format_document

      expect(result).to eq File.read('spec/fixtures/ExpectedLargeExample.storyboard')
    end
  end

  context "find_node" do
    it "finds labels" do
      entry = create_entry('storyboard-label', '0J5-M9-Yfl')

      editor = Terrestrial::Cli::Editor::Storyboard.new(entry) 
      node = editor.find_node(entry.metadata["storyboard_element_id"], entry.type)

      expect(node.name).to eq "label"
      expect(node.attributes['id']).to eq '0J5-M9-Yfl'
    end

    it "finds buttons" do
      entry = create_entry('storyboard-button', 'sjt-dy-pAp')

      editor = Terrestrial::Cli::Editor::Storyboard.new(entry) 
      node = editor.find_node(entry.metadata["storyboard_element_id"], entry.type)

      expect(node.name).to eq "button"
      expect(node.attributes['id']).to eq 'sjt-dy-pAp'
    end

    it "finds text fields" do
      entry = create_entry('storyboard-text-field', 'Dh9-Te-mVD')

      editor = Terrestrial::Cli::Editor::Storyboard.new(entry) 
      node = editor.find_node(entry.metadata["storyboard_element_id"], entry.type)

      expect(node.name).to eq "textField"
      expect(node.attributes['id']).to eq 'Dh9-Te-mVD'
    end

    it "finds bar button items" do
      entry = create_entry('storyboard-bar-button-item', 'Jrj-54-Su4')

      editor = Terrestrial::Cli::Editor::Storyboard.new(entry) 
      node = editor.find_node(entry.metadata["storyboard_element_id"], entry.type)

      expect(node.name).to eq "barButtonItem"
      expect(node.attributes['id']).to eq 'Jrj-54-Su4'
    end

    it "finds navbar items" do
      entry = create_entry('storyboard-navbar-item', 'OYp-Vl-mxW')

      editor = Terrestrial::Cli::Editor::Storyboard.new(entry) 
      node = editor.find_node(entry.metadata["storyboard_element_id"], entry.type)

      expect(node.name).to eq "navigationItem"
      expect(node.attributes['id']).to eq 'OYp-Vl-mxW'
    end

    it "finds text view item" do
      entry = create_entry('storyboard-text-view', '2VW-lv-jgm')

      editor = Terrestrial::Cli::Editor::Storyboard.new(entry) 
      node = editor.find_node(entry.metadata["storyboard_element_id"], entry.type)

      expect(node.name).to eq "textView"
      expect(node.attributes['id']).to eq '2VW-lv-jgm'
    end

    it "finds elements even if they have some other userDefinedRuntimeAttributes" do
      entry = create_entry('storyboard-button', 'QRf-Gx-4Go')

      editor = Terrestrial::Cli::Editor::Storyboard.new(entry) 
      node = editor.find_node(entry.metadata["storyboard_element_id"], entry.type)

      expect(node.name).to eq "button"
      expect(node.attributes["id"]).to eq 'QRf-Gx-4Go'
    end
  end
end
