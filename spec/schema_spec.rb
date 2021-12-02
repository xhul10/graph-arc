require 'spec_helper'

RSpec.describe SolarRails::Schema do
  let(:schema) do
    <<-RUBY
      ActiveRecord::Schema.define(version: 2021_10_20_084658) do

        enable_extension "pg_trgm"

        create_table "accounts", force: :cascade do |t|
          t.jsonb "extra"
          t.decimal "balance", precision: 30, scale: 10, null: false
          t.integer "some_int"
          t.date "some_date"
          t.bigint "some_big_id", null: false
          t.string "name", null: false
          t.boolean "active"
          t.text "notes"
          t.inet "some_ip"
          t.datetime "created_at", null: false
          t.index ["some_big_id"], name: "index_accounts_on_some_big_id", unique: true
        end
      end
    RUBY
  end

  before do
    Solargraph::Convention.register SolarRails::Convention
  end

  it "generates methods based on schema" do
    map = use_workspace "./spec/rails5" do |root|
      root.write_file 'db/schema.rb', schema

      root.write_file 'app/models/account.rb', <<-RUBY
        class Account < ActiveRecord::Base
        end
      RUBY
    end

    assert_public_instance_method(map, "Account#extra", "Hash") do |pin|
      expect(pin.location.range.to_hash).to eq({
        :start => { :line => 5, :character => 0 },
        :end => { :line => 5, :character => 10 }
      })
    end

    assert_public_instance_method(map, "Account#balance", "BigDecimal")
    assert_public_instance_method(map, "Account#some_int", "Integer")
    assert_public_instance_method(map, "Account#some_date", "Date")
    assert_public_instance_method(map, "Account#some_big_id", "Integer")
    assert_public_instance_method(map, "Account#name", "String")
    assert_public_instance_method(map, "Account#active", "Boolean")
    assert_public_instance_method(map, "Account#notes", "String")
    assert_public_instance_method(map, "Account#some_ip", "IPAddr")
  end
end
