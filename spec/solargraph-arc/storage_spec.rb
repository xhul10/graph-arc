require "spec_helper"

RSpec.describe Solargraph::Arc::Storage do
  before do
    Solargraph::Convention.register Solargraph::Arc::Convention
  end

  it "can auto-complete ActiveStorage" do
    map = use_workspace "./spec/rails5" do |root|
      root.write_file 'app/models/thing.rb', <<~EOS
        class Thing < ActiveRecord::Base
          has_one_attached :image
          has_many_attached :photos
        end

        Thing.new.image.att
        Thing.new.photos.att
      EOS
    end

    filename = './app/models/thing.rb'
    expect(completion_at(filename, [5, 19], map)).to include("attach")
    expect(completion_at(filename, [6, 20], map)).to include("attach")
  end
end
