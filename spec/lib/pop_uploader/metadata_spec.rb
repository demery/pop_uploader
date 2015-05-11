require 'spec_helper'

describe PopUploader::Metadata do

  EVIDENCE_HASH = {
    file_name: 'Folio_NC6_Se888_717hb_5',
    url_to_catalog: 'http://franklin.library.upenn.edu/record.html?q=Folio_NC6_Se888_717hb&id=FRANKLIN_2637320&',
    copy_call_number: 'Folio NC6 Se888 717hb',
    copy_volume_number: '',
    copy_current_repository: 'University of Pennsylvania',
    copy_current_collection: 'Dutch Culture',
    copy_author: 'Sewel, William',
    copy_title: 'The history of the rise, increase, and progress of the Christian people called Quakers : intermixed with several remarkable occurrences / written originally in Low-Dutch by William Sewel, and by himself translated into English ; now revis\'d and publish\'d, with some amendments.',
    copy_place_of_publication: 'England, London',
    copy_date_of_publication: '1722',
    copy_printer_publisher: 'J. Sowle',
    evidence_location_in_book: '',
    evidence_format: 'Inscription',
    evidence_type: '',
    evidence_transcription: 'Ce Livre a appartenu a Monsieur le Baron Rocca, General de Bataille des armees et de sa majeste et pourveneur de la ville dIpre 1674Ipre 1674',
    evidence_associated_name: 'Monsieur le Baron de Rocca',
    evidence_date_associated: '1674',
    evidence_place_associated: 'Ipre',
    evidence_description: '',
    id_other: '',
    id_date: '',
    id_place: '',
    id_owner: '',
    id_donor: '',
    id_recipient: '',
    id_seller: '',
    id_selling_agent: '',
    id_buyer: '',
    comments: ''
  }

  let(:md) {  PopUploader::Metadata.new evidence }

  before(:example) { PopUploader.configure! }

  def evidence overrides={}
    EVIDENCE_HASH.merge overrides
  end

  context "creation" do
    it "creates a new PopUploader::Metadata" do
      expect(PopUploader::Metadata.new).to be_a(PopUploader::Metadata)
    end
  end

  context "description" do

    it "prints a call number" do
      expect(md.description).to match(/#{md.copy_call_number}/)
    end

    it "includes URL for the book" do
      expect(md.description).to match(/#{Regexp.escape md.url_to_catalog}.*#{md.copy_call_number}/)
    end

    it "prints a repository" do
      expect(md.description).to match(/<b>Repository<\/b>:\s+#{md.copy_current_repository}/)
    end

    it "prints the copy title" do
      expect(md.description).to match(/#{md.copy_title}/)
    end

    it "prints the author" do
      expect(md.description).to match(/#{md.authors}/)
    end

    it "prints publication information" do
      expect(md.description).to match(/#{md.published}/)
    end
  end

  context "tags" do
    it "has a call number tag" do
      expect(md.tags).to include "\"#{md.copy_call_number}\""
    end

    it "has a call number tag" do
      expect(md.tags).to include "\"#{md.copy_call_number}\""
    end

    it "has no empty values" do
      expect(md.tags.find_all { |s| s.size == 0 }).to be_empty
    end

    it "doesn't contain duplicate values" do
      md = PopUploader::Metadata.new evidence(id_seller: 'Smith, J. X.', id_buyer: 'Smith, J. X.')
      expect(md.tags.find_all { |s| s == '"Smith, J. X."' }.size).to be 1
    end

    it "handles piped tags" do
      md = PopUploader::Metadata.new evidence(id_seller: 'Smith, J. X.|Brown, M. Q.')
      expect(md.tags).to include '"Smith, J. X."'
      expect(md.tags).to include '"Brown, M. Q."'
    end
  end
end
