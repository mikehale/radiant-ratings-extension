require 'spec_helper'

describe Rating do
  dataset :pages

  def valid_attributes
    {
      :page   => pages(:home),
      :rating => 3,
      :user_token => Rating.maximum(:user_token).try(:next) || 'adkfjakdsjfksjf'
    }
  end

  it { should belong_to(:page) }

  it { should validate_presence_of(:rating) }
  it { should validate_presence_of(:page) }
  it { should validate_presence_of(:user_token) }

  it { should have_readonly_attribute(:page_id) }
  it { should have_readonly_attribute(:user_token) }

  it { should validate_numericality_of(:rating) }

  it "should allow a valid record to be saved" do
    lambda {
      Rating.create(valid_attributes)
    }.should change(Rating, :count).by(1)
  end

  context 'when a record already exists' do
    before(:each) do
      Rating.create(valid_attributes) unless Rating.exists?
    end

    it { should validate_uniqueness_of(:page_id).scoped_to(:user_token) }
  end
end