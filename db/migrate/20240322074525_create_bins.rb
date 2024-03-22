# frozen_string_literal: true

class CreateBins < ActiveRecord::Migration[7.1]
  def change
    create_table :bins do |t|
      t.text :payload

      t.timestamps
    end
  end
end
